function [MDP] = spm_MDP_VB_X(MDP,OPTIONS)
% active inference and learning using variational message passing
% FORMAT [MDP] = spm_MDP_VB_X(MDP,OPTIONS)
%
% Input; MDP(m,n)       - structure array of m models over n epochs
%
% MDP.V(T - 1,P,F)      - P allowable policies (T - 1 moves) over F factors
% or
% MDP.U(1,P,F)          - P allowable actions at each move
% MDP.T                 - number of outcomes
%
% MDP.A{G}(O,N1,...,NF) - likelihood of O outcomes given hidden states
% MDP.B{F}(NF,NF,MF)    - transitions among states under MF control states
% MDP.C{G}(O,T)         - prior preferences over O outcomes in modality G
% MDP.D{F}(NF,1)        - prior probabilities over initial states
% MDP.E(P,1)            - prior probabilities over policies
%
% MDP.a{G}              - concentration parameters for A
% MDP.b{F}              - concentration parameters for B
% MDP.c{G}              - concentration parameters for C
% MDP.d{F}              - concentration parameters for D
% MDP.e                 - concentration parameters for E
%
% optional:
% MDP.s(F,T)            - matrix of true states - for each hidden factor
% MDP.o(G,T)            - matrix of outcomes    - for each outcome modality
% or .O{G}(O,T)         - likelihood matrix of  - for each outcome modality
% MDP.u(F,T - 1)        - vector of actions     - for each hidden factor
%
% MDP.alpha             - precision � action selection [16]
% MDP.beta              - precision over precision (Gamma hyperprior - [1])
% MDP.tau               - time constant for gradient descent [4]
% MDP.eta               - learning rate for model parameters
%
% MDP.demi.C            - Mixed model: cell array of true causes (DEM.C)
% MDP.demi.U            - Bayesian model average (DEM.U) see: spm_MDP_DEM
% MDP.link              - link array to generate outcomes from
%                         subordinate MDP; for deep (hierarchical) models
%
% OPTIONS.plot          - switch to suppress graphics:  (default: [0])
% OPTIONS.gamma         - switch to suppress precision: (default: [0])
% OPTIONS.D             - switch to update initial states over epochs
% OPTIONS.BMR           - Bayesian model reduction for multiple trials
%                         see: spm_MDP_VB_sleep(MDP,BMR)
% Outputs:
%
% MDP.P(M1,...,MF,T)    - probability of emitting action M1,.. over time
% MDP.Q{F}(NF,T,P)      - expected hidden states under each policy
% MDP.X{F}(NF,T)        - and Bayesian model averages over policies
% MDP.R(P,T)            - conditional expectations over policies
%
% MDP.un          - simulated neuronal encoding of hidden states
% MDP.vn          - simulated neuronal prediction error
% MDP.xn          - simulated neuronal encoding of policies
% MDP.wn          - simulated neuronal encoding of precision (tonic)
% MDP.dn          - simulated dopamine responses (phasic)
% MDP.rt          - simulated reaction times
%
% MDP.F           - (P x T) (negative) free energies over time
% MDP.G           - (P x T) (negative) expected free energies over time
% MDP.H           - (1 x T) (negative) total free energy over time
% MDP.Fa          - (1 x 1) (negative) free energy of parameters (a)
% MDP.Fb          - ...
%
% This routine provides solutions of active inference (minimisation of
% variational free energy) using a generative model based upon a Markov
% decision process(or a hidden Markov model, in the absence of action). The
% model and inference scheme is formulated in discrete space and time. This
% means that the generative model (and process) are  finite state machines
% or hidden Markov models whose dynamics are given by transition
% probabilities among states and the likelihood corresponds to a particular
% outcome conditioned upon hidden states.
%
% When supplied with outcomes (in terms of their likelihood (O) in the
% absence of any policy specification, this scheme will use variational
% message passing to optimise expectations about latent or hidden states
% (and likelihood (A) and prior (B) probabilities). In other words, it will
% invert a hidden Markov model. When  called with policies, it will
% generate outcomes that are used to infer optimal policies for active
% inference.
%
% This implementation equips agents with the prior beliefs that they will
% maximise expected free energy: expected free energy is the free energy
% of future outcomes under the posterior predictive distribution. This can
% be interpreted in several ways � most intuitively as minimising the KL
% divergence between predicted and preferred outcomes (specified as prior
% beliefs) � while simultaneously minimising ambiguity.
%
% This particular scheme is designed for any allowable policies or control
% sequences specified in MDP.V. Constraints on allowable policies can limit
% the numerics or combinatorics considerably. Further, the outcome space
% and hidden states can be defined in terms of factors; corresponding to
% sensory modalities and (functionally) segregated representations,
% respectively. This means, for each factor or subset of hidden states
% there are corresponding control states that determine the transition
% probabilities.
%
% This specification simplifies the generative model, allowing a fairly
% exhaustive model of potential outcomes. In brief, the agent encodes
% beliefs about hidden states in the past (and in the future) conditioned
% on each policy. The conditional expectations determine the (path
% integral) of free energy that then determines the prior over policies.
% This prior is used to create a predictive distribution over outcomes,
% which specifies the next action.
%
% In addition to state estimation and policy selection, the scheme also
% updates model parameters; including the state transition matrices,
% mapping to outcomes and the initial state. This is useful for learning
% the context. Likelihood and prior probabilities can be specified in terms
% of concentration parameters (of a Dirichlet distribution (a,b,c,..). If
% the corresponding (A,B,C,..) are supplied  they will be used to generate
% outcomes; unless called without policies (in hidden Markov model mode).
% In this case, the (A,B,C,..) are treated as posterior estimates.
%
% If supplied with a structur array, this routine will automatically step
% through the implicit sequence of epochs (implicit in the number of
% columns of the array). if the array has multiple rows, each row will be
% created as a separate model or agent. This enables agents to communicate
% through acting upon a common set of hidden factors, or indeed sharing the
% same outcomes.
%
% See also: spm_MDP, which uses multiple future states and a mean field
% approximation for control states � but allows for different actions
% at all times (as in control problems).
%
% See also: spm_MDP_game_KL, which uses a very similar formulation but just
% maximises the KL divergence between the posterior predictive distribution
% over hidden states and those specified by preferences or prior beliefs.
%__________________________________________________________________________
% Copyright (C) 2005 Wellcome Trust Centre for Neuroimaging

% Karl Friston
% $Id: spm_MDP_VB_X.m 7311 2018-05-13 21:15:07Z karl $


% deal with a sequence of trials
%==========================================================================

% options
%--------------------------------------------------------------------------
try, OPTIONS.plot;  catch, OPTIONS.plot  = 0; end
try, OPTIONS.gamma; catch, OPTIONS.gamma = 0; end
try, OPTIONS.D;     catch, OPTIONS.D     = 0; end

% if there are multiple trials ensure that parameters are updated
%--------------------------------------------------------------------------
if size(MDP,2) > 1
    
    % plotting options
    %--------------------------------------------------------------
    GRAPH        = OPTIONS.plot;
    OPTIONS.plot = 0;
    
    for i = 1:size(MDP,2)
        for m = 1:size(MDP,1)
            
            % update concentration parameters
            %--------------------------------------------------------------
            if i > 1
                try,  MDP(m,i).a = OUT(m,i - 1).a; end
                try,  MDP(m,i).b = OUT(m,i - 1).b; end
                try,  MDP(m,i).d = OUT(m,i - 1).d; end
                try,  MDP(m,i).c = OUT(m,i - 1).c; end
                try,  MDP(m,i).e = OUT(m,i - 1).e; end
                
                % update initial states (post-diction)
                %----------------------------------------------------------
                if OPTIONS.D
                    for f = 1:numel(MDP(m,i).D)
                        MDP(m,i).D{f} = OUT(m,i - 1).X{f}(:,1);
                    end
                end
            end
        end
        
        % solve this trial
        %------------------------------------------------------------------
        OUT(:,i) = spm_MDP_VB_X(MDP(:,i),OPTIONS);
        
        % Bayesian model reduction
        %------------------------------------------------------------------
        if isfield(OPTIONS,'BMR')
            for m = 1:size(MDP,1)
                OUT(m,i) = spm_MDP_VB_sleep(OUT(m,i),OPTIONS.BMR);
            end
        end
        
    end
    
    % plot summary statistics - over trials
    %----------------------------------------------------------------------
    MDP = OUT;
    if GRAPH
        if ishandle(GRAPH)
            figure(GRAPH); clf
        else
            spm_figure('GetWin','MDP'); clf
        end
        spm_MDP_VB_game(MDP(1,:))
    end
    return
end


% set up and preliminaries
%==========================================================================
for m = 1:size(MDP,1)
    
    if isfield(MDP,'U')
        
        % called with repeatable actions (U,T)
        %------------------------------------------------------------------
        T(m) = MDP(m).T;                    % number of updates
        V{m} = MDP(m).U;                    % allowable actions (1,Np)
        HMM  = 0;
        
    elseif isfield(MDP,'V')
        
        % full sequential policies (V)
        %------------------------------------------------------------------
        V{m} = MDP(m).V;                    % allowable policies (T - 1,Np)
        T(m) = size(MDP(m).V,1) + 1;        % number of transitions
        HMM  = 0;
        
    elseif isfield(MDP,'O')
        
        % no policies � assume hidden Markov model (HMM)
        %------------------------------------------------------------------
        T(m) = size(MDP.O{1},2);            % HMM mode
        V{m} = ones(T - 1,1);               % single 'policy'
        HMM  = 1;
    else
        sprintf('Please specify MDP(%d).U, MDP(%i).V or MDP(%d).O',m), return
    end
    
end

% precision defaults
%--------------------------------------------------------------------------
try, alpha = MDP(1).alpha; catch, alpha = 128;  end
try, beta  = MDP(1).beta;  catch, beta  = 1;    end
try, zeta  = MDP(1).zeta;  catch, zeta  = 8;    end
try, eta   = MDP(1).eta;   catch, eta   = 1;    end
try, tau   = MDP(1).tau;   catch, tau   = 4;    end
try, chi   = MDP(1).chi;   catch, chi   = 1/64; end

T     = T(1);
for m = 1:size(MDP,1)
    
    % ensure policy length is less than the number of updates
    %----------------------------------------------------------------------
    if size(V{m},1) > (T - 1)
        V{m} = V{m}(1:(T - 1),:,:);
    end
    
    % fill in (posterior or  process) likelihood and priors
    %----------------------------------------------------------------------
    if ~isfield(MDP(m),'A'), MDP(m).A = MDP(m).a; end
    if ~isfield(MDP(m),'B'), MDP(m).B = MDP(m).b; end
    
    % check format of likelihood and priors
    %----------------------------------------------------------------------
    if ~iscell(MDP(m).A), MDP(m).A = {full(MDP(m).A)}; end
    if ~iscell(MDP(m).B), MDP(m).B = {full(MDP(m).B)}; end
    
    if isfield(MDP(m),'a'), if ~iscell(MDP(m).a), MDP(m).a = {full(MDP(m).a)}; end; end
    if isfield(MDP(m),'b'), if ~iscell(MDP(m).b), MDP(m).b = {full(MDP(m).b)}; end; end
    
    % numbers of transitions, policies and states
    %----------------------------------------------------------------------
    Ng(m) = numel(MDP(m).A);               % number of outcome factors
    Nf(m) = numel(MDP(m).B);               % number of hidden state factors
    Np(m) = size(V{m},2);                  % number of allowable policies
    for f = 1:Nf(m)
        Ns(m,f) = size(MDP(m).B{f},1);     % number of hidden states
        Nu(m,f) = size(MDP(m).B{f},3);     % number of hidden controls
    end
    for g = 1:Ng(m)
        No(m,g) = size(MDP(m).A{g},1);     % number of outcomes
    end
    
    % parameters of generative model and policies
    %======================================================================
    
    % likelihood model (for a partially observed MDP)
    %----------------------------------------------------------------------
    for g = 1:Ng(m)
        
        % ensure probabilities are normalised  : A
        %------------------------------------------------------------------
        MDP(m).A{g} = spm_norm(MDP(m).A{g});
        
        % parameters (concentration parameters): a
        %------------------------------------------------------------------
        if isfield(MDP,'a')
            A{m,g}  = spm_norm(MDP(m).a{g});
        else
            A{m,g}  = spm_norm(MDP(m).A{g});
        end
        
        % (polygamma) function for complexity (and novelty)
        %------------------------------------------------------------------
        if isfield(MDP,'a')
            qA{m,g} = spm_psi(MDP(m).a{g} + 1/16);
            pA{m,g} = MDP(m).a{g};
            wA{m,g} = spm_wnorm(MDP(m).a{g} + exp(-16));
            wA{m,g} = wA{m,g}.*(MDP(m).a{g} > 0);
        end
        
    end
    
    % transition probabilities (priors)
    %----------------------------------------------------------------------
    for f = 1:Nf(m)
        for j = 1:Nu(m,f)
            
            % controlable transition probabilities : B
            %--------------------------------------------------------------
            MDP(m).B{f}(:,:,j) = spm_norm(MDP(m).B{f}(:,:,j));
            
            % parameters (concentration parameters): b
            %--------------------------------------------------------------
            if isfield(MDP,'b') && ~HMM
                sB{m,f}(:,:,j) = spm_norm(MDP(m).b{f}(:,:,j) );
                rB{m,f}(:,:,j) = spm_norm(MDP(m).b{f}(:,:,j)');
            else
                sB{m,f}(:,:,j) = spm_norm(MDP(m).B{f}(:,:,j) );
                rB{m,f}(:,:,j) = spm_norm(MDP(m).B{f}(:,:,j)');
            end
            
        end
        
        % (polygamma) function for complexity
        %------------------------------------------------------------------
        if isfield(MDP,'b')
            qB{m,f} = spm_psi(MDP(m).b{f} + 1/16);
            pB{m,f} = MDP(m).b{f};
        end
        
    end
    
    
    % priors over initial hidden states - concentration parameters
    %----------------------------------------------------------------------
    for f = 1:Nf(m)
        if isfield(MDP,'d')
            D{m,f} = spm_norm(MDP(m).d{f});
        elseif isfield(MDP,'D')
            D{m,f} = spm_norm(MDP(m).D{f});
        else
            D{m,f} = spm_norm(ones(Ns(m,f),1));
            MDP(m).D{f} = D{m,f};
        end
        
        % (polygamma) function for complexity
        %------------------------------------------------------------------
        if isfield(MDP,'d')
            qD{m,f} = spm_psi(MDP(m).d{f} + 1/16);
            pD{m,f} = MDP(m).d{f};
        end
    end
    
    % priors over policies - concentration parameters
    %----------------------------------------------------------------------
    if isfield(MDP,'e')
        E{m} = spm_norm(MDP(m).e);
    elseif isfield(MDP,'E')
        E{m} = spm_norm(MDP(m).E);
    else
        E{m} = spm_norm(ones(Np(m),1));
    end
    
    % (polygamma) function for complexity
    %----------------------------------------------------------------------
    if isfield(MDP,'e')
        qE{m} = spm_psi(MDP(m).e + 1/16);
        pE{m} = MDP(m).e;
    else
        qE{m} = spm_log(E{m});
    end
    
    % prior preferences (log probabilities) : C
    %----------------------------------------------------------------------
    for g = 1:Ng(m)
        if isfield(MDP,'c')
            C{m,g}  = spm_psi(MDP(m).c{g} + 1/16);
            pC{m,g} = MDP(m).c{g};
        elseif isfield(MDP,'C')
            C{m,g}  = MDP(m).C{g};
        else
            C{m,g}  = zeros(No(m,g),1);
        end
        
        % assume time-invariant preferences, if unspecified
        %------------------------------------------------------------------
        if size(C{m,g},2) == 1
            C{m,g} = repmat(C{m,g},1,T);
            if isfield(MDP,'c')
                MDP(m).c{g} = repmat(MDP(m).c{g},1,T);
                pC{m,g}     = repmat(pC{m,g},1,T);
            end
        end
        C{m,g} = spm_log(spm_softmax(C{m,g}));
    end
    
    
    
    % initialise  posterior expectations of hidden states
    %----------------------------------------------------------------------
    Ni    = 16;                         % number of VB iterations
    for f = 1:Nf(m)
        xn{m,f} = zeros(Ni,Ns(m,f),1,1,Np(m)) + 1/Ns(m,f);
        vn{m,f} = zeros(Ni,Ns(m,f),1,1,Np(m));
        x{m,f}  = zeros(Ns(m,f),T,Np(m))      + 1/Ns(m,f);
        X{m,f}  = repmat(D{m,f},1,1);
        for k = 1:Np(m)
            x{m,f}(:,1,k) = D{m,f};
        end
    end
    
    % initialise posteriors over polices and action
    %----------------------------------------------------------------------
    P{m}  = zeros([Nu(m,:),1]);
    un{m} = zeros(Np(m),1);
    u{m}  = zeros(Np(m),1);
    a{m}  = zeros(Nf(m),1);
    
    % If there is only one policy
    %----------------------------------------------------------------------
    if Np(m) == 1
        u{m} = ones(Np(m),T);
    end
    
    % If outcomes have not been specified set to 0
    %----------------------------------------------------------------------
    o{m}  = zeros(Ng(m),T);
    try
        i = find(MDP(m).o);
        o{m}(i) = MDP(m).o(i);
    end
    MDP(m).o = o{m};
    
    % allowable policies
    %----------------------------------------------------------------------
    p{m}  = 1:Np(m);
    
    % expected rate parameter
    %--------------------------------------------------------------------------
    qb{m} = beta;                          % initialise rate parameters
    w{m}  = 1/qb{m};                       % posterior precision (policy)
    
end


% preclude precision updates for mving policies
%--------------------------------------------------------------------------
if isfield(MDP,'U')
    OPTIONS.gamma = 1;
end

% belief updating over successive time points
%==========================================================================
for t = 1:T
    
    % for each agent or model
    %----------------------------------------------------------------------
    for m = 1:size(MDP,1)
        
        % generate hidden states and outcomes (if in active inference mode)
        %==================================================================
        if ~HMM
            
            % sampled state - based on previous action
            %--------------------------------------------------------------
            for f = 1:Nf(m)
                try
                    s{m}(f,t) = MDP(m).s(f,t);
                catch
                    if t > 1
                        ps = MDP(m).B{f}(:,s{m}(f,t - 1),a{m}(f,t - 1));
                    else
                        ps = spm_norm(MDP(m).D{f});
                    end
                    s{m}(f,t) = find(rand < cumsum(ps),1);
                end
            end
            
            % posterior predictive density
            %------------------------------------------------------------------
            for f = 1:Nf(m)
                if t > 1
                    xq{m,f} = sB{m,f}(:,:,a{m}(f,t - 1))*X{m,f}(:,t - 1);
                else
                    xq{m,f} = X{m,f}(:,t);
                end
            end
            
            % sample outcome
            %--------------------------------------------------------------
            for g = 1:Ng(m)
                
                if MDP(m).o(g,t) > 0
                    
                    % specified outcome
                    %------------------------------------------------------
                    o{m}(g,t) = MDP(m).o(g,t);
                    
                elseif MDP(m).o(g,t) < 0
                    
                    % sample outcome from posterior predictive density
                    %------------------------------------------------------
                    po        = spm_dot(A{m,g},xq(m,:));
                    o{m}(g,t) = find(rand < cumsum(po),1);
                    
                else
                    
                    % sample outcome from generative process (i.e., A)
                    %------------------------------------------------------
                    ind       = num2cell(s{m}(:,t));
                    po        = MDP(m).A{g}(:,ind{:});
                    o{m}(g,t) = find(rand < cumsum(po),1);
                    
                end
            end
            
        else
            
            %  hidden states, outcomes and actions are not needed
            %--------------------------------------------------------------
            s{m} = [];
            o{m} = [];
            a{m} = [];
            
        end % end of active inference mode
        
        % get outcome likelihood (O)
        %------------------------------------------------------------------
        for g = 1:Ng(m)
            
            % from posterior predictive density
            %--------------------------------------------------------------
            if isfield(MDP,'link') || isfield(MDP,'demi')
                O{m}{g,t} = spm_dot(A{m,g},xq(m,:));
                
                % specified as a likelihood or observation
                %----------------------------------------------------------
            elseif isfield(MDP,'O')
                O{m}{g,t} = MDP(m).O{g}(:,t);
            else
                O{m}{g,t} = sparse(o{m}(g,t),1,1,No(m,g),1);
            end
        end
        
        % generate outcomes from a subordinate MDP
        %==================================================================
        if isfield(MDP,'link')
            
            % use previous inversions (if available) to reproduce outcomes
            %--------------------------------------------------------------
            try
                mdp = MDP(m).mdp(t);
            catch
                mdp = MDP(m).MDP;
            end
            link       = MDP(m).link;
            mdp.factor = find(any(link,2));
            
            % priors over states (of subordinate level)
            %--------------------------------------------------------------
            for f = 1:size(link,1)
                i = find(link(f,:));
                if numel(i)
                    
                    % empirical priors
                    %------------------------------------------------------
                    mdp.D{m,f} = O{m}{i,t};
                    
                    % hidden state for lower level is the outcome
                    %------------------------------------------------------
                    try
                        mdp.s(f,1) = mdp.s(f,1);
                    catch
                        mdp.s(f,1) = o{m}(i,t);
                    end
                    
                else
                    
                    % otherwise use subordinate priors over states
                    %------------------------------------------------------
                    try
                        mdp.s(f,1) = mdp.s(f,1);
                    catch
                        if isfield(mdp,'D')
                            ps = spm_norm(mdp.D{f});
                        else
                            ps = spm_norm(ones(Ns(m,f),1));
                        end
                        mdp.s(f,1) = find(rand < cumsum(ps),1);
                    end
                end
            end
            
            % infer hidden states at lower level (outcomes at this level)
            %==============================================================
            MDP(m).mdp(t) = spm_MDP_VB_X(mdp);
            
            % get inferred outcomes from subordinate MDP
            %--------------------------------------------------------------
            for g = 1:Ng(m)
                i = find(link(:,g));
                if numel(i)
                    O{m}{g,t} = MDP(m).mdp(t).X{i}(:,1);
                end
            end
            
        end % end of hierarchical mode
        
        
        % generate outcomes from a generalised Bayesian filter
        %==================================================================
        if isfield(MDP,'demi')
            
            % use previous inversions (if available)
            %--------------------------------------------------------------
            try
                MDP(m).dem(t) = spm_ADEM_update(MDP(m).dem(t - 1));
            catch
                MDP(m).dem(t) = MDP(m).DEM;
            end
            
            % get inferred outcome (from Bayesian filtering)
            %--------------------------------------------------------------
            MDP(m).dem(t) = spm_MDP_DEM(MDP(m).dem(t),MDP(m).demi,O{m}(:,t),o{m}(:,t));
            for g = 1:Ng(m)
                O{m}{g,t} = MDP(m).dem(t).X{g}(:,end);
            end
        end
        
        
        % Variational updates (skip to t = T in HMM mode)
        %==================================================================
        if ~HMM || T == t
            
            % eliminate unlikely policies
            %--------------------------------------------------------------
            if ~isfield(MDP,'U') && t > 1
                F    = log(u{m}(p{m},t - 1));
                p{m} = p{m}((F - max(F)) > -3);
            end
            
            % processing time and reset
            %--------------------------------------------------------------
            tstart = tic;
            for f = 1:Nf(m)
                x{m,f} = spm_softmax(spm_log(x{m,f})/4);
            end
            
            % Variational updates (hidden states) under sequential policies
            %==============================================================
            
            % likelihood (for multiple modalities)
            %--------------------------------------------------------------
            Ao{t} = 1;
            for g = 1:Ng(m)
                Ao{t} = Ao{t}.*spm_dot(A{m,g},[O{m}(g,t) x{m,:}],(1:Nf(m)) + 1);
            end
            
            % variational message passing (VMP)
            %--------------------------------------------------------------
            S     = size(V{m},1) + 1;
            F     = zeros(Np(m),1);
            for k = p{m}                    % loop over plausible policies
                dF    = 1;                  % reset criterion for this policy
                for i = 1:Ni                % iterate belief updates
                    F(k)  = 0;              % reset free energy for this policy
                    for j = 1:S             % loop over future time points
                        
                        % curent posterior over outcome factors
                        %--------------------------------------------------
                        if j <= t
                            for f = 1:Nf(m)
                                xq{m,f} = full(x{m,f}(:,j,k));
                            end
                        end
                        
                        for f = 1:Nf(m)
                            
                            % hidden states for this time and policy
                            %----------------------------------------------
                            sx = full(x{m,f}(:,j,k));
                            v  = zeros(Ns(m,f),1);
                            
                            % evaluate free energy and gradients (v = dFdx)
                            %----------------------------------------------
                            if abs(dF) > exp(-8)
                                
                                % marginal likelihood over outcome factors
                                %------------------------------------------
                                if j <= t
                                    Aq = spm_dot(Ao{j},xq(m,:),f);
                                    v  = v + spm_log(Aq(:));
                                end
                                
                                % entropy
                                %------------------------------------------
                                qx  = spm_log(sx);
                                v   = v - qx;
                                
                                % emprical priors
                                %------------------------------------------
                                if j < 2, v = v + spm_log(D{m,f});                                         end
                                if j > 1, v = v + spm_log(sB{m,f}(:,:,V{m}(j - 1,k,f))*x{m,f}(:,j - 1,k)); end
                                if j < S, v = v + spm_log(rB{m,f}(:,:,V{m}(j    ,k,f))*x{m,f}(:,j + 1,k)); end
                                
                                % (negative) expected free energy
                                %------------------------------------------
                                F(k) = F(k) + sx'*v/Nf(m);
                                
                                % update
                                %------------------------------------------
                                sx   = spm_softmax(qx + v/tau);
                                
                            else
                                F(k) = G(k);
                            end

                            % store update neuronal activity
                            %----------------------------------------------
                            x{m,f}(:,j,k)      = sx;
                            xq{m,f}            = sx;
                            xn{m,f}(i,:,j,t,k) = sx;
                            vn{m,f}(i,:,j,t,k) = v - mean(v);
                            
                        end
                    end
   
                    % convergence
                    %------------------------------------------------------
                    if i > 1
                        dF = F(k) - G(k);
                    end
                    G = F;
                    
                end
            end
            
            % accumulate expected free energy of policies (Q)
            %==============================================================
            Q     = zeros(Np(m),1);
            if Np(m) > 1
                for k = p{m}
                    for j = 1:S
                        
                        % get expected states for this policy and time
                        %--------------------------------------------------
                        for f = 1:Nf(m)
                            xq{m,f} = x{m,f}(:,j,k);
                        end
                        
                        % (negative) expected free energy
                        %==================================================
                        
                        % Bayesian surprise about states
                        %--------------------------------------------------
                        Q(k) = Q(k) + spm_MDP_G(A(m,:),xq(m,:));
                        
                        for g = 1:Ng(m)
                            
                            % prior preferences about outcomes
                            %----------------------------------------------
                            qo   = spm_dot(A{m,g},xq(m,:));
                            Q(k) = Q(k) + qo'*(C{m,g}(:,j));
                            
                            % Bayesian surprise about parameters
                            %----------------------------------------------
                            if isfield(MDP,'a')
                                Q(k) = Q(k) - spm_dot(wA{m,g},[qo xq{m,:}]);
                            end
                        end
                    end
                end
                
                % variational updates - policies and precision
                %==========================================================
                
                % eliminate very unlikely policies
                %----------------------------------------------------------
                if ~isfield(MDP,'U')
                    p{m} = p{m}((F(p{m}) - max(F(p{m}))) > -zeta);
                end
                
                
                % previous expected precision
                %----------------------------------------------------------
                if t > 1
                    w{m}(t) = w{m}(t - 1);
                end
                for i = 1:Ni
                    
                    % posterior and prior beliefs about policies
                    %------------------------------------------------------
                    qu = spm_softmax(qE{m}(p{m}) + w{m}(t)*Q(p{m}) + F(p{m}));
                    pu = spm_softmax(qE{m}(p{m}) + w{m}(t)*Q(p{m}));
                    
                    % precision (w) with free energy gradients (v = -dF/dw)
                    %------------------------------------------------------
                    if OPTIONS.gamma
                        w{m}(t) = 1/beta;
                    else
                        eg      = (qu - pu)'*Q(p{m});
                        dFdg    = qb{m} - beta + eg;
                        qb{m}   = qb{m} - dFdg/2;
                        w{m}(t) = 1/qb{m};
                    end
                    
                    % simulated dopamine responses (expected precision)
                    %------------------------------------------------------
                    n             = (t - 1)*Ni + i;
                    wn{m}(n,1)    = w{m}(t);
                    un{m}(p{m},n) = qu;
                    u{m}(p{m},t)  = qu;
                    
                end
            else
                
                % there is only one policy:
                %----------------------------------------------------------
                pu       = 1;               % empirical prior
                qu       = 1;               % posterior
            end
            
            % Bayesian model averaging of hidden states (over policies)
            %--------------------------------------------------------------
            for f = 1:Nf(m)
                for i = 1:S
                    X{m,f}(:,i) = reshape(x{m,f}(:,i,:),Ns(m,f),Np(m))*u{m}(:,t);
                end
            end
            
            % processing (i.e., reaction) time
            %--------------------------------------------------------------
            rt{m}(t)      = toc(tstart);
            
            % record (negative) free energies
            %--------------------------------------------------------------
            MDP(m).F(:,t) = F;
            MDP(m).G(:,t) = Q;
            MDP(m).H(1,t) = qu'*MDP(m).F(p{m},t) - qu'*(log(qu) - log(pu));
            
            % check for residual uncertainty in hierarchical schemes
            %--------------------------------------------------------------
            if isfield(MDP,'factor')
                
                for f = MDP(m).factor(:)'
                    qx   = X{m,f}(:,1);
                    H(f) = qx'*spm_log(qx);
                end
                
                % break if there is no further uncertainty to resolve
                %----------------------------------------------------------
                if sum(H) > - chi
                    T = t;
                end
            end
            
            
            % action selection and sampling of next state (outcome)
            %==============================================================
            if t < T
                
                % marginal posterior over action (for each modality)
                %----------------------------------------------------------
                Pu    = zeros([Nu(m,:),1]);
                for i = 1:Np(m)
                    sub        = num2cell(V{m}(t,i,:));
                    Pu(sub{:}) = Pu(sub{:}) + u{m}(i,t);
                end
                
                % action selection (softmax function of action potential)
                %----------------------------------------------------------
                sub            = repmat({':'},1,Nf(m));
                Pu(:)          = spm_softmax(alpha*log(Pu(:)));
                P{m}(sub{:},t) = Pu;
                
                % next action - sampled from marginal posterior
                %----------------------------------------------------------
                try
                    a{m}(:,t)  = MDP(m).u(:,t);
                catch
                    ind        = find(rand < cumsum(Pu(:)),1);
                    a{m}(:,t)  = spm_ind2sub(Nu(m,:),ind);
                end
                
                
                % update policy and states for moving policies
                %----------------------------------------------------------
                if isfield(MDP,'U')
                    
                    for f = 1:Nf(m)
                        V{m}(t,:,f) = a{m}(f,t);
                    end
                    for j = 1:size(MDP(m).U,1)
                        if (t + j) < T
                            V{m}(t + j,:,:) = MDP(m).U(j,:,:);
                        end
                    end
                    
                    % and reinitialise expectations about hidden states
                    %------------------------------------------------------
                    for f = 1:Nf(m)
                        for k = 1:Np(m)
                            x{m,f}(:,:,k) = 1/Ns(m,f);
                        end
                    end
                end
                
                
            end % end of state and action selection
        end % end of variational updates over time
    end % end of loop over models (agents)
    
    % terminate evidence accumulation if there is no uncertainty
    %----------------------------------------------------------------------
    if t == T
        break;
    end
    
end % end of loop over time

% learning � accumulate concentration parameters
%==========================================================================
for m = 1:size(MDP,1)

    for t = 1:T
        
        % mapping from hidden states to outcomes: a
        %------------------------------------------------------------------
        if isfield(MDP,'a')
            for g = 1:Ng(m)
                da     = sparse(o{m}(g,t),1,1,No(m,g),1);
                for  f = 1:Nf(m)
                    da = spm_cross(da,X{m,f}(:,t));
                end
                da     = da.*(MDP(m).a{g} > 0);
                MDP(m).a{g} = MDP(m).a{g} + da*eta;
            end
        end
        
        % mapping from hidden states to hidden states: b(u)
        %------------------------------------------------------------------
        if isfield(MDP,'b') && t > 1
            for f = 1:Nf(m)
                for k = 1:Np(m)
                    v   = V{m}(t - 1,k,f);
                    db  = u{m}(k,t)*x{m,f}(:,t,k)*x{m,f}(:,t - 1,k)';
                    db  = db.*(MDP(m).b{f}(:,:,v) > 0);
                    MDP(m).b{f}(:,:,v) = MDP(m).b{f}(:,:,v) + db*eta;
                end
            end
        end
        
        % accumulation of prior preferences: (c)
        %------------------------------------------------------------------
        if isfield(MDP,'c')
            for g = 1:Ng(m)
                dc = sparse(o{m}(g,t),1,1,No(m,g),1);
                if size(MDP(m).c{g},2)>1
                    dc = dc.*(MDP(m).c{g}(:,t)>0);
                    MDP(m).c{g}(:,t) = MDP(m).c{g}(:,t) + dc*eta;
                else
                    dc = dc.*(MDP(m).c{g}>0);
                    MDP(m).c{g} = MDP(m).c{g} + dc*eta;
                end
            end
        end
    end
    
    % initial hidden states:
    %----------------------------------------------------------------------
    if isfield(MDP,'d')
        for f = 1:Nf(m)
            i = MDP(m).d{f} > 0;
            MDP(m).d{f}(i) = MDP(m).d{f}(i) + X{m,f}(i,1);
        end
    end
    
    % policies
    %----------------------------------------------------------------------
    if isfield(MDP,'e')
        MDP(m).e = MDP(m).e + u{m}(:,T);
    end
    
    % (negative) free energy of parameters (i.e., complexity)
    %----------------------------------------------------------------------
    for g = 1:Ng(m)
        if isfield(MDP,'a')
            da           = MDP(m).a{g} - pA{m,g};
            MDP(m).Fa(g) = sum(spm_vec(spm_betaln(MDP(m).a{g}))) - ...
                           sum(spm_vec(spm_betaln(pA{m,g})))    - ...
                           spm_vec(da)'*spm_vec(qA{m,g});
        end
        
        if isfield(MDP,'c')
            dc           = MDP(m).c{g} - pC{g};
            MDP(m).Fc(g) = sum(spm_vec(spm_betaln(MDP(m).c{g}))) - ...
                           sum(spm_vec(spm_betaln(pC{m,g})))    - ...
                           spm_vec(dc)'*spm_vec(C{m,g});
        end
    end
    
    for f = 1:Nf(m)
        if isfield(MDP,'b')
            db           = MDP(m).b{f} - pB{m,f};
            MDP(m).Fb(f) = sum(spm_vec(spm_betaln(MDP(m).b{f}))) - ...
                           sum(spm_vec(spm_betaln(pB{m,f})))    - ...
                           spm_vec(db)'*spm_vec(qB{m,f});
        end
        if isfield(MDP,'d')
            dd        = MDP(m).d{f} - pD{m,f};
            MDP(m).Fd(f) = sum(spm_vec(spm_betaln(MDP(m).d{f}))) - ...
                           sum(spm_vec(spm_betaln(pD{m,f})))    - ...
                           spm_vec(dd)'*spm_vec(qD{m,f});
        end
    end
    
    if isfield(MDP,'e')
        de     = MDP(m).e - pE{m};
        MDP(m).Fe = sum(spm_vec(spm_betaln(MDP(m).e))) - ...
                    sum(spm_vec(spm_betaln(pE{m})))    - ...
                    spm_vec(de)'*spm_vec(qE{m});
    end
    
    % simulated dopamine (or cholinergic) responses
    %----------------------------------------------------------------------
    if Np(m) > 1
        dn{m} = 8*gradient(wn{m}) + wn{m}/8;
    else
        dn{m} = [];
        wn{m} = [];
    end
    
    % Bayesian model averaging of expected hidden states over policies
    %----------------------------------------------------------------------
    for f = 1:Nf(m)
        Xn{m,f} = zeros(Ni,Ns(m,f),T,T);
        Vn{m,f} = zeros(Ni,Ns(m,f),T,T);
        for i = 1:T
            for k = 1:Np(m)
                Xn{m,f}(:,:,:,i) = Xn{m,f}(:,:,:,i) + xn{m,f}(:,:,1:T,i,k)*u{m}(k,i);
                Vn{m,f}(:,:,:,i) = Vn{m,f}(:,:,:,i) + vn{m,f}(:,:,1:T,i,k)*u{m}(k,i);
            end
        end
    end
    
    % use penultimate beliefs about moving policies
    %----------------------------------------------------------------------
    if isfield(MDP,'U')
        u{m}(:,T)  = [];
        try un{m}(:,(end - Ni + 1):end) = []; catch, end
    end
    
    % assemble results and place in NDP structure
    %----------------------------------------------------------------------
    MDP(m).T   = T;             % number of belief updates
    MDP(m).V   = V{m};          % policies
    MDP(m).P   = P{m};          % probability of action at time 1,...,T - 1
    MDP(m).R   = u{m};          % conditional expectations over policies
    MDP(m).Q   = x(m,:);        % conditional expectations over N states
    MDP(m).X   = X(m,:);        % Bayesian model averages over T outcomes
    MDP(m).C   = C(m,:);        % utility
    
    if HMM, return, end
    
    MDP(m).o   = o{m}(:,1:T);   % outcomes at 1,...,T
    MDP(m).s   = s{m}(:,1:T);   % states   at 1,...,T
    MDP(m).u   = a{m};          % action   at 1,...,T - 1
    MDP(m).w   = w{m};          % posterior expectations of precision (policy)
    
    MDP(m).vn  = Vn(m,:);       % simulated neuronal prediction error
    MDP(m).xn  = Xn(m,:);       % simulated neuronal encoding of hidden states
    MDP(m).un  = un{m};         % simulated neuronal encoding of policies
    MDP(m).wn  = wn{m};         % simulated neuronal encoding of precision
    MDP(m).dn  = dn{m};         % simulated dopamine responses (deconvolved)
    MDP(m).rt  = rt{m};         % simulated reaction time (seconds)
    
end


% plot
%==========================================================================
if OPTIONS.plot
    if ishandle(OPTIONS.plot)
        figure(OPTIONS.plot); clf
    else
        spm_figure('GetWin','MDP'); clf
    end
    spm_MDP_VB_trial(MDP(1))
end


% auxillary functions
%==========================================================================

function A  = spm_log(A)
% log of numeric array plus a small constant
%--------------------------------------------------------------------------
A  = log(A + 1e-16);

function A  = spm_norm(A)
% normalisation of a probability transition matrix (columns)
%--------------------------------------------------------------------------
A           = bsxfun(@rdivide,A,sum(A,1));
A(isnan(A)) = 1/size(A,1);

function A  = spm_wnorm(A)
% summation of a probability transition matrix (columns)
%--------------------------------------------------------------------------
A   = bsxfun(@minus,1./sum(A,1),1./A);

function sub = spm_ind2sub(siz,ndx)
% subscripts from linear index
%--------------------------------------------------------------------------
n = numel(siz);
k = [1 cumprod(siz(1:end-1))];
for i = n:-1:1,
    vi       = rem(ndx - 1,k(i)) + 1;
    vj       = (ndx - vi)/k(i) + 1;
    sub(i,1) = vj;
    ndx      = vi;
end



