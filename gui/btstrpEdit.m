function varargout = btstrpEdit(varargin)
% BTSTRPEDIT MATLAB code for btstrpEdit.fig
%      BTSTRPEDIT, by itself, creates a new BTSTRPEDIT or raises the existing
%      singleton*.
%
%      H = BTSTRPEDIT returns the handle to a new BTSTRPEDIT or the handle to
%      the existing singleton*.
%
%      BTSTRPEDIT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BTSTRPEDIT.M with the given input arguments.
%
%      BTSTRPEDIT('Property','Value',...) creates a new BTSTRPEDIT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before btstrpEdit_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to btstrpEdit_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help btstrpEdit

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @btstrpEdit_OpeningFcn, ...
                   'gui_OutputFcn',  @btstrpEdit_OutputFcn, ...
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

% --- Executes just before btstrpEdit is made visible.
function btstrpEdit_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to btstrpEdit (see VARARGIN)

% handles.location = UserData.location;
handles.location = pwd;
guidata(hObject, handles);% Update handles structure
% UIWAIT makes btstrpEdit wait for user response (see UIRESUME)
uiwait(handles.figBtstrpEdit);

% --- Executes when user attempts to close figBtstrpEdit.
function figBtstrpEdit_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figBtstrpEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

button = questdlg('Do you want to save changes to data?',...
                  'Save changes to data','Cancel');
              
try
    if isempty(button) || strcmpi(button,'Cancel')
        return;
    elseif strcmpi(button,'Yes')
        ftptInspector('smSave_Callback',handles.smSave,eventdata,handles)
    elseif strcmpi(button,'No')
        ftptInspector('smRevert_Callback',hObject,eventdata,handles)
    end
catch ME
    errordlg('Internal error occured.',...
             'InspectorGadget:InvalidRunEnvironment');
     delete(hObject);
     return;
end
% if exist('tmpSave.mat','file'); delete('tmpSave.mat');end
uiresume(hObject);

% --- Outputs from this function are returned to the command line.
function varargout = btstrpEdit_OutputFcn(hObject, ~, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
varargout = '';
delete(hObject);

% --- Executes during object creation, after setting all properties.
function ppmenuParams_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ppmenuParams (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in ppmenuParams.
function ppmenuParams_Callback(hObject, eventdata, handles)
% hObject    handle to ppmenuParams (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ppmenuParams contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ppmenuParams
% handles.selectionIdx=get(hObject,'Value');
btstrpEdit('PlotNow',handles.axPlot,eventdata,handles); 

% --- Executes on button press in chkShowLegend.
function chkShowLegend_Callback(hObject, eventdata, handles)
% hObject    handle to chkShowLegend (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
status = get(hObject,'Value');
if status 
    legObj = legend(handles.axPlot,'off');
else
    legObj = legend(handles.axPlot,'on');
end
% remove this line if names are to be interpereted as LaTeX
set(legObj,'Interpreter','none');   %to be able to show _ character

% --- Executes on button press in chkLogY.
function chkLogY_Callback(hObject, eventdata, handles)
% hObject    handle to chkLogY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
status = get(hObject,'Value');
if status
    set(handles.axPlot,'YScale','log');
else
    set(handles.axPlot,'YScale','lin');
end

% --- Executes on button press in btnSaveThisPlot.
function btnSaveThisPlot_Callback(hObject, eventdata, handles)
% hObject    handle to btnSaveThisPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[f p]=uiputfile('*.pdf','Save plot as PDF');
newFig=figure;
ax2 = copyobj(handles.axPlot,newFig);
%TODO: copy legend
set(ax2,'Units', 'normalized', 'Position',[0.05 0.05 0.95 0.95]);
print(newFig,'-dpdf',fullfile(p,f));
close(newFig);

% --------------------------------------------------------------------
function smLoadData_Callback(hObject, eventdata, handles)
% hObject    handle to smLoadData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
extfilter = {'*.xls;*.xlsx;*.txt','Bootstrap output files'};
dialogname= 'Select one or more files to import';
[dfnames, pathname, ~]= uigetfile(extfilter,dialogname,...
    fullfile(handles.location, 'data'), 'MultiSelect','on');
if isequal(dfnames,0); return;end
if iscell(dfnames)
    pathvec = repmat({pathname},1,length(dfnames));
    datafiles = cellfun(@strcat,pathvec,dfnames,'uniformoutput',0);
elseif ischar(dfnames)
    datafiles = {strcat(pathname,dfnames)};
end
if ~all(cellfun(@exist,datafiles,repmat({'file'},1,length(datafiles))))
    errordlg('I can''t find one or more of the data files.');
    return;
end

try
    for i=1:length(datafiles)
        btStruct = importdata(datafiles{i});
        database{i} = btStruct.data;
        paramNames{i} = btStruct.colheaders;
    end
catch ME
    errordlg(ME.message, 'Import was unsuccessful');
end

handles.database = database;
handles.paramNames = paramNames;
handles.paramCount = cellfun(@length,paramNames);
handles.containerNames = dfnames;
set(handles.uiPanel,'Visible','on');
set(handles.axPlot,'Visible','on');
guidata(gcbf, handles);
btstrpEdit('populateMenu',gcbf,eventdata,handles);


function populateMenu(callbackFig, eventdata, handles)
%fills popup menu with fit filenames and parameters
% hObject    handle to menuFile (see GCBO)
% Hints: contents = cellstr(get(hObject,'String')) returns ppmenuParams contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ppmenuParams
listLength = sum(handles.paramCount)+length(handles.paramCount);
paramList = cell(listLength,1);
handles.hashTable = cell(listLength,1);

k=1;
for i=1:length(handles.containerNames)
    paramList(k) = handles.containerNames(i);
    handles.hashTable{k} = {i, 1:handles.paramCount(i)};
    for j=1:length(handles.paramNames{i})
        k=k+1;
        paramList{k} = strcat('----------',handles.paramNames{i}{j});
        handles.hashTable{k} = {i, j}; 
    end
    k=k+1;
end
set(handles.ppmenuParams,'String',paramList);
guidata(callbackFig,handles);
btstrpEdit('PlotNow',handles.axPlot,eventdata,handles); 


% --------------------------------------------------------------------
function menuFile_Callback(hObject, eventdata, handles)
% hObject    handle to menuFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function smExit_Callback(hObject, eventdata, handles)
% hObject    handle to smExit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(gcbf);

% --------------------------------------------------------------------
function menuAnalysis_Callback(hObject, eventdata, handles)
% hObject    handle to menuAnalysis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function PlotNow(hObject, eventdata, handles)
% hObject    handle to axPlot
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

selIndex = get(handles.ppmenuParams,'Value');
if selIndex <= 0; return;end
% cla(handles.axPlot);
selDB = handles.hashTable{selIndex}{1};
selCol= handles.hashTable{selIndex}{2};

plotData = handles.database{selDB}(:,selCol);
boxplot(handles.axPlot,plotData);
% % if legend is set to be shown, update it
% legObj = findobj(handles.btstrpEdit,'type','axes','tag','legend');
% if ~isempty(legObj) 
%     delete(legObj); 
%     legObj=legend('show');
%     set(legObj,'Interpreter','none');
% end

% --------------------------------------------------------------------
function smHideData_Callback(~, ~, handles)
% hObject    handle to smHideData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%--- if tree root is selected, take it out of selection
sN = handles.treeData.getSelectedNodes; sNCount = length(sN);
isrt = false(1,sNCount);
for i=1:sNCount
    if sN(i).isRoot 
        isrt(i) = true; 
        sNCount = sNCount - 1;
        break;
    end
end
sN = sN(~isrt);

%--- find next, previous and parent node of the selection.
%    If any of these exists, it will be selected after the current
%    selection is deleted. If none exists, tree root will be selected
if sNCount == 0
    nN = []; pN = []; parent=[];
    rN          = handles.treeUData.getRoot();
elseif sNCount == 1
    rN          = handles.treeData.getRoot();
    parent      = sN(1).getParent();
    nN          = sN(1).getNextSibling();
    pN          = sN(1).getPreviousSibling();

else
%--- If more than one node is selected, order them before chosing next,
%    previous, etc. nodes
    rN    = handles.treeData.getRoot();
    nodeIdx = zeros(1,sNCount);
    for i=1:sNCount
        nodeIdx(i)=rN.getIndex(sN(i))*1e4;
        if nodeIdx(i)<0;    %this node is not a direct root child
            nodeIdx(i)= rN.getIndex(sN(i).getParent) * 1e4 +...
                        (1 + sN(i).getParent.getIndex(sN(i)));
        end
    end
    [~, sortIdx] = sort(nodeIdx);  
    sN = sN(sortIdx);
    parent      = sN(1).getParent();
    nN          = sN(end).getNextSibling();
    pN          = sN(1).getPreviousSibling();
end

%---  add nodes from newData tree
sN_udata = handles.treeUData.getSelectedNodes; sNuCount = length(sN_udata);
isrt = false(1,sNuCount);
for i=1:sNuCount
    if sN_udata(i).isRoot 
        isrt(i) = true; 
        sNuCount = sNuCount - 1;
        break;
    end
end
sN_udata = sN_udata(~isrt);
sN = [sN sN_udata]; sNCount = sNCount+sNuCount;
if sNCount==0; return; end

grpbyName   = strcmpi(handles.treeDataGrouping,'name');
for idx=1:sNCount
    thisNode = sN(idx);
    
    if thisNode.isLeaf
        %Note: all nodes in treeUData are leaves
        handles.masks.headers(str2double(thisNode.getValue)) = false;
    else
        if ~grpbyName   % a complete dataset is hidden
            dsIdxH = find(strcmpi(thisNode.getName,handles.database.datasetID));
            handles.masks.datasets(dsIdxH) = false;
            handles.masks.headers(handles.database.datasetIdx==dsIdxH) = false;
        else
            for child=0:thisNode.getChildCount-1
                handles.masks.headers(...
                    str2double(thisNode.getChildAt(child).getValue)) = false;
            end
        end
        thisNode.removeAllChildren();
    end
    thisNode.removeFromParent();
end

guidata(gcbf,handles);  %update masks before calling NodeSelectedCallback
handles.treeData.reloadNode(rN);
handles.treeUData.reloadNode(rN);
if ~isempty( nN )
    handles.treeData.setSelectedNode( nN );
elseif ~isempty( pN )
    handles.treeData.setSelectedNode( pN );
elseif ~isempty( parent )
    handles.treeData.setSelectedNode( parent );
else
     handles.treeData.setSelectedNode( rN );
end


% --------------------------------------------------------------------
function smSave_Callback(hObject, eventdata, handles)
% hObject    handle to smSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%--- TODO: check what to do when a dataset is removed
handles.rollback = handles.masks;
guidata(hObject,handles);
% fillDataTree(handles.treeData,handles);

% --------------------------------------------------------------------
function smRevert_Callback(hObject, eventdata, handles)
% hObject    handle to smRevert (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if hObject == handles.smRevert 
    button = questdlg({'All unsaved progress will be lost.',...
                       'You can not undo this action.'},...
                       'Revert to last saved data',...
                       'Revert anyway','Cancel','Cancel');
    if isempty(button) || strcmpi(button,'Cancel')
        return;
    end
end
%--- reset masks to the state after last save
handles.masks = handles.rollback;
cla(handles.axPlot);
guidata(hObject,handles);
if hObject==handles.smRevert; fillDataTree(handles.treeData,handles); end


% --- Executes on button press in btnRmOutlier.
function btnRmOutlier_Callback(hObject, eventdata, handles)
% hObject    handle to btnRmOutlier (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in btnReset.
function btnReset_Callback(hObject, eventdata, handles)
% hObject    handle to btnReset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function txtLoLimit_Callback(hObject, eventdata, handles)
% hObject    handle to txtLoLimit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtLoLimit as text
%        str2double(get(hObject,'String')) returns contents of txtLoLimit as a double


% --- Executes during object creation, after setting all properties.
function txtLoLimit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtLoLimit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtHiLimit_Callback(hObject, eventdata, handles)
% hObject    handle to txtHiLimit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtHiLimit as text
%        str2double(get(hObject,'String')) returns contents of txtHiLimit as a double


% --- Executes during object creation, after setting all properties.
function txtHiLimit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtHiLimit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btnSetLimits.
function btnSetLimits_Callback(hObject, eventdata, handles)
% hObject    handle to btnSetLimits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function smHistogrram_Callback(hObject, eventdata, handles)
% hObject    handle to smHistogrram (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function smCorrelation_Callback(hObject, eventdata, handles)
% hObject    handle to smCorrelation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function smPlotMatrix_Callback(hObject, eventdata, handles)
% hObject    handle to smPlotMatrix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function smOutlierAutoRm_Callback(hObject, eventdata, handles)
% hObject    handle to smOutlierAutoRm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function smSummaryReport_Callback(hObject, eventdata, handles)
% hObject    handle to smSummaryReport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function smSaveRawData_Callback(hObject, eventdata, handles)
% hObject    handle to smSaveRawData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function smBoxPlot_Callback(hObject, eventdata, handles)
% hObject    handle to smBoxPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
