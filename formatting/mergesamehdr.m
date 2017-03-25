function data = mergesamehdr(data, varargin)
% MERGESAMEX(DATA,  VARARGIN)
%
% Averages DATA.YDATA elements that have identical DATA.HEADER values
% varargin{1}   Scaling structure, has two fields (see scaleData)
%               .TYPE
%               .RANGE
%
% varargin{2}   MASKS 
%               must contain these fields:
%              .HEADERS  vector of equal elements as columns in YDATA
%                        columns with 'false' value are removed from data
%              .DATA     logical matrix the same size as YDATA
%                        ydata with 'false' mask are considered as NaN
%              .DATASETS 
%


%TODO: allow scaling of y data with scaleData function
 %     so that headers can be scaled before mergin.
if nargin > 2
    scaling = varargin{1};
    masks = varargin{2};
    [x, y, err, xindex, hdrs] = deal(data(1).xdata,...
                                     data(1).ydata(:,masks.headers),...
                                     data(1).edata(:,masks.headers),...
                                     data(1).xindex(masks.headers),...
                                     data(1).headers(masks.headers));
    datamask = masks.data(:,masks.headers);
    y  (~datamask) = NaN;    
    err(~datamask) = NaN;
    [datasetID datasetIdx] = deal(data(1).datasetID,...
                                  data(1).datasetIdx(masks.headers));
    dsCount = length(datasetID)+1;
    
else
    if nargin == 2
        scaling = varargin{1};
    else
        scaling = [];
    end
    [x, y, err, xindex, hdrs] = deal(data(1).xdata,...
                                     data(1).ydata,...
                                     data(1).edata,...
                                     data(1).xindex,...
                                     data(1).headers);
    [datasetID datasetIdx] = deal(data(1).datasetID,...
                                  data(1).datasetIdx);
    dsCount = length(datasetID)+1;
end
n = size(x,1);           %number of rows in x (same in y and err)

% rptCount is the number of times each column is followed by an identical header
rptCount = get_repeats(hdrs); 
groups = find(rptCount>0); grpCount = length(groups);
if grpCount==0
    if ~isempty(scaling)
        [data(1).ydata data(1).edata] = ...
            scaleData(y,err,scaling.type,x(:,xindex),scaling.range);
    end
    return;
end

%FIX: columns that are not repeated are not scaled 
if all(diff(xindex)==0)
    xMrg = repmat(x,max(rptCount)+1,1);
    singleX = true;
else
    xMrg = NaN(n*(max(rptCount)+1),size(x,2)+grpCount);
    xMrg(1:n,1:size(x,2)) = x;
    singleX = false;
end
yMrg = NaN(size(xMrg,1),size(y,2)); yMrg(1:n,:) = y;
eMrg = NaN(size(xMrg,1),size(y,2)); eMrg(1:n,:) = err;
rmMark = false(size(hdrs));
newXcol = size(x,2)+1;
for g=1:length(groups)
    cIndex = groups(g);rptN = rptCount(cIndex); catlength=n*(rptN+1);
    rmMark(cIndex+1:cIndex+rptN) = 1;
    if ~all(datasetIdx(cIndex:cIndex+rptN) == datasetIdx(cIndex))
        datasetID{dsCount} = 'merged';    %ID for merged columns of multiple datasets
        datasetIdx(cIndex) = dsCount;
    end
    if isempty(scaling)
        ytmp = y(:,cIndex:cIndex+rptN);
        etmp = err(:,cIndex:cIndex+rptN);
    else
        [ytmp etmp] = scaleData(y(:,cIndex:cIndex+rptN),...
                        err(:,cIndex:cIndex+rptN),scaling.type,...
                        x(:,xindex(cIndex:cIndex+rptN)),scaling.range);
    end
    yMrg(1:catlength,cIndex) = reshape(ytmp,[],1);
    eMrg(1:catlength,cIndex) = reshape(etmp,[],1);
    if ~singleX 
        % if different xdata columns exist, make a new column for each
        % repeated group of ydata columns. They are checked for possible
        % consolidation later
        xtmp = zeros(catlength,1);
        for i=1:rptN+1; xtmp((i-1)*n+1:i*n) = x(:,xindex(cIndex+i-1));end
        xMrg(1:catlength,newXcol) = xtmp;
        xindex(cIndex) = newXcol;
        newXcol = newXcol+1;
    end
end
yMrg(:,rmMark) = []; eMrg(:,rmMark) = [];
xindex(rmMark) = []; hdrs(rmMark) = []; datasetIdx(rmMark) = [];
[xMrg sortid] = sort(xMrg,1);
if isvector(yMrg)
    yMrg = yMrg(sortid(:,xindex)); eMrg = eMrg(sortid(:,xindex));
else
    for j = 1:size(xMrg,2)
        ycols = (xindex==j);
        yMrg(:,ycols)   = yMrg(sortid(:,j),ycols); 
        eMrg(:,ycols) = eMrg(sortid(:,j),ycols); 
    end
end

%TODO: consolidateX


[data(1).xdata,data(1).ydata,data(1).edata,data(1).xindex,...
data(1).headers, data(1).datasetIdx, data(1).datasetID] ...
             = deal(xMrg, yMrg, eMrg, xindex, hdrs, datasetIdx, datasetID);
end
