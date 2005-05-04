function [H] = spm_logdet(C)
% returns the log of the determinant of the positive definite matrix C
% FORMAT [H] = spm_logdet(C)
% H = log(det(C))
%
% spm_logdet is a computationally efficient operator that can deal with
% sparse matrices
%___________________________________________________________________________
% Copyright (C) 2005 Wellcome Department of Imaging Neuroscience

% Karl Friston
% $Id: spm_logdet.m 112 2005-05-04 18:20:52Z john $


% assume diagonal form
%---------------------------------------------------------------------------
H     = sum(log(diag(C)));

% invoke det if non-diagonal
%---------------------------------------------------------------------------
[i j] = find(C);
n     = length(C);
if any(i ~= j)
      a = exp(H/n);
      H = H + log(det(C/a));           
end

% invoke svd is rank deficient
%---------------------------------------------------------------------------
if imag(H) | isinf(H)
    s  = svd(full(C));
    H  = sum(log(s(s > n*max(s)*eps)));
end
