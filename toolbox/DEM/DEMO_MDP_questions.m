function MDP = DEMO_MDP_questions
% Demo of active inference for visual salience
%__________________________________________________________________________
%
% This routine provide simulations of reading to demonstrate deep temporal
% generative models. It builds upon the scene construction simulations to
% equip the generative model with a second hierarchical level. In effect,
% this creates an agent that can accumulate evidence at the second level
% based upon epistemic foraging at the first. In brief, the agent has to
% categorise a sentence or narrative into one of two categories (happy or
% sad), where it entertains six possible sentences. Each sentence comprises
% four words, which are themselves constituted by two pictures or graphemes
% These are the same visual outcomes used in previous illustrations of
% scene construction and saccadic searches.
%
% Here, the agent has policies at two levels. The second level policy (with
% just one step into the future) allows it to either look at the next word
% or stay on the current page and make a decision. Concurrently, a first
% level policy entails one of four saccadic eye movements to each quadrant
% of the current page, where it will sample a particular grapheme.
%
% This provides a rough simulation of reading � that can be made more
% realistic by terminating first level active inference, when there can be
% no further increase in expected free energy (i.e., all uncertainty about
% the current word has been resolved). The subsequent inferred hidden
% states then become the outcome for the level above.
%
% To illustrate the schemes biological plausibility, one can change the
% agent�s prior beliefs and repeat the reading sequence under violations of
% either local (whether the graphemes are flipped vertically) or globally
% (whether the sentence is surprising) expectations. This produces a
% mismatch negativity (MMN) under local violations) and a MMN with a
% P300 with global violations.
%
% see also: DEM_demo_MDP_habits.m and spm_MPD_VB_X.m
%__________________________________________________________________________
% Copyright (C) 2005 Wellcome Trust Centre for Neuroimaging
 
% Karl Friston
% $Id: DEMO_MDP_questions.m 7300 2018-04-25 21:14:07Z karl $
 
% set up and preliminaries: first level
%==========================================================================
% There are two outcome modalities (what and where), encoding one of 4 cues
% and one of 4 locations.  The hidden states have four factors;
% corresponding to context (three words), where (the 4 locations)
% and two further factors modelling invariance. There are no specific prior
% preferences at this level, which means behaviour is purely epistemic.
%--------------------------------------------------------------------------
 
rng('default')
 
% first level (lexical)
%==========================================================================
 
% prior beliefs about initial states
%--------------------------------------------------------------------------
D{1} = [1 1 1]';           % what:     {'flee','feed','wait'}
D{2} = [1 0 0 0]';         % where:    {'1',...,'4'}
D{3} = [1 1]';             % flip(ud): {'no','yes'}
D{4} = [8 1]';             % flip(rl): {'no','yes'}
 
 
% probabilistic mapping from hidden states to outcomes: A
%--------------------------------------------------------------------------
Nf    = numel(D);
for f = 1:Nf
    Ns(f) = numel(D{f});
end
for f1 = 1:Ns(1)
    for f2 = 1:Ns(2)
        for f3 = 1:Ns(3)
            for f4 = 1:Ns(4)
                
                % location of cues for this hidden state
                %----------------------------------------------------------
                if f1 == 1, a = {'bird','cat' ;'null','null'}; end
                if f1 == 2, a = {'bird','seed';'null','null'}; end
                if f1 == 3, a = {'bird','null';'null','seed'}; end
                
                % flip cues according to hidden (invariants) states
                %----------------------------------------------------------
                if f3 == 2, a = flipud(a); end
                if f4 == 2, a = fliplr(a); end
                
                % A{1} what: {'null','bird,'seed','cat'}
                %==========================================================
                
                % saccade to cue location
                %----------------------------------------------------------
                A{1}(1,f1,f2,f3,f4) = strcmp(a{f2},'null');
                A{1}(2,f1,f2,f3,f4) = strcmp(a{f2},'bird');
                A{1}(3,f1,f2,f3,f4) = strcmp(a{f2},'seed');
                A{1}(4,f1,f2,f3,f4) = strcmp(a{f2},'cat');
                
                % A{2} where: {'1',...,'4'}
                %----------------------------------------------------------
                A{2}(f2,f1,f2,f3,f4) = 1;
                
            end
        end
    end
end
 
% controlled transitions: B{f} for each factor
%--------------------------------------------------------------------------
for f = 1:Nf
    B{f} = eye(Ns(f));
end
 
% controllable fixation points: move to the k-th location
%--------------------------------------------------------------------------
for k = 1:Ns(2)
    B{2}(:,:,k) = 0;
    B{2}(k,:,k) = 1;
end
 
 
% MDP Structure
%--------------------------------------------------------------------------
mdp.T = 3;                      % number of updates
mdp.A = A;                      % observation model
mdp.B = B;                      % transition probabilities
mdp.D = D;                      % prior over initial states
 
mdp.Aname = {'what','where'};
mdp.Bname = {'what','where','flip','flip'};
mdp.alpha = 4;
mdp.chi   = 1/64;
 
clear A B D
 
MDP = spm_MDP_check(mdp);
clear mdp
 
% set up and preliminaries: first level
%==========================================================================
% There are three outcome modalities (what, where and feedback), encoding
% one of three cues (i.e., words) in one of 4 locations.  The hidden states
% have three factors; corresponding to context (one of six sentences),
% with a particular order of words and the four successive locations. The
% third hidden factor corresponds to the categorical decision. A priori,
% the agent prefers to solicit correct feedback.
%--------------------------------------------------------------------------
 
%% second level (semantic)
%==========================================================================
Bname{1}  = 'narrative';    Sname{1}  = {'ready','question','answer'};
Bname{2}  = 'question';     Sname{2}  = {'1','2','3'};
Bname{3}  = 'upper colour'; Sname{3}  = {'green','red'};
Bname{4}  = 'lower colour'; Sname{4}  = {'green','red'};
Bname{5}  = 'upper shape';  Sname{5}  = {'square','triangle'};
Bname{6}  = 'lower shape';  Sname{6}  = {'square','triangle'};
Bname{7}  = 'noun';         Sname{7}  = {'square','triangle'};
Bname{8}  = 'adjective';    Sname{8}  = {'green','red'};
Bname{9}  = 'adverb';       Sname{9}  = {'above','below'};


% prior beliefs about initial states (in terms of counts_: D and d
%--------------------------------------------------------------------------
D{1} = [1 0 0]';    % narrative:    {'ready','question','answer'}
D{2} = [1 0 0]';    % question:     {'1','2','3'}
D{3} = [1 0]';      % upper colour: {'green','red'}
D{4} = [1 0]';      % lower colour: {'green','red'}
D{5} = [1 0]';      % upper shape:  {'square','triangle'}
D{6} = [1 0]';      % lower shape:  {'square','triangle'}
D{7} = [1 0]';      % noun:         {'square','triangle'}
D{8} = [1 0]';      % adjective:    {'green','red'}
D{9} = [1 0]';      % adverb:       {'above','below'}

% question 1: {'noun (7)'}
% question 2: {'noun (7)','adverb (9)'}
% question 3: {'adjective (8)','noun (7)','adverb (9)'}

% probabilistic mapping from hidden states to outcomes: A
%--------------------------------------------------------------------------
Aname{1} = 'noun';   Oname{1}  = {'square','triangle'};
Aname{2} = 'adj.';   Oname{2}  = {'green','red'};
Aname{3} = 'adverb'; Oname{3}  = {'above','below'};
Aname{4} = 'syntax'; Oname{4}  = {'1','2','3','Y','N','Sil.'};

Nf    = numel(D);
for f = 1:Nf
    Ns(f) = numel(D{f});
end
for f1 = 1:Ns(1)
    for f2 = 1:Ns(2)
        for f3 = 1:Ns(3)
            for f4 = 1:Ns(4)
                for f5 = 1:Ns(5)
                    for f6 = 1:Ns(6)
                        for f7 = 1:Ns(7)
                            for f8 = 1:Ns(8)
                                for f9 = 1:Ns(9)
                                    
                                    % indices
                                    %--------------------------------------
                                    j = {f1,f2,f3,f4,f5,f6,f7,f8,f9};
                                    
                                    % answer: depending on question and belifs
                                    %--------------------------------------
                                    Y  = 0;
                                    if f1 == 3
                                        if f2 == 1
                                            Y = (f7 == f5) | (f7 == f6);
                                        elseif f2 == 2
                                            if f9 == 1
                                                Y = (f7 == f5);
                                            elseif f9 == 2
                                                Y = (f7 == f6);
                                            end
                                        elseif f2 == 3
                                            if f9 == 1
                                                Y = (f7 == f5) & (f8 == f3);
                                            elseif f9 == 2
                                                Y = (f7 == f6) & (f8 == f4);
                                            end
                                        end
                                    end
                                    
                                    % A{1} noun:
                                    %======================================
                                    A{1}(f7,j{:}) = 1;
                                    
                                    % A{2} adjective:
                                    %======================================
                                    A{2}(f8,j{:}) = 1;
                                    
                                    % A{3} adverb:
                                    %======================================
                                    A{3}(f9,j{:}) = 1;
                                    
                                    % A{4} syntax: {'1','2','3','Y','N','S'}
                                    %======================================
                                    if f1 == 1
                                        A{4}(6,j{:})     = 1;
                                    elseif f1 == 2
                                        A{4}(f2,j{:})    = 1;
                                    elseif f1 == 3
                                        if Y
                                            A{4}(4,j{:}) = 1;
                                        else
                                            A{4}(5,j{:}) = 1;
                                        end
                                    end
         
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

% likelihood mappings
%--------------------------------------------------------------------------
Ng    = numel(A);
for g = 1:Ng
    No(g) = size(A{g},1);
end
 
%% controlled transitions: B{f} for each factor
%--------------------------------------------------------------------------
for f = 1:Nf
    B{f} = eye(Ns(f));
end
 
% transitions B(1): {'ready','question','answer'}
%--------------------------------------------------------------------------
B{1}(:,:,1) = spm_speye(Ns(1),Ns(1),-1); B{1}(1,Ns(1),1) = 1;

% control states B(2): question {'1','2' or '3'}
%--------------------------------------------------------------------------
for k = 1:Ns(2)
    B{2}(:,:,k) = 0;
    B{2}(k,:,k) = 1;
end
 
% D{7} = [1 0]';      % noun:         {'square','triangle'}
% D{8} = [1 0]';      % adjective:    {'green','red'}
% D{9} = [1 0]';      % adverb:       {'above','below'}
% control states B(7):B{9} 
%--------------------------------------------------------------------------
for i = [7 8 9]
    for k = 1:Ns(i)
        B{i}(:,:,k) = 0;
        B{i}(k,:,k) = 1;
    end
end

% question 1: {'noun (7)'}
% question 2: {'noun (7)','adverb (9)'}
% question 3: {'adjective (8)','noun (7)','adverb (9)'}

% allowable policies (time x polcy x factor)
%--------------------------------------------------------------------------
V         = ones(2,14,Nf);
V(:,:,2)  = kron([1;1],[1 1 2 2 2 2 3 3 3 3 3 3 3 3]);
V(:,:,7)  = kron([1;1],[1 2 1 1 2 2 1 1 1 1 2 2 2 2]);
V(:,:,8)  = kron([1;1],[1 1 1 1 1 1 1 1 2 2 1 1 2 2]);
V(:,:,9)  = kron([1;1],[1 1 1 2 1 2 1 2 1 2 1 2 1 2]);

 
% priors: (utility) C: A{4} syntax: {'1','2','3','Y','N','S'}
%--------------------------------------------------------------------------
for g = 1:Ng
    C{g}  = zeros(No(g),1);
end
C{4}(1,:) = -1;                 % the agent expects
C{4}(3,:) =  1;                 % long questions
C{4}(5,:) = -2;                 % and affirmative answers


% MDP Structure
%--------------------------------------------------------------------------
% mdp.MDP  = MDP;
% mdp.link = sparse(1,1,1,numel(MDP.D),Ng);
 
mdp.V = V;                      % allowable policies
mdp.A = A;                      % observation model
mdp.B = B;                      % transition probabilities
mdp.C = C;                      % preferred outcomes
mdp.D = D;                      % prior over initial states
mdp.s = ones(Nf,1);             % initial state
 
mdp.Aname   = Aname;
mdp.Bname   = Bname;
mdp.Sname   = Sname;
mdp.Oname   = Oname;
mdp         = spm_MDP_check(mdp);
 
 
%% illustrate a single trial
%==========================================================================
MDP  = spm_MDP_VB_X(mdp);

return
 
% show belief updates (and behaviour)
%--------------------------------------------------------------------------
spm_figure('GetWin','Figure 1'); clf
spm_MDP_VB_trial(MDP);
 
% illustrate phase-precession and responses
%--------------------------------------------------------------------------
spm_figure('GetWin','Figure 2'); clf
spm_MDP_VB_LFP(MDP,[],1); subplot(3,1,3)
spm_MDP_search_plot(MDP)

 
% illustrate evidence accumulation and perceptual synthesis (movie)
%--------------------------------------------------------------------------
spm_figure('GetWin','Figure 3'); clf
spm_MDP_search_percept(MDP)
 
% electrophysiological responses
%--------------------------------------------------------------------------
spm_figure('GetWin','Figure 4'); clf
spm_MDP_VB_ERP(MDP,1);
subplot(4,1,4)
spm_MDP_search_plot(MDP)
 
 
% illustrate global and local violations
%==========================================================================
 
% local violation (flipping is now highly likely)
%--------------------------------------------------------------------------
MDL = MDP;
MDL.mdp(4).D{3} = [1;8];
MDL = spm_MDP_VB_X(MDL);
 
% Global violation (the first sentence is surprising)
%--------------------------------------------------------------------------
MDG = MDP;
MDG.D{1}(1,1)   = 1/8;
MDG = spm_MDP_VB_X(MDG);
 
% Global and local violation
%--------------------------------------------------------------------------
MDB = MDP;
MDB.D{1}(1,1)   = 1/8;
MDB.mdp(4).D{3} = [1;8];
MDB = spm_MDP_VB_X(MDB);
 
 
% extract simulated responses to the last letter (in the last worked)
%--------------------------------------------------------------------------
spm_figure('GetWin','Figure 5'); clf
[u ,v ,ind] = spm_MDP_VB_ERP(MDP,1);
[ul,vl,ind] = spm_MDP_VB_ERP(MDL,1);
[ug,vg,ind] = spm_MDP_VB_ERP(MDG,1);
[ub,vb,ind] = spm_MDP_VB_ERP(MDB,1);
 
i   = cumsum(ind);
i   = i(4) + (-32:-1);
u   = u(i,:);
v   = v(i,:);
ul  = ul(i,:);
vl  = vl(i,:);
ug  = ug(i,:);
vg  = vg(i,:);
ub  = ub(i,:);
vb  = vb(i,:);
 
 
% peristimulus time and plot responses (and difference waveforms)
%--------------------------------------------------------------------------
pst = (1:length(i))*1000/64;
 
subplot(3,2,1)
plot(pst,u,':r',pst,v,':b'), hold on
plot(pst,ul,'r',pst,vl,'b'), hold off, axis square
xlabel('Peristimulus time (ms)'), ylabel('Depolarisation')
title('Local deviation','Fontsize',16)
 
subplot(3,2,2)
plot(pst,ul - u,'r',pst,vl - v,'b'),   axis square ij
xlabel('Peristimulus time (ms)'), ylabel('Depolarisation')
title('Difference waveform','Fontsize',16)
 
subplot(3,2,3)
plot(pst,u,'r:',pst,v ,'b:'), hold on
plot(pst,ug,'r',pst,vg,'b'), hold off, axis square
xlabel('Peristimulus time (ms)'), ylabel('Depolarisation')
title('Global deviation','Fontsize',16)
 
subplot(3,2,4)
plot(pst,ug - u,'r',pst,vg - v,'b'),   axis square ij
xlabel('Peristimulus time (ms)'), ylabel('Depolarisation')
title('Difference waveform','Fontsize',16)
 
subplot(3,2,5)
plot(pst,u,':r',pst,v ,':b'), hold on
plot(pst,ub,'r',pst,vb,'b'), hold off, axis square
xlabel('Peristimulus time (ms)'), ylabel('Depolarisation')
title('Local and global','Fontsize',16)
 
subplot(3,2,6)
plot(pst,(ug - u) - (ub - ul),'r',pst,(vg - v) - (vb - vl),'b'),   axis square ij
xlabel('Peristimulus time (ms)'), ylabel('Depolarisation')
title('Difference of differences','Fontsize',16)
 
 
return
 
 
 
 
function spm_MDP_search_plot(MDP)
% illustrate visual search graphically
%--------------------------------------------------------------------------
 
% locations on page and of page
%--------------------------------------------------------------------------
x = [0 0;0 1;1 0;1 1];
y = [1 0;2 0;3 0;4 0]*3;
r = [-1,1]/2;
 
% load images
%--------------------------------------------------------------------------
load MDP_search_graphics
null = zeros(size(bird)) + 1;
 
 
% plot cues
%--------------------------------------------------------------------------
cla;
X     = [];
for p = 1:length(MDP.mdp)
    
    % latent cues for this hidden state
    %----------------------------------------------------------------------
    f    = MDP.mdp(p).s(:,1);
    
    if f(1) == 1, a = {'bird','cats';'null','null'}; end
    if f(1) == 2, a = {'bird','seed';'null','null'}; end
    if f(1) == 3, a = {'bird','null';'null','seed'}; end
    
    % flip cues according to hidden (invariants) states
    %----------------------------------------------------------------------
    if f(3) == 2, a = flipud(a); end
    if f(4) == 2, a = fliplr(a); end
    
    j     = MDP.s(2,p);
    for i = 1:numel(a)
        image(r + y(j,1) + x(i,1),r + y(j,2) + x(i,2), eval(a{i})), hold on
    end
    axis image ij, axis([2 14 -1 2])
    
    % Extract eye movements
    %----------------------------------------------------------------------
    for i = 1:numel(MDP.mdp(p).o(2,:))
        X(end + 1,:) = y(MDP.o(2,p),:) + x(MDP.mdp(p).o(2,i),:);
    end
end
 
% Smooth and plot eye movements
%--------------------------------------------------------------------------
for j = 1:2
    T(:,j) = interp(X(:,j),8,2);
    T(:,j) = T(:,j) + spm_conv(randn(size(T(:,j))),2)/16;
end
i   = 1:(size(T,1) - 8);
plot(T(i,1),T(i,2),'b ','LineWidth',1)
plot(X(:,1),X(:,2),'r.','MarkerSize',16)
 
 
function spm_MDP_search_percept(MDP)
% illustrates visual expectations with a movie
%--------------------------------------------------------------------------
clf;
subplot(4,1,1), spm_MDP_search_plot(MDP)
axis image ij, axis([2 14 -2 2]),
subplot(4,1,2)
axis image ij, axis([2 14 -2 2]), hold on
 
% locations on page and of page
%--------------------------------------------------------------------------
x = [0 0;0 1;1 0;1 1];
y = [1 0;2 0;3 0;4 0]*3;
r = [-1,1]/2;
s = r*(1 + 1/4);
 
 
% load images
%--------------------------------------------------------------------------
load MDP_search_graphics
null = zeros(size(bird)) + 1;
 
mdp = MDP.mdp(1);
try
    d = mdp.D;
catch
    d = mdp.d;
end
Nf    = numel(d);
for f = 1:Nf
    Ns(f) = numel(d{f});
end
 
% plot posterior beliefs
%--------------------------------------------------------------------------
M     = [];
for p = 1:numel(MDP.mdp)
    mdp   = MDP.mdp(p);
    for k = 1:size(mdp.xn{1},4)
        for i = 1:size(mdp.xn{1},1)
            
            % movie over peristimulus time: first level expectations
            %--------------------------------------------------------------
            for j = 1:4
                S{j} = zeros(size(bird));
            end
            for f1 = 1:Ns(1)
                for f2 = 1:Ns(2)
                    for f3 = 1:Ns(3)
                        for f4 = 1:Ns(4)
                            
                            % latent cues for this hidden state
                            %----------------------------------------------
                            if f1 == 1, a = {'bird','cats';'null','null'}; end
                            if f1 == 2, a = {'bird','seed';'null','null'}; end
                            if f1 == 3, a = {'bird','null';'null','seed'}; end
                            
                            % flip cues according to hidden (invariants) states
                            %----------------------------------------------
                            if f3 == 2, a = flipud(a); end
                            if f4 == 2, a = fliplr(a); end
                            
                            % mixture
                            %----------------------------------------------
                            q     = mdp.xn{1}(i,f1,1,k)*mdp.xn{3}(i,f3,1,k)*mdp.xn{4}(i,f4,1,k);
                            for j = 1:4
                                S{j} = S{j} + eval(a{j})*q;
                            end
                        end
                    end
                end
            end
            
            % image
            %--------------------------------------------------------------
            if i > 1
                delete(hl);
            end
            for j = 1:numel(S)
                hl(j) = imagesc(r + y(MDP.o(2,p),1) + x(j,1),r + y(MDP.o(2,p),2) + x(j,2),S{j}/max(S{j}(:)));
            end
            
            
            % saccade
            %--------------------------------------------------------------
            X = y(MDP.o(2,p),:) + x(MDP.mdp(p).o(2,k),:);
            plot(X(:,1),X(:,2),'r.','MarkerSize',32)
            
            
            % movie over peristimulus time: second level expectations
            %--------------------------------------------------------------
            for j = 1:4
                S{j} = zeros(size(bird));
            end
            for f1 = 1:6
                
                % sequence of pictures for each story
                %----------------------------------------------------------
                if f1 == 1, a = {'cats','null','seed','null'}; end  % happy
                if f1 == 2, a = {'null','null','null','seed'}; end  % happy
                if f1 == 3, a = {'null','cats','null','seed'}; end  % happy
                if f1 == 4, a = {'cats','null','seed','cats'}; end  % sad
                if f1 == 5, a = {'null','null','null','cats'}; end  % sad
                if f1 == 6, a = {'null','cats','null','cats'}; end  % sad
                
                % mixture
                %----------------------------------------------------------
                for j = 1:numel(a)
                    S{j} = S{j} + eval(a{j})*MDP.xn{1}(end,f1,p,p);
                end
                
            end
            
            % image
            %--------------------------------------------------------------
            if i > 1
                delete(hh);
            end
            for j = 1:numel(S)
                hh(j) = imagesc(s + y(j,1) + 1/2,s + y(j,2) - 1 - 1/4,S{j}/max(S{j}(:)));
            end
            
            % categorisation
            %--------------------------------------------------------------
            if i > 1
                delete(ht);
            end
            pt    = MDP.xn{3}(end,2,p,p);
            ht(1) = text(12,-2.5,'happy','Color',[1,[1,1]*(1 - pt)],'FontSize',16);
            pt    = MDP.xn{3}(end,3,p,p);
            ht(2) = text(12,-2.0,'sad','Color',[[1,1]*(1 - pt),1],'FontSize',16);
            
            % save
            %--------------------------------------------------------------
            axis image ij, axis([2 14 -2 2]), drawnow
            if numel(M)
                M(end + 1) = getframe(gca);
            else
                M = getframe(gca);
            end
        end
    end
end
 
% save movie
%--------------------------------------------------------------------------
set(gca,'Userdata',{M,16})
set(gca,'ButtonDownFcn','spm_DEM_ButtonDownFcn')
title('Narrative construction','FontSize',16)