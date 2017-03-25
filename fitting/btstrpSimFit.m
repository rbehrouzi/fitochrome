function [initfit, confInt, n] = btstrpSimFit(modelfunc,x_all, y_all, e_all, grpidx,  n)
% [initfit confInt n] = btstrpSimFit(modelfunc,x_all, y_all, e_all, grpidx,  n)
%
% 
% 
%
% MODELFUNC name of m file implementing the function to be fit
%           see manual for conventions
%
% N         number of times residuals are resampled and added to data
%           to create noisy data for fitting
%
% FILENAME  file name to store fitting results
%           the resulting file has N-f rows, where f is the number of
%           failed fits
%
% INITFIT   results of fitting original data without any added noise
%           empty if fitting fails
%
% CONFINT   confidence intervals on fitting parameters calculated from the
%           distribution of the N fits to noisy data
%
% N         The number of times noisy data are refitted


btfits = cell(1,n);
confInt = [];
try
    [initfit, confInt, ~] = modelfunc(x_all, y_all, e_all, grpidx);
catch ME
    display(getReport(ME));
    return;
end
groups = max(grpidx);
initres = zeros(size(y_all));
paramN = zeros(groups,1); paramH = cell(groups,1);
for i=1:groups
    ingrp = grpidx == i;
    initres(ingrp) = feval(initfit{i},x_all(ingrp)) - y_all(ingrp); %initial residuals
    paramN(i) = length(coeffvalues(initfit{i}));
    paramH{i} = coeffnames(initfit{i});
end

initres = repmat(initres,1,n);
ns = length(x_all);
btsample = ceil(ns * rand(ns,n));
btresiduals = initres(btsample);
exitflag = zeros(1,n);
% matlabpool open;
% TODO: figure out why matlabpool does not work
for btN =1:n
    [btfits{btN}, ~, exitflag(btN)] = modelfunc(x_all, y_all+btresiduals(:,btN), e_all, grpidx);
end
% matlabpool close;

btfits(exitflag <= 0) = [];
n = length(btfits);
paramVal = zeros(n,sum(paramN)); paramName = cell(1,sum(paramN));
for bti=1:n
    lasti = 0;
    for grpi=1:groups
        paramVal(bti,lasti+1:lasti+paramN(grpi)) = coeffvalues(btfits{bti}{grpi});
        if bti==1; paramName(lasti+1:lasti+paramN(grpi)) = paramH{i};end
        lasti = lasti + paramN(grpi);
    end
end

%save text file of parameter values in all btstrp repeats
[filename filepath] = uiputfile('*.xls;*.xlsx','Save resampled fit parameters','residual_btstrp');
if ~isempty(filename)
    status = saveBtstrpResultsXls(fullfile(filepath,filename), paramName, paramVal);
end


end
