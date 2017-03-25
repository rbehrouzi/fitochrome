function [cf_ CI_ exitflag] = model_exp_decay(x,y, options)
%fit_hill : Fits mono exponential decay
%           y = baseline - amplitude*(1-exp(-kt))

fiteq_ = 'bline - amp*(1-exp(-k*t))';
fitcoeff_ = {'bline', 'amp', 'k' };
lobound = [0 0 0]; 
hibound = [max(y) max(y) inf]; 
st_ = [min(y) max(y)-min(y) 1];
fo_ = fitoptions(options,'Lower',lobound, 'Upper',hibound,'Startpoint',st_);

ft_ = fittype(fiteq_,'dependent',{'y'},'independent',{'t'},...
     'coefficients',fitcoeff_);
try
    [cf_, ~, output_] = fit(x,y,ft_,fo_);
    exitflag = output_.exitflag;
    CI_ = confint(cf_, 0.68);
catch
    exitflag = -1;
end
return;