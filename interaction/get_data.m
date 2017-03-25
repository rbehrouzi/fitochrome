function inptdata = get_data(filenames, settings)
% FUNCTION inptdata = GET_DATA(FILENAMES, SETTINGS)
%
% Accept Excel or text files indicated by cell array FILENAMES, using 
% SETTINGS input options. Return value, inptdata is a structure including
% data, headers, and association rules of independent variable and error
% columns with data.
%
% Notes:
% Data files must have one and only one header row. All non-numeric values
% after row one are ignored. Column headers can be numeric values.
% If a column header is empty, the value from second row is used as
% header and the second column is removed from all other data columns

%Note: if more than one xdata column is imported for a dataset, this
%function removes redundant copies of same xdata column

inptdata = struct(...
    'xdata',{},...      numeric data containing independent var columns
    'ydata',{},...      numeric data containing dependent var columns
    'edata',{},...      numeric data containing error columns
    'headers',{},...    headers of y columns (cell array)
    'xindex',{},...     index of x associated with each y column
    'dbName',{},...     user defined name for the database
    'datasetIdx',{},... index of dataset which contains this data
    'datasetID',{}); %  name of datasets contained in this structure
%                       'filename_datasheet' in a multipage Excel workbook 
%                       or 'filename' if input is a text file

for thisfile=1:length(filenames)
    [~, fname, ~] = fileparts(filenames{thisfile});

    % On a Windows machine, multipage Excel files can be handled properly
    status = '';
    if ispc; [status, pages, ~] = xlsfinfo(filenames{thisfile}); end
    
    %if it's an Excel file on a PC, read using Excel ActiveX component
    if ~isempty(status) 
        if length(pages) > 1; 
            [selections, ok] = listdlg('ListString',pages,...
                    'Name','Select Excel sheets to import',...
                    'ListSize',[300,150],'PromptString',...
                    sprintf(['%s contains multiple sheets.\n',...
                        'Select sheets you''d like to import'],fname),...
                    'CancelString','Skip this file');
        else
            selections = 1; ok=1;
        end
        if ok
            thesheet=0;
            for pagechoice=selections
                [data hdrs] = xlsread(filenames{thisfile},pagechoice); %read selected sheet
                inptdata(thisfile+thesheet).datasetID = ...
                    {[fname,'_',pages{pagechoice}]};
                inptdata(thisfile+thesheet) = ...
                    takeInputData(inptdata(thisfile+thesheet),data,hdrs, settings);
                thesheet=thesheet+1;
            end
        end
        
    %--- otherwise import as tab delimited file        
    else
        datastruct = importdata(filenames{thisfile},'\t',1); %one header line, the rest are data
        hdrs = datastruct.textdata(1,:);   %numeric values are also imported as string
        data = datastruct.data;
        inptdata(thisfile).datasetID = {fname};
        inptdata(thisfile) = takeInputData(inptdata(thisfile),data,hdrs,settings);
    end
end


%--- Utility function
function inptdata = takeInputData( inptdata, data, hdrs, settings)
    % make sure no header element is empty and that header is the same size as
    % data columns. if a header is empty, the first row of that data column is
    % used as header. if this happens the first row of all data columns will be
    % removed
    data_no = size(data,2);
    if size(hdrs,1) > 1; hdrs = hdrs(1,:); end
    if length(hdrs) < data_no
        hdrs = [hdrs cell(1,(data_no-length(hdrs)))];
    end
    hdrempty = cellfun(@isempty,hdrs);
    if any(hdrempty)
        hdrs(hdrempty) = num2cell(data(1,hdrempty));%copy from 'data' first row
        data(1,:) = []; 
    end
    %-- if numeric headers are read from a text file and thus stored as
    %   string, change them to numeric
    hdrconvert = str2double(hdrs); numhdr = ~isnan(hdrconvert);
    hdrs(numhdr) = num2cell(hdrconvert(numhdr));
    
    % parse DATA into separate components for x,y and error
    % number of x columns may be different from y and error
    % but after parsing, error and y will have the same size. If a y column
    % is not followed by an error column in DATA, NaN will be assigned.
    xhdrvec = repmat({settings.xhdr},1,length(hdrs));
    ehdrvec = repmat({settings.errhdr},1,length(hdrs));
    isxcol = cellfun(@strcmpi,hdrs, xhdrvec);
    isecol = cellfun(@strcmpi,hdrs, ehdrvec);
    isycol = ~(isxcol | isecol);
    inptdata.xdata = data(:, isxcol);
    inptdata.ydata = data(:, isycol);
    inptdata.edata = NaN(size(inptdata.ydata));
    yind = find(isycol);
    if sum(isecol)>0
        for ychk=1:length(yind)
            if yind(ychk)+1<=data_no && isecol(yind(ychk)+1) 
                inptdata.edata(:,ychk)= data(:, yind(ychk)+1);
            end
        end
    end
    
    % XINDEX maps each YDATA column to its corresponding XDATA column
    % this is necessary because many y columns may be associated to one x
    % for example in footprinting data
    inptdata.xindex = ones(1,sum(isycol));
    xind = find(isxcol);
    if sum(isxcol) > 1
        ypos = 1;
        for xchk=1:length(xind)-1
            y_count = sum(isycol(xind(xchk):xind(xchk+1)));
            inptdata.xindex(ypos:ypos+y_count-1) = xchk; 
            ypos = ypos+y_count;
        end
        y_count = sum(isycol(xind(end):end));
        inptdata.xindex(ypos:ypos+y_count-1) = length(xind); 
    end
    
    %-- TODO: check to see if any of XDATA columns are the same
    %   this is to reduce dataset size when x-y1-x-y2-... type of input
    %   file is read.
    inptdata.headers = hdrs(isycol);
    inptdata.datasetIdx = ones(size(inptdata.headers));
