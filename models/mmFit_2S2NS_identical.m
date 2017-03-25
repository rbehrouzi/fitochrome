function [fits, confInt, exitflag] = mmFit_2S2NS_identical(x, y, err, varargin)
%--- [FITS, CONFINT, EXITFLAG] = simFit_2S2NS_simple(X, Y, ERR, GROUPIDX, VARARGIN)
%
%    Fits items of (x,y,err) data simultaneously with a set of common and 
%    data-specific fitting parameters. Each triplet of x,y,e columns is a
%    data item.
%    Fitting model: 
%       Binding of macromolecule with 2 specific and 2
%       nonspecific binding sites to two ligands. Possible binding modes are
%       one or two nonspecific, one or two specific, or one specific and one
%       non-specific ligands. Sites in each group are identical.
%       Fitting parameters are binding constants for specific and
%       nonspecific sites, linkage between two nonspecifically bound
%       ligands, linkage between two specifically bound ligands
%       Binding to nonspecific and specific sites is assumed to have Hill
%       coefficient of 1.
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
%       {1} fitGroup  Numerical array, indicates function to use for
%                       fitting. Permitted values: 1, 2, 3, or 4
%                       1. lowest band corresponding to NCP
%                       2. middle group of bands and smears. 
%                          Sum of one, two nonspecifically bound 
%                          Sir3, and one specific plus one
%                          nonspecifically-bound Sir3
%                       3. NCP bound to one Sir3 specifically
%                       4. NCP bound to two Sir3 specifically
%
% Last modified : 26 Feb 2015 --Reza 

% Trix metadata
%-% begin mmfit
%-% pnumber 4
%-% fit_group 1 NCP
%-% fit_group 2 NS_nonspecific
%-% fit_group 3 NCP_S
%-% fit_group 4 NCP_S2
%-% end

fitChoice = varargin{1};
dataCount = size(y,2);
if size(fitChoice,1)>1; fitChoice=fitChoice';end
[xvec, yvec, errvec, fitgrpvec] = vectorizeMMFitData(x,y,err,fitChoice);
%-------------------------------------

%-- specify the indexes of fit types defined in metadata
fittype_index = [1 2 3 4];

%--- define parameter and independent variable names
%--  and write the equation strings for all the models
equations = cell(1,dataCount);
statfactors = {'1',...
               '2.*Kns.*S + 2*Ks.*Kns.*S.^2 + 0.5*Lns.*Kns.^2*S.^2',...
               '2.*Ks.*S',...
               '0.5.*Ls.*Ks.^2*S.^2'};
pfunc = ['(',strjoin(statfactors,'+'),')']; %partition function
for item=1:dataCount
   equations{item}= ['(',statfactors{fitChoice(item)},')./',pfunc]; %fitting equation
end
fitParams = {'Kns','Lns','Ks','Ls'};    
indVar = 'S';   
%--- define %lower bound, start guess, higher bound for each parameter
%--- order of elements must match the order in 'fitparams'
Kns = [1./nanmax(xvec), 1.0/5, 1]; 
Ks =  [1./nanmax(xvec), 1.0/50, 1];
Lns = [0, 1, 1000];
Ls =  [0, 100, 1000];
lb = [Kns(1), Lns(1), Ks(1), Ls(1)]; %low bound
p0 = [Kns(2), Lns(2), Ks(2), Ls(2)]; %starting guess
ub = [Kns(3), Lns(3), Ks(3), Ls(3)]; %high bound

options = optimset('Display','on');

%-- This function implements the models for all data types
%-- p: vector of parameter values, x: independent var values
function yfit = modelImplementation(p,x)
    % function array of statfactors to be implemented in fitting function
    % Kns = p(1); Lns = p(2); Ks = p(3); Ls = p(4);
    statval = {@(S,c)(1),...
           @(S,c)(2*c(1)*S + 2*c(3)*c(1)*S.^2 + 0.5*c(2)*c(1).^2*S.^2),...
           @(S,c)(2*c(3)*S),...
           @(S,c)(0.5*c(4)*c(3).^2*S.^2)};
    yfit = zeros(size(x));
    pfuncval = 1 + 2*p(1)*x + 2*p(3)*p(1)*x.^2 + 0.5*p(2)*p(1).^2*x.^2 ...
               + 2*p(3)*x + 0.5*p(4)*p(3).^2*x.^2;
    for fc=fittype_index
        yfit(fc == fitgrpvec) = statval{fc}(x(fc == fitgrpvec),p) ./ ...
                              pfuncval( fc == fitgrpvec);     
    end
    %TODO: weighted fit:
%     yfit = yfit.*weights;
end

%--- find global optimum values for fit parameters
[p_hat, ~,~,exitflag] = lsqcurvefit(@modelImplementation,p0,xvec,yvec,lb,ub,options);
    %TODO: weighted fit:
    % weights = 1./errvec;
    % p_hat = lsqcurvefit(@eval3state,p0,x_vec,weights.*y_vec,lb,ub);
    %TODO: use lsqnonlin instead, and then nlparci to get conf. intervals
fits = cell(1,dataCount);
confInt = cell(1,dataCount);
for itm=1:dataCount
   ffun = fittype(equations{fitChoice(itm)},...%model equation
              'independent',indVar,...
              'coefficients',fitParams);
   fits{itm} = cfit(ffun,p_hat(1),p_hat(2),p_hat(3),p_hat(4));
end
end