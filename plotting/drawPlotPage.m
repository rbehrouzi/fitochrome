function drawPlotPage(fitnplt,settings, figRowCol)
% Create figures and draw fits and data in FITNPLT
% Draw PLOTSPERPAGE plots in each figure
% fits with identical FITNPLT.PLOTGROUP values are plotted together
% color of each data is determined by FITNPLT.COLORGROUP

warning('off','MATLAB:Axes:NegativeDataInLogAxis');

colorwheel = {'black','blue','cyan','green','magenta','red'}; 
%--- TODO: generalize ticks
ticks = [0.001 0.01 0.1 1 10 100 1000 10000];
pageCap = figRowCol(1)*figRowCol(2);

if iscell(fitnplt(1).datasetID); figname = fitnplt(1).datasetID{1};
else figname = fitnplt(1).datasetID; end
xlog=false; if strcmpi(settings.prmXscale,'log'); xlog = true;end
createNewFig = true;

for grp = 1:max(fitnplt.plotGroup)
    %-- Prepare figure for plot, one plot per plotGroup
    if createNewFig
        curfig = figure('Name',...
                        [figname,'-',num2str(ceil(grp/pageCap))],...
                        'NumberTitle', 'off','Tag','batchfitplot');
        createNewFig = false;
        set(curfig, 'Visible',settings.chkVisible);
    end
    plotIndex = rem(grp,pageCap);
    if plotIndex == 0   % last plot to be on this page
        plotIndex = pageCap; 
        createNewFig = true;
    end;
    thisPlot = subplot(figRowCol(1), figRowCol(2),plotIndex);
    pltTitle='';
    hold on;
    
    %-- plot all data in this plotGroup
    grpMembers = fitnplt.plotGroup == grp;
    data = fitnplt.data(grpMembers); 
    fits = fitnplt.fits(grpMembers);
    hdrs = fitnplt.headers(grpMembers); 
    clrIndex = rem(fitnplt.colorGroup(grpMembers),length(colorwheel));
    clrIndex(clrIndex==0) = length(colorwheel);
    yRange = [inf -inf]; xRange = [inf -inf];
    for itm = 1:sum(grpMembers)
        x_i = data{itm}(:,1); y_i = data{itm}(:,2); e_i = data{itm}(:,3);
        if xlog %if x axis is log scale,remove negative x
            posX=x_i>0; 
            x_i = x_i(posX);y_i = y_i(posX);e_i = e_i(posX);
        end 
        if isempty(x_i);continue;end
        %-- Plot data and fit
        errorbar(x_i, y_i, e_i,...
            'Parent',thisPlot,'Color',colorwheel{clrIndex(itm)},...
            'LineStyle','none','LineWidth',1.2,'Marker','o', 'MarkerSize',8);
%         plot(x_i, y_i,...
%             'Parent',thisPlot,'Color',colorwheel{clrIndex(itm)},...
%             'LineStyle','none','LineWidth',1.2,'Marker','o', 'MarkerSize',8);
        h_ = plot(fits{itm},'fit',0.95);
        set(h_,'Color',colorwheel{clrIndex(itm)},...
            'LineStyle','-','LineWidth',1,'Marker','none', 'MarkerSize',6);
        yRange = [min([y_i; yRange(1)]),max([y_i; yRange(2)])];
        xRange = [min([x_i; xRange(1)]),max([x_i; xRange(2)])];
%         plot([1 1],yRange,'r-');plot([10 10],yRange,'b-');
        pltTitle = strcat(pltTitle,...
            '\color{',colorwheel{clrIndex(itm)},'}',...
            num2str(hdrs{itm}),', ');
%             '\bf{',num2str(hdrs{itm}),'} ,');
    end
    
%     thisXtick = ticks(ticks >= xRange(1) & ticks <= xRange(2));
    set(thisPlot,'LineWidth',1.2,'Box','on',...
                 'XScale',settings.prmXscale, 'XMinorTick','on',...
                 'XLim',xRange,'Ylim',yRange);
%                  'XLim',[1e-7 1e-5],'Ylim',yRange);
%                'XTick',thisXtick,'XTickLabel',sprintf('%1.2f|',thisXtick),...%                  
    xlabel(thisPlot,fitnplt.xtitle);               
    ylabel(thisPlot,fitnplt.ytitle);       
    title(pltTitle,'FontSize',12);
    legend off; 
end
end