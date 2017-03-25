function removeOnClick(plotObj,currentPoint)
% REMOVEONCLICK(PLOTOBJ,CURRENTPOINT)
%
% Finds the closest data point in PLOTOBJ to the click location stored in 
% CURRENTPOINT and hides that point from the plot. It also updates the mask
% to mark the removal of the point.

handles = guidata(gcbf); 

%--- Find the data point nearest to the clicked point
x = get(plotObj,'xdata');y = get(plotObj,'ydata');  % x and y coordinates
xdiff = abs( x - currentPoint(1,1)); ydiff = abs( y - currentPoint(1,2));
diff = xdiff./nanmean(x) + ydiff./nanmean(y);
idx = find (diff == min(diff));

%--- Update mask to reflect the removed point
%    The Tag of the errorbarseries is set to the containing uitree followed
%    by the index of plotted data in database.ydata or newdb.ydata
hdrIdx = str2double(regexpi(get(plotObj,'Tag'),'\d*','match'));
% sourceTree = regexpi(get(plotObj,'Tag'),'\D*','match');
whichPoint = ( x == x(idx) & y == y(idx) );  
% if strcmpi(sourceTree,'AllData')
handles.masks.data( whichPoint, hdrIdx) = false;
% end

%--- Visual changes to plot
x(idx) = NaN;y(idx) = NaN;
set(plotObj,'xdata',x,'ydata',y);

guidata(gcbf,handles);
[~,cFig,~] = fileparts(get(gcbf,'FileName'));
eval([cFig,'(''smPlotNow_Callback'',handles.axesPlot,[],handles)']);
