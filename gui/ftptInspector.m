function varargout = ftptInspector(varargin)
% FTPTINSPECTOR MATLAB code for ftptInspector.fig
%      FTPTINSPECTOR, by itself, creates a new FTPTINSPECTOR or raises the existing
%      singleton*.
%
%      H = FTPTINSPECTOR returns the handle to a new FTPTINSPECTOR or the handle to
%      the existing singleton*.
%
%      FTPTINSPECTOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FTPTINSPECTOR.M with the given input arguments.
%
%      FTPTINSPECTOR('Property','Value',...) creates a new FTPTINSPECTOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ftptInspector_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ftptInspector_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ftptInspector

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ftptInspector_OpeningFcn, ...
                   'gui_OutputFcn',  @ftptInspector_OutputFcn, ...
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

%--- TODO: implement right-click undo for points
%          maintain a vector indices indicating which element of ydata was
%          removeed last. if right-clicking in the same dataset, revert
%          that point. When savig warn user that undo history will be lost.
%          
%          for undoing dataset or header removal, create menu item holding
%          the list of removed headers and points


% --- Executes just before ftptInspector is made visible.
function ftptInspector_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ftptInspector (see VARARGIN)

handles.colorWheel = {[0,0,0],...
                      [0,0,0.8],[0.8,0,0],[0.1 0.7 0.1],...
                      [1,0,1],[0.1,0.5,0.5],[0.6,0.6,0.1],...
                      [0.4,0.4,0.4]}; 
handles.scaling = '';           % whether and how plotted data are scaled
handles.selectionIdx = [];      % index of data columns selected by user
handles.autoPlot = true;        % Plot data upon being selected in treeData
handles.colorMethod = 'name';   % how to color plots, 'name', 'dataset' or 
                                % 'individual'

usrdata = get(hObject,'UserData');
handles.database = usrdata{1};       
handles.settings = usrdata{2};

% MASKS keep track of which elements are deleted by user
% deleted elements are set to false
handles.masks = struct('datasets',{true(size(handles.database.datasetID))},...
                       'headers',{true(size(handles.database.headers))},...
                       'data'   ,{true(size(handles.database.ydata))});
handles.rollback = handles.masks;   % backup mask to allow revert

switch get(handles.smGroupByName,'checked')
    case 'on'
        handles.treeDataGrouping = 'name';    %group data by header
    case 'off'
        handles.treeDataGrouping= 'dataset'; %group data by dataset
end
for i=get(handles.smColorMethods,'Children')';
    if strcmpi(get(i,'Checked'),'on')
        switch get(i,'Tag')
            case 'smColorEach'; handles.colorMethod = 'individual';
            case 'smColorByName';handles.colorMethod = 'name';
            case 'smColorByDataset';handles.colorMethod = 'dataset';
        end
        break;
    end
end
        

%--- create uitree object to show data and add it to handles
root = uitreenode('v0','alldata','All data',[],false);
treeData = uitree('v0','Root',root,...
                  'position',[5,30,270,500],...
                  'SelectionChangeFcn',@treeData_SelectionChange);
set(treeData,'MultipleSelectionEnabled',1);
fillDataTree(treeData, handles);    %make uitree, group by headers
handles.treeData = treeData; 

%--- create uitree object to hold merged columns and add it to handles
root = uitreenode('v0','newdata','New Data',[],false);
treeUData = uitree('v0','Root',root,...
                  'position',[280,30,180,500],...
                  'SelectionChangeFcn',@treeData_SelectionChange);
set(treeUData,'MultipleSelectionEnabled',1);
handles.treeUData = treeUData; 

%--- check if a model file is passed up by main gui
if ~isfield(handles,'fitModel'); set(handles.smShowFit,'Enable','off');end

guidata(hObject, handles);% Update handles structure

% UIWAIT makes ftptInspector wait for user response (see UIRESUME)
uiwait(handles.figInspector);


% --- Executes when user attempts to close figInspector.
function figInspector_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figInspector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

button = questdlg('Do you want to apply your changes to the database?',...
                  'Save changes to data','Cancel');
try
    if isempty(button) || strcmpi(button,'Cancel')
        return;
    elseif strcmpi(button,'Yes')
        handles.database = applyMask(handles.database,handles.masks);
        guidata(gcbf,handles);
    end
catch ME
    errordlg('Internal error occured.',...
             'InspectorGadget:InvalidRunEnvironment');
     delete(hObject);
     return;
end
% if exist('tmpSave.mat','file'); delete('tmpSave.mat');end
uiresume(hObject);


%Utility function: applies user changes to the database
function data = applyMask(data,masks)
% data columns with false masks are removed
% data points with false masks are set to NaN

data.ydata(~masks.data) = NaN;
data.edata(~masks.data) = NaN;

data.headers(~masks.headers) = [];
data.xindex(~masks.headers) = [];
data.datasetIdx(~masks.headers) = [];
data.ydata(:,~masks.headers) = [];
data.edata(:,~masks.headers) = [];

% --- Outputs from this function are returned to the command line.
function varargout = ftptInspector_OutputFcn(hObject, ~, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
varargout{1} = handles.database;       
delete(hObject);

function fillDataTree(treeObj, handles)
% fillDataTree (TREEOBJ, GROUPBY)
% Populate a uitree with data stored in database
%   TREEOBJ:  handles to uitree to be filled
%   HANDLES.database:  database structure containig information
%
% Association of Leaf nodes to data:
% str2double(node.getValue) returns the index of data column database.ydata 
% node.getName              returns header name for data nodes and
%                           datasetID for the dataset nodes

hdrmask = handles.masks.headers;
dsmask = handles.masks.datasets;
datasetID = handles.database.datasetID;
headers = handles.database.headers;
dataIdx = 1:length(headers); 
headers = headers(hdrmask); dataIdx = dataIdx(hdrmask);
datasetIdx = handles.database.datasetIdx(hdrmask);

root = treeObj.getRoot();
root.removeAllChildren();
switch handles.treeDataGrouping
    %--- group data with same header together
    case 'name'
        rptVec = get_repeats(headers);  %rptVec is the same size as headers
        i=1;
        while i<=length(headers)
            dataNode = uitreenode('v0',headers{i},headers{i},[],false);
            for j=0:rptVec(i)
                dataNode.add(...
                    uitreenode('v0',num2str(dataIdx(i+j)),...
                    datasetID{datasetIdx(i+j)},[],true));
            end
            i=i+rptVec(i)+1;
            root.add(dataNode);
        end
        
    %--- group data from same dataset together
    case 'dataset'
        for i=1:length(datasetID)
            if ~dsmask(i); continue;end %this dataset is hidden
            dsNode = uitreenode('v0',datasetID{i},datasetID{i},[],false);
            subhdrs = headers(datasetIdx==i); 
            subIdx = dataIdx(datasetIdx==i);
            for j=1:length(subhdrs)
                dsNode.add(...
                  uitreenode('v0',num2str(subIdx(j)),subhdrs{j},[],true));
            end
            root.add(dsNode);
        end
end
treeObj.setRoot(root);
treeObj.expand(root);
treeObj.setSelectedNode(root);
guidata(gcbf,handles);


function treeData_SelectionChange(hObject,eventdata,~)
% hObject    handle to cmdataHideMasked (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    (see GUIDATA)

handles = guidata(gcf);
sN = [handles.treeData.getSelectedNodes handles.treeUData.getSelectedNodes];
if isempty(sN); return; end
selected = false(size(handles.database.headers));  

%-- node.getValue of a leaf node returns the index of the corresponding 
%   data column in the database 
for idx=1:length(sN)
    %ignore selection of root ('All Data') node
    if sN(idx).isRoot; continue;end
    if sN(idx).isLeafNode
        selected(str2double(sN(idx).getValue)) = true;
    else
        for child=0:sN(idx).getChildCount-1
            selected(str2double(sN(idx).getChildAt(child).getValue)) = true;
        end
    end
end

%--- pass index of columns that must be plotted
handles.selectionIdx=find(selected);
guidata(handles.figInspector, handles);
if handles.autoPlot
    cla(handles.axesPlot);
    ftptInspector('smPlotNow_Callback',handles.axesPlot,eventdata,handles); 
end


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
function menuData_Callback(hObject, eventdata, handles)
% hObject    handle to menuData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menuPlot_Callback(hObject, eventdata, handles)
% hObject    handle to menuPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function smLogX_Callback(hObject, ~, handles)
% hObject    handle to smLogX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
status = get(hObject,'Checked');
switch status
    case 'off'
        set(handles.axesPlot,'XScale','log');
        set(hObject,'Checked','on');
        warning('off','MATLAB:Axes:NegativeDataInLogAxis');
    case 'on'
        set(handles.axesPlot,'XScale','lin');
        set(hObject,'Checked','off');
end


% --------------------------------------------------------------------
function smLogY_Callback(hObject, ~, handles)
% hObject    handle to smLogY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
status = get(hObject,'Checked');
switch status
    case 'off'
        set(handles.axesPlot,'YScale','log');
        set(hObject,'Checked','on');
    case 'on'
        set(handles.axesPlot,'YScale','lin');
        set(hObject,'Checked','off');
end


% --------------------------------------------------------------------
function smShowFit_Callback(hObject, eventdata, handles)
% hObject    handle to smShowFit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function smSavePlot_Callback(hObject, eventdata, handles)
% hObject    handle to smSavePlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[f p]=uiputfile('*.pdf','Save plot as PDF');
newFig=figure;
ax2 = copyobj(handles.axesPlot,newFig);
%TODO: copy legend
set(ax2,'Units', 'normalized', 'Position',[0.05 0.05 0.95 0.95]);
print(newFig,'-dpdf',fullfile(p,f));
% close(newFig);

% --------------------------------------------------------------------
function smLegend_Callback(hObject, eventdata, handles)
% hObject    handle to smLegend (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
status = get(hObject,'Checked');
if strcmpi(status,'on') 
    set(hObject,'Checked','off');
    legObj = legend(handles.axesPlot,'off');
else
    set(hObject,'Checked','on');
    legObj = legend(handles.axesPlot,'on');
end
% remove this line if names are to be interpereted as LaTeX
set(legObj,'Interpreter','none');   %to be able to show _ character


% --------------------------------------------------------------------
function smGroupByDataset_Callback(hObject, ~, handles)
% hObject    handle to smGroupByDataset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.treeDataGrouping = 'dataset';
fillDataTree(handles.treeData, handles);
cla(handles.axesPlot);
set(hObject,'Checked','on');
set(handles.smGroupByName,'Checked','off');
guidata(gcbf,handles);

% --------------------------------------------------------------------
function smGroupByName_Callback(hObject, ~, handles)
% hObject    handle to smGroupByName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.treeDataGrouping = 'name';
fillDataTree(handles.treeData,handles);
cla(handles.axesPlot);
set(hObject,'Checked','on');
set(handles.smGroupByDataset,'Checked','off');
guidata(gcbf,handles);

% --------------------------------------------------------------------
function smPlotNow_Callback(hObject, eventdata, handles)
% hObject    handle to smPlotNow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isempty(handles.selectionIdx); return;end
selectionIdx = handles.selectionIdx;
datamask = handles.masks.data;
x = handles.database.xdata; 
y = handles.database.ydata; y(~datamask) = NaN; %don't show hidden data
err = handles.database.edata;
xindex = handles.database.xindex;
dsIdx = handles.database.datasetIdx;
headers = handles.database.headers;

%--- determine the color of each plot
switch handles.colorMethod
    case 'name'
        [pltHeaders srtid]= sort(headers(selectionIdx));
        rptVec = get_repeats(pltHeaders);
        if ~any(rptVec) 
            colorIdx = rem(1:length(pltHeaders),length(handles.colorWheel));
        else
            colorIdx = rptVec;
            cCount = 1; i=1;
            while i<=length(colorIdx)
                colorIdx(i:i+rptVec(i)) = cCount;
                i=i+rptVec(i)+1; cCount = cCount+1;
            end
            colorIdx = rem(colorIdx,length(handles.colorWheel));
        end
        colorIdx (colorIdx==0) = length(handles.colorWheel);
        %colorIdx corresponds to sorted selectionIdx
        %undo sorting in colorIdx to match the original
        unsorted = 1:length(pltHeaders);
        undosrt(srtid) = unsorted;
        colorIdx = colorIdx(undosrt);

        
    case 'dataset'
        colorIdx = dsIdx(selectionIdx);
        colorIdx = rem(colorIdx,length(handles.colorWheel));
        colorIdx (colorIdx==0) = length(handles.colorWheel);
        
    case 'individual'
        colorIdx = 1:length(headers(selectionIdx));
        colorIdx = rem(colorIdx,length(handles.colorWheel));
        colorIdx (colorIdx==0) = length(handles.colorWheel);
end

if ~isempty(handles.scaling);
    if strcmpi(handles.scaling,'norm') || strcmpi(handles.scaling,'start')
        [y(:,selectionIdx) err(:,selectionIdx)]...
            = scaleData(y(:,selectionIdx),err(:,selectionIdx),...
            handles.scaling,x(:,xindex(selectionIdx)),[0,1]);
    else
        [y(:,selectionIdx) err(:,selectionIdx)]...
            = scaleData(y(:,selectionIdx),err(:,selectionIdx),handles.scaling);
    end
end

cla(handles.axesPlot);
for idx=1:length(selectionIdx)
    i = selectionIdx(idx);
    hold(handles.axesPlot,'on');
    errorbar(x(:,xindex(i)), y(:,i), err(:,i),...
             'LineStyle','none','Marker','o','MarkerSize',12,...
             'Color',handles.colorWheel{colorIdx(idx)},...
             'LineWidth',1,...
             'Parent',handles.axesPlot,...
             'Tag',['AllData',num2str(i)]  ,...
             'DisplayName',...
             [handles.database.datasetID{dsIdx(i)},' ',headers{i}],...
             'ButtonDownFcn',...
             'removeOnClick(gcbo,get(gca,''CurrentPoint''))');
%'MarkerFaceColor',handles.colorWheel{colorIdx(idx)},...

end
% axis tight

% if legend is set to be shown, update it
legObj = findobj(handles.figInspector,'type','axes','tag','legend');
if ~isempty(legObj) 
    delete(legObj); 
    legObj=legend('show');
    set(legObj,'Interpreter','none');
end


% --------------------------------------------------------------------
function smPlotAuto_Callback(hObject, eventdata, handles)
% hObject    handle to smPlotAuto (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
switch get(hObject,'Checked')
    case 'on'
        handles.autoPlot = false;
        set(hObject,'Checked','off');
    otherwise
        handles.autoPlot = true;
        set(hObject,'Checked','on');
end
guidata(hObject,handles);
ftptInspector('smPlotNow_Callback',handles.axesPlot,eventdata,handles);


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
function smMergeData_Callback(hObject, eventdata, handles)
% hObject    handle to smMergeData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if length(handles.selectionIdx)<2; return;end
selectionIdx = handles.selectionIdx;
db = handles.database;
datamask = handles.masks.data;
%TODO: call applymask
x = db.xdata; y = db.ydata; y(~datamask) = NaN; %don't show hidden data
err = db.edata; err(~datamask) = NaN; xindex = db.xindex; headers = db.headers;

if ~isempty(handles.scaling);
    if strcmpi(handles.scaling,'norm') || strcmpi(handles.scaling,'start')
        [y(:,selectionIdx) err(:,selectionIdx)]...
            = scaleData(y(:,selectionIdx),err(:,selectionIdx),...
            handles.scaling,x(:,xindex(selectionIdx)),[0,1]);
    else
        [y(:,selectionIdx) err(:,selectionIdx)]...
            = scaleData(y(:,selectionIdx),err(:,selectionIdx),handles.scaling);
    end
end

if ~all(db.datasetIdx(selectionIdx) == db.datasetIdx(selectionIdx(1)))
    dsID_new = 'merged';    %ID for merged columns of multiple datasets
    dsIdx_new = length(db.datasetID)+1;
    db.datasetIdx(end+1) = dsIdx_new;
    db.datasetID{end+1} = dsID_new;
else
    db.datasetIdx(end+1) = db.datasetIdx(selectionIdx(1));
end
if any(diff(xindex(selectionIdx)))
    % if merged data have different x columns, make a new one
    y_new = reshape(y(:,selectionIdx),[],1);
    e_new = reshape(err(:,selectionIdx),[],1);
    x_new = reshape(x(:,xindex(selectionIdx)),[],1);
    [x_new y_new e_new] = mergeColumnsByX(x_new, y_new, e_new, 1);
    oldRC = size(y,1); newRC = length(y_new);
    if newRC ~=  oldRC
        y = nan(max(oldRC,newRC),size(y,2)+1);
        y(1:oldRC,1:end-1) = db.ydata; y(1:newRC,end) = y_new;
        err = nan(max(oldRC,newRC),size(err,2)+1);
        err(1:oldRC,1:end-1) = db.edata; err(1:newRC,end) = e_new;
        x = nan(max(oldRC,newRC),size(x,2)+1);
        x(1:oldRC,1:end-1) = db.xdata; x(1:newRC,end) = x_new;
    else
        x = [db.xdata x_new];
        y = [db.ydata y_new]; err = [db.edata e_new];
    end
    xindex(end+1) = size(x,2); 
    
else 
    %all columns are associated to one x column
    y_new = nanmean(y(:,selectionIdx),2); e_new = NaN(size(y_new));
    isweighted = all(isfinite(err(:,selectionIdx)),2); %data with errors
    e_new(isweighted) = sqrt(sum(err(isweighted,selectionIdx).^2, 2))./length(selectionIdx); %TODO: check
    e_new(~isweighted) = nanstd(y(~isweighted,selectionIdx),0,2);
    y = [db.ydata y_new]; err = [db.edata e_new];
    xindex(end+1) = xindex(selectionIdx(1)); 
end

%--- Ask for new header name and merge marked data columns
nN = inputdlg({'Enter a name for merged data'},...
               'Merge data',1,{[headers{selectionIdx(1)} ,'-merge']});
if ~isempty(nN); headers(end+1) = nN;
else             headers{end+1} = [headers{selectionIdx(1)} ,'-merge'];
end
%TODO: make all checks and abort operation if cancel is pressed

[db.xdata, db.ydata,db.edata] = deal(x, y, err);
db.headers = headers; db.xindex = xindex;
handles.database = db;

% make mask the same size as data
handles.masks.data = [datamask true(size(datamask,1),1)];
handles.masks.headers(end+1) = true;
if length(handles.masks.datasets) < length(db.datasetID)
    handles.masks.datasets(end+1) = true;
end
 

newN = uitreenode('v0',num2str(length(headers)),headers{end},[],true);
root = handles.treeUData.getRoot();
root.add(newN);
guidata(gcbf,handles);  
handles.treeUData.reloadNode(root);

% --------------------------------------------------------------------
function smGroupMethods_Callback(hObject, eventdata, handles)
% hObject    handle to smGroupMethods (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% --------------------------------------------------------------------
function smColorMethods_Callback(hObject, eventdata, handles)
% hObject    handle to smColorMethods (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function smColorEach_Callback(hObject, eventdata, handles)
% hObject    handle to smColorEach (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
switch get(hObject,'Checked')
    case 'off'
        handles.colorMethod = 'individual';
        for i=get(handles.smColorMethods,'Children')'
            set(i,'Checked','off');
        end
        set(hObject,'Checked','on');
end
guidata(hObject,handles);
if handles.autoPlot
    ftptInspector('smPlotNow_Callback',handles.axesPlot,eventdata,handles);
end

% --------------------------------------------------------------------
function smColorByName_Callback(hObject, eventdata, handles)
% hObject    handle to smColorByName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
switch get(hObject,'Checked')
    case 'off'
        handles.colorMethod = 'name';
        for i=get(handles.smColorMethods,'Children')'
            set(i,'Checked','off');
        end
        set(hObject,'Checked','on');
end
guidata(hObject,handles);
if handles.autoPlot
    ftptInspector('smPlotNow_Callback',handles.axesPlot,eventdata,handles);
end

% --------------------------------------------------------------------
function smColorByDataset_Callback(hObject, eventdata, handles)
% hObject    handle to smColorByDataset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
switch get(hObject,'Checked')
    case 'off'
        handles.colorMethod = 'dataset';
        for i=get(handles.smColorMethods,'Children')'
            set(i,'Checked','off');
        end
        set(hObject,'Checked','on');
end
guidata(hObject,handles);
if handles.autoPlot
    ftptInspector('smPlotNow_Callback',handles.axesPlot,eventdata,handles);
end

% --------------------------------------------------------------------
function smScalePlots_Callback(hObject, eventdata, handles)
% hObject    handle to smScalePlots (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function smScaleNorm_Callback(hObject, eventdata, handles)
% hObject    handle to smScaleNorm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
switch get(hObject,'Checked')
    case 'on'
        handles.scaling = '';
        set(hObject,'Checked','off');
    otherwise
        handles.scaling = 'norm';
        for i=get(handles.smScalePlots,'Children')'
            set(i,'Checked','off');
        end
        set(hObject,'Checked','on');
end
guidata(hObject,handles);
ftptInspector('treeData_SelectionChange',handles.treeData,eventdata,handles);


% --------------------------------------------------------------------
function smScaleStart_Callback(hObject, eventdata, handles)
% hObject    handle to smScaleStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
switch get(hObject,'Checked')
    case 'on'
        handles.scaling = '';
        set(hObject,'Checked','off');
    otherwise
        handles.scaling = 'start';
        for i=get(handles.smScalePlots,'Children')'
            set(i,'Checked','off');
        end
        set(hObject,'Checked','on');
end
guidata(hObject,handles);
ftptInspector('treeData_SelectionChange',handles.treeData,eventdata,handles);



% --------------------------------------------------------------------
function ScaleToFirst_Callback(hObject, eventdata, handles)
% hObject    handle to ScaleToFirst (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
switch get(hObject,'Checked')
    case 'on'
        handles.scaling = '';
        set(hObject,'Checked','off');
    otherwise
        handles.scaling = 'range';
        for i=get(handles.smScalePlots,'Children')'
            set(i,'Checked','off');
        end
        set(hObject,'Checked','on');
end
guidata(hObject,handles);
ftptInspector('treeData_SelectionChange',handles.treeData,eventdata,handles);

% --------------------------------------------------------------------
function smScaleMeans_Callback(hObject, eventdata, handles)
% hObject    handle to smScaleMeans (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
switch get(hObject,'Checked')
    case 'on'
        handles.scaling = '';
        set(hObject,'Checked','off');
    otherwise
        handles.scaling = 'mean';
        for i=get(handles.smScalePlots,'Children')'
            set(i,'Checked','off');
        end
        set(hObject,'Checked','on');
end
guidata(hObject,handles);
ftptInspector('treeData_SelectionChange',handles.treeData,eventdata,handles);


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
cla(handles.axesPlot);
guidata(hObject,handles);
%refill tree only if this function is called by the menu item
if hObject==handles.smRevert; fillDataTree(handles.treeData,handles); end
