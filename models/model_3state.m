function [cf_ CI_ exitflag] = model_3state(x,y,options)
%model_3state: Uses a partition function with three states 
%              The weight of each species is determined by (C/Cm)^n 
%              upper baseline is fit from data, bottom baseline is 0
%              if midpoints of the states are well-separated, don't use
%              this file. Use sum of two Hill equations instead
%
%             Last modified : 25 Jun 2012 --Reza

ymax = max(y); ymin = min(y);
minx = find(x==min(x),1); maxx = find(x==max(x),1);

if  y(minx) > y(maxx)           % descending
    lobound = [   ymin      ymin        min(x)    min(x)   0     0];
    hibound = [   ymax      ymax        max(x)   max(x)    20    20];
    st_ =     [   ymax      ymax-ymin   median(x)   max(x)    1     1];
    fitcoeff_ = {'bline', 'ampI',       'CmI', 'CmF','nI', 'nF'};
    fiteq_ = ['(bline +ampI*(C/CmI)^nI)',...
              '/( 1+(C/CmI)^nI + (C/CmF)^nF )'];
%     fiteq_ = strrep(fiteq_,'ampF',sprintf('%d-ampI',ymax-ymin));
else                           % ascending
    lobound = [   ymin      ymin        min(x)    min(x)   0     0];
    hibound = [   ymax      ymax        max(x)   max(x)    20    20];
    st_ =     [   ymax      ymax-ymin   median(x)   max(x)    1     1];
    fitcoeff_ = {'bline',   'ampI',     'CmI', 'CmF','nI', 'nF'};
    fiteq_ = ['( ampI*(C/CmI)^nI + bline*(C/CmF)^nF )',...
              '/( 1+(C/CmI)^nI + (C/CmF)^nF )'];
%     fiteq_ = strrep(fiteq_,'ampF',sprintf('%d-ampI',ymax-ymin));
end

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
