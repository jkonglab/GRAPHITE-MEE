function trackplotter(annotations, background, outpath)
%TRACKPLOTTER Plots tag tracks on the background image
%   Generates a summary image that 
%
%   SYNTAX
%   trackplotter(annotations, vid, outpath)
%
%   DESCRIPTION
%   trackplotter(annotations, vid, outpath) specifies the annotations to
%   summarize, the video handle to the video returned by vidpreproc.m, and
%   the output video filename.
%
%   AUTHOR
%   Blair J. Rossetti
%
%   DATE LAST MODIFIED
%   2016-06-23

% remove non-tags
data = annotations([annotations.istag]);
if isempty(data)
    return
end

% define track colors
colors = lines(max([data.trackid]))*255;

% get tracks
tracks = unique([data.trackid]);

% insert tracks
figure = background;
for i = 1:length(tracks)
% for i = 3
    track = data([data.trackid] == tracks(i));
    coords = [track.centroid];
%     sidx = 28;
%     j=1;
%     eidx = 70;
    sidx = 1;
    eidx = [find(diff([track.time]) >= 1) length([track.time])];
    figure = insertMarker(figure, coords(1:2), 'square', 'Color', colors(tracks(i),:));
    figure = insertMarker(figure, coords(end-1:end), 'circle', 'Color', colors(tracks(i),:));
    for j = 1:length(eidx)
        figure = insertShape(figure, 'Line', coords(2*sidx-1:2*eidx(j)), 'Color', colors(tracks(i),:));
        sidx = eidx(j)+1;
    end    
end

imwrite(figure, outpath);
