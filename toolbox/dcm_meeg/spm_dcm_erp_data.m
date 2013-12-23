function DCM = spm_dcm_erp_data(DCM,h)
% prepares structures for forward model(EEG, MEG and LFP)
% FORMAT DCM = spm_dcm_erp_data(DCM,h)
% DCM  - DCM structure
% h    - order of drift terms
%
% requires
%
%    DCM.xY.Dfile        - data file
%    DCM.options.trials  - trial codes
%    DCM.options.Tdcm    - Peri-stimulus time window
%    DCM.options.D       - Down-sampling
%    DCM.options.han     - Hanning
%
% sets
%    DCM.xY.modality - 'MEG','EEG' or 'LFP'
%    DCM.xY.Time     - Time [ms] data
%    DCM.xY.pst      - Time [ms] of down-sampled data
%    DCM.xY.dt       - sampling in seconds (s)
%    DCM.xY.y        - response variable for DCM
%    DCM.xY.xy       - cell array of trial-specific response {[ns x nc]}
%    DCM.xY.It       - Indices of (ns) time bins
%    DCM.xY.Ic       - Indices of (nc) good channels
%    DCM.xY.name     - names of (nc) channels
%    DCM.xY.scale    - scalefactor applied to raw data
%    DCM.xY.coor2D   - 2D coordinates for plotting
 
%
%    DCM.xY.Hz       - Frequency bins (for Wavelet transform)
%    DCM.options.h
%__________________________________________________________________________
% Copyright (C) 2008 Wellcome Trust Centre for Neuroimaging
 
% Karl Friston
% $Id: spm_dcm_erp_data.m 5816 2013-12-23 18:52:56Z karl $
 
 
% Set defaults and Get D filename
%--------------------------------------------------------------------------
try
    Dfile = DCM.xY.Dfile;
catch
    errordlg('Please specify data and trials');
    error('')
end
 
% order of drift terms
%--------------------------------------------------------------------------
try, h; catch, h = 0; end
 
% load D
%--------------------------------------------------------------------------
try
    D = spm_eeg_load(Dfile);
catch
    try
        [dum,f]      = fileparts(Dfile);
        D            = spm_eeg_load(f);
        DCM.xY.Dfile = fullfile(pwd,f);
    catch
        try
            [f,p]        = uigetfile('*.mat','please select data file');
            name         = fullfile(p,f);
            D            = spm_eeg_load(name);
            DCM.xY.Dfile = fullfile(name);
        catch
            warndlg([Dfile ' could not be found'])
            return
        end
    end
end
 
% get time-frequency data if appropriate
%--------------------------------------------------------------------------
if isequal(D.transformtype, 'TF')
    DCM = spm_dcm_ind_data(DCM);
    return;
end
 
% indices of EEG channel (excluding bad channels) and peristimulus times
%--------------------------------------------------------------------------
if ~isfield(DCM.xY, 'modality')
    [mod, list] = modality(D, 0, 1);
    if isequal(mod, 'Multimodal')
        qstr    = 'Only one modality can be modelled at a time. Please select.';
        if numel(list) < 4
            
            % Pretty dialog box
            %--------------------------------------------------------------
            options = [];
            options.Default = list{1};
            options.Interpreter = 'none';
            DCM.xY.modality = questdlg(qstr, 'Select modality', list{:}, options);
            
        else
            
            % can accommodate more buttons
            %--------------------------------------------------------------
            ind = menu(qstr, list);
            DCM.xY.modality = list{ind};
        end
    else
        DCM.xY.modality = mod;
    end
end
 
% good channels
%--------------------------------------------------------------------------
Ic = D.indchantype(DCM.xY.modality,'GOOD');
if isempty(Ic)
    warndlg('No good channels in these data');
    return
end
 
Nc            = length(Ic);               % number of channels
DCM.xY.name   = D.chanlabels(Ic);         % channel names
DCM.xY.Ic     = Ic;                       % channel indices
DCM.xY.Time   = time(D, [], 'ms');        % PST (ms)
DCM.xY.dt     = 1/D.fsample;              % time bins
DCM.xY.coor2D = D.coor2D(Ic);             % coordinates (topographic)
DCM.xY.xy     = {};
 
% options
%==========================================================================
try
    DT    = DCM.options.D;
catch
    errordlg('Please specify down sampling');
    error('')
end
try
    han   = DCM.options.han;
catch
    han   = 0;
end
try
    trial = DCM.options.trials;
catch
    errordlg('please specify trials');
    error('')
end
try
 
    % time window and bins for modelling
    %----------------------------------------------------------------------
    T1          = DCM.options.Tdcm(1);
    T2          = DCM.options.Tdcm(2);
    [dum, T1]   = min(abs(DCM.xY.Time - T1));
    [dum, T2]   = min(abs(DCM.xY.Time - T2));
 
    % Time [ms] of down-sampled data
    %----------------------------------------------------------------------
    It          = (T1:DT:T2)';
    Ns          = length(It);                % number of samples
    DCM.xY.pst  = DCM.xY.Time(It);           % Down-sampled PST
    DCM.xY.dt   = DT/D.fsample;              % sampling in seconds
    DCM.xY.It   = It;                        % Indices of time bins
 
catch
    errordlg('Please specify time window');
    error('')
end
 
% get trial averages - ERP
%--------------------------------------------------------------------------
cond  = D.condlist;
for i = 1:length(trial)
 
    % trial indices
    %----------------------------------------------------------------------
    c     = D.indtrial(cond(trial(i)), 'GOOD');
    Nt    = length(c);
 
    % ERP
    %----------------------------------------------------------------------
    Y     = zeros(Ns,Nc);
    for j = 1:Nt
        Y = Y + squeeze(D(Ic,It,c(j)))';
    end
    DCM.xY.xy{i} = Y/Nt;
    DCM.xY.nt(i) = Nt;
end
 
 
% confounds - DCT:
%--------------------------------------------------------------------------
if h == 0
    X0 = sparse(Ns,1);
else
    X0 = spm_dctmtx(Ns,h);
end
R      = speye(Ns) - X0*X0';
 
% hanning (omit second residualization for very long time-series)
%--------------------------------------------------------------------------
if han
    if Ns < 2048
        R  = R*sparse(diag(hanning(Ns)))*R;
    else
        R  = sparse(diag(hanning(Ns)))*R;
    end
end
 
% adjust data
%--------------------------------------------------------------------------
for i = 1:length(DCM.xY.xy);
    DCM.xY.xy{i} = R*DCM.xY.xy{i};
end
 
% condition units of measurement
%--------------------------------------------------------------------------
DCM.xY.y     = DCM.xY.xy;
DCM.xY.code  = cond(trial);
DCM.xY.scale = 1;
