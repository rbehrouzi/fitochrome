function filename = getfilehandle(extfilter,dialogname)

[fname, pathname, ~]= uigetfile(extfilter,dialogname);
filename = fullfile(pathname,fname);
if fname==0 || ~exist(filename,'file')
    filename = '';
end
return