function masks= enforceRptCount(data, masks, threshold)
% MASKS = enforceRptCount(DATA, MASKS, THRESHOLD)
%
% Marks items which occur less than THRESHOLD times in DATA structure
% These items are marked by setting their MASKS.HEADERS to false
%
% Notes
%      1. This function requires that data columns are pre-sorted 
%         according to data.headers
%      2. Masks are ignored in counting number of occurences of each item.

rptVec = get_repeats(data.headers);
rptIndex = find(rptVec>=threshold-1);
if isempty(rptIndex); return;end

rmMark = true(size(rptVec));
for i=1:length(rptIndex)
    rmMark(rptIndex(i):rptIndex(i)+rptVec(rptIndex(i))) = false;
end

masks.headers(rmMark) = false;


