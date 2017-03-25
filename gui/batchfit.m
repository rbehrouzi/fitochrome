function varargout = batchfit(varargin)
% BATCHFIT MATLAB code for batchfit.fig
%      BATCHFIT, by itself, creates a new BATCHFIT or raises the existing
%      singleton*.
%
%      H = BATCHFIT returns the handle to a new BATCHFIT or the handle to
%      the existing singleton*.
%
%      BATCHFIT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BATCHFIT.M with the given input arguments.
%
%      BATCHFIT('Property','Value',...) creates a new BATCHFIT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before batchfit_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to batchfit_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help batchfit

% Last Modified by GUIDE v2.5 08-Aug-2012 10:41:51

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @batchfit_OpeningFcn, ...
                   'gui_OutputFcn',  @batchfit_OutputFcn, ...
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


% --- Executes just before batchfit is made visible.
function batchfit_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to batchfit (see VARARGIN)

% Start as small window without header table
set(handles.figBatchFit,'Units','pixels');
oldVal = get(handles.figBatchFit,'Position');
handles.largeWin = oldVal(3:4);
handles.smallWin = [280 300];
set(handles.figBatchFit,'Position',[oldVal(1:2) handles.smallWin]);

userdata = get(hObject,'UserData');
handles.database = userdata{1};
handles.settings = userdata{2};
handles.location = userdata{3};
handles.fitnplt = [];
handles.fitMessage = [];

set(handles.tagDataNo,'String',length(handles.database.headers));
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes batchfit wait for user response (see UIRESUME)
uiwait(handles.figBatchFit);



% --- Executes when user attempts to close figBatchFit.
function figBatchFit_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figBatchFit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
uiresume(handles.figBatchFit);


% --- Outputs from this function are returned to the command line.
function varargout = batchfit_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.fitnplt;
varargout{2} = handles.fitMessage;
delete(hObject);

% --- Executes on button press in btnLoadModel.
function btnLoadModel_Callback(hObject, eventdata, handles)
% hObject    handle to btnLoadModel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[mdlFile, pathname, ~]= uigetfile('*.m','Select a model file to load',...
                                  [handles.location, '/models']);
if isequal(mdlFile,0); return;end
handles.fitModel = fullfile(pathname,mdlFile);
set(handles.tagModelName,'String',mdlFile);
set(handles.btnStart,'Enable','on');
guidata(hObject,handles);

% --- Executes on button press in btnStart.
function btnStart_Callback(hObject, eventdata, handles)
% hObject    handle to btnStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
database = handles.database;
if get(handles.chkFitAll,'Value')==0
    tmp = get(handles.tblHeaders,'Data');
    toFit = cell2mat(tmp(:,1));
    database.ydata(:,~toFit) = [];
    database.edata(:,~toFit) = [];
    database.xindex(~toFit) = [];
    database.datasetIdx(~toFit) = [];
    database.headers(~toFit) = [];
end
if ~exist(handles.fitModel,'file')
    errordlg('I can''t find the model file.');
    return;
end

set(handles.figBatchFit,'Visible','off'); drawnow expose;
% fit data items individually
% if handles.settings.chkBootstrap
%     parpool;
% end
[handles.fitnplt, handles.fitMessage]= ...
    fit_data(database, handles.settings, handles.fitModel);
% delete(gcp);
guidata(hObject,handles);
close(handles.figBatchFit);


% --- Executes on button press in btnCancel.
function btnCancel_Callback(hObject, eventdata, handles)
% hObject    handle to btnCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.fitMessage = 'Cancelled.';
guidata(hObject,handles);
close(handles.figBatchFit);

% --- Executes on button press in chkFitAll.
function chkFitAll_Callback(hObject, eventdata, handles)
% hObject    handle to chkFitAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%TODO: fix this sizing dependence
oldVal = get(handles.figBatchFit,'Position');
if get(hObject,'Value')==0
    smallWin = handles.smallWin;
    hdrs = handles.database.headers';
    data = [num2cell(true(size(hdrs))), hdrs];
    set(handles.figBatchFit,'Units','pixels',...
        'Position',[oldVal(1:2) handles.largeWin]);
    set(handles.tblHeaders,'Visible','on','Data',data);
else
    set(handles.figBatchFit,'Units','pixels',...
        'Position',[oldVal(1:2) handles.smallWin]);
    if isfield(handles,'tblHeaders')
        set(handles.tblHeaders,'Visible','off'); 
    end
end

guidata(handles.figBatchFit,handles);


% --- Executes on button press in chkBootstrap.
function chkBootstrap_Callback(hObject, eventdata, handles)
% hObject    handle to chkBootstrap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if get(hObject,'Value') == 1
    handles.settings.chkBootstrap = 1;
else
    handles.settings.chkBootstrap = 0;
end
guidata(hObject,handles);
