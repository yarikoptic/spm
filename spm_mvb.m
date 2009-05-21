function model = spm_mvb(X,Y,X0,U,V,nG,sG)
% Bayesian optimisation of a multivariate linear model with a greedy search
% FORMAT model = spm_mvb(X,Y,X0,U,V,nG,sG)
%
% X      - contrast or target vector
% Y      - date feature matrix
% X0     - confounds
% U      - patterns
% V      - observation noise covariance
% nG     - number of Greedy iterations (nG = 1 => uniform hyperpriors)
%        - if not specified, the search will terminate when F falls
% sG     - size of successive subdivisions [default is 1/2)
%
% returns model:
%                F: log-evidence [F(0), F(1),...]
%                G: covariance partition indices
%                h: covariance hyperparameters
%                U: ordered patterns
%               qE: conditional expectation of voxel weights
%               qC: conditional variance of voxel weights
%               Cp: prior covariance (ordered  pattern space)
%               cp: prior covariance (original pattern space)
%__________________________________________________________________________
%
% model: X = Y*P + X0*Q + R
%        P = U*E;           
%   cov(E) = h1*diag(G(:,1)) + h2*diag(G(:,2)) + ...
%
% See spm_mvb_ui and:
%
% Bayesian decoding of brain images.
% Friston K, Chu C, Mour�o-Miranda J, Hulme O, Rees G, Penny W, Ashburner J.
% Neuroimage. 2008 Jan 1;39(1):181-205
% 
% Multiple sparse priors for the M/EEG inverse problem.
% Friston K, Harrison L, Daunizeau J, Kiebel S, Phillips C, Trujillo-Barreto 
% N, Henson R, Flandin G, Mattout J.
% Neuroimage. 2008 Feb 1;39(3):1104-20.
% 
% Characterizing dynamic brain responses with fMRI: a multivariate approach.
% Friston KJ, Frith CD, Frackowiak RS, Turner R.
% Neuroimage. 1995 Jun;2(2):166-72.
%__________________________________________________________________________
% Copyright (C) 2008 Wellcome Trust Centre for Neuroimaging
 
% Karl Friston
% $Id: spm_mvb.m 3139 2009-05-21 18:37:29Z karl $
 
% defaults (use splits +/- one standard deviation by default)
%--------------------------------------------------------------------------
try, V;          catch, V  = [];             end
try, nG; aG = 0; catch, nG = 8; aG = 1;      end
try, sG;         catch, sG = 1/2;            end
 
% get orders
%--------------------------------------------------------------------------
ns     = size(Y,1);                 % number of samples
nv     = size(Y,2);                 % number of voxels
np     = size(U,2);                 % number of patterns or parameters
 
% confounds
%--------------------------------------------------------------------------
if isempty(X0), X0 = zeros(ns,1);  end
if isempty(U),  U  = zeros(nv,0);  end
if isempty(V),  V  = speye(ns,ns); end
 
% number of error components
%--------------------------------------------------------------------------
if iscell(V)
    nh = length(V);
else
    nh = 1;
end
 
% null model
%--------------------------------------------------------------------------
model  = spm_mvb_G(X,zeros(ns,0),X0,[],V);
if ~np, return, end
 
% initialise G and greedy search
%==========================================================================
F  = model.F;
L  = Y*U;
G  = ones(np,1);
for  i = 1:nG
 
    % invert
    %----------------------------------------------------------------------
    M  = spm_mvb_G(X,L,X0,G,V);
    
    % record conditional estimates (and terminate automatically if aG)
    %----------------------------------------------------------------------
    if i == 1
        save_model = 1;
    else
        save_model = M.F > max(F);
    end
    if  save_model
        model      = M;
    elseif aG
        break
    end
    
    % record free-energy
    %----------------------------------------------------------------------
    F(i + 1)     = M.F;
    lnh          = log(M.h');
    
    disp('log evidence & hyperparameters:')
    fprintf('% 8.2f',F-F(1)),fprintf('\n')
    fprintf('% 8.2f',full(lnh)),fprintf('\n\n')
    
    
    % eliminate redundant components
    %----------------------------------------------------------------------
    lnh          = lnh((nh + 1):end) - lnh(end);
    j            = find(lnh < -16);
    G(:,j)       = [];
 
    % create new spatial support
    %----------------------------------------------------------------------
    g            = find(G(:,end));
    ng           = ceil(length(g)*sG);
    [q j]        = sort(-sum(M.qE(g,:).^2,2));
    q            = g(j(1:ng));
    G(q,end + 1) = 1;
    
    % break if cluster is one
    %----------------------------------------------------------------------
    if ng < 1/(1 - sG), break, end
 
end
 
% project pattern weights to feature (voxel) weights
%==========================================================================
 
% remove some patterns if there are too many
%--------------------------------------------------------------------------
qE       = sum(model.qE.^2,2);
[i j]    = sort(-qE);
try
    i    = j(1:2^11);
catch
    i    = j;
end
L        = L(:,i);
U        = U(:,i);
cp       = model.Cp;
Cp       = cp(i,i);
MAP      = U*model.MAP(i,:);
qE       = U*model.qE(i,:);
 
% remove confounds from L = Y*U
%--------------------------------------------------------------------------
L        = L - X0*pinv(full(X0))*L;
 
% conditional covariance in voxel space: qC  = U*( Cp - Cp*L'*iC*L*Cp )*U';
%--------------------------------------------------------------------------
UCp      = U*Cp;
qC       = sum(UCp.*U,2) - sum((UCp*L').*MAP,2);
 
model.F  = F;
model.U  = U;
model.M  = MAP;
model.qE = qE;                              % conditional expectation
model.Cp = Cp;                              % prior covariance (ordered)
model.cp = cp;                              % prior covariance (original)
model.qC = max(qC,exp(-16));                % conditional variance

