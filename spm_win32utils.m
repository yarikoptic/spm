function varargout = spm_win32utils(varargin)
% Various utilities for the Win32 platform - a compiled routine
% FORMAT varargout = spm_win32utils(action,varargin)
% action   - string prescribing required action
%
% FORMAT user = spm_win32utils('username')
% Returns username for Windows95/98 platform
% user     - Username, extracted from "Network Logon" registry entry
%
% FORMAT drivestr = spm_win32utils('drives')
% Returns valid drive letters for this computer (omits drives A & B - floppies)
% drivestr - string containing valid drive letters
%
%_______________________________________________________________________
% Copyright (C) 2005 Wellcome Department of Imaging Neuroscience

% Matthew Brett
% $Id: spm_win32utils.m 112 2005-05-04 18:20:52Z john $


%-This is merely the help file for the compiled routine
error('spm_win32utils.c not compiled - see Makefile')
