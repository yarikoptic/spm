% spm_setup_satfig

% spm_setup_satfig sets up a satellite figure to allow simultaneous display
% of table values and overlays.
%----------------------------------------------------------------------------
% Copyright (C) 2005 Wellcome Department of Imaging Neuroscience

% Darren R Gitelman
% $Id: spm_setup_satfig.m 112 2005-05-04 18:20:52Z john $


global SatWindow

FS   = spm('FontSizes');                   %-Scaled font sizes
PF   = spm_platform('fonts');              %-Font names (for this platform)
WS = spm('WinSize','0','raw');             %-Graphics window rectangle
Rect = [WS(1)+5 WS(4)*.40 WS(3)*.49 WS(4)*.57];

SatWindow     = figure(...
    'Tag','Satellite',...
    'Position',Rect,...
    'Resize','off',...
    'MenuBar','none',...
    'Name','SPM: Satellite Results Table',...
    'Numbertitle','off',...
    'Color','w',...
    'ColorMap',gray(64),...
    'DefaultTextColor','k',...
    'DefaultTextInterpreter','none',...
    'DefaultTextFontName',PF.helvetica,...
    'DefaultTextFontSize',FS(10),...
    'DefaultAxesColor','w',...
    'DefaultAxesXColor','k',...
    'DefaultAxesYColor','k',...
    'DefaultAxesZColor','k',...
    'DefaultAxesFontName',PF.helvetica,...
    'DefaultPatchFaceColor','k',...
    'DefaultPatchEdgeColor','k',...
    'DefaultSurfaceEdgeColor','k',...
    'DefaultLineColor','k',...
    'DefaultUicontrolFontName',PF.helvetica,...
    'DefaultUicontrolFontSize',FS(10),...
    'DefaultUicontrolInterruptible','on',...
    'PaperType','A4',...
    'PaperUnits','normalized',...
    'PaperPosition',[.0726 .0644 .854 .870],...
    'InvertHardcopy','off',...
    'Renderer','zbuffer',...
    'Visible','on',...
    'DeleteFcn',[...
        'global SatWindow,',...
        'if SatWindow,',...
        'delete(SatWindow),',...
        'SatWindow = 0;',...
        'end']);


