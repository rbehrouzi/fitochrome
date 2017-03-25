function varargout = reducedata(varargin)
% REDUCEDATA MATLAB code for reducedata.fig
%      REDUCEDATA, by itself, creates a new REDUCEDATA or raises the existing
%      singleton*.
%
%      H = REDUCEDATA returns the handle to a new REDUCEDATA or the handle to
%      the existing singleton*.
%
%      REDUCEDATA('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in REDUCEDATA.M with the given input arguments.
%
%      REDUCEDATA('Property','Value',...) creates a new REDUCEDATA or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before reducedata_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to reducedata_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help reducedata

% Last Modified by GUIDE v2.5 21-May-2015 00:02:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @reducedata_OpeningFcn, ...
                   'gui_OutputFcn',  @reducedata_OutputFcn, ...
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


% --- Executes just before reducedata is made visible.
function reducedata_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to reducedata (see VARARGIN)

userdata = get(hObject,'UserData');
handles.database = userdata{1};
handles.settings = userdata{2};
dsID = handles.database.datasetID';
datatbl = [num2cell(false(size(dsID))),dsID];
set(handles.tblDatasets,'Data',datatbl);
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes reducedata wait for user response (see UIRESUME)
uiwait(handles.dlg_reducedata);


% --- Executes when user attempts to close dlg_reducedata.
function dlg_reducedata_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to dlg_reducedata (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
uiresume(hObject);

% --- Outputs from this function are returned to the command line.
function varargout = reducedata_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.database;
delete(hObject);


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in chkMergeSameHeader.
function chkMergeSameHeader_Callback(hObject, eventdata, handles)
% hObject    handle to chkMergeSameHeader (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
status = get(hObject,'Value');
switch status
    case 0
        set(hObject,'Value',1);
        handles.settings.chkMergeSameHeader = true;
    case 1
        set(hObject,'Value',0);
        andles.settings.chkMergeSameHeader = false;
end
guidata(hObject,handles);


% --- Executes on button press in chkScaleData.
function chkScaleData_Callback(hObject, eventdata, handles)
% hObject    handle to chkScaleData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chkScaleData


% --- Executes on selection change in pmenuScaleRule.
function pmenuScaleRule_Callback(hObject, eventdata, handles)
% hObject    handle to pmenuScaleRule (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pmenuScaleRule contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pmenuScaleRule


% --- Executes during object creation, after setting all properties.
function pmenuScaleRule_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pmenuScaleRule (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtScaleRangeLo_Callback(hObject, eventdata, handles)
% hObject    handle to txtScaleRangeLo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtScaleRangeLo as text
%        str2double(get(hObject,'String')) returns contents of txtScaleRangeLo as a double


% --- Executes during object creation, after setting all properties.
function txtScaleRangeLo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtScaleRangeLo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtScaleRangeHi_Callback(hObject, eventdata, handles)
% hObject    handle to txtScaleRangeHi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtScaleRangeHi as text
%        str2double(get(hObject,'String')) returns contents of txtScaleRangeHi as a double


% --- Executes during object creation, after setting all properties.
function txtScaleRangeHi_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtScaleRangeHi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btnCancel.
function btnCancel_Callback(hObject, eventdata, handles)
% hObject    handle to btnCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in btnReduceData.
function btnReduceData_Callback(hObject, eventdata, handles)
% hObject    handle to btnReduceData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in chkAvgSameX.
function chkAvgSameX_Callback(hObject, eventdata, handles)
% hObject    handle to chkAvgSameX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
status = get(hObject,'Value');
switch status
    case 0
        set(hObject,'Value',1);
        handles.settings.chkMergeSameX = true;        
    case 1
        set(hObject,'Value',0);
        handles.settings.chkMergeSameX = false;
end
guidata(hObject,handles);
