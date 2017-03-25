function [cf_ CI_ exitflag] = model_2hills_0start(x,y,options)
%model_2hills : two consecutive Hill equations, ascending or descending
%             Works best when the two transitions have well-separated
%             midpoints, otherwise don't use this. Instead, use a fit with
%             a three-state partition function
%
%             Last modified: 21 Jun 2012 --Reza 

ymax = max(y); ymin = min(y);

lobound = [ ymin   0  0   0   0];
hibound = [ ymax   max(x)  max(x)  20  20];
st_ = [ymax-ymin median(x) max(x) 1 1];
fitcoeff_ = {'ampI', 'CmI', 'CmF','nI', 'nF'};
fiteq_ = [' ampI *(C/CmI)^nI/( 1+(C/CmI)^nI ) + ',...
          '(ampF)*(C/CmF)^nF/( 1+(C/CmF)^nF )'];
fiteq_ = strrep(fiteq_,'ampF',sprintf('%d-ampI',ymax-ymin));

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
