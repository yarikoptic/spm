function DCM = spm_dcm_post_hoc(P,fun,varargin)
% Post hoc optimisation of DCMs (under the Laplace approximation)
% FORMAT DCM = spm_dcm_post_hoc(P,fun,field,field,...)
%
% P         - character/cell array of DCM filenames
%           - or cell array of DCM structures; where
%  DCM.M.pE - prior expectation (with parameters in pE.A, pE.B and pE.C)
%  DCM.M.pC - prior covariance
%  DCM.Ep   - posterior expectations
%  DCM.Cp   - posterior covariance
%
% Optional parameters:
%
% fun       - optional family definition function: k = fun(A,B,C)
%             k = 1,2,...,K for K families or proper subsets of a partition
%             of model space - a function of the adjacency matrices: e.g.,
%
%             fun = @(A,B,C) any(spm_vec(B(:,:,2))) + 1;
%
%             returns 1 if there are no bilinear parameters for the 2nd
%             bilinear effect and 2 if there are. fun should be an inline
%             function or script. NB: Model posteriors over families with
%             and without free parameters (in A,B,C and D) are evaluated
%             automatically and saved in DCM_BPA (DCM.Pp)
%
% field     - the field nsmes of the parameters in the structure pE and Ep 
%             that are to be inlcudied in Baysian model reduction.
%             The default is the cell array 'A','B','C'
%
% write_all - if true, saves all models from the final iteration of the
%             search (i.e. those models in the display) into a subfolder
%             named 'reduced' of the original model).
%
%--------------------------------------------------------------------------
% This routine searches over all possible reduced models of a full model
% (DCM) and uses post hoc model selection to select the best. Reduced
% models mean all permutations of free parameters (parameters with a non-
% zero prior covariance), where models are defined in terms of their prior
% covariance. The full model should be inverted prior to post hoc
% optimization. If there are more than 16 free-parameters, this routine
% will implement a greedy search: This entails searching over all
% permutations of the 8 parameters whose removal (shrinking the prior
% variance to zero) produces the smallest reduction (greatest increase)
% in model evidence. This procedure is repeated until all 8 parameters
% are retained in the best model or there are no more parameters to
% consider. When several DCMs are optimized together (as in group studies),
% they are checked to ensure the same free parameters have been specified
% and the log-evidences are pooled in a fixed effects fashion.
%
% This application of post hoc optimization assumes the DCMs that are
% optimized are the same model of different data. Normally, this would be
% a full model, in the sense of having the maximum number of free
% parameters, such that the set of reduced models is as large as possible.
% In contrast spm_dcm_search operates on different DCMs of the same data
% to identify the best model, after inverting the full(est) model
%
% The outputs of this routine are graphics reporting the model reduction
% (optimisation) and a DCM_opt_??? for every specified DCM that contains
% reduced conditional parameters estimates (for simplicity, the original
% kernels and predicted states are retained). The structural and functional
% (spectral embedding) graphs are based on Bayesian parameter averages
% over multiple DCMs, which are stored in DCM_BPA.mat. This DCM also
% contains the posterior probability of models partitioned according to
% whether a particular parameter exists or not:
%
% DCM.Pp     -  Model posterior (with and without each parameter)
% DCM.Ep     -  Bayesian parameter average under selected model
% DCM.Cp     -  Bayesian parameter covariance under selected model
% DCM.Pf     -  Model posteriors over user specified families
% DCM.fun    -  User-specified family definition function
% DCM.files  -  List of DCM files used for Bayesian averaging

% See alos: spm_dcm_search.m
%
%__________________________________________________________________________
% Copyright (C) 2010-2012 Wellcome Trust Centre for Neuroimaging

% Karl Friston, Peter Zeidman
% $Id: spm_dcm_post_hoc.m 6149 2014-09-03 16:20:28Z peter $


% number of parameters to consider before invoking greedy search
%--------------------------------------------------------------------------
nmax = 8;

% Get filenames
%--------------------------------------------------------------------------
if nargin < 1
    [P, sts] = spm_select([1 Inf],'^DCM.*\.mat$','Select DCM*.mat files');
    if ~sts, return; end
end

if ischar(P),   P = cellstr(P); end
if isstruct(P), P = {P};        end
N   = numel(P);
TOL = exp(-16);

% Check family definition functions
%--------------------------------------------------------------------------
if nargin < 2; fun = {}; end

% Check fields of parameter stucture
%--------------------------------------------------------------------------
if nargin < 3 || isempty(varargin{1})
    field = {'A','B','C'};
else
    field = varargin{1};
end

% Check whether to write all models
%--------------------------------------------------------------------------
if nargin < 4
    write_all = 0;
else
    write_all = logical(varargin{2});
end
    
% Run post-hoc DCM
%--------------------------------------------------------------------------

% Check models are compatible in terms of their prior variances
[example_DCM,C] = check_models();

% Greedy search (GS) - eliminating parameters in a top down fashion
[C,model_space] = greedy_search(C,example_DCM);

% Inference over families
[Pk, Pf] = family_inference(example_DCM,C,model_space,fun);

% Calculate reduced models and BPA
BPA = compute_post_hoc(example_DCM,C);

% Show full and reduced conditional estimates (for Bayesian average)
create_plots(example_DCM,BPA,Pk,Pf,fun);

% Save Bayesian Parameter Average and family-wise model inference
save_bpa_dcm(Pk,BPA,fun,Pf);

% =========================================================================
function [example_DCM,C] = check_models()
    % Check models are compatible in terms of their prior variances
    %
    % example_DCM - an example model    
    % C           - binarized prior variance vector of an example model    
    
    for j = 1:N
        % Get prior covariances
        %------------------------------------------------------------------
        try, DCM=load(P{j}); DCM=DCM.DCM; catch, DCM = P{j}; end
        try, pC = diag(DCM.M.pC); catch, pC  = spm_vec(DCM.M.pC); end

        % and compare it with the first model
        %------------------------------------------------------------------
        if j == 1
            C = pC;
        else
            if any(xor(pC,C))
                error('Please check model %i for compatibility.\n',j)
            end
        end
    end

    example_DCM = DCM;
    
    C = logical(C);
end

% =========================================================================
function [C,model_space] = greedy_search(C,DCM)
    % Perform a greedy search to reduce the number of free parameters in C
    %
    % A model space is created, K, each row indicates which free 
    % parameters to disable. (If there are more than nmax free 
    % parameters, K will just include combinations of the 8 parameters 
    % which contribute the least, and the whole process will repeat). 
    %
    % C   - binary vector indicating which parameters are free (have 
    %       non-zero prior variance)
    % DCM - example model to be reduced
    %
    % C             - updated binary vector of all parameters (1=free)
    % model_space.k - indices of free parameters to keep
    % model_space.K - model space (most recent iteration). 1=disabled parameter  
    % model_space.p - pooled model evidence (posterior probabilities)
   
    GS = 1;
    while GS

        % Find free coupling parameters
        %------------------------------------------------------------------
        k = spm_fieldindices(DCM.Ep,field{:});
        k = k(C(k));
        nparam = length(k);

        % If there are too many params find those with the least evidence
        %------------------------------------------------------------------
        if nparam > nmax            
            k = identify_parameters_with_least_evidence(k,C);
            
            % Flag a greedy search
            GS = 1;
        elseif isempty(k)
            error('There are no free parameters in this model');
        else
            GS = 0;
        end

        % Evaluate the model space
        %------------------------------------------------------------------
        [C,nelim,model_space] = evaluate_model_space(C,k);
                
        % Continue greedy search if any parameters have been eliminated
        %------------------------------------------------------------------        
        GS     = GS & nelim;
        
        % Show results
        % -----------------------------------------------------------------
        spm_figure('Getwin','Graphics'); clf    
        fprintf('%i out of %i free parameters removed \n',nelim,nparam)

        subplot(3,2,1)
        if length(model_space.K) > 32, plot(model_space.S,'k'),...
        else, bar(model_space.S,'c'), end
        title('log-posterior','FontSize',16)
        xlabel('model','FontSize',12)
        ylabel('log-probability','FontSize',12)
        axis square

        subplot(3,2,2)
        if length(model_space.K) > 32, plot(model_space.p,'k'),...
        else, bar(model_space.p,'r'), end
        title('model posterior','FontSize',16)
        xlabel('model','FontSize',12)
        ylabel('probability','FontSize',12)
        axis square
        drawnow

    end
end

% =========================================================================
function [C,nelim,model_space] = evaluate_model_space(C,k)
    % Evaluate all possible models, each with different permutations of
    % parameters (specified in k) eliminated. Return updated C with
    % the least successful parameters pruned, plus statistics on the model 
    % space.
    %
    % C - binary vector of all parameters (1=free)
    % k - indices of free parameters to try disabling
    %
    % C              - updated parameter vector (1=free)
    % nelim          - number of parameters eliminated
    % model_space.K  - the model space (permutations x parameters in k)
    % model_space.k  - indices of free parameters (as provided)
    % model_space.S  - log-posterior probability of each parameter
    % model_space.p  - posterior probability of each parameter   
    
    % Create model space in terms of free parameter indices
    %------------------------------------------------------------------
    K     = spm_perm_mtx(length(k));

    %-Loop through DCMs and models and get log-evidences
    %------------------------------------------------------------------
    G     = [];
    for j = 1:N

        try, DCM=load(P{j}); DCM=DCM.DCM; catch, DCM = P{j}; end
        if isstruct(DCM.M.pC), DCM.M.pC = diag(spm_vec(DCM.M.pC)); end
        fprintf('\nsearching (%i): 00%%',j)

        % Get priors and posteriors
        %--------------------------------------------------------------
        qE    = DCM.Ep;
        qC    = DCM.Cp;
        pE    = DCM.M.pE;
        pC    = DCM.M.pC;

        % Remove (a priori) null space
        %--------------------------------------------------------------
        U     = spm_svd(pC);
        qE    = U'*spm_vec(qE);
        pE    = U'*spm_vec(pE);
        qC    = U'*qC*U;
        pC    = U'*pC*U;

        % Model search over new prior (covariance)
        %--------------------------------------------------------------
        for i = 1:length(K)
            
            r      = C; r(k(K(i,:))) = 0;                       
            R      = U(r,:)'*U(r,:);
            G(i,j) = spm_log_evidence(qE,qC,pE,pC,pE,R*pC*R);
            
            if write_all
                write_reduced_model(r,i,DCM,P{j});
            end            

            fprintf('\b\b\b\b')
            fprintf('%-3.0f%%',i*100/length(K))
        end
    end
    fprintf('\n')

    % Pooled model evidence
    %------------------------------------------------------------------
    S     = sum(G,2);
    S     = S - S(end);
    p     = exp(S - max(S));
    p     = p/sum(p);

    % Prune parameters (row of K) which gave the largest increase in 
    % evidence when removed
    % -----------------------------------------------------------------
    [unused, i]  = max(p);
    C(k(K(i,:))) = 0;
    
    % Number of eliminated parameters
    nelim  = full(sum(K(i,:)));
    
    % Results to return
    model_space = struct('K',K, 'k',k, 'S',S, 'p',p);
end

% =========================================================================
function k = identify_parameters_with_least_evidence(k,C)    
    % Identify the 8 parameters with the least evidence
    %
    % k - Indices of free parameters
    %
    % k - Updated indices of free parameters (with least evidence)
    % C - Binary vector of all parameters (1=free)
    
    % Loop through DCMs and free parameters and get log-evidences
    %--------------------------------------------------------------
    Z     = [];
    for j = 1:N

        try, DCM=load(P{j}); DCM=DCM.DCM; catch, DCM = P{j}; end
        if isstruct(DCM.M.pC), DCM.M.pC = diag(spm_vec(DCM.M.pC)); end

        fprintf('\ninitial search (%i): 00%%',j)

        % Get priors and posteriors
        %----------------------------------------------------------
        qE    = DCM.Ep;
        qC    = DCM.Cp;
        pE    = DCM.M.pE;
        pC    = DCM.M.pC;

        % Remove (a priori) null space
        %----------------------------------------------------------
        U     = spm_svd(pC);
        qE    = U'*spm_vec(qE);
        pE    = U'*spm_vec(pE);
        qC    = U'*qC*U;
        pC    = U'*pC*U;

        % Model search over new prior without the i-th parameter
        %----------------------------------------------------------
        for i = 1:length(k)
            r      = C; r(k(i)) = 0;
            R      = U(r,:)'*U(r,:);
            Z(i,j) = spm_log_evidence(qE,qC,pE,pC,pE,R*pC*R);

            fprintf('\b\b\b\b')
            fprintf('%-3.0f%%',i*100/length(k))
        end
    end

    % Find parameters with the least evidence
    %--------------------------------------------------------------
    Z          = sum(Z,2);
    [unused,i] = sort(-Z);
    k          = k(i(1:8));
end

% =========================================================================
function [Pk, Pf] = family_inference(DCM,C,model_space,fun)
    % Perform family level inference
    %
    % DCM             - example DCM structure
    % C               - binary vector of all free parameters
    % model_space.K   - model space
    % model_space.k   - vector of free parameter indices
    % model_space.p   - posterior probabiliy of all models      
    % fun             - family function
    %
    % Pk  - posterior probability of each parameter
    % Pf  - posterior probability of each family
    
    pE    = DCM.M.pE;

    %-Inference over families (one family per coupling parameter)
    %----------------------------------------------------------------------
    for i = 1:length(model_space.k)
        Pk(1,i) = mean(model_space.p(~model_space.K(:,i)));
        Pk(2,i) = mean(model_space.p( model_space.K(:,i)));
    end
    Pk    = Pk(1,:)./sum(Pk);
    Pn    = full(double(C));    
    Pn(model_space.k) = Pk;
    Pk    = spm_unvec(Pn,pE);

    %-Inference over families (specified by fun)
    %----------------------------------------------------------------------
    if isempty(fun)
        Pf = 0;
    else
        for i = 1:length(model_space.K)
            Pn     = full(double(C));
            Pn(model_space.K(i,:)) = 0;
            Pn     = spm_unvec(Pn,pE);
            try
                Kf(i)     = fun(Pn.A,Pn.B,Pn.C);
            catch
                try
                    Kf(i) = fun(Pn.A,Pn.B);
                catch
                    Kf(i) = fun(Pn.A);
                end
            end

        end
        for i = 1:max(Kf)
            Pf(i) = mean(model_space.p(Kf == i));
        end
        Pf(isnan(Pf)) = 0;
        Pf    = Pf/sum(Pf);
    end
end

% =========================================================================
function BPA = compute_post_hoc(DCM,C)
    % For each model, creates reduced model (DCM_opt*.mat) and collates
    % data for bayesian parameter average (CQ,Cq,EQ,Eq).
    %
    % DCM - template DCM structure
    % C   - binary vector of parameters
    %
    % BPA.CQ  - BPA covariances (full model)
    % BPA.Cq  - BPA covariances (reduced model)
    % BPA.EQ  - BPA means (full model)
    % BPA.Eq  - BPA means (reduced model)    
            
    % Selected model (reduced prior covariance);
    %----------------------------------------------------------------------
    pC      = DCM.M.pC;
    rC      = diag(C)*pC*diag(C);

    R = spm_unvec(full(C),DCM.M.pE);
    
    try
        R.a = DCM.a & R.A;
        R.b = DCM.b & R.B;
        R.c = DCM.c & R.C;
        R.d = DCM.d & R.D;
    end

    EQ      = 0;
    PQ      = 0;
    Eq      = 0;
    Pq      = 0;
    
    for j = 1:N

        % Get priors and posteriors
        %------------------------------------------------------------------
        try, DCM=load(P{j}); DCM=DCM.DCM; catch, DCM = P{j}; end

        qE  = DCM.Ep;
        qC  = DCM.Cp;
        pE  = DCM.M.pE;
        pC  = DCM.M.pC;

        % Get posterior of selected model - rC
        %------------------------------------------------------------------
        [F,Ep,Cp] = spm_log_evidence_reduce(qE,qC,pE,pC,pE,rC);

        % Bayesian parameter average (for full and reduced selected model)
        %------------------------------------------------------------------
        PP  = spm_inv(qC,TOL);
        Pp  = spm_inv(Cp,TOL);
        EQ  = EQ + PP*spm_vec(qE);      % BPA means (full model)
        Eq  = Eq + Pp*spm_vec(Ep);      % BPA means (reduced model)
        PQ  = PQ + PP;                  % BPA precisions (full model)
        Pq  = Pq + Pp;                  % BPA precisions (reduced model)

        %-Put reduced conditional estimates in DCM
        %------------------------------------------------------------------

        % Bayesian inference and variance
        try
            T = full(spm_vec(pE)) + DCM.T;
        catch
            T = full(spm_vec(pE));
        end
        sw   = warning('off','SPM:negativeVariance');
        Pp   = spm_unvec(1 - spm_Ncdf(T,abs(spm_vec(Ep)),diag(Cp)),Ep);
        Vp   = spm_unvec(diag(Cp),Ep);
        warning(sw);

        % Store parameter estimates
        DCM.M.pC    = rC;
        DCM.Ep      = Ep;
        DCM.Cp      = Cp;
        DCM.Pp      = Pp;
        DCM.Vp      = Vp;

        % and in DEM format
        DCM.qP.P{1} = Ep;
        DCM.qP.C    = Cp;
        DCM.qP.V{1} = spm_unvec(diag(Cp),Ep);

        % and in prior constraints fields
        try
            DCM.a   = R.a;
            DCM.b   = R.b;
            DCM.c   = R.c;
            DCM.d   = R.d;
        end  

        % approximations to model evidence: negative free energy, AIC, BIC
        DCM.F    = F;
        try
            evidence = spm_dcm_evidence(DCM);
            DCM.AIC  = evidence.aic_overall;
            DCM.BIC  = evidence.bic_overall;
        end

        %-Save optimised DCM
        %------------------------------------------------------------------
        try
            [pth, name] = fileparts(P{j});
            if ~strncmp(name,'DCM_opt_',8)
                name = ['DCM_opt_' name(5:end) '.mat'];
            end
            P{j} = fullfile(pth,name);
        catch
            P{j} = fullfile(pwd,['DCM_opt_' date '.mat']);
        end
        save(P{j},'DCM','F','Ep','Cp', spm_get_defaults('mat.format'));

    end

    %-Calculate bayesian parameter average
    %----------------------------------------------------------------------
    if isstruct(pC), pC = diag(spm_vec(pC)); end

    ipC = spm_inv(pC);                         % prior precision (full)
    irC = spm_inv(rC);                         % prior precision (reduced)
    CQ  = spm_inv(PQ + (1 - N)*ipC,TOL);       % post covariance (full)
    Cq  = spm_inv(Pq + (1 - N)*irC,TOL);       % post covariance (reduced)
    EQ  = CQ*(EQ - (N - 1)*ipC*spm_vec(pE));   % post mean (full)
    Eq  = Cq*(Eq - (N - 1)*irC*spm_vec(pE));   % post mean (reduced)
    EQ  = spm_unvec(EQ,pE);
    Eq  = spm_unvec(Eq,pE);
    
    % Pack BPA results to return
    %----------------------------------------------------------------------
    BPA.CQ = CQ; BPA.Cq = Cq; 
    BPA.EQ = EQ; BPA.Eq = Eq;
end

% =========================================================================
function create_plots(DCM,BPA,Pk,Pf,fun)
    % Plot results
    %
    % DCM     - template DCM structure
    % BPA.CQ  - BPA posterior covariance (full)
    % BPA.Cq  - BPA posterior covariance (reduced)
    % BPA.EQ  - BPA posterior mean (full)
    % BPA.Eq  - BPA posterior mean (reduced)
    % Pk      - Posterior probability of each parameter
    % Pf      - Posterior probability of each family   
    % fun     - Family function

    pE = DCM.M.pE;
        
    i   = spm_fieldindices(DCM.Ep,'A','B','C');
    pE  = spm_vec(pE);
    EP  = spm_vec(BPA.EQ);
    Ep  = spm_vec(BPA.Eq);
    
    % Plot summary of results
    % ---------------------------------------------------------------------    
    spm_figure('Getwin','Graphics');
    
    subplot(3,2,3)
    spm_plot_ci(EP(i),BPA.CQ(i,i))
    title('MAP connections (full)','FontSize',16)
    axis square
    a   = axis;

    subplot(3,2,4)
    spm_plot_ci(Ep(i),abs(BPA.Cq(i,i)))
    title('MAP connections (reduced)','FontSize',16)
    axis square
    axis(a)

    subplot(3,2,5)
    bar(EP(i) - pE(i))
    xlabel('parameter')
    title('MAP minus prior','FontSize',16)
    spm_axis tight
    axis square

    subplot(3,2,6)
    bar(Ep(i) - EP(i))
    xlabel('parameter')
    title('differences in MAP','FontSize',16)
    spm_axis tight
    axis square
    drawnow

    % Show structural and functional graphs
    %----------------------------------------------------------------------
    if ~nargout
        spm_figure('Getwin','Graph analysis'); clf
        try
            spm_dcm_graph(DCM.xY,BPA.Eq.A);
        catch
            try
                spm_dcm_graph(DCM,BPA.Eq.A);
            end
        end
    end


    % Show coupling matrices
    %----------------------------------------------------------------------
    if ~nargout && numel(field) == 3;

        spm_figure('Getwin','Bayesian parameter average (selected model)'); clf
        spm_dcm_fmri_image(BPA.Eq)

        spm_figure('Getwin','Model posterior (over parameters)'); clf
        spm_dcm_fmri_image(Pk)

    end

    % illustrate family-wise inference
    %----------------------------------------------------------------------
    if ~isempty(fun) && ~nargout

        spm_figure('Getwin','Model posterior (over families)'); clf
        subplot(2,1,1)
        bar(Pf)
        xlabel('familiy')
        title('Model posterior (over families)','FontSize',16)
        axis square
    end
end

% =========================================================================
function save_bpa_dcm(Pk,BPA,fun,Pf)
    % Save the Bayesian Parameter Average
    %
    % Pk     - Posterior probability of each parameter
    % BPA.Cq - BPA covariances (reduced model)
    % BPA.Eq - BPA means (reduced model)
    % fun    - Family function
    % Pf     - Model posteriors over user specified families
    
    % Get original (first) DCM
    try, DCM=load(P{1}); DCM=DCM.DCM; catch, DCM = P{1}; end

    DCM.Pp    = Pk;    
    DCM.Ep    = BPA.Eq;
    DCM.Cp    = BPA.Cq;
    DCM.fun   = fun;   
    DCM.files = P;     
    DCM.Pf    = Pf;    

    % and save as DCM_BPA
    try
        pth  = fileparts(P{1});
        name = 'DCM_BPA.mat';
        name = fullfile(pth,name);
    catch
        name = fullfile(pwd,'DCM_BPA.mat');
    end

    save(name,'DCM', spm_get_defaults('mat.format'));
        
end

% =========================================================================
function write_reduced_model(C,i,DCM,filename)
    % Create and saves a DCM file for a reduced model
    %
    % C        - reduced variance vector    
    % DCM      - model
    % i        - model index
    % filename - original filename of the model
    
    R = spm_unvec(full(C),DCM.M.pE);
    
    try
        R.a = DCM.a & R.A;
        R.b = DCM.b & R.B;
        R.c = DCM.c & R.C;
        R.d = DCM.d & R.D;
    end    
    
    % Get priors and posteriors
    %------------------------------------------------------------------
    qE  = DCM.Ep;
    qC  = DCM.Cp;
    pE  = DCM.M.pE;
    pC  = DCM.M.pC;

    rC = diag(C)*pC*diag(C);    

    % Get posterior of selected model - rC
    %------------------------------------------------------------------
    [F,Ep,Cp] = spm_log_evidence_reduce(qE,qC,pE,pC,pE,rC);
   
    % Put reduced conditional estimates in DCM
    %------------------------------------------------------------------

    % Bayesian inference and variance
    try
        T = full(spm_vec(pE)) + DCM.T;
    catch
        T = full(spm_vec(pE));
    end
    sw   = warning('off','SPM:negativeVariance');
    Pp   = spm_unvec(1 - spm_Ncdf(T,abs(spm_vec(Ep)),diag(Cp)),Ep);
    Vp   = spm_unvec(diag(Cp),Ep);
    warning(sw);

    % Store parameter estimates
    DCM.M.pC    = rC;
    DCM.Ep      = Ep;
    DCM.Cp      = Cp;
    DCM.Pp      = Pp;
    DCM.Vp      = Vp;

    % and in DEM format
    DCM.qP.P{1} = Ep;
    DCM.qP.C    = Cp;
    DCM.qP.V{1} = spm_unvec(diag(Cp),Ep);

    % and in prior constraints fields
    try
        DCM.a   = R.a;
        DCM.b   = R.b;
        DCM.c   = R.c;
        DCM.d   = R.d;
    end  

    % approximations to model evidence: negative free energy, AIC, BIC
    DCM.F    = F;
    try
        evidence = spm_dcm_evidence(DCM);
        DCM.AIC  = evidence.aic_overall;
        DCM.BIC  = evidence.bic_overall;
    end
    
    % and save as DCM_reduced_*    
    try
        [pth,name] = fileparts(filename);
        pth = fullfile(pth,'reduced');
        if ~exist(pth,'file')
            mkdir(pth);
        end
        name = sprintf('%s_reduced_%i.mat',name,i);
        name = fullfile(pth,name);
    catch
        name = sprintf('DCM_reduced_%i.mat',i);
    end
    save(name,'DCM', spm_get_defaults('mat.format'));            
end

end