function opts = spm_config_norm
% Configuration file for normalise jobs
%_______________________________________________________________________
% %W% %E%

%_______________________________________________________________________
 
w = spm_jobman('HelpWidth');
 
%------------------------------------------------------------------------

smosrc.type = 'entry';
smosrc.name = 'Source Image Smoothing';
smosrc.tag  = 'smosrc';
smosrc.strtype = 'e';
smosrc.num  = [1 1];
smosrc.def  = 'normalise.estimate.smosrc';
smosrc.help = spm_justify(w,...
'Smoothing to apply to a copy of the source image.',...
'The template and source images should have approximately',...
'the same smoothness. Remember that the templates supplied',...
'with SPM have been smoothed by 8mm, and that smoothnesses',...
'combine by Pythagorus'' rule.');

%------------------------------------------------------------------------

smoref.type = 'entry';
smoref.name = 'Template Image Smoothing';
smoref.tag  = 'smoref';
smoref.strtype = 'e';
smoref.num  = [1 1];
smoref.def  = 'normalise.estimate.smoref';
smoref.help = spm_justify(w,...
'Smoothing to apply to a copy of the template image.',...
'The template and source images should have approximately',...
'the same smoothness. Remember that the templates supplied',...
'with SPM have been smoothed by 8mm, and that smoothnesses',...
'combine by Pythagorus'' rule.');

%------------------------------------------------------------------------
 
regtype.type = 'menu';
regtype.name = 'Affine Regularisation';
regtype.tag  = 'regtype';
regtype.labels = {'ICBM space template', 'Average sized template','No regularisation'};
regtype.values = {'mni','subj','none'};
regtype.def  = 'normalise.estimate.regtype';
regtype.help   = spm_justify(w,...
'Affine registration into a standard space can be made more robust by',...
'regularisation (penalising excessive stretching or shrinking).  The',...
'best solutions can be obtained by knowing the approximate amount of',...
'stretching that is needed (e.g. ICBM templates are slightly bigger',...
'than typical brains, so greater zooms are likely to be needed).',...
'If registering to an image in ICBM/MNI space, then choose the first',...
'option.  If registering to a template that is close in size, then',...
'select the second option.  If you do not want to regularise, then',...
'choose the third.');
 
%------------------------------------------------------------------------

template.type = 'files';
template.name = 'Template Image';
template.tag  = 'template';
template.filter = 'image';
template.num  = [1 Inf];
template.help   = spm_justify(w,...
'Specify a template image to match the source image with.',...
'The contrast in the template must be similar to that of the',...
'source image in order to acheive a good registration.  It is',...
'also possible to select more than one template, in which case',...
'the registration algorithm will try to find the best linear',...
'combination of these images in order to best model the intensities',...
'in the source image.');
%------------------------------------------------------------------------

weight.type = 'files';
weight.name = 'Template Weighting Image';
weight.tag  = 'weight';
weight.filter = 'image';
weight.num  = [0 1];
weight.def  = 'normalise.estimate.weight';
p1 = spm_justify(w,...
'Applies a weighting mask to the template(s) during the parameter',...
'estimation.  With the default brain mask, weights in and around the',...
'brain have values of one whereas those clearly outside the brain are',...
'zero.  This is an attempt to base the normalization purely upon',...
'the shape of the brain, rather than the shape of the head (since',...
'low frequency basis functions can not really cope with variations',...
'in skull thickness).');
p2 = spm_justify(w,...
'The option is now available for a user specified weighting image.',...
'This should have the same dimensions and mat file as the template',...
'images, with values in the range of zero to one.');
weight.help = {p1{:},'',p2{:}};
 
%------------------------------------------------------------------------

cutoff.type = 'entry';
cutoff.name = 'Nonlinear Frequency Cutoff';
cutoff.tag  = 'cutoff';
cutoff.strtype = 'e';
cutoff.num  = [1 1];
cutoff.def  = 'normalise.estimate.cutoff';
cutoff.help = spm_justify(w,...
'Cutoff of DCT bases.  Only DCT bases of periods longer than the',...
'cutoff are used to describe the warps. The number used will',...
'depend on the cutoff and the field of view of the template image(s).');

%------------------------------------------------------------------------

nits.type = 'entry';
nits.name = 'Nonlinear Iterations';
nits.tag  = 'nits';
nits.strtype = 'w';
nits.num  = [1 1];
nits.def  = 'normalise.estimate.nits';
nits.help = spm_justify(w,...
'Number of iterations of nonlinear warping performed.');

%------------------------------------------------------------------------

reg.type = 'entry';
reg.name = 'Nonlinear Regularisation';
reg.tag  = 'reg';
reg.strtype = 'e';
reg.num  = [1 1];
reg.def  = 'normalise.estimate.reg';
reg.help = spm_justify(w,...
'The amount of regularisation for the nonlinear part of the spatial',...
'normalisation.',...
'Pick a value around one.  However, if your normalized images appear',...
'distorted, then it may be an idea to increase the amount of',...
'regularization (by an order of magnitude) - or even just use an affine',...
'normalization.',...
'The regularization influences the smoothness of the deformation',...
'fields.');

%------------------------------------------------------------------------

wtsrc.type = 'files';
wtsrc.name = 'Source Weighting Image';
wtsrc.tag  = 'wtsrc';
wtsrc.filter = 'image';
wtsrc.num  = [0 1];
wtsrc.val  = {''};
wtsrc.help = spm_justify(w,...
'  Optional weighting images (consisting of pixel',...
'  values between the range of zero to one) to be used for registering',...
'  abnormal or lesioned brains.  These images should match the dimensions',...
'  of the image from which the parameters are estimated, and should contain',...
'  zeros corresponding to regions of abnormal tissue.');

%------------------------------------------------------------------------

eoptions.type = 'branch';
eoptions.name = 'Estimation Options';
eoptions.tag  = 'eoptions';
eoptions.val  = {template,weight,smosrc,smoref,regtype,cutoff,nits,reg};
eoptions.help = spm_justify(w,'Various settinds for estimating warps.');

%------------------------------------------------------------------------

preserve.type = 'menu';
preserve.name = 'Preserve';
preserve.tag  = 'preserve';
preserve.labels = {'Preserve Concentrations','Preserve Amount'};
preserve.values = {0,1};
preserve.def  = 'normalise.write.preserve';
p1 = spm_justify(w,...
'Spatially normalised images are not"modulated". The warped images',...
'preserve the intensities of the original images.');
p2 = spm_justify(w,...
'Spatially normalised images are "modulated" in order to preserve the',...
'total amount of signal in the images. Areas that are expanded during',...
'warping are correspondingly reduced in intensity.');
preserve.help = {'Preserve Concentrations',p1{:},'','Preserve Total',p2{:}};

%------------------------------------------------------------------------

bb.type = 'entry';
bb.name = 'Bounding box';
bb.tag  = 'bb';
bb.num  = [2 3];
bb.strtype = 'e';
bb.def = 'normalise.write.bb';
bb.help = spm_justify(w,...
'The bounding box (in mm) of the volume which is to be written',...
'(relative to the anterior commissure).');

%------------------------------------------------------------------------

vox.type = 'entry';
vox.name = 'Voxel sizes';
vox.tag  = 'vox';
vox.num  = [1 3];
vox.strtype = 'e';
vox.def  = 'normalise.write.vox';
vox.help = spm_justify(w,...
'The voxel sizes (x, y & z, in mm) of the written normalised images.');

%------------------------------------------------------------------------

interp.type = 'menu';
interp.name = 'Interpolation';
interp.tag  = 'interp';
interp.labels = {'Nearest neighbour','Trilinear','2nd Degree B-spline',...
'3rd Degree B-Spline','4th Degree B-Spline','5th Degree B-Spline',...
'6th Degree B-Spline','7th Degree B-Spline'};
interp.values = {0,1,2,3,4,5,6,7};
interp.def  = 'normalise.write.interp';
interp.help = {...
'The method by which the images are sampled when being written in a',...
'different space.',...
'    Nearest Neighbour',...
'    - Fastest, but not normally recommended.',...
'    Bilinear Interpolation',...
'    - OK for PET, or realigned fMRI.',...
'    B-spline Interpolation',...
'    - Better quality (but slower) interpolation, especially',...
'      with higher degree splines.  Do not use B-splines when',...
'      there is any region of NaN or Inf in the images.',...
'',...
'References:',...
'    * M. Unser, A. Aldroubi and M. Eden.',...
'      "B-Spline Signal Processing: Part I-Theory,"',...
'      IEEE Transactions on Signal Processing 41(2):821-832 (1993).',...
'    * M. Unser, A. Aldroubi and M. Eden.',...
'      "B-Spline Signal Processing: Part II-Efficient Design and',...
'      Applications,"',...
'      IEEE Transactions on Signal Processing 41(2):834-848 (1993).',...
'    * M. Unser.',...
'      "Splines: A Perfect Fit for Signal and Image Processing,"',...
'      IEEE Signal Processing Magazine, 16(6):22-38 (1999)',...
'    * P. Thevenaz and T. Blu and M. Unser.',...
'      "Interpolation Revisited"',...
'      IEEE Transactions on Medical Imaging 19(7):739-758 (2000).',...
};

%------------------------------------------------------------------------

wrap.type = 'menu';
wrap.name = 'Wrapping';
wrap.tag  = 'wrap';
wrap.labels = {'No wrap','Wrap X','Wrap Y','Wrap X & Y','Wrap Z',...
'Wrap X & Z','Wrap Y & Z','Wrap X, Y & Z'};
wrap.values = {[0 0 0],[1 0 0],[0 1 0],[1 1 0],[0 0 1],[1 0 1],[0 1 1],[1 1 1]};
wrap.def    = 'normalise.write.wrap';
wrap.help = {...
'These are typically:',...
'    No wrapping - for PET or images that have already',...
'                  been spatially transformed.',...
'    Wrap in  Y  - for (un-resliced) MRI where phase encoding',...
'                  is in the Y direction (voxel space).'};

%------------------------------------------------------------------------

roptions.type = 'branch';
roptions.name = 'Writing Options';
roptions.tag  = 'roptions';
roptions.val  = {preserve,bb,vox,interp,wrap};
roptions.help = {'Various options for writing normalised images.'};

%------------------------------------------------------------------------

source.type = 'files';
source.name = 'Source Image';
source.tag  = 'source';
source.num  = [1 1];
source.filter = 'image';
source.help   = spm_justify(w,...
'The image that is warped to match the template(s).  The result is',...
'a set of warps, which can be applied to this image, or any other',...
'image that is in register with it.');

scansr.type = 'files';
scansr.name = 'Images to Write';
scansr.tag  = 'resample';
scansr.num  = [1 Inf];
scansr.filter = 'image';
scansr.val  = {''};
scansr.help   = spm_justify(w,...
'These are the images for warping according to the estimated parameters.');

matname.type = 'files';
matname.name = 'Parameter File';
matname.tag  = 'matname';
matname.num  = [1 1];
matname.filter = '.*_sn\.mat$';
matname.help = spm_justify(w,...
'Select the ''_sn.mat'' file containing the spatial normalisation',...
'parameters for that subject. If nothing is selected, then the routine',...
'will assume that no more subjects need to be selected.');

%------------------------------------------------------------------------

subj.type = 'branch';
subj.name = 'Subject';
subj.tag  = 'subj';
subj.val  = {source, wtsrc};
subj.help = spm_justify(w,'Data for this subject.');

data.type = 'repeat';
data.name = 'Data';
data.values = {subj};
data.help = spm_justify(w,'List of subjects.');

est.type = 'branch';
est.name = 'Normalise: Estimate';
est.tag  = 'est';
est.val  = {data,eoptions};
est.prog = @estimate;
est.vfiles = @vfiles_estimate;
est.help = spm_justify(w,...
'Computes the warp that best registers a source image (or series of',...
'source images) to match',...
'a template, saving it to a file imagename''_sn.mat''.');

%------------------------------------------------------------------------

subj.type = 'branch';
subj.name = 'Subject';
subj.tag  = 'subj';
subj.val  = {matname,scansr};
subj.help = spm_justify(w,'Data for this subject.');

data.type = 'repeat';
data.name = 'Data';
data.values = {subj};
data.help = spm_justify(w,'List of subjects.');

writ.type = 'branch';
writ.name = 'Normalise: Write';
writ.tag  = 'write';
writ.val  = {data,roptions};
writ.prog = @write;
writ.vfiles = @vfiles_write;
writ.help = spm_justify(w,...
'Allows previously estimated warps (stored in imagename''_sn.mat'' files)',...
'to be applied to series of images.');

%------------------------------------------------------------------------

subj.type = 'branch';
subj.name = 'Subject';
subj.tag  = 'subj';
subj.val  = {source, wtsrc, scansr};
subj.help = spm_justify(w,'Data for this subject.');

data.type = 'repeat';
data.name = 'Data';
data.values = {subj};
data.help = spm_justify(w,'List of subjects.');

estwrit.type = 'branch';
estwrit.name = 'Normalise: Estimate & Write';
estwrit.tag  = 'estwrite';
estwrit.val  = {data,eoptions,roptions};
estwrit.prog = @estwrite;
estwrit.vfiles = @vfiles_estwrite;
estwrit.help = spm_justify(w,...
'Computes the warp that best registers a source image (or series of',...
'source images) to match',...
'a template, saving it to the file imagename''_sn.mat''.',...
'This option also allows the contents of the imagename''_sn.mat''',...
'files to be applied to a series of images.');

%------------------------------------------------------------------------

opts.type = 'repeat';
opts.name = 'Normalise';
opts.tag  = 'normalise';
opts.values = {est,writ,estwrit};
opts.modality = {'FMRI','PET','VBM'};
p1 = spm_justify(w,...
'This module spatially (stereotactically) normalizes MRI, PET or SPECT',...
'images into a standard space defined by some ideal model or template',...
'image[s].  The template images supplied with SPM conform to the space',...
'defined by the ICBM, NIH P-20 project, and approximate that of the',...
'the space described in the atlas of Talairach and Tournoux (1988).',...
'The transformation can also be applied to any other image that has',...
'been coregistered with these scans.');
p2 = spm_justify(w,...
'Generally, the algorithms work by minimising the sum of squares',...
'difference between the image which is to be normalised, and a linear',...
'combination of one or more template images.  For the least squares',...
'registration to produce an unbiased estimate of the spatial',...
'transformation, the image contrast in the templates (or linear',...
'combination of templates) should be similar to that of the image from',...
'which the spatial normalization is derived.  The registration simply',...
'searches for an optimum solution.  If the starting estimates are not',...
'good, then the optimum it finds may not find the global optimum.');
p3 = spm_justify(w,...
'The first step of the normalization is to determine the optimum',...
'12-parameter affine transformation.  Initially, the registration is',...
'performed by matching the whole of the head (including the scalp) to',...
'the template.  Following this, the registration proceeded by only',...
'matching the brains together, by appropriate weighting of the template',...
'voxels.  This is a completely automated procedure (that does not',...
'require ``scalp editing'') that discounts the confounding effects of',...
'skull and scalp differences.   A Bayesian framework is used, such that',...
'the registration searches for the solution that maximizes the a',...
'posteriori probability of it being correct.  i.e., it maximizes the',...
'product of the likelihood function (derived from the residual squared',...
'difference) and the prior function (which is based on the probability',...
'of obtaining a particular set of zooms and shears).');
p4 = spm_justify(w,...
'The affine registration is followed by estimating nonlinear deformations,',...
'whereby the deformations are defined by a linear combination of three',...
'dimensional discrete cosine transform (DCT) basis functions.  The default',...
'options result in each of the deformation fields being described by 1176',...
'parameters, where these represent the coefficients of the deformations in',...
'three orthogonal directions.  The matching involved simultaneously',...
'minimizing the membrane energies of the deformation fields and the',...
'residual squared difference between the images and template(s).');
p5 = spm_justify(w,...
'Primarily for stereotactic normalization to facilitate inter-subject',...
'averaging and precise characterization of functional anatomy.  It is',...
'not necessary to spatially normalise the data (this is only a',...
'pre-requisite  for  intersubject averaging or reporting in the',...
'Talairach space).  If you wish to circumnavigate this step  (e.g. if',...
'you have single slice data or do not have an appropriate high',...
'resolution MRI scan) simply specify where you think the  anterior',...
'commissure  is  with  the  ORIGIN in the header of the first scan',...
'(using the ''Display'' facility) and proceed directly  to ''Smoothing''',...
'or ''Statistics''.');
p6 = spm_justify(w,...
'All normalized *.img scans are written to the same subdirectory as',...
'the original *.img, prefixed with a ''w'' (i.e. w*.img).  The details',...
'of the transformations are displayed in the results window, and the',...
'parameters are saved in the "*_sn.mat" file.');
p7 = spm_justify(w,...
'K.J. Friston, J. Ashburner, C.D. Frith, J.-B. Poline,',...
'J.D. Heather, and R.S.J. Frackowiak.',...
'Spatial Registration and Normalization of Images.',...
'Human Brain Mapping 2:165-189(1995)');
p8 = spm_justify(w,...
'J. Ashburner, P. Neelin, D.L. Collins, A.C. Evans and K. J. Friston.',...
'Incorporating Prior Knowledge into Image Registration.',...
'NeuroImage 6:344-352 (1997)');
p9 = spm_justify(w,...
'J. Ashburner and K. J. Friston',...
'Nonlinear Spatial Normalization using Basis Functions.',...
'Human Brain Mapping 7(4):in press (1999)');
opts.help = {'Spatial Normalisation',p1{:},'',...
'Mechanism',p2{:},'',p3{:},'',p4{:},'',...
'Uses',p5{:},'',...
'Outputs',p6{:},'',...
'References',p7{:},'',p8{:},'',p9{:}};
%------------------------------------------------------------------------

return;
%------------------------------------------------------------------------

%------------------------------------------------------------------------
function estimate(varargin)
job    = varargin{1};
o      = job.eoptions;
eflags = struct(...
	'smosrc', o.smosrc,...
	'smoref', o.smoref,...
	'regtype',o.regtype,...
	'cutoff', o.cutoff,...
	'nits',   o.nits,...
	'reg',    o.reg);

for i=1:length(job.subj),
	matname = [spm_str_manip(strvcat(job.subj(i).source{:}),'sd') '_sn.mat'];
	spm_normalise(strvcat(job.eoptions.template{:}),...
		strvcat(job.subj(i).source{:}), matname,...
		strvcat(job.eoptions.weight{:}), strvcat(job.subj(i).wtsrc{:}), eflags);
end;
return;
%------------------------------------------------------------------------

%------------------------------------------------------------------------
function write(varargin)
job    = varargin{1};
o      = job.roptions;
rflags = struct(...
	'preserve',o.preserve,...
	'bb',      o.bb,...
	'vox',     o.vox,...
	'interp',  o.interp,...
	'wrap',    o.wrap);

for i=1:length(job.subj),
	spm_write_sn(strvcat(job.subj(i).resample{:}),...
		strvcat(job.subj(i).matname{:}),rflags);
end;
return;
%------------------------------------------------------------------------
 
%------------------------------------------------------------------------
function estwrite(varargin)
job    = varargin{1};
o      = job.eoptions;
eflags = struct(...
	'smosrc', o.smosrc,...
	'smoref', o.smoref,...
	'regtype',o.regtype,...
	'cutoff', o.cutoff,...
	'nits',   o.nits,...
	'reg',    o.reg);
o      = job.roptions;
rflags = struct(...
	'preserve',o.preserve,...
	'bb',      o.bb,...
	'vox',     o.vox,...
	'interp',  o.interp,...
	'wrap',    o.wrap);

for i=1:length(job.subj),
    [ pth,nam ] = spm_fileparts(deblank(job.subj(i).source{:}));
    matname     = fullfile(pth,[nam,'_sn.mat']);
    spm_normalise(strvcat(job.eoptions.template{:}),...
        strvcat(job.subj(i).source{:}), matname,...
        strvcat(job.eoptions.weight{:}), strvcat(job.subj(i).wtsrc{:}), eflags);
    spm_write_sn(strvcat(job.subj(i).resample{:}), matname, rflags);
end;
return;
%------------------------------------------------------------------------
 
%------------------------------------------------------------------------
function vf = vfiles_estimate(varargin)
job = varargin{1};
vf  = cell(length(job.subj),1);
for i=1:length(job.subj),
    [pth,nam,ext,num] = spm_fileparts(deblank(job.subj(i).source{:}));
    vf{i} = fullfile(pth,[nam,'_sn.mat']);
end;
%------------------------------------------------------------------------

%------------------------------------------------------------------------
function vf = vfiles_estwrite(varargin)
job = varargin{1};
vf  = cell(length(job.subj),1);
for i=1:length(job.subj),
    [pth,nam,ext,num] = spm_fileparts(deblank(job.subj(i).source{:}));
    vf{i} = fullfile(pth,[nam,'_sn.mat']);
end;
for i=1:length(job.subj),
    res = job.subj(i).resample;
    vf1 = cell(1,length(res));
    for j=1:length(res),
        [pth,nam,ext,num] = spm_fileparts(res{j});
        vf1{j} = fullfile(pth,['w' nam '.img' num]);
    end;
    vf = {vf{:} vf1{:}};
end;
%------------------------------------------------------------------------

%------------------------------------------------------------------------
function vf = vfiles_write(varargin)
job = varargin{1};
vf  = {};
for i=1:length(job.subj),
    res = job.subj(i).resample;
    vf1 = cell(1,length(res));
    for j=1:length(res),
        [pth,nam,ext,num] = spm_fileparts(res{j});
        vf1{j} = fullfile(pth,['w' nam '.img' num]);
    end;
    vf = {vf{:} vf1{:}};
end;
