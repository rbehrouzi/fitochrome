function dtbase = tidyUpDatabase(dtbase)
% db = tidyUpDatabase(db)
%
% 1. Remove unreferenced x columns and datasetIDs that may have formed 
%    during merge opertations of databases or headers
% 2. Sort x data ascendingly and y data according to x
% 3. Remove redundant copies of x columns


%--- remove unused x columns and update xindex
xRM = false(1,size(dtbase.xdata,2));
xshift = zeros(size(dtbase.xindex));
for xi=1:length(xRM)
    if ~any(dtbase.xindex == xi); xRM(xi) = true; end
end
if any(xRM)
    xRMind = find(xRM);
    for xi=xRMind
        xshift(dtbase.xindex > xi ) = xshift(dtbase.xindex > xi ) +1;
    end
end
dtbase.xdata(:,xRM) = [];
dtbase.xindex = dtbase.xindex - xshift;

%--- remove unused datasetID's and update datasetIdx
dsRM = false(1,length(dtbase.datasetID));
dsshift = zeros(size(dtbase.datasetIdx));
for dsi=1:length(dsRM)
    if ~any(dtbase.datasetIdx == dsi); dsRM(dsi) = true; end
end
if any(dsRM)
    dsRMind = find(dsRM);
    for dsi=dsRMind
        dsshift(dtbase.datasetIdx > dsi ) = dsshift(dtbase.datasetIdx > dsi ) +1;
    end
end
dtbase.datasetID(:,dsRM) = [];
dtbase.datasetIdx = dtbase.datasetIdx- dsshift;

%--- sort x and re-order corresponding y columns
[dtbase.xdata sidx] = sort(dtbase.xdata,1);
if isvector(dtbase.ydata)
    dtbase.ydata = dtbase.ydata(sidx(:,dtbase.xindex)); 
    dtbase.edata = dtbase.edata(sidx(:,dtbase.xindex));
else
    for xi = 1:size(dtbase.xdata,2)
        ycols = (dtbase.xindex==xi);
        dtbase.ydata(:,ycols) = dtbase.ydata(sidx(:,xi),ycols); 
        dtbase.edata(:,ycols) = dtbase.edata(sidx(:,xi),ycols); 
    end
end
emptylines = all(isnan(dtbase.ydata),2);   
dtbase.ydata(emptylines,:) = [];
dtbase.edata(emptylines,:) = [];
dtbase.xdata(emptylines,:) = [];

%--- compare all x columns and keep only one copy of identical columns
%    update xindex to reflect this change
n = size(dtbase.xdata,2); xRM = false(1,n); xi_new = 0;
for xi=1:n
    if xRM(xi); continue; end
    xi_new = xi_new + 1;
    thisx = repmat(dtbase.xdata(:,xi),1,n);
    diffx = dtbase.xdata - thisx;
    eqx = ~any(diffx,1);     % row vector with 1 at equal columns to thisx
    eqidx = find(eqx);
    if length(eqidx) > 1
        for ii=eqidx
            dtbase.xindex(dtbase.xindex == ii) = xi_new;
        end
        eqx(xi) = false; xRM(eqx) = true;
    else
        dtbase.xindex(dtbase.xindex==eqidx) = xi_new;
    end
end
dtbase.xdata(:,xRM) = [];

%--- compare all datasetID's and keep only one copy of identical ones
%    update datasetIdx to reflect this change
n = size(dtbase.datasetID,2); dsRM = false(1,n); dsi_new = 0;
for dsi=1:n
    if dsRM(dsi); continue; end
    dsi_new = dsi_new + 1;
    eqds = strcmpi(dtbase.datasetID{dsi}, dtbase.datasetID);
    eqidx = find(eqds);
    if length(eqidx) > 1
        for ii=eqidx
            dtbase.datasetIdx(dtbase.datasetIdx == ii) = dsi_new;
        end
        eqds(dsi) = false; dsRM(eqds) = true;
    else
        dtbase.datasetIdx(dtbase.datasetIdx==eqidx) = dsi_new;
    end
end
dtbase.datasetID(:,dsRM) = [];

end