function [m,Lambda,Cm] = spm_nwrnd (M,N)
% Generate N samples from Normal-Wishart density
% FORMAT [m,Lambda,Cm] = spm_nwrnd (M,N)
% 
% Parameters M
%           .a,.B,.beta,.m
% N         number of samples
%
% m         Means
% Lambda    precisions
% Cm        covariances
%
% See J. Bernardo and A. Smith (2000) 
% Bayesian Theory, Wiley (page 435)
%__________________________________________________________________________
% Copyright (C) 2014 Wellcome Trust Centre for Neuroimaging

% Will Penny
% $Id: spm_nwrnd.m 6275 2014-12-01 08:41:18Z will $

%iB=inv(M.B);
for n=1:N,
    % Sample precisions
    %L=wishrnd(iB,M.a);
    L=spm_wishrnd(M.B,M.a);
    C=pinv(L);
    
    if nargout>1
        Lambda(:,:,n)=L;
        Cm(:,:,n)=C;
    end
    
    % Sample means
    %C=pinv(M.beta*L);
    %m(:,n)=spm_normrnd(M.m,C,1);
    
    m(:,n)=spm_normrnd(M.m,C/M.beta,1);
end

if N==1
    Lambda=squeeze(Lambda);
    Cm=squeeze(Cm);
end


