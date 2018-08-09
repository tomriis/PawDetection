function varargout = ManualOversightGUI(varargin)
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
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ManualOversightGUI (see VARARGIN)

p = inputParser;
addOptional(p,'input',0, @(x) isstruct(x));
addOptional(p,'Images', 0, @(x) isnumeric(x));
addOptional(p, 'pawCenters', 0, @(x) isnumeric(x));
addOptional(p, 'imNum',1, @(x) isnumeric(x));
parse(p, varargin{:})

if isstruct(p.Results.input)
    handles.Images = p.Results.input.Images;
    handles.pawCenters = p.Results.input.pawCenters;
  
end
if size(p.Results.Images,1) > 1
    handles.Images = p.Results.Images;
end
if size(p.Results.pawCenters,1) > 1
    handles.pawCenters = p.Results.pawCenters;
end
handles.imNum = p.Results.imNum;

% Update handles structure
guidata(hObject, handles);
ShowPawPlacement(handles.Images, handles.pawCenters, handles.imNum);
disp(strcat('Viewing image--',num2str(handles.imNum)))
% UIWAIT makes ManualOversightGUI wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ManualOversightGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
varargout{1} = handles.pawCenters;
disp('Closing ManualOversight')
delete(handles.figure1);

% --- Executes on key press with focus on figure1 and none of its controls.
function figure1_KeyPressFcn(hObject, eventdata, handles)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was pressed, in lower case
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
        ShowPawPlacement(handles.Images, handles.pawCenters, handles.imNum);
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
