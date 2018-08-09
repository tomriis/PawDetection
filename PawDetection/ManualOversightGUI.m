function varargout = ManualOversightGUI(varargin)
% MANUALOVERSIGHTGUI MATLAB code for ManualOversightGUI.fig
%      MANUALOVERSIGHTGUI, by itself, creates a new MANUALOVERSIGHTGUI or raises the existing
%      singleton*.
%
%      H = MANUALOVERSIGHTGUI returns the handle to a new MANUALOVERSIGHTGUI or the handle to
%      the existing singleton*.
%
%      MANUALOVERSIGHTGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MANUALOVERSIGHTGUI.M with the given input arguments.
%
%      MANUALOVERSIGHTGUI('Property','Value',...) creates a new MANUALOVERSIGHTGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ManualOversightGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ManualOversightGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ManualOversightGUI

% Last Modified by GUIDE v2.5 09-Aug-2018 13:00:11

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ManualOversightGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @ManualOversightGUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before ManualOversightGUI is made visible.
function ManualOversightGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ManualOversightGUI (see VARARGIN)
handles.Images = varargin{1};
handles.pawCenters = varargin{2};
handles.imNum = 1;
% Choose default command line output for ManualOversightGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
pawPoints = ShowPawPlacement(handles.Images, handles.pawCenters, handles.imNum);
setappdata(hObject, 'pawCenters1', handles.pawCenters);
% UIWAIT makes ManualOversightGUI wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ManualOversightGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.pawCenters;
disp('EXITING output')
delete(handles.figure1);

% --- Executes on key press with focus on figure1 and none of its controls.
function figure1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
    if strcmp(eventdata.Key,'rightarrow')==1
        handles.imNum = handles.imNum + 1;
    elseif strcmp(eventdata.Key, 'leftarrow')==1
        handles.imNum = handles.imNum - 1;
    elseif strcmp(eventdata.Key,'space')==1
        handles.pawCenters(:,1:2,handles.imNum) = TotalManual(handles.Images(:,:,:,handles.imNum));
    end
    
    if handles.imNum < 1 || handles.imNum > size(handles.Images,4)
        disp('End of Images')
    else
        disp(strcat('Viewing image--',num2str(handles.imNum)))
        pawPoints = ShowPawPlacement(handles.Images, handles.pawCenters, handles.imNum);
    end
    guidata(hObject, handles);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
if isequal(get(hObject, 'waitstatus'), 'waiting')
% The GUI is still in UIWAIT, us UIRESUME
uiresume(hObject);
else
% The GUI is no longer waiting, just close it
delete(hObject);
end
