function varargout = globalSMFit_dialog(varargin)
% GLOBALSMFIT_DIALOG MATLAB code for globalSMFit_dialog.fig
%      GLOBALSMFIT_DIALOG, by itself, creates a new GLOBALSMFIT_DIALOG or raises the existing
%      singleton*.
%
%      H = GLOBALSMFIT_DIALOG returns the handle to a new GLOBALSMFIT_DIALOG or the handle to
%      the existing singleton*.
%
%      GLOBALSMFIT_DIALOG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GLOBALSMFIT_DIALOG.M with the given input arguments.
%
%      GLOBALSMFIT_DIALOG('Property','Value',...) creates a new GLOBALSMFIT_DIALOG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before globalSMFit_dialog_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to globalSMFit_dialog_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help globalSMFit_dialog

% Last Modified by GUIDE v2.5 27-Feb-2015 14:00:31

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @globalSMFit_dialog_OpeningFcn, ...
                   'gui_OutputFcn',  @globalSMFit_dialog_OutputFcn, ...
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


% --- Executes just before globalSMFit_dialog is made visible.
function globalSMFit_dialog_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to globalSMFit_dialog (see VARARGIN)

% Start as small window without header table
set(handles.figGlobalSMFit,'Units','pixels');
oldval = get(handles.figGlobalSMFit,'Position');
handles.smallWin = [280 250];
set(handles.figGlobalSMFit,'Position',[oldval(1:2) handles.smallWin]);

userdata = get(hObject,'UserData');
handles.database = userdata{1};
handles.settings = userdata{2};
handles.location = userdata{3};
handles.fitnplt = [];
handles.fitMessage = [];

set(handles.tagDataNo,'String',length(handles.database.headers));
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes globalSMFit_dialog wait for user response (see UIRESUME)
uiwait(handles.figGlobalSMFit);



% --- Executes when user attempts to close figGlobalSMFit.
function figGlobalSMFit_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figGlobalSMFit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
uiresume(handles.figGlobalSMFit);


% --- Outputs from this function are returned to the command line.
function varargout = globalSMFit_dialog_OutputFcn(hObject, eventdata, handles) 
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

set(handles.figGlobalSMFit,'Visible','off'); drawnow expose;
% fit data items individually
% if handles.settings.chkBootstrap
%     parpool;
% end
[handles.fitnplt, handles.fitMessage]= ...
    gsmfit_data(database, handles.settings, handles.fitModel);
% delete(gcp);
guidata(hObject,handles);
close(handles.figGlobalSMFit);


% --- Executes on button press in btnCancel.
function btnCancel_Callback(hObject, eventdata, handles)
% hObject    handle to btnCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.fitMessage = 'Cancelled.';
guidata(hObject,handles);
close(handles.figGlobalSMFit);

% --- Executes on button press in chkFitAll.
function chkFitAll_Callback(hObject, eventdata, handles)
% hObject    handle to chkFitAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%TODO: fix this sizing dependence
oldval = get(handles.figGlobalSMFit,'Position');
if get(hObject,'Value')==0
    smallWin = handles.smallWin;
    hdrs = handles.database.headers';
    data = [num2cell(true(size(hdrs))), hdrs];
    set(handles.figGlobalSMFit,'Units','pixels',...
        'Position',[oldval(1:2) smallWin(1)+150 smallWin(2)]);
    set(handles.tblHeaders,'Visible','on','Data',data);
else
    set(handles.figGlobalSMFit,'Units','pixels',...
        'Position',[oldval(1:2) handles.smallWin]);
    if isfield(handles,'tblHeaders')
        set(handles.tblHeaders,'Visible','off'); 
    end
end

guidata(handles.figGlobalSMFit,handles);


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
