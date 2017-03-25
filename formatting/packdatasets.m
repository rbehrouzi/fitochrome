function cmbdataset = packdatasets(dbases)
% CMBDATASET = PACKDATASETS(DBASES)
%
% Combines data from a multi dataset structure, DBASES, and returns a
% structure of length 1, in which data column are sorted
% alphabetically/numerically according to INPTDATA.HEADERS. 
% CMBDATASET.XINDEX and CMBDATASET.DATASETIDX are updated accordingly.
%
% CMBDATA contains the same fields as INPTDATA

%-----
% First, Pack data and headers matrices one after another in a cell array
dsCount = length(dbases);
[allXdata{1:dsCount}] = deal(dbases.xdata); 
[allYdata{1:dsCount}] = deal(dbases.ydata); 
[alldsID{1:dsCount}] = deal(dbases.datasetID); 
% Then, get the number of rows and headers in each cell element 
[datalengths yCounts] = cellfun(@size,allYdata);  
[~, xCounts] = cellfun(@size,allXdata);           
[~, dsCounts] = cellfun(@size,alldsID);           
allDataCount = sum(yCounts); allXCount = sum(xCounts);allDSCount = sum(dsCounts);

% The number of rows in the combined dataset is determined by the dataset
% with the highest number of rows. NaN is added to the bottom of XDATA, 
% YDATA, and EDATA from other datasets to make them all have the same 
% number of rows
cmbxdata = NaN(max(datalengths),allXCount);
cmbydata = NaN(max(datalengths),allDataCount);
cmbedata = NaN(max(datalengths),allDataCount);
cmbhdrs = cell(1,allDataCount);
cmbxindex = ones(1,allDataCount);
cmbdsIndex = zeros(1,allDataCount);
cmbdsID = cell(1,allDSCount);
hi = 0; hix = 0; hids = 0;
for p=1:dsCount
    lo = hi+1; lox = hix + 1; lods = hids + 1;
    hi = hi + yCounts(p);
    hix = hix + xCounts(p);
    hids = hids + dsCounts(p);
    cmbxdata(1:datalengths(p),lox:hix) = dbases(p).xdata;
    cmbydata(1:datalengths(p),lo:hi) = dbases(p).ydata;
    cmbedata(1:datalengths(p),lo:hi) = dbases(p).edata;
    [cmbhdrs{lo:hi}] = deal(dbases(p).headers{:});
    [cmbdsID{lods:hids}] = deal(dbases(p).datasetID{:});
    % xindex values must be shifted by the number of x columns that already
    % exist in the combined xdata matrix
    % datasetIdx values are shifted by the number of datasetID's that exist
    % in previous databases
    cmbxindex(lo:hi) = dbases(p).xindex + (hix - xCounts(p));
    cmbdsIndex(lo:hi) = dbases(p).datasetIdx + (hids - dsCounts(p));
end
%-----

%------SORT HEADERS
% if all headers are numeric values, sort them numerically,
% not alphabetically. If some but not all headers are numeric, convert them
% to strings, otherwise SORT will break
numhdrs = cellfun(@isnumeric,cmbhdrs);
if all(numhdrs)
    [~, sortid] = sort(cell2mat(cmbhdrs));
    cmbhdrs = cmbhdrs(sortid);
elseif any(numhdrs)
    fmtstr = repmat({'%03.0f'},1,length(cmbhdrs(numhdrs)));
    cmbhdrs(numhdrs) = cellfun(@num2str,cmbhdrs(numhdrs),...
                               fmtstr,'UniformOutput',0);
    [cmbhdrs sortid] = sort(cmbhdrs);
else
    [cmbhdrs sortid] = sort(cmbhdrs);
end;
cmbydata = cmbydata(:,sortid);
cmbedata = cmbedata(:,sortid);
cmbdsIndex = cmbdsIndex(sortid);
cmbxindex = cmbxindex(sortid);
%xdata is not affected by sorting

%-- TODO: run procedure to remove redundant x columns

cmbdataset(1).xdata = cmbxdata;
cmbdataset(1).ydata = cmbydata;
cmbdataset(1).edata = cmbedata;
cmbdataset(1).headers= cmbhdrs;
cmbdataset(1).datasetIdx = cmbdsIndex; 
cmbdataset(1).xindex = cmbxindex;
cmbdataset(1).datasetID = cmbdsID;
cmbdataset(1).dbName = dbases.dbName;
end