function meeg = spm_cfg_eeg
% SPM M/EEG Configuration file for MATLABBATCH
%__________________________________________________________________________
% Copyright (C) 2013 Wellcome Trust Centre for Neuroimaging

% $Id: spm_cfg_eeg.m 5357 2013-03-26 15:04:40Z vladimir $

%--------------------------------------------------------------------------
% M/EEG preprocessing
%--------------------------------------------------------------------------
meegprep        = cfg_choice;
meegprep.tag    = 'preproc';
meegprep.name   = 'M/EEG Preprocessing';
meegprep.help   = {'M/EEG preprocessing.'};
meegprep.values = {spm_cfg_eeg_epochs spm_cfg_eeg_prepare spm_cfg_eeg_montage spm_cfg_eeg_filter...
    spm_cfg_eeg_bc spm_cfg_eeg_artefact spm_cfg_eeg_downsample spm_cfg_eeg_merge...
    spm_cfg_eeg_fuse spm_cfg_eeg_combineplanar spm_cfg_eeg_reduce spm_cfg_eeg_crop spm_cfg_eeg_remove_bad_trials}; 

%--------------------------------------------------------------------------
% M/EEG averaging
%--------------------------------------------------------------------------
meegavg        = cfg_choice;
meegavg.tag    = 'averaging';
meegavg.name   = 'M/EEG Averaging';
meegavg.help   = {'M/EEG Averaging'};
meegavg.values = {spm_cfg_eeg_average spm_cfg_eeg_grandmean spm_cfg_eeg_contrast}; 

%--------------------------------------------------------------------------
% M/EEG images
%--------------------------------------------------------------------------
meegimg        = cfg_choice;
meegimg.tag    = 'images';
meegimg.name   = 'M/EEG Images';
meegimg.help   = {'M/EEG Images'};
meegimg.values = {spm_cfg_eeg_convert2images spm_cfg_eeg_collapse_timefreq}; 

%--------------------------------------------------------------------------
% M/EEG time-frequency
%--------------------------------------------------------------------------
meegtf        = cfg_choice;
meegtf.tag    = 'tf';
meegtf.name   = 'M/EEG Time-frequency';
meegtf.help   = {'M/EEG time-frequency.'};
meegtf.values = { spm_cfg_eeg_tf spm_cfg_eeg_tf_rescale spm_cfg_eeg_avgfreq spm_cfg_eeg_avgtime}; 

%--------------------------------------------------------------------------
% M/EEG source reconstruction
%--------------------------------------------------------------------------
source        = cfg_choice;
source.tag    = 'source';
source.name   = 'M/EEG Source reconstruction';
source.help   = {'M/EEG source reconstruction.'};
source.values = { spm_cfg_eeg_inv_headmodel, spm_cfg_eeg_inv_headmodelhelmet, spm_cfg_eeg_inv_invert, spm_cfg_eeg_inv_invertiter ,spm_cfg_eeg_inv_simulate, spm_cfg_eeg_inv_results, spm_cfg_eeg_inv_extract,spm_cfg_eeg_inv_coregshift }; 
%--------------------------------------------------------------------------
% M/EEG Statistics
%--------------------------------------------------------------------------
meegstat        = cfg_choice;
meegstat.tag    = 'stat';
meegstat.name   = 'M/EEG Stats';
meegstat.help   = {'M/EEG Statistics'};
meegstat.values = {spm_cfg_eeg_firstlevel}; 
%--------------------------------------------------------------------------
% M/EEG other
%--------------------------------------------------------------------------
meegothr        = cfg_choice;
meegothr.tag    = 'other';
meegothr.name   = 'M/EEG Other';
meegothr.help   = {'M/EEG Other'};
meegothr.values = {spm_cfg_eeg_review, spm_cfg_eeg_copy, spm_cfg_eeg_delete}; 

%--------------------------------------------------------------------------
% M/EEG
%--------------------------------------------------------------------------
meeg         = cfg_choice;
meeg.tag     = 'meeg';
meeg.name    = 'M/EEG';
meeg.help    = {'M/EEG functions.'};
meeg.values  = {spm_cfg_eeg_convert meegprep meegavg meegimg meegtf source meegstat meegothr};