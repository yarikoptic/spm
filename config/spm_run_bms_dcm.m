function out = spm_run_bms_dcm (varargin)
% API to compare DCMs on the basis of their log-evidences. Four methods
% are available to identify the best among alternative models:
%
%  (1) single subject BMS using Bayes factors
%     (see Penny et al, NeuroImage, 2004)
%  (2) fixed effects group BMS using group Bayes factors
%     (see Stephan et al,NeuroImage, 2007)
%  (3) random effects group BMS using exceedance probabilities
%     (see Stephan et al,NeuroImage, 2009)
%  (4) comparing model families
%     (see Penny et al, PLOS-CB, submitted) 
%
% Note: All functions use the negative free energy (F) as an approximation
% to the log model evidence.
%
% __________________________________________________________________________
% Copyright (C) 2008 Wellcome Trust Centre for Neuroimaging

% Chun-Chuan Chen
% $Id: spm_run_bms_dcm.m 3522 2009-10-29 20:08:50Z maria $

% input
% -------------------------------------------------------------------------
job     = varargin{1};
fname   = 'BMS.mat';                 % Output filename
fname   = fullfile(job.dir{1},fname);% Output filename (including directory)
priors  = job.priors;
ld_f    = ~isempty(job.load_f{1});
ld_msp  = ~isempty(job.model_sp{1});
bma_do  = isfield(job.bma,'bma_yes');
data_se = ~isempty(job.sess_dcm);

% method
% -------------------------------------------------------------------------
if strcmp(job.method,'FFX');
    method = 'FFX';
else
    method = 'RFX';
    if strcmp(job.method,'RFX')
        str_meth = 'VB';
    else
        str_meth = 'Gibbs';
    end 
end

% check DCM.mat files and BMA 
% -------------------------------------------------------------------------
do_bma_famwin = 0;
do_bma_all    = 0;

if bma_do
    if data_se
        load(job.sess_dcm{1}(1).mod_dcm{1})   
    else
        if ld_msp
            disp('Loading model space')
            load(job.model_sp{1});
            load(subj(1).sess(1).model(1).fname)
        else
            error('Plase specify DCM.mat files to do BMA!')
        end
    end
    
    n  = size(DCM.a,2);
    m  = size(DCM.c,2);
    mi = size(DCM.c,2);
    bma.nsamp       = str2num(job.bma.bma_yes.bma_nsamp);
    bma.odds_ratio  = str2num(job.bma.bma_yes.bma_ratio);
    bma.a           = zeros(n,n,bma.nsamp);
    bma.b           = zeros(n,n,m,bma.nsamp);
    bma.c           = zeros(n,mi,bma.nsamp);
    
    if isfield(job.bma.bma_yes.bma_set,'bma_famwin')
        do_bma_famwin = 1;
    else
        if isfield(job.bma.bma_yes.bma_set,'bma_all')
            do_bma_all = 1;
        else
            bma_fam    = double(job.bma.bma_yes.bma_set.bma_part);
        end
    end
end

F = [];
N = {};

% prepare the data
% -------------------------------------------------------------------------
if  ld_f
    data = job.load_f{1};
    load(data);
    nm      = size(F,2);                               % No of Models
    ns      = size(F,1);                               % No of Models
    N       = 1:nm;
    subj    = [];
    f_fname = data;
    
else
    
    f_fname = [];
    
    if ld_msp
        ns      = length(subj);                         % No of Subjects
        nsess   = length(subj(1).sess);                 % No of sessions
        nm      = length(subj(1).sess(1).model);        % No of Models
    else
        ns      = size(job.sess_dcm,2);                 % No of Subjects
        nsess   = size(job.sess_dcm{1},2);              % No of sessions
        nm      = size(job.sess_dcm{1}(1).mod_dcm,1);   % No of Models
    end
    
    F       = zeros(ns,nm);
    N       = cell(nm);
    
    % Check if No of models > 2
    if nm < 2
        msgbox('Please select more than one file')
        return
    end
    
    for k=1:ns

        if ld_msp
           nsess_now       = length(subj(k).sess);
           nmodels         = length(subj(k).sess(1).model);
        else
           disp(sprintf('Loading DCMs for subject %d', k));
           nsess_now       = size(job.sess_dcm{k},2);
           nmodels         = size(job.sess_dcm{k}(1).mod_dcm,1);
        end

        if (nsess_now == nsess && nmodels== nm) % Check no of sess/mods
            
            ID = zeros(nsess, nm);
            
            for j=1:nm
                
                F_sess      = [];
                
                for h = 1:nsess_now
                   
                    if ~ld_msp
                                              
                        clear DCM
                        
                        tmp = job.sess_dcm{k}(h).mod_dcm{j};
                      DCM = loadmat(tmp,'DCM.F','DCM.Ep','DCM.Cp'); % Use
%                       this option if you have the file loadmat.m
%                         DCM = load(tmp);
                        
                        F_sess  = [F_sess,DCM.DCM.F];
                        
                        subj(k).sess(h).model(j).fname = tmp;
                        subj(k).sess(h).model(j).F     = DCM.DCM.F;
                        subj(k).sess(h).model(j).Ep    = DCM.DCM.Ep;
                        subj(k).sess(h).model(j).Cp    = DCM.DCM.Cp;
                        
                    else
                        
                        F_sess = [F_sess,subj(k).sess(h).model(j).F];
                        
                    end
                    
                    % Data ID verification. At least for now we'll
                    % re-compute the IDs rather than use the ones stored
                    % with the DCM.
                    if job.verify_id
                        M = DCM_tmp.DCM.M;
                        
                        if isfield(DCM_tmp.DCM, 'xY')
                            Y = DCM_tmp.DCM.xY;  %not fMRI
                        else
                            Y = DCM_tmp.DCM.Y;   % fMRI
                        end
                        
                        if isfield(M,'FS')
                            try
                                ID(h, j)  = spm_data_id(feval(M.FS,Y.y,M));
                            catch
                                ID(h, j)  = spm_data_id(feval(M.FS,Y.y));
                            end
                        else
                            ID(h, j) = spm_data_id(Y.y);
                        end
                        
                    end
                end
                
                F_mod       = sum(F_sess);
                F(k,j)      = F_mod;
                N{j}        = sprintf('model%d',j);
                
            end
            
            if job.verify_id
                failind = find(max(abs(diff(ID))) > eps);
                if ~isempty(failind)
                    out.files{1} = [];
                    msgbox(['Error: the models for subject ' num2str(k) ...
                        ' session(s) ' num2str(failind) ' were not fitted to the same data.']);
                    return
                end
            end
        else
            out.files{1} = [];
            msgbox('Error: the number of sessions/models should be the same for all subjects!')
            return
            
        end
        
    end
end

% bayesian model selection 
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------

% free energy
sumF = sum(F,1);

% family or model level
% -------------------------------------------------------------------------
if isfield(job.family_level,'family_file')
    
    if ~isempty(job.family_level.family_file{1})
    
        load(job.family_level.family_file{1});
        do_family    = 1;
        family.prior = priors;
        family.infer = method;
    
        nfam    = size(family.names,2);
        npart   = length(unique(family.partition));
        maxpart = max(family.partition);
        m_indx  = 1:nm;
    
        if nfam ~= npart || npart == 1 || maxpart > npart
            error('Invalid family file!')
            out.files{1} = [];
        end
    else     
        do_family = 0;
    end
    
else
    
    if isempty(job.family_level.family)
        do_family    = 0;
    else
        do_family    = 1;
        nfam         = size(job.family_level.family,2);
        
        names_fam  = {};
        models_fam = [];
        m_indx     = [];
        for f=1:nfam
            names_fam    = [names_fam,job.family_level.family(f).family_name];
            m_indx       = [m_indx,job.family_level.family(f).family_models'];
            models_fam(job.family_level.family(f).family_models) = f;
        end
        
        family.names     = names_fam;
        family.partition = models_fam;
        
        npart   = length(unique(family.partition));
        maxpart = max(family.partition);
        nmodfam = length(m_indx);

        if nfam ~= npart || npart == 1 || maxpart > npart || nmodfam > nm 
           error('Invalid family!')
           out.files{1} = [];
           return
        end
        
        family.prior     = priors;
        family.infer     = method;
      
    end
    
end

% single subject BMS or 1st level( fixed effects) group BMS
% -------------------------------------------------------------------------
if strcmp(method,'FFX'); 
    
    disp('Computing FFX model/family posteriors ...');
    if ~do_family
        family         = [];
        model.post     = spm_api_bmc(sumF,N,[],[]);
    else
        Ffam           = F(:,m_indx);
        [family,model] = spm_compare_families (Ffam,family);
        P              = spm_api_bmc(sumF,N,[],[],family);
    end
    
    if bma_do,  
        if do_family
            if do_bma_famwin
                [fam_max,fam_max_i]  = max(family.post);
                bma.indx = find(family.partition==fam_max_i);
                bma.post  = model.post(bma.indx);
            else
                if do_bma_all  
                   bma.post  = model.post;
                   bma.indx = 1:nm;
                else
                    if bma_fam <= nfam && bma_fam > 0 && rem(bma_fam,1) == 0 
                           bma.indx = find(family.partition==bma_fam);
                           bma.post  = model.post(bma.indx);
                    else
                    error('Incorrect family for BMA!');
                    end         
                end
            end
        else
               bma.post  = model.post;
               bma.indx = 1:nm;
        end  

       disp('FFX Bayesian model averaging ...');
       
       % bayesian model averaging
       % ------------------------------------------------------------------
       theta = spm_dcm_bma(bma.post,bma.indx,subj,bma.nsamp,bma.odds_ratio);

       % reshape parameters
       % ------------------------------------------------------------------
       for i = 1:bma.nsamp,
           [A,B,C]     = spm_dcm_reshape(theta(:,i),m,n,1);
           bma.a(:,:,i)   = A(:,:);
           bma.b(:,:,:,i) = B(:,:,:);
           bma.c(:,:,i)   = C(:,:);
       end
       
    else
        
        bma = [];
        
    end

    if exist(fullfile(job.dir{1},'BMS.mat'),'file')
        load(fname);
        if  isfield(BMS,'DCM') && isfield(BMS.DCM,'ffx')
            str = { 'Warning: existing BMS.mat file has been over-written!'};
            msgbox(str)
        end
    end
    BMS.DCM.ffx.data    = subj;
    BMS.DCM.ffx.F_fname = f_fname;
    BMS.DCM.ffx.F       = F;
    BMS.DCM.ffx.SF      = sumF;
    BMS.DCM.ffx.model   = model;
    BMS.DCM.ffx.family  = family;
    BMS.DCM.ffx.bma     = bma;
     
    save(fname,'BMS')
    out.files{1} = fname;
    
% 2nd-level (random effects) BMS
% -------------------------------------------------------------------------
else   
    
    disp(sprintf('Computing RFX model/family posteriors (using %s method)...', str_meth));
    if ~do_family
        if nm <= ns || strcmp(job.method,'RFX')
            [alpha,exp_r,xp] = spm_BMS(F, 1e6, 0);
            model.g_post     = exp_r;
        else
            [exp_r,xp,r_samp,g_post] = spm_BMS_gibbs(F);
            model.g_post             = g_post;
        end
        model.alpha = [];
        model.exp_r = exp_r;
        model.xp    = xp;
        family      = [];
    else
        
        Ffam           = F(:,m_indx);
        [family,model] = spm_compare_families(Ffam,family);
        
    end
    
    % display the result
    if do_family
        P = spm_api_bmc(sumF,N,model.exp_r,model.xp,family);
    else
        P = spm_api_bmc(sumF,N,model.exp_r,model.xp); 
    end
    
    if bma_do,  
        if do_family
            if do_bma_famwin
                [fam_max,fam_max_i]  = max(family.exp_r);
                bma.indx = find(family.partition==fam_max_i);
                bma.post  = model.g_post(:,bma.indx);
            else
                if do_bma_all  
                   bma.post = model.g_post;
                   bma.indx = 1:nm;
                else
                    if bma_fam <= nfam && bma_fam > 0 && rem(bma_fam,1) == 0 
                           bma.indx = find(family.partition==bma_fam);
                           bma.post = model.g_post(:,bma.indx);
                    else
                    error('Incorrect family for BMA!');
                    end         
                end
            end
        else
               bma.post  = model.g_post;
               bma.indx = 1:nm;
        end 
    
       disp('RFX Bayesian model averaging ...');
       % bayesian model averaging
       % ------------------------------------------------------------------
       
       [theta, Nocc] = spm_dcm_bma(bma.post,bma.indx,subj,bma.nsamp,bma.odds_ratio);
       bma.Nocc      = Nocc;
       
       % reshape parameters
       % ------------------------------------------------------------------
       for i = 1:bma.nsamp,
           [A,B,C]     = spm_dcm_reshape(theta(:,i),m,n,1);
           bma.a(:,:,i)   = A(:,:);
           bma.b(:,:,:,i) = B(:,:,:);
           bma.c(:,:,i)   = C(:,:);
       end

    else
        
        bma = [];
        
    end

    if exist(fullfile(job.dir{1},'BMS.mat'),'file')
        load(fname);
        if  isfield(BMS,'DCM') && isfield(BMS.DCM,'rfx')
            str = { 'Warning:  existing BMS.mat file has been over-written!'};
            msgbox(str)
        end
    end
    BMS.DCM.rfx.data    = subj;
    BMS.DCM.rfx.F_fname = f_fname;  
    BMS.DCM.rfx.F       = F;
    BMS.DCM.rfx.SF      = sumF;
    BMS.DCM.rfx.model   = model;
    BMS.DCM.rfx.family  = family;
    BMS.DCM.rfx.bma     = bma;
    
    save(fname,'BMS')
    out.files{1}= fname;
    
end

% Save model_space
% -------------------------------------------------------------------------
if ~ld_msp
    disp('Saving model space...')
    fname = [job.dir{1} 'model_space'];
    save(fname,'subj')
end

% Data verification
% -------------------------------------------------------------------------
if job.verify_id
    disp('Data identity has been verified');
else
    disp('Data identity has not been verified');
end

end

