function [fits, confInt, exitflag] = gsmFit_example(x, y, err, varargin)
%--- [FITS, CONFINT, EXITFLAG] = gsmFit_example(X, Y, ERR, VARARGIN)
%
%    Fits items of (x,y,err) data simultaneously with a set of common and 
%    data-specific fitting parameters. Each triplet of x,y,e columns is a
%    data item.
%    Fitting model: 
%       Line and hyperbola.
%
%    Return values:
%       FITS:       same size as data groups, cfit object
%       CONFINT:    confidence intervals for fit parameters
%       EXITFLAG:   indicate the state of function, see lsqcurvefit
%
%    Inputs:
%       X:          matrix of x values corresponding to y columns
%       Y:          matrix of data (data items organized in columns)
%       ERR:        matrix of uncertainties associated with y columns
%      Varargin:
%
% Last modified : 26 Feb 2015 --Reza 

% Trix metadata
%-% begin gsmfit
%-% globalp 3
%-% localp 1
%-% end

[xvec, yvec, errvec, fitgrpvec] = vectorizeDataMatrix(x,y,err,fitChoice);
%-------------------------------------

%--- define parameter and independent variable names
%--  and write the equation strings for all the models
equations = {'a.*x + b',...
             'a.*x.^2 + b.*x + c'};
indVar = 'x';
fitParams = {'a','b','c'};    

%--- define lower bound, start guess, higher bound for each parameter
%--- order of elements must match the order in 'fitparams'
lb = [0, 0, 0]; %low bound
p0 = [1, 10, 1]; %starting guess
ub = [inf, inf, inf]; %high bound

%-- specify any further options for optimization
options = optimset('Display','on');

%-- This function implements the models for all data types
%-- p: vector of parameter values, x: independent var values
function yfit = modelImplementation(p,x)
    % function array of statfactors to be implemented in fitting function
    % a = p(1); b = p(2); c=p(3)
    models = {@(x,p)(p(1).*x + p(2)),...
              @(x,p)(p(1).*x.^2 + p(2).*x + p(3))};
    yfit = zeros(size(x));
    for fg=fittype_index
        yfit(fg == fitgrpvec) = models{fg}(x(fg == fitgrpvec),p);     
    end
end

%--- find global optimum values for fit parameters
[p_hat, ~,~,exitflag] = lsqcurvefit(@modelImplementation,p0,xvec,yvec,lb,ub,options);
    %TODO: weighted fit:
    % weights = 1./errvec;
    % p_hat = lsqcurvefit(@eval3state,p0,x_vec,weights.*y_vec,lb,ub);
    %TODO: use lsqnonlin instead, and then nlparci to get conf. intervals

%--- create fit objects for each data item
%    This will be used in other modules for plotting and query    
dataCount = size(y,2);
fits = cell(1,dataCount);
confInt = cell(1,dataCount);
for itm=1:dataCount
   if fitChoice(itm) == 1 %line
       ffun = fittype(equations{fitChoice(itm)},...%model equation
                  'independent',indVar,...
                  'coefficients',fitParams(1:2));
       fits{itm} = cfit(ffun,p_hat(1),p_hat(2));
   elseif fitChoice(itm) == 2 %hyperbole
       ffun = fittype(equations{fitChoice(itm)},...%model equation
                  'independent',indVar,...
                  'coefficients',fitParams);
       fits{itm} = cfit(ffun,p_hat(1),p_hat(2),p_hat(3));
   end 
end
end