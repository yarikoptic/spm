function cdf = spm_Pcdf(y,theta)
% Cumulative Distribution Function (PDF) of Poisson distribution
% FORMAT cdf = spm_Ppdf(y,theta)
%
% y	- ordinates - non-negative integers
% theta	- Poisson parameter (mean) - greater than zero
%
%_______________________________________________________________________
%
% spm_Pcdf implements the Cumulative Distribution Function of the
% Poisson distribution.
% 
% For large theta (>64), the normal approximation Y~N(theta ,theta) is
% used together with a continuity correction.
%
%_______________________________________________________________________
% %W% Andrew Holmes %E%

%-Check arguments
%-----------------------------------------------------------------------
if nargin~=2, error('Insufficient arguments'), end
if any(theta<=0), error('theta must be strictly positive'), end
if length(theta)~=1, error('theta must be a scalar'), end
if any(y(:)<0), error('y must be non-negative'), end
if any(floor(y(:))~=ceil(y(:))), error('y must be integer'), end


%-Computation
%-----------------------------------------------------------------------
if theta <= 64

	%-Direct computation by summation of pdf
	%---------------------------------------------------------------
	cdf    = zeros(size(y));
	tmp    = cumsum(spm_Ppdf(0:max(y(:)),theta));
	cdf(:) = tmp(y+1);

else

	%-Use normal approximation Y~N(theta ,theta)
	% with continuity correction.
	%---------------------------------------------------------------
	cdf = spm_Ncdf( (y + 0.5 - theta) / sqrt(theta) );

end
