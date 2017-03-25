function [x y err] = mergeColumnsByX(x, y, err, xindex)
% in each column of y, average data values that have identical x values
% if err for both of the values is finite, propagate error
% otherwise set error to standard deviation of the averaged data

n=size(x,2);
[x sortid] = sort(x,1);
if isvector(y)
    y = y(sortid); err = err(sortid);
else
    for j = 1:n
        ycols = (xindex==j);
        y(:,ycols)   = y  (sortid(:,j),ycols); 
        err(:,ycols) = err(sortid(:,j),ycols); 
    end
end

for xcol=1:n
    repeated = [0; diff(x(:,xcol))==0]; %repeats,but not the first instance are marked
    rptIndex = find(repeated);    %index of repeated x values
    if isempty(rptIndex); continue;end
    rptDistance = [diff(rptIndex); 0];   

    rmMark = false(size(x,1),1); %Marks elements to be removed after averaging
    begAvg = max(1,rptIndex(1)-1);
    for i=1:length(rptIndex)
        rmMark(rptIndex(i))=1;
        if rptDistance(i)==1; continue;end %another repeat of the same is next
        
        y(begAvg,xindex==xcol) = nanmean(y(begAvg:rptIndex(i),xindex==xcol));   %overwrite first element of repeat
        % if all averaged y points have errors, then propagate
        % if not calculate st. deviation
        if all(isfinite(err(begAvg:rptIndex(i),xindex==xcol)))
            err(begAvg,xindex==xcol) = ...
                sqrt(sum(err(begAvg:rptIndex(i),xindex==xcol).^2, 1))./length(begAvg:rptIndex(i));
        else
            err(begAvg,xindex==xcol) = nanstd(y(begAvg:rptIndex(i),xindex==xcol));
        end
        if i<length(rptIndex); begAvg = rptIndex(i+1)-1;end
    end
    % remove other instances of the repeat
    x(rmMark,xcol) = NaN; 
    y(rmMark,xindex==xcol) = NaN; 
    err(rmMark,xindex==xcol) = NaN; 
end

%sort x and then sort y and error based on x
[x sortid] = sort(x,1);
emptyxlines = all(isnan(x),2);   %find rows that are all NaN
if isvector(y)
    y = y(sortid); err = err(sortid);
else
    for j = 1:n
        ycols = (xindex==j);
        y(:,ycols)   = y  (sortid(:,j),ycols); 
        err(:,ycols) = err(sortid(:,j),ycols); 
    end
end
x(emptyxlines,:) = [];
y(emptyxlines,:) = [];
err(emptyxlines,:) = [];
