function [cf_ CI_ exitflag] = model_hill_01(x,y, options)
%fit_hill : Fits Hill equation and returns the fit object

fiteq_ = '(C^n)/(C^n+Cm)';

fitcoeff_ = {'Cm', 'n'};
lobound = [0 0]; hibound = [max(x) 20]; st_ = [median(x) 1];
fo_ = fitoptions(options,'Lower',lobound, 'Upper',hibound,'Startpoint',st_);
ft_ = fittype(fiteq_,'dependent',{'y'},'independent',{'C'},...
     'coefficients',fitcoeff_);
try
    [cf_, ~, output_] = fit(x,y,ft_,fo_);
    exitflag = output_.exitflag;
    CI_ = confint(cf_, 0.68);
catch
    exitflag = -1;
end
return;