function fitopt = get_options(filename)
% FITOPT = GET_OPTIONS(FILENAME)
% reads settings text files and creates options structure

settingstart = '<multifitOptions>';
settingend = '</multifitOptions>';
textline='';
fitopt = struct(...
    'xhdr',{'x'},...                      header for independent variable columns
    'errhdr',{'err'},...                  header for error columns
    'optMultipleDatasets',{'overlay'},... What to do with multiple datasets
    'prmRepeatThreshold',{2},...          Minimum number of repeats necessary to be included
    'prmXrange',{[-inf inf]},...          range of data to include
    'chkDelRangeOutlier',{true},...          delete outliers from y data
    'chkMergeSameHeader',{true},...          average y columns with identical headers
    'chkMergeSameX',{true},...               average y values with identical x 
    'chkVisible',{'off'},...
    'chkMergeFits',{1},...
    'chkBootstrap',{0},...
    'prmBtstrpN',{10000},...
    'prmXtitle',{''},...
    'prmYtitle',{''},...
    'ytrend',{'auto'},...                 ascending, descending or a combination
    'prmXscale',{'lin'},...               x-axis is linear or logarithmic
    'prmPaperSize',{[8.5 11]},...
    'prmPageMargins',{[0.25 0.25 0.5 0.5]}...
    );


fid = fopen(filename,'r');
while ~strcmpi(textline,settingstart) && ~feof(fid)
    textline = strtrim(fgetl(fid)); 
end
while ~strcmpi(textline,settingend) && ~feof(fid)
    textline = strtrim(fgetl(fid)); 
    if ~ischar(textline); break; end        %end of file reached
    if isempty(textline) || textline(1) == '<'; continue; end
    
    fitopt = assignset(fitopt, textline);
end
fclose(fid);
end

function fitopt = assignset(fitopt, textline)
    token = regexpi(textline,'.+:','match');
    token = lower(regexprep(token{:},{':','\s'},''));    %remove ':' and any spaces
    switch token
        case 'xname'
            value = regexpi(textline,'".+"','match');
            if ~isempty(value); fitopt(1).xhdr = regexprep(value{:},{'"','\s'},''); end    
        case 'errorname'
            value = regexpi(textline,'".+"','match');
            if ~isempty(value); fitopt(1).errhdr = regexprep(value{:},{'"','\s'},''); end    
        case 'removeoutlieryvalues'
            value = regexprep(regexpi(textline,'".+"','match'),{'"','\s'},'');
            if strcmpi(value,'no'); fitopt(1).chkDelRangeOutlier = false; end    
        case 'averageidenticalheaders'
            value = regexprep(regexpi(textline,'".+"','match'),{'"','\s'},'');
            if strcmpi(value,'no'); fitopt(1).chkMergeSameHeader = false; end    
        case 'averagesamex'
            value = regexprep(regexpi(textline,'".+"','match'),{'"','\s'},'');
            if strcmpi(value,'no'); fitopt(1).chkMergeSameX = false; end    
        case 'multipledatasets'
            value = regexprep(regexpi(textline,'".+"','match'),{'"','\s'},'');
            if ~isempty(value); fitopt(1).optMultipleDatasets = value{:}; end
        case 'repeatsignificancethreshold'
            value = regexprep(regexpi(textline,'".+"','match'),{'"','\s'},'');
            if ~isempty(value); fitopt(1).prmRepeatThreshold = str2double(value{:}); end
        case 'visible'
            value = regexprep(regexpi(textline,'".+"','match'),{'"','\s'},'');
            if ~isempty(value); fitopt(1).chkVisible = value{:}; end
        case 'combineidenticalheaders'
            value = regexprep(regexpi(textline,'".+"','match'),{'"','\s'},'');
            if strcmpi(value,'no'); fitopt(1).chkMergeFits = 0; end    
        case 'xdomain'
            value = regexpi(textline,'".+"','match');
            if ~isempty(value)
                limits = parse_range(regexprep(value{:},{'"','\s'},''));
                fitopt(1).prmXrange = limits; 
            end
        case 'ytrend'
            value = regexpi(textline,'".+"','match');
            if ~isempty(value); fitopt(1).ytrend = regexprep(value{:},{'"','\s'},''); end    
        case 'xaxisscale'
            value = regexpi(textline,'".+"','match');
            if ~isempty(value); fitopt(1).prmXscale = regexprep(value{:},{'"','\s'},''); end    
        case 'xaxistext'
            value = regexprep(regexpi(textline,'".+"','match'),{'"','\s'},'');
            if ~isempty(value); fitopt(1).prmXtitle = value{:}; end    
        case 'yaxistext'
            value = regexprep(regexpi(textline,'".+"','match'),{'"','\s'},'');
            if ~isempty(value); fitopt(1).prmYtitle = value{:}; end    
        case 'papersize'
            value = regexprep(regexpi(textline,'".+"','match'),{'"','\s'},'');
            if ~isempty(value); fitopt(1).prmPaperSize = str2double(value{:}); end    
        case 'pagemargins'
            value = regexprep(regexpi(textline,'".+"','match'),{'"','\s'},'');
            if ~isempty(value); fitopt(1).prmPageMargins = str2double(value{:}); end    
        case 'iterations'
            value = regexprep(regexpi(textline,'".+"','match'),{'"','\s'},'');
            if ~isempty(value); fitopt(1).prmBtstrpN = str2double(value{:}); end    
%         case 'simulationname'
%             value = regexpi(textline,'".+"','match');
%             if ~isempty(value); fitopt(1).simname = regexprep(value{:},{'"','\s'},''); end    
%         case 'simulationparameters'
%             value = regexpi(textline,'".+"','match');
%             if ~isempty(value); value = regexprep(value{:},{'"','\s',','},' ');end
%             if ~isempty(value); fitopt(1).simparam = regexpi(value,'\w*','match'); end    
%         case 'simulationequation'
%             value = regexpi(textline,'".+"','match');
%             if ~isempty(value); fitopt(1).simeq = regexprep(value{:},{'"','\s'},''); end    
    end
end
