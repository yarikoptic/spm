function opts = spm_config_segment
% Configuration file for segment jobs
%_______________________________________________________________________
% Copyright (C) 2005 Wellcome Department of Imaging Neuroscience

% John Ashburner
% $Id$

%_______________________________________________________________________

scans.type = 'files';
scans.tag  = 'scans';
scans.tag  = 'multispec';
scans.name = 'Subject';
p1 = [...
'If more than one volume is specified (eg T1 & T2), then they must be ',...
'in register (same position, size, voxel dims etc..).'];
scans.help = {'Select scans for this subject.',p1};
scans.filter = 'image';
scans.num = [1 Inf];

%------------------------------------------------------------------------

scans2.type   = 'repeat';
scans2.name   = 'Multi-spectral images';
scans2.values = {scans};
scans2.help   = {...
'Multispectral tissue classification'};

%------------------------------------------------------------------------

scans.type = 'files';
scans.tag  = 'scans';
scans.tag  = 'singlespec';
scans.name = 'Single-channel images';
scans.help = {...
'Select scans for classification. ',...
'This assumes that there is one scan for each subject'};
scans.filter = 'image';
scans.num = [1 Inf];

%------------------------------------------------------------------------

data  = struct('type','choice','name','Data','tag','data','values',{{scans,scans2}});
data.help = {[...
'Classification can be done on either a single image for each subject ',...
'(single channel) or can be based on two or more registered images ',...
'(multispectral).']};

%------------------------------------------------------------------------

template.type = 'files';
template.tag  = 'template';
template.name = 'Template image(s)';
template.num  = [1 5];
template.filter = 'image';
template.val = {{fullfile(spm('Dir'),'templates','T1.nii')}};
template.help = {[...
'Select one or more template images, which will be used for affine matching. ',...
'Matching involves minimising the mean squared difference between the image and ',...
'template, so the tamplate should have the same contrast, or be of the same ',...
'modality as the image you want to register with it. ',...
'Note that for multi-spectral classification, the affine transform is only ',...
'determined from the first image specified for each subject.']};

%------------------------------------------------------------------------

regtype.type = 'menu';
regtype.name = 'Regularisation';
regtype.tag  = 'regtype';
regtype.labels = {'ICBM space template', 'Average sized template','No regularisation'};
regtype.values = {'mni','subj','none'};
regtype.def  = 'segment.estimate.affreg.regtype';
regtype.help   = {[...
'Affine registration into a standard space can be made more robust by ',...
'regularisation (penalising excessive stretching or shrinking).  The ',...
'best solutions can be obtained by knowing the approximate amount of ',...
'stretching that is needed (e.g. ICBM templates are slightly bigger ',...
'than typical brains, so greater zooms are likely to be needed). ',...
'If registering to an image in ICBM/MNI space, then choose the first ',...
'option.  If registering to a template that is close in size, then ',...
'select the second option.  If you do not want to regularise, then ',...
'choose the third.']};

%------------------------------------------------------------------------

weight.type = 'files';
weight.name = 'Weighting image';
weight.tag  = 'weight';
weight.filter = 'image';
weight.num  = [0 1];
weight.def  = 'segment.estimate.affreg.weight';
weight.help = {[...
'The affine registration can be weighted by an image that conforms to ',...
'the same space as the template image.  If an image is selected, then ',...
'it must match the template(s) voxel-for voxel, and have the same ',...
'voxel-to-world mapping.']};

%------------------------------------------------------------------------

smosrc.type = 'entry';
smosrc.name = 'Smoothing FWHM (mm)';
smosrc.tag  = 'smosrc';
smosrc.strtype = 'e';
smosrc.num  = [1 1];
smosrc.def  = 'segment.estimate.affreg.smosrc';
smosrc.help = {[...
'This is the full width at half maximum (FWHM - in mm) of the Gaussian ',...
'smoothing kernel applied to the source image before doing the affine ',...
'registration.  Templates released with SPM are usually smoothed by 8mm ',...
'so 8mm would normally be the best value to use.']};

%------------------------------------------------------------------------

affreg.type = 'branch';
affreg.name = 'Affine register';
affreg.tag  = 'affreg';
affreg.val  = {template,weight,regtype,smosrc};
affreg.help = {'An affine registration needs to be done for non spatially normalised images.'};

%------------------------------------------------------------------------

unnecessary.type = 'const';
unnecessary.tag  = 'unnecessary';
unnecessary.val  = {[]};
unnecessary.name = 'Already spatially normalised';
unnecessary.help = {[...
'If the data are already spatially normalised, then no affine registration ',...
'is needed in order to overlay the prior probability images.']};

%------------------------------------------------------------------------
 
%affreg1.type = 'menu';
%affreg1.tag  = 'template';
%affreg1.name = 'Predefined template';
%affreg1.labels = {'Register T1 MRI ',...
%'Register T2 MRI','Register PD MRI','Register EPI MR'};
%affreg1.values = {...
%fullfile(spm('Dir'),'templates ', T1.nii'),...
%fullfile(spm('Dir'),'templates ', T2.nii'),...
%fullfile(spm('Dir'),'templates ', PD.nii'),...
%fullfile(spm('Dir'),'templates','EPI.nii')};
%affreg1.help = {...
%'Select one of the template images, which will be used for affine matching. ',...
%'Note that for multi-spectral classification, the affine transform is only ',...
%'determined from the first image specified for each subject.'};

%------------------------------------------------------------------------
 
overlay.type = 'choice';
overlay.tag  = 'overlay';
overlay.name = 'Prior overlay';
overlay.values = {unnecessary,affreg};
overlay.help = {'How should the priors be overlayed over the image to segment.'};

%------------------------------------------------------------------------

priors.type = 'files';
priors.name = 'Prior probability maps';
priors.tag  = 'priors';
priors.filter = 'image';
priors.num = 3;
priors.def = 'segment.estimate.priors';
priors.help = {[...
'Prior probability images that are overlayed on the images to segment. ',...
'These should be prior probability maps of grey matter, white matter ',...
'and cerebro-spinal fluid.']};

%------------------------------------------------------------------------

samp.type = 'entry';
samp.name = 'Sampling distance';
samp.tag  = 'samp';
samp.num  = [1 1];
samp.strtype = 'e';
samp.def  = 'segment.estimate.samp';
samp.help = {[...
'The approximate distance between sampled points when estimating the ',...
'segmentation parameters.']};

%------------------------------------------------------------------------

bb.type = 'entry';
bb.name = 'Bounding box';
bb.tag  = 'bb';
bb.num  = [2 3];
bb.strtype = 'e';
bb.def = 'segment.estimate.bb';
bb.help = {[...
'Bounding box defining the region in which the segmentation parameters ',...
'are estimated']};

%------------------------------------------------------------------------

custom.type = 'branch';
custom.name = 'Custom';
custom.tag  = 'custom';
custom.val  = {priors,bb,samp};
custom.help = {'Tweekable things'};

%------------------------------------------------------------------------

reg.tag  = 'reg';
reg.type = 'menu';
reg.name = 'Bias regularisation';
reg.help = {[...
'The importance of smoothness for the estimated bias field. Without ',...
'any regularisation, the algorithm will attempt to correct for ',...
'different grey levels arising from different tissue types, rather than ',...
'just correcting bias artifact. ',...
'Bias correction uses a Bayesian framework (again) to model intensity ',...
'inhomogeneities in the image(s).  The variance associated with each ',...
'tissue class is assumed to be multiplicative (with the ',...
'inhomogeneities).  The low frequency intensity variability is ',...
'modelled by a linear combination of three dimensional DCT basis ',...
'functions (again), using a fast algorithm (again) to generate the ',...
'curvature matrix.  The regularization is based upon minimizing the ',...
'integral of square of the fourth derivatives of the modulation field ',...
'(the integral of the squares of the first and second derivs give the ',...
'membrane and bending energies respectively).']};
reg.labels = {'no regularisation (0) ','extremely light regularisation (0.00001)',...
'very light regularisation (0.0001) ','light regularisation (0.001)',...
'medium regularisation (0.01) ','heavy regularisation (0.1)',...
'very heavy regularisation (1)','extremely heavy regularisation (10)'};
reg.values = {0, 0.00001, 0.0001, 0.001, 0.01, 0.1, 1.0, 10};
reg.def    = 'segment.estimate.reg';

%------------------------------------------------------------------------

cutoff.tag  = 'cutoff';
cutoff.type = 'menu';
cutoff.name = 'Bias cutoff';
cutoff.help = {[...
'Cutoff of DCT bases.  Only DCT bases of periods longer than the ',...
'cutoff are used to describe the bias. The number used will ',...
'depend on the cutoff and the field of view of the image.']};
cutoff.labels = {'20mm cutoff','25mm cutoff','30mm cutoff','35mm cutoff',...
'40mm cutoff','45mm cutoff','50mm cutoff','60mm cutoff','70mm cutoff',...
'80mm cutoff','90mm cutoff','100mm cutoff','No correction'};
cutoff.values = {20,25,30,35,40,45,50,60,70,80,90,100,Inf};
cutoff.def    = 'segment.estimate.cutoff';

%------------------------------------------------------------------------

cleanup.tag  = 'cleanup';
cleanup.type = 'menu';
cleanup.name = 'Clean up the partitions';
cleanup.help = {[...
'This uses a crude routine for extracting the brain from segmented ',...
'images.  It begins by taking the white matter, and eroding it a ',...
'couple of times to get rid of any odd voxels.  The algorithm ',...
'continues on to do conditional dilations for several iterations, ',...
'where the condition is based upon grey or white matter being present. ',...
'This identified region is then used to clean up the grey and white ',...
'matter partitions, and has a slight influences on the CSF partition.']};
cleanup.labels = {'Clean up the partitions','Dont do cleanup'};
cleanup.values = {1 0};
cleanup.def    = 'segment.write.cleanup';

%------------------------------------------------------------------------

wrt_cor.tag    = 'wrt_cor';
wrt_cor.type   = 'menu';
wrt_cor.name   = 'Write bias correted image';
wrt_cor.help   = {'Write bias correted versions of the images to disk'};
wrt_cor.labels = {'Write bias corrected','Dont write bias corrected'};
wrt_cor.values = {1 0};
wrt_cor.def    = 'segment.write.wrt_cor';

%------------------------------------------------------------------------

bias   = struct('type','branch','name','Bias correction','tag','bias',...
                'dim', Inf ,'val',{{reg,cutoff,wrt_cor}});
bias.help = {[...
'This uses a Bayesian framework (again) to model intensity ',...
' inhomogeneities in the image(s).  The variance associated with each ',...
' tissue class is assumed to be multiplicative (with the ',...
' inhomogeneities).  The low frequency intensity variability is ',...
' modelled by a linear combination of three dimensional DCT basis ',...
' functions (again), using a fast algorithm (again) to generate the ',...
' curvature matrix.  The regularization is based upon minimizing the ',...
' integral of square of the fourth derivatives of the modulation field ',...
' (the integral of the squares of the first and second derivs give the ',...
' membrane and bending energies respectively).']};

%------------------------------------------------------------------------

opts.type = 'branch';
opts.tag  = 'segment';
opts.name = 'Segment';
opts.prog = @execute;
opts.vfiles = @vfiles;
opts.dim  =  Inf;
opts.val  = {data,overlay,bias,custom,cleanup};
opts.help = {...
'Segment an MR image into Grey, White & CSF.',...
'',...
'The algorithm is four step:',...
[...
'1) Determine the affine transform which best matches the image with a ',...
'     template image. If the name of more than one image is passed, then ',...
'     the first image is used in this step. This step is not performed if ',...
'     no template images are specified.'],...
[...
'2) Perform Cluster Analysis with a modified Mixture Model and a-priori ',...
'     information about the likelihoods of each voxel being one of a ',...
'     number of different tissue types. If more than one image is passed, ',...
'     then they they are all assumed to be in register, and the voxel ',...
'     values are fitted to multi-normal distributions.'],...
[...
'3) Do a "cleanup" of the partitions, analagous to what <Xtract Brain> ',...
'     followed by <ImCalc> with "i1.*i4./(i1+i2+i3+eps)" did with SPM99.'],... 
[...
'4) Write the segmented image. The names of these images have ',...
'     "c1", "c2" & "c3" prepended to the name of the ',...
'     first image passed.'],...
'',...
' _______________________________________________________________________ ',...
'  Refs: ',...
'',...
['  Ashburner J & Friston KJ (1997) Multimodal Image Coregistration and ',...
'  Partitioning - a Unified Framework. NeuroImage 6:209-217'],...
'',...
['  Ashburner J & Friston KJ (2000) Voxel-Based Morphometry - The Methods. ',...
'  NeuroImage 11(6):805-821'],...
'',...
['  Ashburner J (2002) "Another MRI Bias Correction Approach" [abstract]. ',...
'  Presented at the 8th International Conference on Functional Mapping of ',...
'  the Human Brain, June 2-6, 2002, Sendai, Japan. Available on CD-Rom ',...
'  in NeuroImage, Vol. 16, No. 2.'],...
'',...
' _______________________________________________________________________ ',...
};

return;
%------------------------------------------------------------------------

%------------------------------------------------------------------------
function execute(varargin)
job = varargin{1};

flags.estimate.priors = strvcat(job.custom.priors);
flags.estimate.reg    = job.bias.reg;
flags.estimate.cutoff = job.bias.cutoff;
flags.estimate.samp   = job.custom.samp;
flags.estimate.bb     = job.custom.bb;
flags.write.cleanup = job.cleanup;
flags.write.wrt_cor = job.bias.wrt_cor;

data = {{}};
if isfield(job.data,'singlespec'),
	data = {};
	singlespec = job.data.singlespec;
	for i=1:length(singlespec),
		data = {data{:},deblank(singlespec{i})};
	end;
elseif isfield(job.data,'multispec'),
	data = {};
	for i=1:length(job.data.multispec),
		data = {data,strvcat(job.data.multispec{i})};
	end;
end;

if isfield(job.overlay,'unnecessary'),
	VG = eye(4);
else
	VG = spm_vol(strvcat(job.overlay.affreg.template));
	flags.estimate.affreg.smosrc  = job.overlay.affreg.smosrc;
	flags.estimate.affreg.regtype = job.overlay.affreg.regtype;
	flags.estimate.affreg.weight  = strvcat(job.overlay.affreg.weight);
end;

for i=1:length(data),
	spm_segment(data{i},VG,flags);
end;
%------------------------------------------------------------------------

%------------------------------------------------------------------------
function vf = vfiles(varargin)
job = varargin{1};
vf  = {};

if job.bias.wrt_cor, n=4; else  n=3; end;
if isfield(job.data,'singlespec'),
    vf = cell(n,numel(job.data.singlespec));
    for i=1:numel(job.data.singlespec),
        [pth,nam,ext,num] = spm_fileparts(job.data.singlespec{i});
        sub = {...
            fullfile(pth,['c1', nam, ext, num]),...
            fullfile(pth,['c2', nam, ext, num]),...
            fullfile(pth,['c3', nam, ext, num]),...
            fullfile(pth,['m',  nam, ext, num])};
        for j=1:n,
            vf{j,i} = sub{j};
        end;
    end;
elseif isfield(job.data,'multispec'),
    vf = cell(n,numel(job.data.multispec));
    for i=1:numel(job.data.multispec),
        [pth,nam,ext,num] = spm_fileparts(job.data.multispec{i}{1});
        sub = {...
            fullfile(pth,['c1', nam, ext, num]),...
            fullfile(pth,['c2', nam, ext, num]),...
            fullfile(pth,['c3', nam, ext, num]),...
            fullfile(pth,['m',  nam, ext, num])};
        for j=1:n,
            vf{j,i} = sub{j};
        end;
    end;
end;
