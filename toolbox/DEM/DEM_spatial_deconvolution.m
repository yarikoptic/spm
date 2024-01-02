function DEM_spatial_deconvolution
% FORMAT DEM_spatial_deconvolution
%--------------------------------------------------------------------------
% This (toy) demonstration routine illustrates spatiotemporal
% deconvolution of regional responses from imaging time-series.  The
% generative model assumes the data are generated by a small number of
% anatomical parcels that are smoothly displaced. The resulting data are
% then convolved spatially with a smoothly varying spatial kernel. The smooth
% displacement and dispersion are modelled in the usual way using discrete
% cosine basis set.  The model operates on reduced data features, using
% the eigenvariates of the original time-series - this supplements the
% implicit deconvolution with eigen-de-noising.  The ensuing estimates are
% anatomically informed because the generative model stars with a parcellation
% scheme.
%__________________________________________________________________________
 
% Karl Friston
% Copyright (C) 2008-2022 Wellcome Centre for Human Neuroimaging
 
 
% parcellation scheme (U) (make an atlas on the fly)
%==========================================================================
rng('default')

ATLAS = spm_conv(randn(64,16),6,6);
AP    = ATLAS;
a     = spm_vec(ATLAS);
[q,x] = hist(a,4);
A     = zeros(size(a));
for i = 1:length(x)
    A(:,i) = a < x(i);
    j      = find(A(:,i));
    a(j)   = Inf;
    AP(j)  = i;
end
 
U.u   = A;
U.dt  = size(ATLAS);
 
 
% Specify the generative model and generate some noisy data
%==========================================================================

 
% parameters and priors
%--------------------------------------------------------------------------
nD    = numel(U.dt);       % number of dimensions
nB    = 2;                 % number of basis functions
nP    = nB^nD;             % number of parameters
nY    = size(U.u,2);       % number of parcels
nT    = 32;
 
pE.D  = 0;
pE.S  = zeros(nP,nD);
pC.D  = pE.D + 1;
pC.S  = pE.S + 1;
 
P.D   = 0;                % true dispersion (log precision)
P.S   = randn(nP,nD)/2;    % true dislocation
G     = randn(nY,nT);      % true time series
G     = spm_conv(G,0,2);



% gradient functions for speed (not implemented here)
%--------------------------------------------------------------------------
M.FS   = @(y,M)M.U'*y;
M.IS   = @spm_gen_image;
M.G    = @(g,M)g';
 
% create data
%--------------------------------------------------------------------------
y      = spm_gen_image(P,M,U)*M.G(G)';
y      = y + randn(size(y))/128;
 
% dimension reduction
%--------------------------------------------------------------------------
[u,s,v] = spm_svd(y);
try
    M.U = u(:,1:(nY*2));
    M.V = v(:,1:(nY*2));
catch
    M.U = u;
    M.V = v;
end
 
% complete data and model specification
%==========================================================================
Y.y    = y*M.V;
 
M.pE   = pE;
M.pC   = pC;
M.gE   = zeros(nY,size(Y.y,2));
M.gC   = speye(spm_length(M.gE));
M.hE   = 4;
M.hC   = 1/16;
M.Nmax = 32;
 
 
% invert (deconvolve)
%==========================================================================
[Ep,Eg] = spm_nlsi_N(M,U,Y);
EG      = Eg*M.V';
 
% reconstructed data (with no distortions or dispersion)
%--------------------------------------------------------------------------
EP    = Ep;
EP.D  = 3;
EP.S  = EP.S*0;
YQ    = spm_gen_image(EP,M,U)*M.G(EG)';

PS    = P;
PS.D  = 2;
YS    = spm_gen_image(PS,M,U)*M.G(G)';
PS.S  = PS.S*0;
YP    = spm_gen_image(PS,M,U)*M.G(G)';

% Graphics
%==========================================================================
spm_figure('GetWin','Figure 1'); clf
 
subplot(3,4,1), imagesc(spm_unvec(YP(:,1),ATLAS))
title('True signal','FontSize',16), axis image
subplot(3,4,2), imagesc(spm_unvec(YS(:,1),ATLAS))
title('Displaced','FontSize',16), axis image
subplot(3,4,3), imagesc(spm_unvec(y(:,1),ATLAS))
title('BOLD data','FontSize',16), axis image
subplot(3,4,4), imagesc(spm_unvec(YQ(:,1),ATLAS))
title('Deconvolved','FontSize',16), axis image

 
subplot(3,1,2), 
plot(1:nT,EG,'-.'), hold on
plot(1:nT,G),            hold off
title('True and reconstructed time courses','FontSize',16)
xlabel('Time'), ylabel('regional signal')
 
subplot(3,2,5), plot(G,EG,'.')
title('Deconvolution','FontSize',16)
xlabel('True'), ylabel('predicted')
 
subplot(3,2,6), plot(G,(A*diag(1./sum(A)))'*y,'.')
title('Standard ROI averages','FontSize',16)
xlabel('True'), ylabel('predicted')
 
return
 
function y = spm_gen_image(P,M,U)
% generative model of image
% FORMAT y = spm_gen_image(P,M,U)
%__________________________________________________________________________
 
% convolve
%--------------------------------------------------------------------------
y  = K(P,M,U)*U.u;
 
function K = K(P,M,U)
% convolution kernel
% FORMAT K = K(P)
%__________________________________________________________________________
 
nV  = U.dt;        % number of voxels
nD  = numel(nV);   % number of dimensions
nP  = size(P.S,1); % number of parameters
nB  = nP^(1/nD);   % number of basis functions
 
B     = 1;
for i = 1:nD
    b = spm_dctmtx(nV(i),nB)*sqrt(nV(i));
    B = kron(B,b);  
end
 
% dispersion and displacement
%--------------------------------------------------------------------------
D     = exp(P.D)/2;
S     = B*P.S;
 
% kernel
%--------------------------------------------------------------------------
nK     = size(B,1);
K      = sparse(nK,nK);
[I,J]  = ind2sub(nV,1:nK);
X(:,1) = I;
X(:,2) = J;
 
k     = 0;
for i = 1:nD
 d    = (X(:,i) + S(:,i))*ones(1,nK) - ones(nK,1)*X(:,i)';
 k    = k + D*(d.^2);
end

% cosine approximation to Gaussian
%--------------------------------------------------------------------------
i     = find(abs(k) < pi);
K(i)  = (1 + cos(k(i)/pi))/2;
K     = diag(1./sum(K,2))*K;
