function minc = spm_cfg_minc
% SPM Configuration file
% automatically generated by the MATLABBATCH utility function GENCODE
%_______________________________________________________________________
% Copyright (C) 2008 Wellcome Trust Centre for Neuroimaging

% $Id: spm_cfg_minc.m 1775 2008-06-02 09:18:18Z volkmar $

rev = '$Rev: 1775 $';
% ---------------------------------------------------------------------
% data MINC files
% ---------------------------------------------------------------------
data         = cfg_files;
data.tag     = 'data';
data.name    = 'MINC files';
data.help    = {'Select the MINC files to convert.'};
data.filter = 'mnc';
data.ufilter = '.*';
data.num     = [1 Inf];
% ---------------------------------------------------------------------
% dtype Data Type
% ---------------------------------------------------------------------
dtype         = cfg_menu;
dtype.tag     = 'dtype';
dtype.name    = 'Data Type';
dtype.help    = {'Data-type of output images. Note that the number of bits used determines the accuracy, and the amount of disk space needed.'};
dtype.labels = {
                'UINT8  - unsigned char'
                'INT16 - signed short'
                'INT32 - signed int'
                'FLOAT - single prec. float'
                'DOUBLE - double prec. float'
}';
dtype.values = {spm_type('uint8') spm_type('int16') spm_type('int32') ...
                spm_type('float') spm_type('double')};
dtype.def    = @(val)spm_get_defaults('minc.dtype', val{:});
% ---------------------------------------------------------------------
% ext NIFTI Type
% ---------------------------------------------------------------------
ext         = cfg_menu;
ext.tag     = 'ext';
ext.name    = 'NIFTI Type';
ext.help    = {'Output files can be written as .img + .hdr, or the two can be combined into a .nii file.'};
ext.labels = {
              '.nii only'
              '.img + .hdr'
}';
ext.values = {
              '.nii'
              '.img'
}';
ext.def    = @(val)spm_get_defaults('minc.ext', val{:});
% ---------------------------------------------------------------------
% opts Options
% ---------------------------------------------------------------------
opts         = cfg_branch;
opts.tag     = 'opts';
opts.name    = 'Options';
opts.val     = {dtype ext };
opts.help    = {'Conversion options'};
% ---------------------------------------------------------------------
% minc MINC Import
% ---------------------------------------------------------------------
minc         = cfg_exbranch;
minc.tag     = 'minc';
minc.name    = 'MINC Import';
minc.val     = {data opts };
minc.help    = {'MINC Conversion.  MINC is the image data format used for exchanging data within the ICBM community, and the format used by the MNI software tools. It is based on NetCDF, but due to be superceded by a new version relatively soon. MINC is no longer supported for reading images into SPM, so MINC files need to be converted to NIFTI format in order to use them. See http://www.bic.mni.mcgill.ca/software/ for more information.'};
minc.prog = @spm_run_minc;
minc.vout = @vout;
%------------------------------------------------------------------------

%------------------------------------------------------------------------
function dep = vout(job)
dep            = cfg_dep;
dep.sname      = 'Converted Images';
dep.src_output = substruct('.','files');
dep.tgt_spec   = cfg_findspec({{'filter','image','strtype','e'}});

