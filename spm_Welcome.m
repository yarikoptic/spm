function F = spm_Welcome
% Open SPM's welcome splash screen
% FORMAT F = spm_Welcome
% F        - welcome figure handle
%__________________________________________________________________________
% Copyright (C) 2014 Wellcome Trust Centre for Neuroimaging

% Guillaume Flandin
% $Id: spm_Welcome.m 6221 2014-09-30 20:52:29Z guillaume $


%-Open startup window, set window defaults
%--------------------------------------------------------------------------
RectW = spm('WinSize','W',1); % 500x280 figure
Rect0 = spm('WinSize','0',1);
Pos   = [Rect0(1)+(Rect0(3)-RectW(3))/2,...
         Rect0(2)+(Rect0(4)-RectW(4))/2,...
         RectW(3),...
         RectW(4)];
WS    = [1 1 1 1]; % spm('WinScale')

PF = spm_platform('fonts');
PF.helvetica = 'helvetica';

F = figure('IntegerHandle','off',...
    'Name',spm('Version'),...
    'NumberTitle','off',...
    'Tag','Welcome',...
    'Units','pixels',...
    'Position',Pos,...
    'Resize','on',...
    'Pointer','arrow',...
    'Color',[1 1 1]*.8,...
    'MenuBar','none',...
    'DefaultUicontrolFontName',PF.helvetica,...
    'HandleVisibility','off',...
    'Visible','off');

%-Text
%--------------------------------------------------------------------------
hA = axes('Parent',F,...
    'Units','pixels',...
    'Position',[10 10 80 260].*WS,...
    'Visible','Off');

text(0.5,0.5,'SPM',...
    'Parent',hA,...
    'FontName',PF.times,'FontSize',72,...
    'FontAngle','Italic','FontWeight','Bold',...
    'Rotation',90,...
    'VerticalAlignment','Middle',...
    'HorizontalAlignment','Center',...
    'Color',[1 1 1]*.6);

uicontrol(F,'Style','Text',...
    'String','Statistical Parametric Mapping',...
    'Position',[100 245 390 030].*WS,...
    'FontName',PF.helvetica,'FontSize',18,'FontAngle','Italic',...
    'FontWeight','Bold',...
    'ForegroundColor',[1 1 1]*.5,...
    'BackgroundColor',[1 1 1]*.8);

uipanel('Parent',F,'Title','',...
    'Units','pixels',...
    'Position',[100 130 390 110].*WS,...
    'BackgroundColor',[1 1 1]*.75);

uipanel('Parent',F,'Title','',...
    'Units','pixels',...
    'Position',[100 030 390 085].*WS,...
    'BackgroundColor',[1 1 1]*.75);

uicontrol(F,'Style','Text',...
    'String',spm('Ver'),...
    'Position',[105 200 380 030].*WS,...
    'FontName',PF.helvetica,'FontSize',22,'FontWeight','Bold',...
    'ForegroundColor',[0 0.5 0],...
    'BackgroundColor',[1 1 1]*.75)

uicontrol(F,'Style','Text',...
    'Position',[105 175 380 020].*WS,...
    'String','developed by members and collaborators of',...
    'FontName',PF.helvetica,'FontSize',10,'FontAngle','Italic',...
    'BackgroundColor',[1 1 1]*.75)

uicontrol(F,'Style','Text',...
    'Position',[105 157 380 020].*WS,...
    'String','The Wellcome Trust Centre for Neuroimaging',...
    'FontName',PF.helvetica,'FontSize',12,'FontWeight','Bold',...
    'BackgroundColor',[1 1 1]*.75)

uicontrol(F,'Style','Text',...
    'Position',[105 137 380 020].*WS,...
    'String','Institute of Neurology, University College London',...
    'FontName',PF.helvetica,'FontSize',11,...
    'BackgroundColor',[1 1 1]*.75)

uicontrol(F,'Style','Text',...
    'String',['Copyright (c) 1991,1994-' datestr(now,'yyyy')],...
    'Position',[100 005 390 020].*WS,...
    'ForegroundColor',[1 1 1]*.5,...
    'BackgroundColor',[1 1 1]*.8,...
    'FontName',PF.helvetica,'FontSize',11,...
    'HorizontalAlignment','center',...
    'BackgroundColor',[1 1 1]*.8)

%-Objects with Callbacks - PET, M/EEG, fMRI, About SPM, SPMweb, Quit
%--------------------------------------------------------------------------
set(F,'DefaultUicontrolFontSize',12,'DefaultUicontrolInterruptible','on');

uicontrol(F,'Style','pushbutton',...
    'String','PET & VBM',...
    'Position',[135 075 100 030].*WS,...
    'CallBack','delete(gcbf);spm(''Clean'');spm(''PET'')',...
    'FontName',PF.helvetica,...
    'ForegroundColor',[0.5 0 0])

uicontrol(F,'Style','pushbutton',...
    'String','M/EEG',...
    'Position',[245 075 100 030].*WS,...
    'CallBack','delete(gcbf);spm(''Clean'');spm(''EEG'')',...
    'FontName',PF.helvetica,...
    'ForegroundColor',[0.5 0 0])

uicontrol(F,'Style','pushbutton',...
    'String','fMRI',...
    'Position',[355 075 100 030].*WS,...
    'CallBack','delete(gcbf);spm(''Clean'');spm(''FMRI'')',...
    'FontName',PF.helvetica,...
    'ForegroundColor',[0.5 0 0])

uicontrol(F,'Style','pushbutton',...
    'String','About SPM',...
    'Position',[135 040 100 030].*WS,...
    'CallBack','spm_help',...
    'FontName',PF.helvetica,...
    'ForegroundColor',[0 0.5 0])

uicontrol(F,'Style','pushbutton',...
    'String','SPMweb',...
    'Position',[245 040 100 030].*WS,...
    'CallBack','web(''http://www.fil.ion.ucl.ac.uk/spm/'')',...
    'FontName',PF.helvetica,...
    'ForegroundColor',[0 0.5 0])

uicontrol(F,'Style','pushbutton',...
    'String','Quit',...
    'FontName',PF.helvetica,...
    'Position',[355 040 100 030].*WS,...
    'CallBack','delete(gcbf)',...
    'Interruptible','off',...
    'ForegroundColor',[1 0 0])

if ~ismac
    set(findobj(F,'Style','pushbutton'),'BackgroundColor',[1 1 1]*0.75);
end

%-
%--------------------------------------------------------------------------
set(findobj(F),'Units','normalized');
set(findobj(F,'FontUnits','points'),'FontUnits','normalized');
set(F,'Visible','on')
spm_figure('Focus',F);
