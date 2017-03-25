function [fitstruct, message]= mmfit_data(dataset, fitGroupNumber, settings, modelfile)
% [FITSTRUCT MESSAGE] = MMFIT_DATA(fitGroupNumber, settings, modelfile)
% Fits data items that have the same fitGroupNumber simultaneously, using
% modelfile. The model file may implement more than one function for each
% data item. The proper function is chosen according to fitGroupNumber for each
% data item. 
%
% Last modified: 20 Apr 2014 --Reza

[ x_all, y, err ] = deal(dataset(1).xdata, dataset(1).ydata, dataset(1).edata);
%-- create x to be the same size as y and e with corresponding columns
x = x_all(:,dataset(1).xindex);
datagrp = dataset(1).datasetIdx;
dataCount= size(y,2);
xyePlot = cell(1,dataCount);  %Pruned data for plotting purposes
rmMark = false(1,dataCount);
fits = cell(1,dataCount);
confInterval = cell(1,dataCount);
message = '';

[mpath, modelname, ~] = fileparts(modelfile);
addpath(mpath); 
modelfunc = str2func(modelname);

%-- multi model fitting considers data groups separately. 
%   data groups are distinguished by their datasetIdx
fitAlready = [];
for thisgrp = datagrp
    if any(fitAlready) == thisgrp
        continue; % this data group is already fitted
    end
    inthisgroup = false(1,dataCount);
    for ditm = 1:dataCount
        %-- Exclude data out of SETTINGS.PRMXRANGE from fitting 
        if datagrp(ditm) ~= thisgrp; continue; end
        inthisgroup(ditm) = true;
        xcluded = excludedata(x(:,ditm),y(:,ditm),'domain',settings.prmXrange);
        %TODO: weighted fit
    %     if any(e_i); w_i = 1 ./ (e_i);    %weight = 1 / uncertainty
    %     else w_i = zeros(size(y_i));end
        if isempty(x(~xcluded,ditm)) || isempty(y(~xcluded,ditm))
            rmMark(ditm) = 1;
            continue;
        else
            x(xcluded,ditm) = NaN;
            y(xcluded,ditm) = NaN;
            err(xcluded,ditm) = NaN;
            xyePlot{ditm} = [x(:,ditm),y(:,ditm),err(:,ditm)];
        end
    end
    %remove failed fits
    if all(rmMark(inthisgroup))
        message = sprintf('%sNo valid data items exist in dataset %s.\n',...
                            message,dataset(1).datasetID{thisgrp});
                continue;
    elseif any(rmMark(inthisgroup));
        message = sprintf('%sIn set %s, No valid data points found in %s.\n',... 
                    message, dataset(1).datasetID{thisgrp},...
                    strjoin(dataset(1).headers(rmMark(inthisgroup)),', '));
    end

    okay = inthisgroup & ~rmMark;
    % TODO: update bootstrap segment. no longer compatabile with this
    % if settings.chkBootstrap
    %     tic;
    %     [fits, confInterval, n] = btstrpSimFit(modelfunc,x_all, y_all, e_all, groupIdx, settings.prmBtstrpN);
    %     message= sprintf('%s\n%d out of %d bootstrap trials converged (Total time: %2.1f min).',...
    %                   message, n, settings.prmBtstrpN, toc/60);
    % else
    fprintf(1,'fitting group %s\n',dataset(1).datasetID{thisgrp});
    [fits(okay), confInterval(okay), exitflag] = modelfunc(x(:,okay),...
                                         y(:,okay), err(:,okay),...
                                         fitGroupNumber(okay) );
    if exitflag < 0
        message = sprintf('%sFitting failed for dataset %s.\n',...
                            message,dataset(1).datasetID{thisgrp});
    end        
    % end
    fitAlready = [fitAlready, thisgrp];
end 
%create fits structure from parameter values returned
fitstruct = struct('headers',{dataset(1).headers(~rmMark)},...
               'datasetID',{dataset(1).datasetID},...   
               'datasetIdx',{dataset(1).datasetIdx(~rmMark)},...
               'data',{xyePlot},...
               'fits',{fits},...
               'confInt',{confInterval},...
               'xtitle',{settings.prmXtitle},...
               'ytitle',{settings.prmYtitle});

message= strjoin({message,'Multi Model Fit ended normally.'},'\n');
rmpath(mpath);
%TODO: remove after debug
save fitstruct;

end

