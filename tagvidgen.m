function tagvidgen(annotations, vid, outpath)
%TAGVIDGEN Graphics generator for bee tag annotation files
%   Generates a summary video that highlights tag annotations. The summary
%   video only contains frames containing verified tags. Each frame is
%   annotated with the tags minimum bounding rectangle, tag digits, and
%   timestamp.
%
%   SYNTAX
%   tagvidgen(annotations, vid, outpath)
%
%   DESCRIPTION
%   tagvidgen(annotations, vid, outpath) specifies the annotations to
%   summarize, the video handle to the video returned by vidpreproc.m, and
%   the output video filename.
%
%   AUTHOR
%   Blair J. Rossetti
%
%   DATE LAST MODIFIED
%   2016-05-10

% remove non-tags
data = annotations([annotations.istag]);
if isempty(data)
    return
end

% define track colors
colors = lines(max([data.trackid]))*255;
cellexpand = @(x) x{:};
numexpand = @(x) cellexpand(num2cell(x,2));
[data.color] = numexpand(colors([data.trackid],:));
clear colors;

% get times
times = unique([data.time]);

% create new video file and open
[~, ~, ext] = fileparts(outpath);
if strcmpi(ext, '.mp4')
    profile = 'MPEG-4';
else
    profile = 'Motion JPEG AVI';
end
outvid = VideoWriter(outpath, profile);
outvid.FrameRate = 15;
open(outvid);


% loop over times
for i = times
    % get tag indices
    idx = find([data.time] == i);
    
    % get frame
    vid.CurrentTime = i;
    frame = readFrame(vid);
    
    % annotate each tag
    for j = idx
        % add mbr
        pts = data(j).mbr';
        frame = insertShape(frame,'polygon', pts(:)', 'Color', data(j).color);
        
        % add digits
        frame = insertText(frame, data(j).bbox(1:2), data(j).digits, ...
                'AnchorPoint','LeftBottom', 'TextColor', data(j).color, ...
                'BoxOpacity', 0); 
    end
    
    % add timestamp
    frame = insertText(frame, [1, size(frame,1)], ['Time: ' num2str(i)], ...
            'AnchorPoint','LeftBottom', 'TextColor', 'white', ...
            'BoxOpacity', 0, 'FontSize', 8);
    
    % write frame to video file
    writeVideo(outvid,frame)
end

% close video file
close(outvid);