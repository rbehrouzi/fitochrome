function data = mergesamex(data, varargin)
% MERGESAMEX(DATA,  VARARGIN)
%
% Averages DATA.YDATA elements that have identical DATA.XDATA values
% If a second argument is present, it is taken to be MASKS
% MASKS must contain these fields:
%   .HEADERS  vector of equal elements as columns in YDATA
%             columns with 'false' value are removed from data
%   .DATA     logical matrix the same size as YDATA
%             ydata with 'false' mask are considered as NaN

if nargin > 1
    masks = varargin{1};
    [x, y, err, xindex, hdrs, dsIdx] = deal(data(1).xdata,...
                                     data(1).ydata(:,masks.headers),...
                                     data(1).edata(:,masks.headers),...
                                     data(1).xindex(masks.headers),...
                                     data(1).headers(masks.headers),...
                                     data(1).datasetIdx(masks.headers));
    datamask = masks.data(:,masks.headers);
    y  (~datamask) = NaN;    
    err(~datamask) = NaN;
else
    [x, y, err, xindex] = deal(data(1).xdata, data(1).ydata,...
                               data(1).edata,...
                               data(1).xindex);
end    

[x y err] = mergeColumnsByX(x,y,err,xindex);

%-- TODO: consolidateX
[data(1).xdata, data(1).ydata,data(1).edata] = deal(x, y, err);
if nargin > 1
    data(1).headers = hdrs; data(1).datasetIdx = dsIdx;
end
