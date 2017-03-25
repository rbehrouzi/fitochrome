function varargout = combineData(varargin)
% COMBINEDATA MATLAB code for combineData.fig
%      COMBINEDATA, by itself, creates a new COMBINEDATA or raises the existing
%      singleton*.
%
%      H = COMBINEDATA returns the handle to a new COMBINEDATA or the handle to
%      the existing singleton*.
%
%      COMBINEDATA('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in COMBINEDATA.M with the given input arguments.
%
%      COMBINEDATA('Property','Value',...) creates a new COMBINEDATA or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before combineData_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to combineData_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help combineData

% Last Modified by GUIDE v2.5 04-Jun-2012 12:39:44

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @combineData_OpeningFcn, ...
                   'gui_OutputFcn',  @combineData_OutputFcn, ...
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


% --- Executes just before combineData is made visible.
function combineData_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to combineData (see VARARGIN)

usrdata = get(hObject,'UserData');
handles.database = usrdata{1};
handles.output = [];

set(handles.txtDBName,'String', [handles.database.dbName, '_merged']);
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes combineData wait for user response (see UIRESUME)
uiwait(handles.figCombine);


% --- Executes when user attempts to close figCombine.
function figCombine_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figCombine (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume(handles.figCombine);


% --- Outputs from this function are returned to the command line.
function varargout = combineData_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

varargout{1} = handles.output;
delete(hObject);


% --- Executes on button press in chkAvgX.
function chkAvgX_Callback(hObject, eventdata, handles)
% hObject    handle to chkAvgX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chkAvgX


% --- Executes on button press in chkScale.
function chkScale_Callback(hObject, eventdata, handles)
% hObject    handle to chkScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if (get(hObject,'Value') == get(hObject,'Max'))
 % Checkbox is checked
    set(handles.panelScale,'Visible','on');
else
 % Checkbox is not checked-take appropriate action
 set(handles.panelScale,'Visible','off');
end


function txtDBName_Callback(hObject, eventdata, handles)
% hObject    handle to txtDBName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtDBName as text
%        str2double(get(hObject,'String')) returns contents of txtDBName as a double


% --- Executes during object creation, after setting all properties.
function txtDBName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtDBName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popScaleParam.
function popScaleParam_Callback(hObject, eventdata, handles)
% hObject    handle to popScaleParam (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popScaleParam contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popScaleParam


% --- Executes during object creation, after setting all properties.
function popScaleParam_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popScaleParam (see GCBO)
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
handles.output = [];
close(handles.figCombine);

% --- Executes on button press in btnSave.
function btnSave_Callback(hObject, eventdata, handles)
% hObject    handle to btnSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%-- Scaling checkbox is checked 
if get(handles.chkScale,'Value')==1 
    scaleMethod = get(get(handles.panelScale,'SelectedObject'),'Tag');
    switch scaleMethod
        case 'radioDynamic'
            scTypes = get(handles.popScaleParam,'String');
            idx = get(handles.popScaleParam,'Value');
            scaling = scTypes{idx};
            setrange = [];
            
        case 'radioPreset'
            setrange = [str2double(get(handles.txtScaleMin,'String')),...
                        str2double(get(handles.txtScaleMax,'String'))];
            scaling = 'norm';
    end
    handles.database = mergesamehdr(handles.database,struct('type',{scaling}, 'range',{setrange}));
else
    handles.database = mergesamehdr(handles.database);
end

if get(handles.chkAvgX,'Value')==1
    handles.database = mergesamex(handles.database);
end
dbn = get(handles.txtDBName,'String');
if isempty(dbn); dbn = handles.database.dbName; end
handles.database.dbName = dbn;
handles.database.datasetID = {dbn};
handles.database.datasetIdx = ones(size(handles.database.headers));
handles.output = tidyUpDatabase(handles.database);
guidata(handles.figCombine,handles);
close(handles.figCombine);

function txtScaleMin_Callback(hObject, eventdata, handles)
% hObject    handle to txtScaleMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

val = str2double(get(hObject,'String'));
if isnan(val); set(hObject,'String','0.00');end


% --- Executes during object creation, after setting all properties.
function txtScaleMin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtScaleMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtScaleMax_Callback(hObject, eventdata, handles)
% hObject    handle to txtScaleMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

val = str2double(get(hObject,'String'));
if isnan(val); set(hObject,'String','1.00');end


% --- Executes during object creation, after setting all properties.
function txtScaleMax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtScaleMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when selected object is changed in panelScale.
function panelScale_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in panelScale 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
switch get(eventdata.NewValue,'Tag')
    case 'radioPreset'
        set(handles.popScaleParam,'Enable','off');
        set(handles.txtScaleMin,'Enable','on');
        set(handles.txtScaleMax,'Enable','on');
    case 'radioDynamic'
        set(handles.popScaleParam,'Enable','on');
        set(handles.txtScaleMin,'Enable','off');
        set(handles.txtScaleMax,'Enable','off');
    otherwise
        return;
end
