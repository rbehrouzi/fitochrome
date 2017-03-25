function [cf_, CI_, exitflag] = model_2exp(x,y, options)
%fit_hill : Fits mono exponential decay
%           y = baseline - amplitude*(1-exp(-kt))

fiteq_ = 'amp1.*exp(-k1.*t)+(range-amp1).*exp(-k2.*t)';
%Now replace "range" in the equation with the y value of the first point
fiteq_ = strrep(fiteq_,'range',sprintf('%5.4e',y(1))); 
fitcoeff_ = {'amp1', 'k1', 'k2' };
lobound = [max(y)/10 0.1 0.001]; 
hibound = [max(y) 100 1]; 
st_ = [max(y) 2 0.1];
fo_ = fitoptions(options,'Lower',lobound, 'Upper',hibound,'Startpoint',st_);
CI_ = '';

ft_ = fittype(fiteq_,'dependent',{'y'},'independent',{'t'},'coefficients',fitcoeff_);
try
    [cf_, ~, output_] = fit(x,y,ft_,fo_);
    exitflag = output_.exitflag;
%     CI_ = confint(cf_, 0.68);
catch
    exitflag = -1;
end
return;