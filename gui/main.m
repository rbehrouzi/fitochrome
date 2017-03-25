function varargout = main(varargin)
% MAIN MATLAB code for main.fig
%      MAIN, by itself, creates a new MAIN or raises the existing
%      singleton*.
%
%      H = MAIN returns the handle to a new MAIN or the handle to
%      the existing singleton*.
%
%      MAIN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAIN.M with the given input arguments.
%
%      MAIN('Property','Value',...) creates a new MAIN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before main_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to main_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help main

% Last Modified by GUIDE v2.5 20-May-2015 18:46:43

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @main_OpeningFcn, ...
                   'gui_OutputFcn',  @main_OutputFcn, ...
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


% --- Executes just before main is made visible.
function main_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to main (see VARARGIN)

additionalData = get(handles.figMain,'UserData');
handles.location = additionalData{1};
handles.settings = additionalData{2};
guidata(hObject, handles); % Update handles structure

sendMSG(handles.txtStatus,...
    {datestr(now),...
    sprintf('\nImport data files or load a database to start.\n')}...
    ,'clean');

% UIWAIT makes main wait for user response (see UIRESUME)
% uiwait(handles.figMain);


% --- Outputs from this function are returned to the command line.
function varargout = main_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
% varargout{1} = handles.output;


function figMain_CloseRequestFcn(hObject,eventdata,handles)
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%--- TODO: check whether wants to save anything
% uiresume(hObject);
delete(hObject);

function txtStatus_Callback(hObject, eventdata, handles)
% hObject    handle to txtStatus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtStatus as text
%        str2double(get(hObject,'String')) returns contents of txtStatus as a double


% --- Executes during object creation, after setting all properties.
function txtStatus_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtStatus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%     set(hObject,'BackgroundColor','white');
% end


% --------------------------------------------------------------------
function smReset_Callback(hObject, ~, handles)
% hObject    handle to smReset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
newhandles = guihandles(gcbf);
newhandles.location = handles.location;
newhandles.settings = handles.settings;
ItemsToRemove = {'database','dbCurrent'};
for item=ItemsToRemove
    if isfield(newhandles,item)
        newhandles = rmfield(newhandles,item);
    end
end
set(handles.figMain,'Name','TRIX');
guidata(hObject,newhandles);
sendMSG(handles.txtStatus,...
    {datestr(now),...
    sprintf('\nImport data files or load a database to start.\n')}...
    ,'clean');

% --------------------------------------------------------------------
function menuFile_Callback(hObject, eventdata, handles)
% hObject    handle to menuFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function smImportData_Callback(hObject, eventdata, handles)
% hObject    handle to smImportData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

extfilter = {'*.xls;*.xlsx;*.txt','Data files'};
dialogname= 'Select one or more data files to import';
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
sendMSG(handles.txtStatus,'Importing data files...'); drawnow expose;

try
    database = get_data(datafiles, handles.settings);
    % pack all datasets to one (sorted by headers) 
    database = packdatasets(database);

    dbn = inputdlg({'Enter a name for the new database'},...
                   'New database',1,database.datasetID(1));
    if ~isempty(dbn); database.dbName = dbn{1};
    else              database.dbName = database.datasetID{1};
    end
        
    handles.database = database;
    handles.dbCurrent = database;
    guidata(hObject,handles);
%     applyDataSettings(hObject, eventdata, handles);
    set(handles.figMain,'Name',['TRIX - ',database.dbName]);
    sendMSG(handles.txtStatus,'done!','add');

catch ME
    sendMSG(handles.txtStatus,'failed.','add');
    sendMSG(handles.txtStatus,getReport(ME,'basic'));
    return;
end


% --------------------------------------------------------------------
function smOpenData_Callback(hObject, eventdata, handles)
% hObject    handle to smOpenData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

extfilter = {'*.mat','TRIX database files'};
dialogname= 'Select one or more database files to open';
[dfnames, pathname, ~]= uigetfile(extfilter,dialogname,...
    fullfile(handles.location, 'data'), 'MultiSelect','on');
if isequal(dfnames,0); return;end
if iscell(dfnames)
    pathvec = repmat({pathname},1,length(dfnames));
    datafiles = cellfun(@fullfile,pathvec,dfnames,'uniformoutput',0);
elseif ischar(dfnames)
    datafiles = {fullfile(pathname,dfnames)}; %make it a 1x1 cell 
end
if ~all(cellfun(@exist,datafiles,repmat({'file'},1,length(datafiles))))
    errordlg('I can''t find one or more of the data files.');
    return;
end

% if length(datafiles)==1 %one database selected
%     ldb = load(datafiles{1},'-mat'); 
%     if ~isfield(ldb,'database') 
%         sendMSG(handles.txtStatus,'No database found!'); return; 
%     else
%         database = ldb.database;
%     end
% else
%     for i=1:length(datafiles)
%         ldb = load(datafiles{i},'-mat'); 
%         if isfield(ldb,'database')
%             database(i) = ldb.database(1);
%         end
%     end
%     if isempty(database); sendMSG(handles.txtStatus,'No database found!'); 
%         return; end
%     database = packdatasets(database);
%     database = rmfield(database,'dbName');
% end
for i=1:length(datafiles)
    ldb = load(datafiles{i},'-mat'); 
    if isfield(ldb,'dbCurrent')
        database(i) = ldb.dbCurrent(1);
    end
end
if isempty(database)
    sendMSG(handles.txtStatus,'No database found!'); 
    return; 
end
database = packdatasets(database);
if length(datafiles)>1; database = rmfield(database,'dbName');end
if ~isfield(database,'dbName') || isempty(database.dbName)
    dbn = inputdlg({'Enter a name for this database'},...
               'New database',1,database.datasetID(1));
    if ~isempty(dbn); database.dbName = dbn{1};
    else              database.dbName = database.datasetID{1};
    end
end

handles.database = tidyUpDatabase(database);
handles.dbCurrent = handles.database;
set(handles.figMain,'Name',['TRIX - ',database.dbName]);
guidata(hObject,handles);
sendMSG(handles.txtStatus,sprintf('Opened %d databases.', length(datafiles))); 


% --------------------------------------------------------------------
function smAddData_Callback(hObject, eventdata, handles)
% hObject    handle to smAddData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function smSaveData_Callback(hObject, eventdata, handles)
% hObject    handle to smSaveData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isfield(handles,'dbCurrent')
    dbCurrent = handles.dbCurrent;
    uisave('dbCurrent',fullfile(handles.location,'data'));
end

% --------------------------------------------------------------------
function smExportData_Callback(hObject, eventdata, handles)
% hObject    handle to smExportData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%TODO: ask whether to group data based on xindex, datasetid, or header
expdb = handles.dbCurrent;
[xindex srtid] = sort(expdb.xindex);
headers = expdb.headers(srtid);
dsIdx = expdb.datasetIdx(srtid);
x = expdb.xdata; y = expdb.ydata(:,srtid); err = expdb.edata(:,srtid);
if any(any(err)); jump=2; else jump = 1; end
xcount = get_repeats(xindex); xplace = find(xcount);
if isempty(xplace); xplace = 1:length(xindex);end
outputhdr = cell(2,length(xplace)+size(y,2)*jump);
outputnum = zeros(size(y,1),length(xplace)+size(y,2)*jump);
i=1;
for j=xplace
    endblck = i+(xcount(j)+1)*jump;
    outputnum(:,i) = x(:,xindex(j));
    outputnum(:,i+1:jump:endblck) =   y(:,j:j+xcount(j));
    outputhdr(2,i) = {handles.settings.xhdr};
    outputhdr(1,i+1:jump:endblck) = expdb.datasetID(dsIdx(j:j+xcount(j)));
    outputhdr(2,i+1:jump:endblck) = headers(j:j+xcount(j));
    if jump>1
        outputnum(:,i+2:jump:endblck+1)   = err(:,j:j+xcount(j));
        outputhdr(2,i+2:jump:endblck+1) = ...
            repmat({handles.settings.errhdr},1,xcount(j)+1);
    end
    i= endblck+1;
end
[dbn dbp] = uiputfile('*.txt','Export database as text file','exported_db');
if ~isempty(dbn); filename = fullfile(dbp, dbn);
else              filename = 'exported_db';
end
writetable(cell2table([outputhdr; num2cell(outputnum)]),filename,...
    'WriteVariableNames',false,'delimiter','tab');

% xlswrite(filename,[outputhdr; num2cell(outputnum)]);

% --------------------------------------------------------------------
function smSettings_Callback(hObject, eventdata, handles)
% hObject    handle to smSettings (see GCBO)
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
function smPackSameX_Callback(hObject, eventdata, handles)
% hObject    handle to smPackSameX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
status = get(hObject,'Checked');
switch status
    case 'off'
        set(hObject,'Checked','on');
        handles.settings.chkMergeSameX = true;
    case 'on'
        set(hObject,'Checked','off');
        handles.settings.chkMergeSameX = false;
end
guidata(hObject,handles);
applyDataSettings(hObject,eventdata,handles);

% --------------------------------------------------------------------
function smEditDatasets_Callback(hObject, eventdata, handles)
% hObject    handle to smEditDatasets (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function smCombine_Callback(hObject, eventdata, handles)
% hObject    handle to smCombine (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isfield(handles,'database')
    maskedDB = applyMask(handles.database,handles.masks);
    database = combineData('UserData',{maskedDB});
    if ~isempty(database)
        uisave('database',fullfile(handles.location,'data'));
        handles.databaseCombined = tidyUpDatabase(database);
        guidata(handles.figMain,handles);
    end
else
    msgbox('Please import data files or load a database first.');
end

% --------------------------------------------------------------------
function smReduceData_Callback(hObject, eventdata, handles)
% hObject    handle to smReduceData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB

% ReduceData always starts with the original loaded database
% The results of operations are stored in dbCurrent
if isfield(handles,'database')
    handles.dbCurrent = reducedata('Userdata',...
        {handles.database, handles.settings});
    guidata(hObject,handles);
else
    msgbox('Please load or create a database first.');
end
% handles    structure with handles and user data (see GUIDATA)


function smFtptInspector_Callback(hObject, eventdata, handles)
% hObject    handle to smFtptInspector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isfield(handles,'dbCurrent')
    handles.dbCurrent.headers = cellfun(@num2str,handles.dbCurrent.headers,...
        'UniformOutput',false);
    handles.dbCurrent = ftptInspector('Userdata',...
                    {handles.dbCurrent, handles.settings});
    guidata(hObject,handles);
else
    msgbox('Please load or create a database first.');
end

% --------------------------------------------------------------------
function smBatchFit_Callback(hObject, eventdata, handles)
% hObject    handle to smBatchFit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isfield(handles,'dbCurrent')
    sendMSG(handles.txtStatus,'Fitting in progress...'); drawnow expose;
    [fitnplt fitMessage]= batchfit('UserData',...
                           {handles.dbCurrent, handles.settings, handles.location});
    if ~strcmpi(fitMessage, 'Canceled')
        handles.fitnplt = fitnplt;
    end
    %---TODO: Ask for and add a name to fitnplt
    %         fitnplt can be a multielement structure of different
    %         fit groups
    guidata(hObject,handles);
    sendMSG(handles.txtStatus,fitMessage);
%     fits = handles.fitnplt; save('fits.mat','fits');
else
    msgbox('Please create or open a database first.');
end    

% --------------------------------------------------------------------
function menuFitting_Callback(hObject, eventdata, handles)
% hObject    handle to menuFitting (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function smExportFitParams_Callback(hObject, eventdata, handles)
% hObject    handle to smExportFitParams (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isfield(handles,'fitnplt') || isempty(handles.fitnplt)
    msgbox('No fitting data were found to export.');
else
    if ispc
        [exFileName,exPathName,~] = uiputfile(...
              {'*.xlsx', 'Excel Spreadsheet'},...
               'Choose location and file name to save',...
               fullfile(handles.location, 'output'));
        filename = fullfile(exPathName,exFileName);
        if exFileName==0; return;end
        status = saveFitResults(filename, handles.fitnplt);
    else
        [exFileName,exPathName,~] = uiputfile(...
               {'*.txt', 'Tab-delimited Text'},...
               'Choose location and file name to save',...
               fullfile(handles.location, 'output'));
        filename = fullfile(exPathName,exFileName);
        if exFileName==0; return;end
        status = saveFitResults(filename, handles.fitnplt, 'SaveAsText');
    end
end

% --------------------------------------------------------------------
function smClosePlots_Callback(hObject, eventdata, handles)
% hObject    handle to smClosePlots (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(findobj('Tag','batchfitplot'));

% --------------------------------------------------------------------
function smViewBatchFits_Callback(hObject, eventdata, handles)
% hObject    handle to smViewBatchFits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isfield(handles,'fitnplt')
    fitnplt = handles.fitnplt;
    if isempty(fitnplt); return; end
    sendMSG(handles.txtStatus,'Plotting fits...');
    %--- add plotGroup and colorGroup indices
    switch handles.settings.optMultipleDatasets
        case 'overlay'
            fitnplt.colorGroup = fitnplt.datasetIdx;
            onedataset=false; 
            if ~any(diff(fitnplt.datasetIdx)); onedataset=true;end
            fitnplt.plotGroup = ones(size(fitnplt.headers));
            rptVec = get_repeats(fitnplt.headers);
            i=1;group=1;
            while i<=length(rptVec)
                fitnplt.plotGroup(i:i+rptVec(i))=group;
                if onedataset; fitnplt.colorGroup(i:i+rptVec(i)) = 1:rptVec(i)+1;end
                group = group+1;
                i=i+rptVec(i)+1;
            end
        case 'merge'
            fitnplt.colorGroup = ones(size(fitnplt.headers));
            fitnplt.plotGroup = 1:length(fitnplt.headers);
    end
    handles.fitnplt = fitnplt;
    guidata(hObject,handles);
    plotfits(handles.fitnplt,handles.settings);
    sendMSG(handles.txtStatus,'done!','add');
else
    errordlg('No plots found for viewing!');
end


% --------------------------------------------------------------------
function smSavePlots_Callback(hObject, eventdata, handles)
% hObject    handle to smSavePlots (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isfield(handles,'fitnplt')
    errordlg('No plots found for exporting as PDF!');
    return;
end
    
[pdfFileName,pdfPathname,~] = uiputfile(...
                           {'*.pdf', 'Portable Document Format (PDF)'},...
                           'Specify PDF file name', 'batchfit-plots.pdf');
if pdfFileName==0; return;end
    
try
    sendMSG(handles.txtStatus,'Please wait for plots to be saved as PDF...');
    figlist = sort(findobj('Tag','batchfitplot'));
    if isempty(figlist)
        main('smViewBatchFits_Callback',hObject, eventdata, handles);
        figlist = sort(findobj('Tag','batchfitplot'));
    end
    for thisFig=1:length(figlist)
        fillPage(thisFig,'papersize',handles.settings.prmPaperSize,...
                         'margins', handles.settings.prmPageMargins);
        print('-append','-dpsc2',figlist(thisFig),'tmpFig.ps'); 
    end
    if ~isempty(figlist)
        ps2pdf('psfile', 'tmpFig.ps', 'deletepsfile', 1,...
               'pdffile', fullfile(pdfPathname,pdfFileName))
        sendMSG(handles.txtStatus,'done!','add');
    else
        sendMSG(handles.txtStatus,'failed!','add');
        sendMSG(handles.txtStatus,'There are no plots to save.');
    end
catch ME
    sendMSG(handles.txtStatus,'failed','add');
    sendMSG(handles.txtStatus,getReport(ME,'basic'));
end


%---- utility functions
function applyDataSettings(hObject, eventdata, handles)
% hObject    handle to uiObject that called this function (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

masks = handles.masks;
database = handles.database;

%--- remove columns that are not repeated as many times as set by user
if handles.settings.prmRepeatThreshold > 1
    masks = enforceRptCount(database, masks,...
                            handles.settings.prmRepeatThreshold);
end

try
%--- combine y data columns that have identical headers
    if handles.settings.chkMergeSameHeader 
        handles.databaseAuto = mergesamehdr(database, [], masks);
    end
%--- average points in each y data column that have identical x values
    if handles.settings.chkMergeSameX
        if isfield(handles,'databaseAuto')
            handles.databaseAuto = mergesamex(handles.databaseAuto);
        else
            handles.databaseAuto = mergesamex(database,masks);
        end
    end
catch ME
    display(getReport(ME));
end
if ~(handles.settings.chkMergeSameHeader || handles.settings.chkMergeSameX)
    if isfield(handles,'databaseAuto'); handles = rmfield(handles,'databaseAuto');end
end

handles.masks = masks;
guidata(handles.figMain,handles);

% --------------------------------------------------------------------
function sendMSG(hObject,message,varargin)
% hObject   handle to text box to be written to
% message   text or cell array of strings to be written
% mode      can be either
%               'append': add message to the end as new line (default) 
%               'add'   : add message to the end of the last line
%               'clean' : erase text box and write message

if nargin==2; mode = 'append';
else          mode = varargin{1}; 
end
if ~iscell(message); message = {message};end

switch mode
    case 'append'
        set(hObject,'String',[get(hObject,'String');message]);
    case 'add'
        txt = get(hObject,'string'); 
        lastline = [txt{end},' ',message{:}];
        txt = [txt(1:end-1); {lastline}];
        set(hObject,'String',txt);
    case 'clean'
        set(hObject,'String',message);
end


% --------------------------------------------------------------------
function smMultimodelFit_Callback(hObject, eventdata, handles)
% hObject    handle to smMultimodelFit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isfield(handles,'dbCurrent')
    sendMSG(handles.txtStatus,'Starting Multi-Model Fit...'); drawnow expose;
    [fitnplt, fitMessage]= mmFit_dialog('UserData',...
                           {handles.dbCurrent, handles.settings, handles.location});
    if ~strcmpi(fitMessage, 'Cancelled.')
        handles.fitnplt = fitnplt;
    end
    %---TODO: Ask for and add a name to fitnplt
    %         fitnplt can be a multielement structure of different
    %         fit groups
    guidata(hObject,handles);
    sendMSG(handles.txtStatus,fitMessage);
%     fits = handles.fitnplt; save('fits.mat','fits');
else
    msgbox('You need to open or create a database first.');
end    


% --------------------------------------------------------------------
function smGlobalFit_Callback(hObject, eventdata, handles)
% hObject    handle to smGlobalFit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isfield(handles,'dbCurrent')
    sendMSG(handles.txtStatus,'Starting Global Single-Model Fit...'); drawnow expose;
    [fitnplt, fitMessage]= globalSMFit_dialog('UserData',...
                           {handles.dbCurrent, handles.settings, handles.location});
    if ~strcmpi(fitMessage, 'Cancelled.')
        handles.fitnplt = fitnplt;
    end
    %---TODO: Ask for and add a name to fitnplt
    %         fitnplt can be a multielement structure of different
    %         fit groups
    guidata(hObject,handles);
    sendMSG(handles.txtStatus,fitMessage);
%     fits = handles.fitnplt; save('fits.mat','fits');
else
    msgbox('Please open or create a database first.');
end    


% --------------------------------------------------------------------
function menuResults_Callback(hObject, eventdata, handles)
% hObject    handle to menuResults (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function smAnalyzeBootstrap_Callback(hObject, eventdata, handles)
% hObject    handle to smAnalyzeBootstrap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
