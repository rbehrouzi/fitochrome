function num_repeats = get_repeats(inVec, varargin)
% NUM_REPEATS = COUNTREPEATS(INVEC, VARARGIN)
%
% Determines the number of repeats for each element of INVEC
%
% INVEC         a numerical vector or a cell vector of strings
%
% VARARGIN{1}  can be either 'contig' (default) or 'count'
%              'contig' : only uninterrupted repeats are considered
%              'count'  : all repeats of one element are counted together
%
% NUM_REPEATS   a vector the same size as INVEC and shows how many repeats
%               follow each element of INVEC. This value is nonzero only at
%               the beginning of a repeat block. for example
%
%               INVEC = {'a','a','a','b','c','c'}
%               NUM_REPEATS = [2,0,0,0,1,0]

if nargin > 1
    if strcmpi(varargin{1},'count')
        [inVec srtid] = sort(inVec);
    end
end

if ~isvector(inVec); error('Input argument must be a vector.');end
n=length(inVec);
num_repeats = zeros(1,n);

%-- how it works
% each row in LOGIX shows the results of comparing INVEC to a left-shifted
% version of itself. In each STEP, INVEC is shifted one more unit. This is
% repeated until an all-zero row in LOGIX is formed.
% When the for-loop exits, LOGIX has p (non-zero) rows. Non-zero elements
% of row p are elements of INVEC which are repeated p+1 times. Non-zero
% elements in row p-1, are INVEC elements that are repeated either p times
% or p+1 times, etc.
logix = false(n); %n by n
if isnumeric(inVec)
    if all(diff(inVec)==0); num_repeats(1) = n-1;return;end;
    for step=1:n-1
        logix(step,1:end-step) = inVec(1:end-step)==inVec(1+step:end);
        if ~any(logix(step,:));logix(step:end,:)=[];break;end
    end
elseif iscell(inVec)
    if ~any(isnan(str2double(inVec))) 
        num_repeats = get_repeats(str2double(inVec));
        return;
    end
    if all(strcmpi(inVec{1},inVec)); num_repeats(1) = n-1;return;end;
    for step=1:n-1
        logix(step,1:end-step) = cellfun(...
        @strcmpi,inVec(1:end-step),inVec(1+step:end));
        if ~any(logix(step,:));logix(step:end,:)=[];break;end
    end
else
    error('Input argument must be a numeric or cell vector');
end

%-- how it works
% now navigate rows of LOGIX from end to the beginning to count blocks
% and their sizes. If LOGIX has p rows:
% Non-zero elements in row p, indicate the beginning of (p+1) long blocks;
% then, [(p-1 XOR p) XOR (1-bit right shifted p)] indicates beginning
% of independent p long blocks (not part of p+1 long blocks); because
% (p-1 XOR p) shows where p long repeats start,
% right shifting row p makes it to mark elements which are next to the
% beginning of r+1 blocks, therefore the second XOR removes r repeats which
% are part of a bigger r+1 repeat. There's only a small point here: In
% order to be able to detect repeats that start in position 1, it must be
% compared to first element of next row. Therefore, in the second XOR
% operation, first element of second row is duplicated to create the right
% shifting.
% finally, elements marked in row p are removed from all rows, reducing the
% problem to an identical one, but one degree simpler.

if size(logix,1)==0; return;end;    %no column is repeated
num_repeats(logix(end,:)) = size(logix,1);
for r=size(logix,1)-1 : -1 : 1
    tmp = xor(logix(r,:),logix(r+1,:)); % elements followed by r-1 repeats
    num_repeats( xor(tmp, [false,logix(r+1,1:end-1)]) ) = r;
    logix(:,logix(r+1,:)) = 0;  %reduce the degree; repeat
end

% if argument 'count' is passed, INVEC is sorted inside this code
% we need to undo the sort so that NUM_REPEATS corresponds to the original
if nargin > 1 && strcmpi(varargin{1},'count')
    unsorted = 1:length(inVec);
    undosrt(srtid) = unsorted;
    num_repeats = num_repeats(undosrt);
end

end