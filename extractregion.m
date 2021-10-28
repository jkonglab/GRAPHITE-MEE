function [ image ] = extractregion(image, pts)
%EXTRACTREGION Extracts region based on coordinates of bounding rectangle
%   Extracts an image region according to coordinates of its bounding
%   bounding rectangle. The extracted region is rotated to have its major
%   or minor axis at 0 and 90 degrees. For rotated regions, bilinear
%   interpolation is used to estimate bounded pixels values.
%
%   SYNTAX
%   [ image ] = extractregion(image, pts)
%
%   DESCRIPTION
%   [ image ] = extractregion(image, pts) extracts the regions specified by
%   pts from the image. pts must be a 4x2 matrix with the x- and y-values
%   corresponding to the first and second columns, respectively. The
%   returned image only contains pixels information bounded by pts.
%
%   AUTHOR
%   Blair J. Rossetti
%
%   DATE LAST MODIFIED
%   2016-05-10

% get image size
[y, x, c] = size(image);

% find edge for rotation
[~, idx] = sort(pts(:,2), 'ascend');
idx = idx(1:2);

% compute rotation
theta = atan((pts(idx(1),2)-pts(idx(2),2))/(pts(idx(1),1)-pts(idx(2),1)));

% define tform
if theta == 0
    % use indexing to crop
    minmax = @(x) [min(x) max(x)];
    xys = floor(minmax(pts));
    xys(xys < 1) = 1;
    if xys(3) > x
        xys(3) = x;
    end
    if xys(4) > y
        xys(4) = y;
    end
    image = image(xys(2):xys(4), xys(1):xys(3), :);
    return 
elseif theta < 0
    % rotate on leftmost point
    [~, idx] = min(pts(:,1));
else
    % rotate on topmost point
    idx = idx(1);
end

tform = invert(affine2d([cos(theta), sin(theta), 0; ...
                        -sin(theta), cos(theta), 0; ...
                         pts(idx,1), pts(idx,2), 1]));

% transform points
[w, h] = transformPointsForward(tform, pts(:,1), pts(:,2));
w = floor(max(w));
h = floor(max(h));

image = imwarp(image,tform,'bilinear', 'OutputView', imref2d([h, w]));

end %function
