function [fitstruct, msg]= fit_data(dataset, settings, modelfile)
% 
% [fitstruct msg]= fit_data(dataset, settings, modelfile)
%
% fits the function implemented by MODELFILE to data stored in DATASET
% DATASET is a structure containing XDATA, YDATA, EDATA which are matrices
%         of the same size, with corresponding [x,y,err] columns
% 
% SETTINGS is a structure containing fitting and data options
%          Check Trix manual for valid settings
%
% MODELFILE is the function to be fit. Check Trix manual for description.
%
% FITSTRUCT is a structure with these fields
%     HEADERS       data column names
%     DATASETID     dataset names
%     DATASETIDX    index of which dataset each data column belongs to
%     DATA          [x,y,err] of data which were fit
%     FITS          cfit objects
%     CONFINT       confidence intervals obtained from fits or bootstrap
%     XTITLE        x axis title
%     YTITLE        y axis title


[mpath, modelname, ~] = fileparts(modelfile);
addpath(mpath); %add the path to matlab file to MATLAB search path

[ x, y, err ] = deal(dataset(1).xdata, dataset(1).ydata, dataset(1).edata);
dataCount= size(y,2);
fits = cell(1,dataCount); confInterval = fits;    %cfit results and CI
xyePlot = cell(1,dataCount);  %Pruned data for plotting purposes
rmMark = false(1,dataCount);
msg='';

if settings.chkBootstrap
    % ask for folder to save files, use column header as file name
    % replace illegal characters in column header with _ in filename
    foldername = uigetdir(pwd,'Select or create a folder to save bootstrap result files');
    if foldername==0; fitstruct = []; msg = {'Canceled'}; return; end
end

for ycol = 1:dataCount
    %-- Prepare data for fitting
    x_i = x(:,dataset(1).xindex(ycol)); y_i = y(:,ycol); e_i = err(:,ycol);
    ok_ = isfinite(x_i) & isfinite(y_i);    
    x_i = x_i(ok_); y_i = y_i(ok_); e_i = e_i(ok_); %remove Inf and NaN
%     if any(e_i); w_i = 1 ./ (e_i);    %weight = 1 / uncertainty
%     else w_i = zeros(size(y_i));end
    
    %TODO: weighted fit
    if isempty(x_i) || isempty(y_i);rmMark(ycol) = 1;continue;end

    %-- Exclude data out of SETTINGS.PRMXRANGE from fitting 
    xcluded = excludedata(x_i,y_i,'domain',settings.prmXrange);
    xyePlot{ycol} = [x_i,y_i,e_i];
    fopt = fitoptions('Method','NonlinearLeastSquares',...
                      'MaxFunEvals',1000,'Exclude', xcluded);
    modelfunc = str2func(modelname);
    
    if settings.chkBootstrap
        %TODO: make message output to text window asynchronous
        fn = dataset(1).headers{ycol}; fn(regexpi(fn,'[\\/?:*<>"|]')) = '_'; 
        filename = fullfile(foldername,fn);
        tic;
        [fits{ycol}, confInterval{ycol}, n] = btstrpFit(modelfunc, x_i, y_i, fopt, settings.prmBtstrpN, filename);
        if isempty(fits{ycol})
            rmMark(ycol) = 1;
            msg= sprintf('%s\nInitial fit failed. Bootstrap cannot continue for %s',...
                              msg,num2str(dataset(1).headers{ycol}));
            continue;
        else
            msg= sprintf('%s\n%s: %d out of %d bootstrap trials converged (Total time: %2.1f min).',...
                      msg, num2str(dataset(1).headers{ycol}),n, settings.prmBtstrpN, toc/60);
        end
    else
        %TODO: utilize exit flag
        [fits{ycol}, confInterval{ycol}, exitflag] = modelfunc(x_i, y_i, fopt);
        % TODO: weighted fit
        if exitflag <= 0
            fits{ycol} = []; confInterval{ycol} = [];
            rmMark(ycol) = 1;
            continue;
        end
    end
end

if all(rmMark)
    msg = {'Could not fit any of data items.'};
elseif any(rmMark);
    failedfits = '';
    for i=dataset(1).headers(rmMark)
        failedfits = sprintf(' %s %s',failedfits,num2str(i{1}));
    end
    msg = {msg;'Could not fit these data items:';failedfits};
    msg = [msg; {sprintf('%d data items were fit successfully.',...
                                sum(~rmMark))}];
else
    msg = {msg;sprintf('%d data items were fit successfully.',dataCount)};
end
 
%remove failed fits
xyePlot(rmMark) = []; fits(rmMark) = [];

fitstruct = struct('headers',{dataset(1).headers(~rmMark)},...
                   'datasetID',{dataset(1).datasetID},...   
                   'datasetIdx',{dataset(1).datasetIdx(~rmMark)},...
                   'data',{xyePlot},...
                   'fits',{fits},...
                   'confInt',{confInterval},...
                   'xtitle',{settings.prmXtitle},...
                   'ytitle',{settings.prmYtitle});

%TODO: remove after debug
save fitstruct;
rmpath(mpath);
end

