function opts = spm_config_dicom
% Configuration file for dicom import jobs
%_______________________________________________________________________
% Copyright (C) 2005 Wellcome Department of Imaging Neuroscience

% John Ashburner
% $Id: spm_config_dicom.m 112 2005-05-04 18:20:52Z john $


%_______________________________________________________________________

data.type = 'files';
data.name = 'DICOM files';
data.tag  = 'data';
data.filter = 'any';
data.num  = Inf;
data.help = {'Select the DICOM files to convert.'};

opts.type = 'branch';
opts.name = 'DICOM Import';
opts.tag  = 'dicom';
opts.val  = {data};
opts.prog = @convert_dicom;
opts.help = {[...
'DICOM Conversion.  Most scanners produce data in DICOM format. '...
'Thios routine attempts to convert DICOM files into SPM compatible '...
'image volumes, which are written into the current directory. '...
'Note that not all flavours '...
'of DICOM can be handled, as DICOM is a very complicated format, and '...
'some scanner manufacturers use their own fields, which are not '...
'in the official documentation at http://medical.nema.org/']};

%------------------------------------------------------------------------

%------------------------------------------------------------------------
function convert_dicom(job)
hdr = spm_dicom_headers(strvcat(job.data));
spm_dicom_convert(hdr);
return;
