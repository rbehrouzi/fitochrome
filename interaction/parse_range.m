function limits = parse_range(inputstr)
% extracts numerical min and max values from a string constraint
% returns a vector of numerical values

% find numbers and points after < and >
lo_str = regexp(inputstr,'>(=?[\d\.]*)', 'match');
hi_str = regexp(inputstr,'<(=?[\d\.]*)', 'match');

if isempty(hi_str); hi = inf; 
else hi = str2double(regexprep(hi_str,{'<','='},'')); end
if isempty(lo_str); low = -inf; 
else low  = str2double(regexprep(lo_str,{'>','='},'')); end
limits = [low, hi];
end
