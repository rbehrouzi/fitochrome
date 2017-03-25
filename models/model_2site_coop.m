function [cf_ CI_ exitflag] = model_2site_ind(x,y, options)
%fit_hill : Fits Hill equation and returns the fit object

fiteq_ = 'amp*(1-(1/(1+2*C/Kd+(c*C/Kd)^2)))';
fiteq_ = strrep(fiteq_,'amp',sprintf('%e',y(find(x==max(x),1))));

fitcoeff_ = {'Kd','c'}; %Kd is microscopic binding constant
lobound = [min(x) 1]; hibound = [max(x) inf]; st_ = [median(x) 10];



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