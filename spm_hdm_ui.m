function [Ep,Cp,K1,K2] = spm_hdm_ui(xSPM,SPM,hReg)
% user interface for hemodynamic model estimation
% FORMAT [Ep,Cp,K1,K2] = spm_hdm_ui(xSPM,SPM,hReg);
%
% xSPM   - structure containing specific SPM details
% SPM    - structure containing generic  SPM details
% hReg   - Handle of results section XYZ registry (see spm_results_ui.m)
%
% Ep     - conditional expectations of the hemodynamic model parameters
% Cp     - conditional  covariance  of the hemodynamic model parameters
% K1     - 1st order kernels
% K2     - 2nd order kernels
%          (see main body of routine for details of model specification)
%___________________________________________________________________________
% %W% Karl Friston %E%

% get figure handles
%---------------------------------------------------------------------------
Finter = spm_figure('GetWin','Interactive');
header = get(Finter,'Name');
set(Finter,'Name','Hemodynamic modelling')

% inputs
%===========================================================================

% which session?
%---------------------------------------------------------------------------
s    = length(SPM.Sess);
if s > 1
	s = spm_input('which session',1,'n1',1,1,s);
end
Sess = SPM.Sess(s);

% 'causes' or imputs U
%---------------------------------------------------------------------------
spm_input('Input specification:...  ',1,'d');
U.dt = Sess.U(1).dt;
u    = length(Sess.U);
if u == 1 & length(Sess.U(1).name) == 1
	U.name = Sess.U(1).name{1};
	U.u    = Sess.U(1).u(33:end,1);
else
	U.name = {};
	U.u    = [];
	for  i = 1:u
	for  j = 1:length(Sess.U(i).name)
		str   = ['include ' Sess.U(i).name{j} '?'];
		if spm_input(str,2,'y/n',[1 0])
			U.u             = [U.u Sess.U(i).u(33:end,j)];
			U.name{end + 1} = Sess.U(i).name{j};
		end
	end
	end
end


% system outputs
%===========================================================================

% enforce adjustment w.r.t. all effects
%---------------------------------------------------------------------------
xY     = struct(	'Ic'		,1,...	
 	   		'name'		,'HDM',...
 	   		'Sess'		,s);


% get region stucture
%---------------------------------------------------------------------------
[y xY] = spm_regions(xSPM,SPM,hReg,xY);


%-confounds
%---------------------------------------------------------------------------
X0     = SPM.xX.X(:,[SPM.xX.iB SPM.xX.iG]);
try
	X0 = [X0 full(SPM.xX.K(s).KH)];
end

%-adjust and place in response variable structure
%---------------------------------------------------------------------------
y      = xY.u;
Y.y    = y;
Y.dt   = SPM.xY.RT;
Y.X0   = X0;

% estimate
%===========================================================================
spm('Pointer','Watch')
spm('FigName','Estimation in progress');


% Model specification: m input; 4 state; 1 outout; m + 5 parameters
%---------------------------------------------------------------------------
% u(m) - mth stimulus function     (u)
%
% x(1) - vascular signal           (s)
% x(2) - rCBF                      (f)
% x(3) - venous volume             (v)
% x(4) - deoyxHb                   (q)
%
% y(1) - BOLD                      (y)
%
% P(1)       - signal decay     - d(ds/dt)/ds)  half-life = log(2)/P(2) ~ 1sec
% P(2)       - autoregulation   - d(ds/dt)/df)  2*pi*sqrt(1/P(3)) ~ 10 sec
% P(3)       - transit time               (t0)  ~ 1 sec
% P(4)       - exponent for Fout(v)    (alpha)  c.f. Grubb's exponent (~ 0.38)
% P(5)       - resting oxygen extraction  (E0)  ~ range 20 - 50%
% P(5 + 1:m) - input efficacies - d(ds/dt)/du)  ~0.3 per event
%---------------------------------------------------------------------------

% priors (3 modes of hemodynamic variation)
%---------------------------------------------------------------------------
m       = size(U.u,2);
[pE,pC] = spm_hdm_priors(m,3);

% model
%---------------------------------------------------------------------------
M.fx    = 'spm_fx_HRF';
M.lx    = 'spm_lambda_HRF';
M.x     = [0 1 1 1]';
M.pE    = pE;    
M.pC    = pC;
M.m     = m;
M.n     = 4;
M.l     = 1;
M.N     = 64;
M.dt    = 24/M.N;

% nonlinear system identification
%---------------------------------------------------------------------------
[Ep,Cp,Ce,K0,K1,K2,M0,M1] = spm_nlsi(M,U,Y);

%-display results
%===========================================================================
t       = [1:M.N]*M.dt;
Fhdm    = spm_figure;
set(Fhdm,'name','Hemodynamic Modeling')


% display input parameters
%---------------------------------------------------------------------------
subplot(2,2,1)
P     = Ep(6:end);
C     = diag(Cp(6:end,6:end));
[i j] = max(abs(P));
spm_barh(P,C)
axis square
title({'stimulus efficacy'; 'with 90% confidence intervals'},'FontSize',10)
set(gca,'Ytick',[1:m],'YTickLabel',U.name,'FontSize',8)
str = {};
for i = 1:m
	str{end + 1} = U.name{i};
	str{end + 1} = sprintf('mean = %0.2f',P(i));
	str{end + 1} = '';
end
set(gca,'Ytick',[1:m*3]/3 + 1/2,'YTickLabel',str)
xlabel('relative efficacy per event/sec')


% display hemodynamic parameters
%---------------------------------------------------------------------------
subplot(2,2,3)
P     = Ep(1:5);
pE    = pE(1:5);
C     = diag(Cp(1:5,1:5));
spm_barh(P,C,pE)
title({	'hemodynamic parameters'},'FontSize',10)
set(gca,'Ytick',[1:15]/3 + 1/2)
set(gca,'YTickLabel',{	'SIGNAL decay',...
			 sprintf('%0.2f per sec',P(1)),'',...
			'FEEDBACK',...
			 sprintf('%0.2f per sec',P(2)),'',...
			'TRANSIT TIME',...
			 sprintf('%0.2f seconds',P(3)),'',...
			'EXPONENT',...
			 sprintf('%0.2f',P(4)),'',...
			'EXTRACTION',...
			 sprintf('%0.0f %s',P(5)*100,'%'),''},'FontSize',8)


% get display state kernels (i.e. state dynamics) 
%===========================================================================

% Volterra kernels of states
%---------------------------------------------------------------------------
[H0,H1] = spm_kernels(M0,M1,M.N,M.dt);

subplot(3,2,2)
plot(t,H1(:,:,j))
axis square
title({	['1st order kernels for ' U.name{j}];...
	'state variables: s, f, q and v'},'FontSize',9)
ylabel('normalized values')
legend('s','f','q','v',0);
grid on


% display output kernels (i.e. BOLD response) 
%---------------------------------------------------------------------------
subplot(3,2,4)
plot(t,K1(:,:,j))
axis square
title({	'1st order kernel';...
	'output: BOLD'},'FontSize',9)
ylabel('normalized flow signal')
grid on

subplot(3,2,6)
imagesc(t,t,K2(:,:,1,j,j))
axis square
title({	'2nd order kernel';...
	'output: BOLD'},'FontSize',9)
xlabel({'time {seconds} for'; U.name{j}})
grid on


%-Reset title
%---------------------------------------------------------------------------
spm('FigName',header);
spm('Pointer','Arrow')
spm_input('Thank you',1,'d')
