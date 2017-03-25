function [initfit, confInt, n] = btstrpFit(modelfunc,x_i, y_i, fopt,  n, filename)
% [initfit confInt n] = btstrpFit(modelfunc,x_i, y_i, fopt,  n, filename)
%
% fits MODELFUNC to [x_i,y_i] data pairs N times, where [x_i,y_i] are
% original data plus resampled residuals of the previous fit
%
% MODELFUNC name of m file implementing the function to be fit
%           see manual for conventions
%
% X_I, Y_I  data pair to be fit
%
% FOPT      fit options, see manual for conventions
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
try
    [initfit, confInt] = modelfunc(x_i, y_i, fopt);
catch ME
    display(getReport(ME));
    initfit = [];
    return;
end
initres = feval(initfit,x_i) - y_i; %initial residuals
paramVal = zeros(n,length(coeffvalues(initfit))); 
paramName = coeffnames(initfit);


initres = repmat(initres,1,n);
ns = length(x_i);
btsample = ceil(ns * rand(ns,n));
btresiduals = initres(btsample);

exitflag = zeros(1,n);
%TODO: figure out why parfor doesnt work
for btN =1:n
    [btfits{btN}, ~, exitflag(btN)] = modelfunc(x_i, y_i+btresiduals(:,btN), fopt);
end

btfits(exitflag <= 0) = []; %fit not converged or failed
n = length(btfits);
for bti=1:n
    paramVal(bti,:) = coeffvalues(btfits{bti});
end

%save excel file of parameter values in all btstrp repeats
%TODO: take care of status
status = saveBtstrpResults(filename, paramName, paramVal);

end
