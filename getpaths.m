function [ files ] = getpaths( rootdir, ext )
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

files = dir(fullfile(rootdir, ['*' ext]));
dirIdx = [files.isdir];
files = {files(~dirIdx).name}';
numFiles = length(files);

%build full file path
for i = 1:numFiles
    files{i} = fullfile(rootdir,files{i});
end

end

