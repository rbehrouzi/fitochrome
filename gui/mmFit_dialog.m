function varargout = mmFit_dialog(varargin)
% MMFIT_DIALOG MATLAB code for mmFit_dialog.fig
%      MMFIT_DIALOG, by itself, creates a new MMFIT_DIALOG or raises the existing
%      singleton*.
%
%      H = MMFIT_DIALOG returns the handle to a new MMFIT_DIALOG or the handle to
%      the existing singleton*.
%
%      MMFIT_DIALOG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MMFIT_DIALOG.M with the given input arguments.
%
%      MMFIT_DIALOG('Property','Value',...) creates a new MMFIT_DIALOG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before mmFit_dialog_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to mmFit_dialog_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help mmFit_dialog

% Last Modified by GUIDE v2.5 25-Feb-2015 18:27:30

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @mmFit_dialog_OpeningFcn, ...
                   'gui_OutputFcn',  @mmFit_dialog_OutputFcn, ...
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


% --- Executes just before mmFit_dialog is made visible.
function mmFit_dialog_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to mmFit_dialog (see VARARGIN)
% handles.output = [];
userdata = get(hObject,'UserData');
handles.database = userdata{1};
handles.settings = userdata{2};
handles.location = userdata{3};
handles.fitnplt = [];
handles.fitMessage = [];

%load data table with proper data
hdrs = handles.database.headers'; %name of data items
handles.fitGrpNumber = zeros(size(hdrs)); %index of selected fit group
datagroups = handles.database.datasetID(handles.database.datasetIdx(:));
if size(datagroups,2) > 1; datagroups = datagroups'; end
table_data = [num2cell(false(size(hdrs))), hdrs, datagroups, cell(size(hdrs))];
set(handles.tblData,'Data',table_data);
% % Update handles structure
guidata(hObject, handles);
% % UIWAIT makes mmFit_dialog wait for user response (see UIRESUME)
uiwait(handles.mmFit_dialog);

function varargout = mmFit_dialog_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
varargout{1} = handles.fitnplt;
varargout{2} = handles.fitMessage;

% --- Executes when user attempts to close mmFit_dialog.
function mmFit_dialog_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to mmFit_dialog (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume(handles.mmFit_dialog);
delete(hObject);

% --- Executes on selection change in pmenuGroups.
function pmenuGroups_Callback(hObject, eventdata, handles)
% hObject    handle to pmenuGroups (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pmenuGroups contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pmenuGroups


% --- Executes during object creation, after setting all properties.
function pmenuGroups_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pmenuGroups (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in btnCancel.
function btnCancel_Callback(hObject, eventdata, handles)
% hObject    handle to btnCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.fitMessage = 'Cancelled.';
guidata(hObject,handles);
close(handles.mmFit_dialog);

% --- Executes on button press in btnModelFile.
function btnModelFile_Callback(hObject, eventdata, handles)
% hObject    handle to btnModelFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[mdlFile, pathname, ~]= uigetfile('*.m','Select a model file to load',...
                                  [handles.location, '/models']);
if isequal(mdlFile,0); return;end
handles.fitModel = fullfile(pathname,mdlFile);
handles.groupNames = readGroupNames(handles.fitModel);
set(handles.pmenuGroups,'Value',handles.groupNames);
set(handles.tagModelName,'String',mdlFile);
set(handles.btnStart,'Enable','on');
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function pmenuTargetGroup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pmenuTargetGroup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in btnStart.
function btnStart_Callback(hObject, eventdata, handles)
% hObject    handle to btnStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%remove excluded rows 

%set(hObject,'Enable','off');
if ~exist(handles.fitModel,'file')
    errordlg('I can''t find the model file.');
    return;
end
handles.database.ydata(:,handles.fitGrpNumber == 0) = [];
handles.database.edata(:,handles.fitGrpNumber == 0) = [];
handles.database.xindex(handles.fitGrpNumber == 0) = [];
handles.database.datasetIdx(handles.fitGrpNumber == 0) = [];
handles.database.headers(handles.fitGrpNumber == 0) = [];
handles.fitGrpNumber(handles.fitGrpNumber == 0) = [];
[handles.fitnplt, handles.fitMessage]= mmfit_data(...
                                handles.database, handles.fitGrpNumber,...
                                handles.settings, handles.fitModel);
guidata(hObject,handles);
close(handles.mmFit_dialog);

% --- Executes on button press in btnAddToGroup.
function btnAddToGroup_Callback(hObject, eventdata, handles)
% hObject    handle to btnAddToGroup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data = get(handles.tblData,'Data');
rows_selected= cell2mat(data(:,1));
fit_selection = get(handles.pmenuGroups,'Value');
if fit_selection == 1 %first element is do not fit
    data(rows_selected,4) = repmat({'Do not fit'},sum(rows_selected),1);
else
    data(rows_selected,4) = repmat(handles.fitGroups(fit_selection-1),sum(rows_selected),1);
end
handles.fitGrpNumber(rows_selected) = fit_selection-1;
set(handles.tblData,'Data',data);
guidata(hObject,handles);


% --- Executes on button press in btnLoadModel.
function btnLoadModel_Callback(hObject, eventdata, handles)
% hObject    handle to btnLoadModel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[mdlFile, pathname, ~]= uigetfile('*.m','Select a model file to load',...
                                  [handles.location, '/models']);
if isequal(mdlFile,0); return;end

modelfile = fullfile(pathname,mdlFile); 
handles.fitModel = modelfile;
%extract fit groups from the file
expr = '%-% fit_group \d* (\w*)';
fitgrps = regexpi(fileread(modelfile),expr,'tokens');
handles.fitGroups = cellfun(@char,fitgrps,'uniformoutput',false);

set(handles.pmenuGroups,'String',[{'Do not fit'},handles.fitGroups]);
set(handles.tagModelName,'String',mdlFile);
set(handles.btnStart,'Enable','on');
set(handles.btnAddToGroup,'Enable','on');
set(handles.pmenuGroups,'Enable','on');
guidata(hObject,handles);
