function [cf_ CI_ exitflag] = model_4site_ind(x,y, options)
%fit_hill : Fits Hill equation and returns the fit object

fiteq_ = 'amp*(1-(1/(1+C/Kd+(C/Kd)^2+(C/Kd)^3+(C/Kd)^4)))';
fitcoeff_ = {'amp', 'Kd'}; %Kd is macroscopic binding constant
lobound = [0 min(x)]; hibound = [inf max(x)]; st_ = [1 median(x)];



fo_ = fitoptions(options,'Lower',lobound, 'Upper',hibound,'Startpoint',st_);

ft_ = fittype(fiteq_,'dependent',{'y'},'independent',{'C'},...
     'coefficients',fitcoeff_);
try
    [cf_, ~, output_] = fit(x,y,ft_,fo_);
    exitflag = output_.exitflag;
    CI_ = confint(cf_, 0.68);
catch
    cf_ = []; CI_=[];
    exitflag = -1;
end
return;