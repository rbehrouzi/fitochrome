function status = saveFitResults(filename,fitStruct, varargin)
% 
% 
% Saves the table of parameter values of successful bootstrap fits in a
% text file. 
%   On Windows PC, writing in Microsoft Excel format is tried. If it
%   fails, dlmwrite is implicitly invoked to write as tab delimited format.
%   If this fails too, a tab limited text file is written explicitly. 
%   On Mac, text file is default.
%
% FILENAME (char array)
%   Fully-qualified file name (i.e. including folder path)
% FITSTRUCT (structure)
%   contains:
%   FITSTRUCT.HEADERS
%       header names for data, will be written in the first row of the file
%   FITSTRUCT.FITS (cell vector of cfit objects)
%       cfit objects with fit results
%   FITSTRUCT.CONFINT (cell array)
%       confidence intervals for fit parameters
% VARARGIN
%   Passing any extra parameter will result in data being saved
%   explicitly as tab-limited text file without attempting Excel format.
%
% STATUS
%   -1: Save failed. Results saved in mat file format.
%   0 : Save succeeded in Excel format.
%   1 : Save succeeded in text-delimited format.
%
% ---------- Last modified: 08/25/2014 --Reza
fitnames = fitStruct.headers';
fits = fitStruct.fits;
paramNames = reshape(coeffnames(fits{1}),1,[]);
nFits = length(fits); nParams=length(paramNames);
paramVal = zeros(nFits, 1, nParams); % parameter value from fit
pConfInt = zeros(nFits, 2, nParams); %confidence intervals 
CIheader = repmat({'-';'+'},1,nParams);
for i=1:length(fits)
    ctemp = coeffvalues(fits{i});
    paramVal(i,1,:) = ctemp;
    if ~isempty(fitStruct.confInt{i})
        pConfInt(i,:,:) = fitStruct.confInt{i}-repmat(ctemp,2,1); 
    else
        pConfInt(i,:,:) = NaN;
    end
end
hdrTable = reshape(vertcat(paramNames,CIheader),1,[]);
writeTable = reshape(horzcat(paramVal,pConfInt),nFits,nParams*3);
writeTable = [hdrTable;num2cell(writeTable)];
writeTable = [['Name';fitnames],writeTable];

if nargin < 3
    try
        xlswrite(filename,writeTable);
        status = 0;
    catch ME
        %TODO: convert cell to Table and cell2table and write with
        %writeTable
        display('Failed to save as Excel file. Trying tab-delimited text.');
        status = saveFitResults(filename,fitStruct,'SaveAsText');
    end
else
    try
        fmt_hdr   = ['%s',repmat('\t%s',1,size(writeTable,2)-1),'\n'];
        fmt_data = ['%s',repmat('\t%5.4E',1,size(writeTable,2)-1),'\n'];
        fid = fopen(filename,'w');
        fprintf(fid,fmt_hdr,writeTable{1,:});
        for row=2:size(writeTable,1)
            fprintf(fid,fmt_data,writeTable{row,:}); 
        end
        fclose(fid);
        status = 1;
    catch ME
        % last resort measure to prevent loss of bootstrap data
        % dump results as mat file for later rescue
        save(filename,'writeTable'); 
        display(sprintf('Fit results dumped as mat file in %s',filename));
        display(getReport(ME));
        status = -1;
    end    
end

end