function [cf_ CI_ exitflag] = model_quadratic(x,y, options)
%fit_quadratic : Finds optimum Kd by fitting fraction macromolecule bound 
% when the concentration of ligand and macromolecule are comparable, 
% so free concentrations cannot beapproximated by total concentration 
% f_b = 1 ./ 2.*Mtotal .* 
%       ( Mtotal + Ltotal + Kd - sqrt((Mtotal + Ltotal +Kd).^2 
%         - 4.*Mtotal.*Ltotal))

Mtotal = 0.06; %macrmolecule concentration in µM
fiteq_ = '(0.5./Mtotal).*(Mtotal+x+Kd-sqrt((Mtotal+x+Kd).^2-4.*Mtotal.*x))';
fiteq_ = strrep(fiteq_,'Mtotal',num2str(Mtotal));
fitcoeff_ = {'Kd'};
lobound = [0]; hibound = [inf]; st_ = [1./median(x)];
fo_ = fitoptions(options,'Lower',lobound, 'Upper',hibound,'Startpoint',st_);

ft_ = fittype(fiteq_,'dependent',{'y'},'independent',{'x'},...
     'coefficients',fitcoeff_);
try
    [cf_, ~, output_] = fit(x,y,ft_,fo_);
    exitflag = output_.exitflag;
    CI_ = confint(cf_, 0.68);
catch
    exitflag = -1;
end
return;