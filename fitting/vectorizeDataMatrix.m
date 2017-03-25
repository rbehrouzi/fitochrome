function [x_vec, y_vec, e_vec, fitgroup_vec] = vectorizeDataMatrix (x, y, err, fitgroups)
% creates column vectors of identical size from x,y,error and fitgroup
% x,y,err are matrices
% This function assigns fitgroup_vec to each element in y_vec, so they can 
% be selected for fitting by indexing using their fitIndex
%
% fitgroup is a column or row vector, length(fitgroup) = size(y,2)

fitIndex = zeros(size(y));
for itm = 1:size(y,2)
    fitIndex(:,itm) = repmat(fitgroups(itm),size(y(:,itm)));
end
% vectorize x,y,e 
x_vec = reshape(x,[],1);
y_vec = reshape(y,[],1);
e_vec = reshape(err,[],1); 
fitgroup_vec = reshape(fitIndex,[],1);
okay = isfinite(x_vec) & isfinite(y_vec);

x_vec(~okay) = []; y_vec(~okay) = []; 
e_vec(~okay) = []; fitgroup_vec(~okay) = [];
end