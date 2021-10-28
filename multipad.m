function [ mat, pads ] = multipad(mat, m, fill)
%MULTIPAD Pads a 2D matrix to a given multiple
%   Pads a matrix such that the dimensions satisfy the condition that they
%   are a multiple of a given number. This function returns the padded
%   matrix and a 1x4 matrix that specifies the pre row pad, post row pad,
%   pre column pad, and post column pad.
%
%   SYNTAX
%   [ mat, pads ] = multipad(mat, m, fill) 
%
%   DESCRIPTION
%   [ mat, pads ] = multipad(mat, m, fill) specifies the input 2D matrix
%   mat, the multiple m, and the fill value fill. The function returns a
%   padded matrix mat and the size of the pad pads.
%
%   AUTHOR
%   Blair J. Rossetti
%
%   DATE LAST MODIFIED
%   2016-05-10

[h,w] = size(mat);
pads = zeros(1,4);

%% Pad Rows
hpad = ceil(h/m)*m - h;

if mod(hpad,2)
    mat = padarray(mat, [ceil(hpad/2) 0], fill);
    mat = mat(1:end-1,:);
    pads(1) = ceil(hpad/2);
    pads(2) = floor(hpad/2);
else
    mat = padarray(mat, [hpad/2 0], fill);
    pads(1:2) = hpad/2;
end

%% Pad Columns
wpad = ceil(w/m)*m - w;

if mod(wpad,2)
    mat = padarray(mat, [0 ceil(wpad/2)], fill);
    mat = mat(:,1:end-1);
    pads(3) = ceil(wpad/2);
    pads(4) = floor(wpad/2);
else
    mat = padarray(mat, [0 wpad/2], fill);
    pads(3:4) = wpad/2;
end

