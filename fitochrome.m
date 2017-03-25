function fitochrome()

%add all subfolders to search path
mypath = mfilename('fullpath'); 
[~, folder] = strtok(mypath(end:-1:1),'\/'); 
folder = folder(end:-1:1);
addpath(genpath(folder));   
defaultsettings = get_options('defaults.txt');

main('UserData',{folder, defaultsettings});

% rmpath(genpath(mypath));    %remove added folders to search path