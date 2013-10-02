function [y] = spm_fs_fmri_csd(y,M)
% spectral feature selection for a CSD DCM
% FORMAT [y] = spm_fs_fmri_csd(y,M)
% y      - CSD
% M      - model structure
%__________________________________________________________________________
%
% This simply log-transforms the (real) auto-spectra
%
% David O, Friston KJ (2003) A neural mass model for MEG/EEG: coupling and
% neuronal dynamics. NeuroImage 20: 1743-1755
%__________________________________________________________________________
% Copyright (C) 2008 Wellcome Trust Centre for Neuroimaging
 
% Karl Friston
% $Id: spm_fs_fmri_csd.m 5660 2013-09-28 21:39:11Z karl $


% return (scaled) cross-spectra and covariance functions
%--------------------------------------------------------------------------
c  = spm_csd2ccf(y,M.Hz,4*length(M.Hz));
y  = [y; c(1:8:end,:,:)*32];