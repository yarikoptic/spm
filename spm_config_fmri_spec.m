function conf = spm_config_fmri_spec
% Configuration file for specification of fMRI model
%_______________________________________________________________________
% Copyright (C) 2005 Wellcome Department of Imaging Neuroscience

% Darren Gitelman and Will Penny
% $Id: spm_config_fmri_spec.m 250 2005-10-07 16:08:39Z john $


% Define inline types.
%-----------------------------------------------------------------------

entry = inline(['struct(''type'',''entry'',''name'',name,'...
    '''tag'',tag,''strtype'',strtype,''num'',num,''help'',hlp)'],...
    'name','tag','strtype','num','hlp');

files = inline(['struct(''type'',''files'',''name'',name,'...
    '''tag'',tag,''filter'',fltr,''num'',num,''help'',hlp)'],...
    'name','tag','fltr','num','hlp');

mnu = inline(['struct(''type'',''menu'',''name'',name,'...
    '''tag'',tag,''labels'',{labels},''values'',{values},''help'',hlp)'],...
    'name','tag','labels','values','hlp');

branch = inline(['struct(''type'',''branch'',''name'',name,'...
    '''tag'',tag,''val'',{val},''help'',hlp)'],...
    'name','tag','val','hlp');

repeat = inline(['struct(''type'',''repeat'',''name'',name,'...
    '''tag'',tag,''values'',{values},''help'',hlp)'],...
    'name','tag','values','hlp');

choice = inline(['struct(''type'',''choice'',''name'',name,'...
    '''tag'',tag,''values'',{values},''help'',hlp)'],...
    'name','tag','values','hlp');

%-----------------------------------------------------------------------

sp_text = ['                                                      ',...
      '                                                      '];
%-----------------------------------------------------------------------

onset   = entry('Onsets','onset','e',[Inf 1],'Vector of onsets');
p1 = ['Specify a vector of onset times for this condition type. '];
onset.help = {p1};

%-------------------------------------------------------------------------

duration = entry('Durations','duration','e',[Inf 1],'Duration/s');
duration.help = [...
  'Specify the event durations (in seconds). Epoch and event-related ',...
  'responses are modeled in exactly the same way but by specifying their ',...
  'different durations.  Events are ',...
  'specified with a duration of 0.  If you enter a single number for the ',...
  'durations it will be assumed that all trials conform to this duration. ',...
  'If you have multiple different durations, then the number must match the ',...
  'number of onset times.'];

%-------------------------------------------------------------------------

time_mod = mnu('Time Modulation','tmod',...
    {'No Time Modulation','1st order Time Modulation',...
     '2nd order Time Modulation','3rd order Time Modulation',...
     '4th order Time Modulation','5th order Time Modulation',...
     '6th order Time Modulation'},...
    {0,1,2,3,4,5,6},'');
time_mod.val = {0};
p1 = [...
  'This option allows for the characterisation of linear or nonlinear ',...
  'time effects. ',...
  'For example, 1st order modulation ',...
  'would model the stick functions and a linear change of the stick function ',...
  'heights over time. Higher order modulation will introduce further columns that ',...
  'contain the stick functions scaled by time squared, time cubed etc.'];
p2 = [...
  'Interactions or response modulations can enter at two levels.  Firstly ',...
  'the stick function itself can be modulated by some parametric variate ',...
  '(this can be time or some trial-specific variate like reaction time) ',...
  'modeling the interaction between the trial and the variate or, secondly ',...
  'interactions among the trials themselves can be modeled using a Volterra ',...
  'series formulation that accommodates interactions over time (and therefore ',...
  'within and between trial types).'];
time_mod.help = {p1,'',p2};

%-------------------------------------------------------------------------
%ply = mnu('Polynomial Expansion','poly',...
%    {'None','1st order','2nd order','3rd order','4th order','5th order','6th order'},...
%    {0,1,2,3,4,5,6},'Polynomial Order');
%ply.val = {0};
%-------------------------------------------------------------------------

name      = entry('Name','name','s', [1 Inf],'Name of parameter');
name.val  = {'Param'};
name.help = {'Enter a name for this parameter.'};

%-------------------------------------------------------------------------

param  = entry('Values','param','e',[Inf 1],'Parameter vector');
param.help = {'Enter a vector of values, one for each occurence of the event.'};

%-------------------------------------------------------------------------

ply = mnu('Polynomial Expansion','poly',...
    {'1st order','2nd order','3rd order','4th order','5th order','6th order'},...
    {1,2,3,4,5,6},'Polynomial Order');
ply.val = {1};
ply.help = {[...
  'For example, 1st order modulation ',...
  'would model the stick functions and a linear change of the stick function ',...
  'heights over different values of the parameter. Higher order modulation will ',...
  'introduce further columns that ',...
  'contain the stick functions scaled by parameter squared, cubed etc.']};

%-------------------------------------------------------------------------

pother = branch('Parameter','mod',{name,param,ply},'Custom parameter');
p1 = [...
  'Model interractions with user specified parameters. ',...
  'This allows nonlinear effects relating to some other measure ',...
  'to be modelled in the design matrix.'];
p2 = [...
  'Interactions or response modulations can enter at two levels.  Firstly ',...
  'the stick function itself can be modulated by some parametric variate ',...
  '(this can be time or some trial-specific variate like reaction time) ',...
  'modeling the interaction between the trial and the variate or, secondly ',...
  'interactions among the trials themselves can be modeled using a Volterra ',...
  'series formulation that accommodates interactions over time (and therefore ',...
  'within and between trial types).'];
pother.help = {p1,'',p2};

%-------------------------------------------------------------------------
mod      = repeat('Parametric Modulations','mod',{pother},'');
mod.help = {[...
  'The stick function itself can be modulated by some parametric variate ',...
  '(this can be time or some trial-specific variate like reaction time) ',...
  'modeling the interaction between the trial and the variate. ',...
  'The events can be modulated by zero or more parameters.']};

%-------------------------------------------------------------------------

name     = entry('Name','name','s',[1 Inf],'Condition Name');
name.val = {'Trial'};

%-------------------------------------------------------------------------

cond  = branch('Condition','cond',{name,onset,duration,time_mod,mod},...
    'Condition');
cond.check = @cond_check;
cond.help = {[...
  'An array of input functions is contructed, ',...
  'specifying occurrence events or epochs (or both). ',...
  'These are convolved with a basis set at a later stage to give ',...
  'regressors that enter into the design matrix. Interactions of evoked ',...
  'responses with some parameter (time or a specified variate) enter at ',...
  'this stage as additional columns in the design matrix with each trial multiplied ',...
  'by the [expansion of the] trial-specific parameter. ',...
  'The 0th order expansion is simply the main effect in the first column.']};

%-------------------------------------------------------------------------

conditions = repeat('Conditions','condrpt',{cond},'Conditions');
conditions.help = {[...
  'You are allowed to combine both event- and epoch-related ',...
  'responses in the same model and/or regressor. Any number ',...
  'of condition (event or epoch) types can be specified.  Epoch and event-related ',...
  'responses are modeled in exactly the same way by specifying their ',...
  'onsets [in terms of onset times] and their durations.  Events are ',...
  'specified with a duration of 0.  If you enter a single number for the ',...
  'durations it will be assumed that all trials conform to this duration.',...
  'For factorial designs, one can later associate these experimental conditions ',...
'with the appropriate levels of experimental factors. ';]};

%-------------------------------------------------------------------------

multi    = files('Multiple conditions','multi','.*',[0 1],'');
p1=['Select the *.mat file containing details of your multiple experimental conditions. '];
p2=['If you have mutliple conditions then entering the details a condition ',...
'at a time is very inefficient. This option can be used to load all the ',...
'required information in one go. You will first need to create a *.mat file ',...
'containing the relevant information. '];
p3=['This *.mat file must include the following cell arrays: names, onsets and durations ',...
'eg. names{2}=''SSent-DSpeak'', onsets{2}=[3 5 19 222], durations{2}=[0 0 0 0] ',...
'contain the required details of the second condition. These cell arrays may be made available ',...
'by your stimulus delivery program eg. COGENT. The duration vectors can ',...
'contain a single entry if the durations are identical for all events. '];
multi.help = {p1,sp_text,p2,sp_text,p3};
multi.val={''};


%-------------------------------------------------------------------------

name     = entry('Name','name','s',[1 Inf],'');
name.val = {'Regressor'};
p1=['Enter name of regressor eg. First movement parameter'];
name.help={p1};

%-------------------------------------------------------------------------

val      = entry('Value','val','e',[Inf 1],'');
val.help={['Enter the vector of regressor values']};

%-------------------------------------------------------------------------

regress  = branch('Regressor','regress',{name,val},'regressor');
regressors = repeat('Regressors','regress',{regress},'Regressors');
regressors.help = {[...
  'Regressors are additional columns included in the design matrix, ',...
  'which may model effects that would not be convolved with the ',...
  'haemodynamic response.  One such example would be the estimated movement ',...
  'parameters, which may confound the data.']};

%-------------------------------------------------------------------------

multi_reg    = files('Multiple regressors','multi_reg','.*',[0 1],'');
p1=['Select the *.mat/*.txt file containing details of your multiple regressors. '];
p2=['If you have mutliple regressors eg. realignment parameters, then entering the ',...
'details a regressor at a time is very inefficient. ',...
'This option can be used to load all the ',...
'required information in one go. '];
p3=['You will first need to create a *.mat file ',...
'containing a matrix R or a *.txt file containing the regressors. ',...
'Each column of R will contain a different regressor. ',...
'When SPM creates the design matrix the regressors will be named R1, R2, R3, ..etc.'];
multi_reg.help = {p1,sp_text,p2,sp_text,p3};
multi_reg.val={''};

%-------------------------------------------------------------------------

scans    = files('Scans','scans','image',[1 Inf],'Select scans');
scans.help = {[...
'Select the fMRI scans for this session.  They must all have the same ',...
'image dimensions, orientation, voxel size etc.']};

%-------------------------------------------------------------------------

hpf      = entry('High-pass filter','hpf','e',[1 1],'');
hpf.val  = {128};
hpf.help = {[...
    'The default high-pass filter cutoff is 128 seconds.',...
    'Slow signal drifts with a period longer than this will be removed. ',...
    'Use ''explore design'' ',...
    'to ensure this cut-off is not removing too much experimental variance. ',...
    'High-pass filtering is implemented using a residual forming matrix (i.e. ',...
    'it is not a convolution) and is simply to a way to remove confounds ',...
    'without estimating their parameters explicitly.  The constant term ',...
    'is also incorporated into this filter matrix.']};

%-------------------------------------------------------------------------

sess  = branch('Subject/Session','sess',{scans,conditions,multi,regressors,multi_reg,hpf},'Session');
sess.check = @sess_check;
p1 = [...
'The design matrix for fMRI data consists of one or more separable, ',...
'session-specific partitions.  These partitions are usually either one per ',...
'subject, or one per fMRI scanning session for that subject.'];
sess.help = {p1};

%-------------------------------------------------------------------------

block = repeat('Data & Design','blocks',{sess},'');
block.num = [1 Inf];
p1 = [...
  'The design matrix defines the experimental design and the nature of ',...
  'hypothesis testing to be implemented.  The design matrix has one row ',...
  'for each scan and one column for each effect or explanatory variable. ',...
  '(e.g. regressor or stimulus function).  '];
p2 = [...
  'This allows you to build design matrices with separable ',...
  'session-specific partitions.  Each partition may be the same (in which ',...
  'case it is only necessary to specify it once) or different.  Responses ',...
  'can be either event- or epoch related, where the latter model involves prolonged ',...
  'and possibly time-varying responses to state-related changes in ',...
  'experimental conditions.  Event-related response are modelled in terms ',...
  'of responses to instantaneous events.  Mathematically they are both ',...
  'modelled by convolving a series of delta (stick) or box-car functions, ',...
  'encoding the input or stimulus function. with a set of hemodynamic ',...
  'basis functions.'];
block.help = {p1,'',p2};

% Specification of factorial designs

fname.type    = 'entry';
fname.name    = 'Name';
fname.tag     = 'name';
fname.strtype = 's';
fname.num     = [1 1];
fname.help    = {'Name of factor, eg. ''Repetition'' '};

levels = entry('Levels','levels','e',[Inf 1],''); 
p1=['Enter number of levels for this factor, eg. 2'];
levels.help ={p1};

factor.type   = 'branch';
factor.name   = 'Factor';
factor.tag    = 'fact';
factor.val    = {fname,levels};
factor.help = {'Add a new factor to your experimental design'};

factors.type = 'repeat';
factors.name = 'Factorial design';
factors.tag  = 'factors';
factors.values = {factor};
p1 = ['If you have a factorial design then SPM can automatically generate ',...
      'the contrasts necessary to test for the main effects and interactions. '];
p2 = ['This includes the F-contrasts necessary to test for these effects at ',...
      'the within-subject level (first level) and the simple contrasts necessary ',...
      'to generate the contrast images for a between-subject (second-level) ',...
      'analysis.'];
p3 = ['To use this option, create as many factors as you need and provide a name ',...
      'and number of levels for each.  ',...
      'SPM assumes that the condition numbers of the first factor change slowest, ',...
      'the second factor next slowest etc. It is best to write down the contingency ',...
      'table for your design to ensure this condition is met. This table relates the ',...
      'levels of each factor to the ',...
      'conditions. '];
p4= ['For example, if you have 2-by-3 design ',...
      ' your contingency table has two rows and three columns where the ',...
      'the first factor spans the rows, and the second factor the columns. ',...
      'The numbers of the conditions are 1,2,3 for the first row and 4,5,6 ',...
      'for the second. '];
  
factors.help ={p1,sp_text,p2,sp_text,p3,sp_text,p4};
    


%-------------------------------------------------------------------------

glob  = mnu('Global normalisation','global',...
    {'Scaling','None'},{'Scaling','None'},{'Global intensity normalisation'});
glob.val={'None'};

%-------------------------------------------------------------------------

derivs = mnu('Model derivatives','derivs',...
    {'No derivatives', 'Time derivatives', 'Time and Dispersion derivatives'},...
    {[0 0],[1 0],[1 1]},'');
derivs.val = {[0 0]};
p1=['Model HRF Derivatives. The canonical HRF combined with time and ',...
    'dispersion derivatives comprise an ''informed'' basis set, as ',...
    'the shape of the canonical response conforms to the hemodynamic ',...
    'response that is commonly observed. The incorporation of the derivate ',...
    'terms allow for variations in subject-to-subject and voxel-to-voxel ',...
    'responses. The time derivative allows the peak response to vary by plus or ',...
    'minus a second and the dispersion derivative allows the width of the response ',...
    'to vary. The informed basis set requires an SPM{F} for inference. T-contrasts ',...
    'over just the canonical are perfectly valid but assume constant delay/dispersion. ',...
    'The informed basis set compares ',...
    'favourably with eg. FIR bases on many data sets. ']; 
derivs.help = {p1};
%-------------------------------------------------------------------------

hrf   = branch('Canonical HRF','hrf',{derivs},'Canonical Hemodynamic Response Function');
hrf.help = {[...
'Canonical Hemodynamic Response Function. This is the default option. ',...
'Contrasts of these effects have a physical interpretation ',...
'and represent a parsimonious way of characterising event-related ',...
'responses. This option is also ',...
'useful if you wish to ',...
'look separately at activations and deactivations (this is implemented using a ',...
't-contrast with a +1 or -1 entry over the canonical regressor). ']};

%-------------------------------------------------------------------------

len   = entry('Window length','length','e',[1 1],'');
len.help={'Post-stimulus window length (in seconds)'};
order = entry('Order','order','e',[1 1],'');
order.help={'Number of basis functions'};
o1    = branch('Fourier Set','fourier',{len,order},'');
o1.help = {'Fourier basis functions. This option requires an SPM{F} for inference.'};
o2    = branch('Fourier Set (Hanning)','fourier_han',{len,order},'');
o2.help = {'Fourier basis functions with Hanning Window - requires SPM{F} for inference.'};
o3    = branch('Gamma Functions','gamma',{len,order},'');
o3.help = {'Gamma basis functions - requires SPM{F} for inference.'};
o4    = branch('Finite Impulse Response','fir',{len,order},'');
o4.help = {'Finite impulse response - requires SPM{F} for inference.'};

%-------------------------------------------------------------------------

bases = choice('Basis Functions','bases',{hrf,o1,o2,o3,o4},'');
bases.val = {hrf};
bases.help = {[...
    'The most common choice of basis function is the Canonical HRF with ',...
    'or without time and dispersion derivatives. ']};

%-------------------------------------------------------------------------

volt  = mnu('Model Interactions (Volterra)','volt',{'Do not model Interractions','Model Interractions'},{1,2},'');
volt.val = {1};
p1 = ['Generalized convolution of inputs (U) with basis set (bf).'];
p2 = [...
  'For first order expansions the causes are simply convolved ',...
  '(e.g. stick functions) in U.u by the basis functions in bf to create ',...
  'a design matrix X.  For second order expansions new entries appear ',...
  'in ind, bf and name that correspond to the interaction among the ',...
  'orginal causes. The basis functions for these efects are two dimensional ',...
  'and are used to assemble the second order kernel. ',...
  'Second order effects are computed for only the first column of U.u.'];
p3 = [...
  'Interactions or response modulations can enter at two levels.  Firstly ',...
  'the stick function itself can be modulated by some parametric variate ',...
  '(this can be time or some trial-specific variate like reaction time) ',...
  'modeling the interaction between the trial and the variate or, secondly ',...
  'interactions among the trials themselves can be modeled using a Volterra ',...
  'series formulation that accommodates interactions over time (and therefore ',...
  'within and between trial types).'];
volt.help = {p1,'',p2,p3};

%-------------------------------------------------------------------------

mask = files('Explicit mask','mask','image',[0 1],'Image mask');
mask.val = {''};
p1=['Specify an image for explicitly masking the analysis. ',...
 'A sensible option here is to use a segmention of structural images ',...
 'to specify a within-brain mask. If you select that image as an ',...
 'explicit mask then only those voxels in the brain will be analysed. ',...
 'This both speeds the estimation and restricts SPMs/PPMs to within-brain ',...
 'voxels. Alternatively, if such structural images are unavailble or no ',...
 'masking is required, then leave this field empty.'];
mask.help={p1};

%-------------------------------------------------------------------------

cdir = files('Directory','dir','dir',1,'');
cdir.help = {[...
'Select a directory where the SPM.mat file containing the ',...
'specified design matrix will be written.']};

%-------------------------------------------------------------------------
fmri_t0 = entry('Microtime onset','fmri_t0','e',[1 1],'');
p1=['The microtime onset, t0, is the first time-bin at which the regressors ',...
    'are resampled to coincide ',...
  'with data acquisition.  If t0 = 1 then the ',...
  'regressors will be appropriate for the first slice.  If you want to ',...
  'temporally realign the regressors so that they match responses in the ',...
  'middle slice then make t0 = t/2 ',...
  '(assuming there is a negligible gap between ',...
  'volume acquisitions). '];
p2=['Do not change the default setting unless you have a long TR. '];
fmri_t0.val={1};
fmri_t0.help={p1,sp_text,p2};

fmri_t = entry('Microtime resolution','fmri_t','e',[1 1],'');
p1=['The microtime resolution, t, is the number of time-bins per ',...
    'scan used when building regressors. '];
p2=['Do not change this parameter unless you have a long TR and wish to ',...
        'shift regressors so that they are ',...
  'aligned to a particular slice. '];
fmri_t.val={16};
fmri_t.help={p1,sp_text,p2};

rt       = entry('Interscan interval','RT','e',[1 1],'Interscan interval {secs}');
rt.help = {[...
'Interscan interval, TR, (specified in seconds).  This is the time between acquiring a plane of one volume ',...
'and the same plane in the next volume.  It is assumed to be constant throughout.']};

%-------------------------------------------------------------------------

units    = mnu('Units for design','units',{'Scans','Seconds'},{'scans','secs'},'');
p1=['The onsets of events or blocks can be specified in either scans or seconds.'];
units.help = {p1};

timing = branch('Timing parameters','timing',{units,rt,fmri_t,fmri_t0},'');
p1=['Specify various timing parameters needed to construct the design matrix. ',...
    'This includes the units of the design specification and the interscan interval.'];

p2 = ['Also, with longs TRs you may want to shift the regressors so that they are ',...
  'aligned to a particular slice.  This is effected by changing the ',...
  'microtime resolution and onset. '];
timing.help={p1,sp_text,p2};

%-------------------------------------------------------------------------

cvi   = mnu('Serial correlations','cvi',{'none','AR(1)'},{'none','AR(1)'},...
    {'Correct for serial correlations'});
cvi.val={'AR(1)'};
p1 = [...
    'Serial correlations in fMRI time series due to aliased biorhythms and unmodelled ',...
    'neuronal activity can be accounted for using an autoregressive AR(1) ',...
    'model during Classical (ReML) parameter estimation.  '];
p2=['This estimate assumes the same ',...
    'correlation structure for each voxel, within each session.  ReML ',...
    'estimates are then used to correct for non-sphericity during inference ',...
    'by adjusting the statistics and degrees of freedom appropriately.  The ',...
    'discrepancy between estimated and actual intrinsic (i.e. prior to ',...
    'filtering) correlations are greatest at low frequencies.  Therefore ',...
    'specification of the high-pass filter is particularly important. '];
p3=[...
    'Serial correlation can be ignored if you choose the ''none'' option. ',...
    'Note that the above options only apply if you later specify that your model will be ',...
    'estimated using the Classical (ReML) approach. If you choose Bayesian estimation ',...
    'these options will be ignored. For Bayesian estimation, the choice of noise',...
    'model (AR model order) is made under the estimation options. '];
cvi.help = {p1,sp_text,p2,sp_text,p3};

%-------------------------------------------------------------------------

conf = branch('fMRI model specification','fmri_spec',...
    {timing,block,factors,bases,volt,cdir,glob,mask,cvi},'fMRI design');
conf.prog   = @run_stats;
conf.vfiles = @vfiles_stats;
conf.check  = @check_dir;
conf.modality = {'FMRI'};
p1=['Statistical analysis of fMRI data uses a mass-univariate approach ',...
    'based on General Linear Models (GLMs). It comprises the following ',...
    'steps (1) specification of the GLM design matrix, fMRI data files and filtering ',...
  '(2) estimation of GLM paramaters using classical or ',...
  'Bayesian approaches and (3) interrogation of results using contrast vectors to ',...
  'produce Statistical Parametric Maps (SPMs) or Posterior Probability Maps (PPMs).' ];
p2 = [...
  'The design matrix defines the experimental design and the nature of ',...
  'hypothesis testing to be implemented.  The design matrix has one row ',...
  'for each scan and one column for each effect or explanatory variable. ',...
  '(eg. regressor or stimulus function). ',...
  'You can build design matrices with separable ',...
  'session-specific partitions.  Each partition may be the same (in which ',...
  'case it is only necessary to specify it once) or different. '];
p3 = ['Responses ',...
  'can be either event- or epoch related, the only distinction is the duration ',...
  'of the underlying input or stimulus function. Mathematically they are both ',...
  'modeled by convolving a series of delta (stick) or box functions (u), ',...
  'indicating the onset of an event or epoch with a set of basis ',...
  'functions.  These basis functions model the hemodynamic convolution, ',...
  'applied by the brain, to the inputs.  This convolution can be first-order ',...
  'or a generalized convolution modeled to second order (if you specify the ',...
  'Volterra option). The same inputs are used by the Hemodynamic model or ',...
  'Dynamic Causal Models which model the convolution explicitly in terms of ',...
  'hidden state variables. '];
p4=['Basis functions can be used to plot estimated responses to single events ',...
  'once the parameters (i.e. basis function coefficients) have ',...
  'been estimated.  The importance of basis functions is that they provide ',...
  'a graceful transition between simple fixed response models (like the ',...
  'box-car) and finite impulse response (FIR) models, where there is one ',...
  'basis function for each scan following an event or epoch onset.  The ',...
  'nice thing about basis functions, compared to FIR models, is that data ',...
  'sampling and stimulus presentation does not have to be synchronized ',...
  'thereby allowing a uniform and unbiased sampling of peri-stimulus time.'];
p5 = [...
  'Event-related designs may be stochastic or deterministic.  Stochastic ',...
  'designs involve one of a number of trial-types occurring with a ',...
  'specified probability at successive intervals in time.  These ',...
  'probabilities can be fixed (stationary designs) or time-dependent ',...
  '(modulated or non-stationary designs).  The most efficient designs ',...
  'obtain when the probabilities of every trial type are equal. ',...
  'A critical issue in stochastic designs is whether to include null events ',...
  'If you wish to estimate the evoked response to a specific event ',...
  'type (as opposed to differential responses) then a null event must be ',...
  'included (even if it is not modeled explicitly).'];
p6 = [...
  'In SPM, analysis of data from multiple subjects typically proceeds in two stages ',...
  'using models at two ''levels''. The ''first level'' models are used to ',...
  'implement a within-subject analysis. Typically there will be as many first ',...
  'level models as there are subjects. Analysis proceeds as described using the ',...
  '''Specify first level'' and ''Estimate'' options. The results of these analyses ',...
  'can then be presented as ''case studies''. More often, however, one wishes to ',...
  'make inferences about the population from which the subjects were drawn. This is ',...
  'an example of a ''Random-Effects (RFX) analysis'' (or, more properly, a mixed-effects ',...
  'analysis). In SPM, RFX analysis is implemented using the ''summary-statistic'' ',...
  'approach where contrast images from each subject are used as summary ',...
  'measures of subject responses. These are then entered as data into a ''second level'' ',...
  'model. '];
conf.help = {p1,'',p2,'',p3,'',p4,'',p5,'',p6};

return;
%-------------------------------------------------------------------------

%-------------------------------------------------------------------------

function t = check_dir(job)
t = {};
%d = pwd;
%try,
%    cd(job.dir{1});
%catch,
%    t = {['Cannot Change to directory "' job.dir{1} '".']};
%end;

%disp('Checking...');
%disp(fullfile(job.dir{1},'SPM.mat'));

% Should really include a check for a "virtual" SPM.mat
%if exist(fullfile(job.dir{1},'SPM.mat'),'file'),
 %   t = {'SPM files exist in the analysis directory.'};
 %end;
%return;
%-------------------------------------------------------------------------

%-------------------------------------------------------------------------

function t = cond_check(job)
t   = {};
if (numel(job.onset) ~= numel(job.duration)) && (numel(job.duration)~=1),
    t = {sprintf('"%s": Number of event onsets (%d) does not match the number of durations (%d).',...
        job.name, numel(job.onset),numel(job.duration))};
end;
for i=1:numel(job.mod),
    if numel(job.onset) ~= numel(job.mod(i).param),
        t = {t{:}, sprintf('"%s" & "%s":Number of event onsets (%d) does not equal the number of parameters (%d).',...
            job.name, job.mod(i).name, numel(job.onset),numel(job.mod(i).param))};
    end;
end;
return;
%-------------------------------------------------------------------------

%-------------------------------------------------------------------------

function t = sess_check(sess)
t = {};
for i=1:numel(sess.regress),
    if numel(sess.scans) ~= numel(sess.regress(i).val),
        t = {t{:}, sprintf('Num scans (%d) ~= Num regress[%d] (%d).',numel(sess.scans),i,numel(sess.regress(i).val))};
    end;
end;
return;
%-------------------------------------------------------------------------

%-------------------------------------------------------------------------
function my_cd(varargin)
job = varargin{1};
if ~isempty(job)
    try
    cd(char(job));
    fprintf('Changing directory to: %s\n',char(job));
    catch
        error('Failed to change directory. Aborting run.')
    end
end
return;
%------------------------------------------------------------------------

%------------------------------------------------------------------------
function run_stats(job)
% Set up the design matrix and run a design.

spm_defaults;
global defaults
defaults.modality='FMRI';

original_dir = pwd;
my_cd(job.dir);
    
%-Ask about overwriting files from previous analyses...
%-------------------------------------------------------------------
if exist(fullfile(job.dir{1},'SPM.mat'),'file')
    str = {	'Current directory contains existing SPM file:',...
            'Continuing will overwrite existing file!'};
    if spm_input(str,1,'bd','stop|continue',[1,0],1,mfilename);
        fprintf('%-40s: %30s\n\n',...
            'Abort...   (existing SPM file)',spm('time'));
        return
    end
end

% If we've gotten to this point we're committed to overwriting files.
% Delete them so we don't get stuck in spm_spm
%------------------------------------------------------------------------
files = {'mask.???','ResMS.???','RVP.???',...
    'beta_????.???','con_????.???','ResI_????.???',...
    'ess_????.???', 'spm?_????.???'};
for i=1:numel(files),
    if any(files{i} == '*' | files{i} == '?')
        [j,unused] = spm_list_files(pwd,files{i});
        for i=1:size(j,1),
            spm_unlink(deblank(j(i,:)));
        end
    else
        spm_unlink(files{i});
    end
end


% Variables
%-------------------------------------------------------------
SPM.xY.RT = job.timing.RT;
SPM.xY.P = [];

% Slice timing
defaults.stats.fmri.t=job.timing.fmri_t;
defaults.stats.fmri.t0=job.timing.fmri_t0;

% Basis function variables
%-------------------------------------------------------------
SPM.xBF.UNITS = job.timing.units;
SPM.xBF.dt    = job.timing.RT/defaults.stats.fmri.t;
SPM.xBF.T     = defaults.stats.fmri.t;
SPM.xBF.T0    = defaults.stats.fmri.t0;

% Basis functions
%-------------------------------------------------------------
if strcmp(fieldnames(job.bases),'hrf')
    if all(job.bases.hrf.derivs == [0 0])
        SPM.xBF.name = 'hrf';
    elseif all(job.bases.hrf.derivs == [1 0])
        SPM.xBF.name = 'hrf (with time derivative)';
    elseif all(job.bases.hrf.derivs == [1 1])
        SPM.xBF.name = 'hrf (with time and dispersion derivatives)';
    else
        error('Unrecognized hrf derivative choices.')
    end
else
    nambase = fieldnames(job.bases);
    if ischar(nambase)
        nam=nambase;
    else
        nam=nambase{1};
    end
    switch nam,
        case 'fourier',
            SPM.xBF.name = 'Fourier set';
        case 'fourier_han', 
            SPM.xBF.name = 'Fourier set (Hanning)';
        case 'gamma',
            SPM.xBF.name = 'Gamma functions';
        case 'fir',
            SPM.xBF.name = 'Finite Impulse Response';
        otherwise
            error('Unrecognized hrf derivative choices.')
    end
    SPM.xBF.length = job.bases.(nam).length;
    SPM.xBF.order  = job.bases.(nam).order;
end
SPM.xBF          = spm_get_bf(SPM.xBF);
if isempty(job.sess),
    SPM.xBF.Volterra = false;
else
    SPM.xBF.Volterra = job.volt;
end;

for i = 1:numel(job.sess),
    sess = job.sess(i);

    % Image filenames
    %-------------------------------------------------------------
    SPM.nscan(i) = size(sess.scans,1);
    SPM.xY.P     = strvcat(SPM.xY.P,sess.scans{:});

    U = [];

    % Augment the singly-specified conditions with the multiple conditions
    % specified in the conditions.mat file 
    %------------------------------------------------------------
    if ~strcmp(sess.multi,'')
        names=[];onsets=[];durations=[];
        load(char(sess.multi{:}));
        
        k=length(onsets);
        j=length(sess.cond);
        for ii=1:k,
            cond.name=names{ii};
            cond.onset=onsets{ii};
            cond.duration=durations{ii};
            cond.tmod=0;
            cond.mod={};
            sess.cond(ii+j)=cond;    
        end
    end
    
    % Configure the input structure array
    %-------------------------------------------------------------
    for j = 1:length(sess.cond),
        cond      = sess.cond(j);
        U(j).name = {cond.name};
        U(j).ons  = cond.onset(:);
        U(j).dur  = cond.duration(:);
        if length(U(j).dur) == 1
            U(j).dur    = U(j).dur*ones(size(U(j).ons));
        elseif length(U(j).dur) ~= length(U(j).ons)
            error('Mismatch between number of onset and number of durations.')
        end

        P  = [];
        q1 = 0;
        if cond.tmod>0,
            % time effects
            P(1).name = 'time';
            P(1).P    = U(j).ons*job.timing.RT;
            P(1).h    = cond.tmod;
            q1        = 1;
        end;
        for q = 1:numel(cond.mod),
            % Parametric effects
            q1 = q1 + 1;
            P(q1).name = cond.mod(q).name;
            P(q1).P    = cond.mod(q).param;
            P(q1).h    = cond.mod(q).poly;
        end;
        if isempty(P)
            P.name = 'none';
            P.h    = 0;
        end
        U(j).P = P;

    end

    SPM.Sess(i).U = U;


    % User specified regressors
    %-------------------------------------------------------------
    C = [];
    Cname = cell(1,numel(sess.regress));
    for q = 1:numel(sess.regress),
        Cname{q} = sess.regress(q).name;
        C         = [C, sess.regress(q).val(:)];
    end
    
    % Augment the singly-specified regressors with the multiple regressors
    % specified in the regressors.mat file 
    %------------------------------------------------------------
    if ~strcmp(sess.multi_reg,'')
        tmp=load(char(sess.multi_reg{:}));
        if isstruct(tmp) && isfield(tmp,'R')
            R = tmp.R;
        elseif isnumeric(tmp)
            % load from e.g. text file
            R = tmp;
        else
            warning('Can''t load user specified regressors in %s', ...
                    char(sess.multi_reg{:}));
            R = [];
        end

        C=[C, R];
        nr=size(R,2);
        nq=length(Cname);
        for inr=1:nr,
            Cname{inr+nq}=['R',int2str(inr)];
        end
    end
    SPM.Sess(i).C.C    = C;
    SPM.Sess(i).C.name = Cname;

    
end

% Factorial design
%-------------------------------------------------------------
if isfield(job,'fact') 
    if ~isempty(job.fact)
        NC=length(SPM.Sess(1).U); % Number of conditions
        CheckNC=1;
        for i=1:length(job.fact)
            SPM.factor(i).name=job.fact(i).name;
            SPM.factor(i).levels=job.fact(i).levels;
            CheckNC=CheckNC*SPM.factor(i).levels;
        end
        if ~(CheckNC==NC)
            disp('Error in fmri_spec job: factors do not match conditions');
            return
        end
    end
else
    SPM.factor=[];
end

% Globals
%-------------------------------------------------------------
SPM.xGX.iGXcalc = job.global;
SPM.xGX.sGXcalc = 'mean voxel value';
SPM.xGX.sGMsca  = 'session specific';

% High Pass filter
%-------------------------------------------------------------
for i = 1:numel(job.sess),
    SPM.xX.K(i).HParam = job.sess(i).hpf;
end

% Autocorrelation
%-------------------------------------------------------------
SPM.xVi.form = job.cvi;

% Let SPM configure the design
%-------------------------------------------------------------
SPM = spm_fmri_spm_ui(SPM);

if ~isempty(job.mask)
    SPM.xM.VM         = spm_vol(job.mask{:});
    SPM.xM.xs.Masking = [SPM.xM.xs.Masking, '+explicit mask'];
end

%-Save SPM.mat
%-----------------------------------------------------------------------
fprintf('%-40s: ','Saving SPM configuration')   %-#
if str2num(version('-release'))>=14,
    save('SPM','-V6','SPM');
else
    save('SPM','SPM');
end;

fprintf('%30s\n','...SPM.mat saved')                     %-#


my_cd(original_dir); % Change back dir
fprintf('Done\n')
return
%-------------------------------------------------------------------------

%-------------------------------------------------------------------------
function vf = vfiles_stats(job)
direc = job.dir{1};
vf    = {fullfile(direc,'SPM.mat')};

% Should really create a few vfiles for beta images etc here as well.

