function status = saveBtstrpResults(filename, cnames, cvalues, varargin)
% status = saveBtstrpResults(filename, cnames, cvalues, varargin)
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
% CNAMES (cell vector)
%   header names for data, will be written in the first row of the file
% CVALUES
%   numeric matrix of data, each row is related to one bootstrap fit
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

writeTable = [reshape(cnames,1,[]);num2cell(cvalues)];
if ispc && nargin < 4
    try
        xlswrite(filename,writeTable);
        status = 0;
    catch ME
        % try saving explicitly as text file
        display('Failed to save as Excel file. Trying tab-delimited text.');
        status = saveBtstrpResults(filename, cnames, cvalues, 'rethrow'); 
    end
else
    try
        columnNo = size(writeTable,2);
        fmt_hdr   = ['%s',repmat('\t%s'   ,1,columnNo-1),'\n'];
        fmt_data =  ['%s',repmat('\t%5.4f',1,columnNo-1),'\n'];
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
        display(sprintf('Bootstrap results dumped as mat file in %s',filename));
        display(getReport(ME));
        status = -1;
    end
end
end
