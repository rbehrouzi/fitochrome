function [scaled_y scaled_e] = scaleData(y,err,scaling,varargin)
% [SCALED_Y SCALED_E] = scaleData(Y, ERR, SCALING, VARARGIN)
%
% Adjust the range of columns of y according to scaling and returns scaled
% y data and scaled error bars
%
%----------     ---------------------------------------------
% PARAMETER                 DEFINITION
%----------     ---------------------------------------------
% y             dependent variable columns
% err           errors associated with each y column
% scaling       string, valid values are
%               'norm'      y columns are normalized to a predetermined range
%                           see VARARGIN{1}
%               'range'     y columns are normalized to [min, max] of the 
%                            first column
%               'mean'      y columns are normalized so that all columns have
%                            means equal to the first column
%               'median'    y columns are normalized so that all columns have
%                            medians equal to the first column
%               'start'     y columns are scaled so that all have equal
%                           value at x = min(x), that is they are uniformly 
%                           shifter so that they all start at the same point
% varargin{1}   x data (assumed to be sorted ascendingly)
%               if scaling is set to 'norm' and this parameter is nonempty
%               upper and lower baselines of y are set to normalization
%               boundaries. If not provided, min and max of y are set to
%               normalization boundaries.
% varargin{2}   numeric vector, two elements
%               if third parameter is set to 'norm', this parameter
%               determines the range that all data columns are transformed
%               to, otherwise it is ignored. If no value is passed, it
%               defaults to [0, 1]
%----------     ---------------------------------------------
% y and err must have the same number of columns

%TODO: change err columns appropriately

if nargin < 4 
    setrange = [0,1]; 
    x = [];
elseif nargin==4 
    setrange = [0, 1];
    x = varargin{1};
elseif nargin==5
    x = varargin{1};
    if ~isempty(varargin{2})
        setrange = [varargin{2}(1), varargin{2}(2)];
    else
        setrange = [0, 1];
    end
end

[m n]=size(y);
if m==1 && n>1  %y is a row vector
    y = y'; err = err';
end
if ~all(size(y)==size(err))
    error('Scaling:SizeMismatch','data and error matrices have different sizes.');
end

switch scaling
    case 'norm'
        % scale all data to the predetermined range SETRANGE
        if ~isempty(x)
            st_ = zeros(1,n); hibase=zeros(1,n);
            for col=1:n
                ok_y = isfinite(y(:,col));
                xtmp = x(ok_y,col); ytmp = y(ok_y,col);
                hibase(col) = mean(ytmp(xtmp==nanmin(xtmp)));
                st_(col) = mean(ytmp(xtmp==nanmax(xtmp))); 
            end
            st_ = repmat(st_,m,1); hibase = repmat(hibase,m,1);
            scaled_y = setrange(1) + ((y - st_)./(hibase - st_)).*diff(setrange);
            scaled_e = err;
        else
            ymin = repmat(nanmin(y,[],1),m,1);
            ymax = repmat(nanmax(y,[],1),m,1);
            scaled_y = setrange(1) + ((y - ymin)./(ymax-ymin)).*diff(setrange);
            scaled_e = err;
        end        
        
    case 'range'
        % scale all columns to the range of first column
        if n==1
            scaled_y = y; scaled_e = err;
            return;
        end
        ymin0 = nanmin(y(:,1)); ymax0 = nanmax(y(:,1));
        ymin = repmat(nanmin(y,[],1),m,1);
        ymax = repmat(nanmax(y,[],1),m,1);
        ynorm = (y - ymin)./(ymax-ymin);
        scaled_y = ymin0 + (ymax0-ymin0).*ynorm;
        scaled_e = err;
        
    case 'mean'
        if n==1
            scaled_y = y; scaled_e = err;
            return;
        end
        scalefactor = nanmean(y,1)./ nanmean(y(:,1));
        scaled_y = y ./ repmat(scalefactor,m,1);
        scaled_e = err; 
        
    case 'median'
        if n==1
            scaled_y = y; scaled_e = err;
            return;
        end
        scalefactor = nanmedian(y,1)./ nanmedian(y(:,1));
        scaled_y = y ./ repmat(scalefactor,m,1);
        scaled_e = err;
        
    case 'start'
        if n==1
            scaled_y = y; scaled_e = err;
            return;
        end
        st_ = zeros(1,n); %y(min(x)) for each column
        for col=1:n
            ok_y = isfinite(y(:,col));
            xtmp = x(ok_y,col); ytmp = y(ok_y,col);
            st_(col) = mean(ytmp(xtmp==nanmin(xtmp))); 
        end
        scalefactor = st_ ./ st_(1);
        scaled_y = y ./ repmat(scalefactor,m,1);
        scaled_e = err;

    otherwise
        warning('Scaling:InvalidArgument','Scaling type not recognized.');
end