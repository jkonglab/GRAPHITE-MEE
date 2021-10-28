function [ img, cropbbox ] = tagpreproc(img)
%TAGPREPROC Bee tag image preprocessing
%   Cleans bee tag images for use in OCR by tagocr.m. The input image is
%   wavelet denoised, background subtracted, filtered, and isolated. The
%   input image must be dark text on a light background. The output image
%   is light text on a dark background.
%
%   SYNTAX
%   [ img, cropbbox ] = tagpreproc(img)
%
%   DESCRIPTION
%   [ img, cropbbox ] = tagpreproc(img) preprocesses tag images specified 
%   as img for OCR. The preprocessed image is returned along with the
%   coordinates for the digit bounding box specified as cropbbox.
%
%   DEPENDENCIES
%   multipad.m
%
%   AUTHOR
%   Blair J. Rossetti
%
%   DATE LAST MODIFIED
%   2016-05-10

% parameters
RBR = 5;    %rolling ball radius
CP = 2;     %crop padding

% get image dimensions
[h, w, c] = size(img);

% denoise and background subtract
for i = 1:c
    % wavelet denoise
    tmp = img(:,:,i);
    wname = 'fk4';
    level = 5;
    
    % pad image
    [tmp , pads] = multipad(tmp, 2^level, 0);
    
    % denoising parameters
    sorh = 'h';
    thrSettings = repmat(14.5, [3 5]);

    % decompose using SWT2
    wDEC = swt2(double(tmp), level, wname);

    % denoise
    permDir = [1 3 2];
    for j = 1:level
        for kk = 1:3
            idx = (permDir(kk)-1)*level+j;
            thr = thrSettings(kk, j);
            wDEC(:,:,idx) = wthresh(wDEC(:,:,idx), sorh, thr);
        end
    end

    % reconstruct the denoise signal
    tmp = iswt2(wDEC, wname);
    
    % remove pad
    tmp = tmp(pads(1)+1:end-pads(2),pads(3)+1:end-pads(4));
    
    % background subtract
    tmp = 255-uint8(tmp);

    % pad image
    wpad = 2*RBR;
    tmp = padarray(tmp, [wpad wpad], 255);
    
    % define background
    background = imopen(tmp, offsetstrel('ball', RBR, RBR));
    
    % remove background
    tmp = tmp-background;
    
    % remove pad
    tmp = tmp(wpad+1:end-wpad,wpad+1:end-wpad);
    
    % adjust intensities
    img(:,:,i) = imadjust(tmp);
end %for

% sharpen
img = imsharpen(img, 'Threshold', 0.7);

% convert to grayscale
if c > 1
    img = rgb2gray(img);
end

% define digit region
mask = mat2gray(sum(img,2)*sum(img,1));
mask = imbinarize(mask);
mask = bwmorph(mask, 'hbreak', Inf);
mask = bwmorph(mask, 'spur', Inf);

% filter regions
cc = bwconncomp(mask);
stats = regionprops(cc, 'Area', 'PixelList');

% filter small regions
areaIdx = [stats.Area] > 20;

% check if empty
if all(~areaIdx)
    img = [];
    cropbbox = [];
    return
end

% get list of pixels
pxList = cat(1, stats(areaIdx).PixelList);

% get crop coordinates
minmax = @(x) [min(x) max(x)];
ccorr = minmax(pxList);

% crop to coordinates
ccorr(1:2) = ccorr(1:2) - CP;
ccorr(3:4) = ccorr(3:4) + CP;
ccorr(ccorr < 1 ) = 1;
if ccorr(3) > w
    ccorr(3) = w;
end
if ccorr(4) > h
    ccorr(4) = h;
end
img = img(ccorr(2):ccorr(4),ccorr(1):ccorr(3));

cropbbox = [ccorr(1:2), ccorr(3)-ccorr(1), ccorr(4)-ccorr(2)];

end %function
