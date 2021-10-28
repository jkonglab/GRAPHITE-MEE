function [ annotations ] = tagocr(annotations, outpath)
%TAGOCR Reads tag digits and updates a tag annotations file
%   Loops through a tag annotations structure and reads the digits for each
%   tag. A new annotations structure is returned that includes the detected
%   digits and the associated confidence levels. Before OCR, tags are
%   preprocessed.
%
%   SYNTAX
%   [ annotations ] = tagocr(annotations, outpath)
%
%   DESCRIPTION
%   [ annotations ] = tagocr(annotations, outpath) reads in the tag images
%   specified in annotations, preprocesses each image, and determines the
%   most likely three digits. A new annotations array structure is returned
%   with ocr fields (istag, digits, orientation, confidence, digit bounding
%   boxes, and crop bounding box), and the tag_annotations.mat files is 
%   updated.
%
%   DEPENDENCIES
%   ./tessdata, tagpreproc.m, multipad.m, tag image files
%
%   AUTHOR
%   Blair J. Rossetti
%
%   DATE LAST MODIFIED
%   2016-05-10

% set OCR language
lang = 'tessdata/dgt.traineddata';

% preprocess tag image
for i = 1:length(annotations)
    % read image
    img = imread(annotations(i).filepath);
    [h,w,c] = size(img);
    
    % preprocess
    [img, cropbbox] = tagpreproc(img);
    
    % check if img is a tag
    if isempty(img)
        annotations(i).istag = false;
        annotations(i).digits = '';
        annotations(i).orientation = [];
        annotations(i).confidence = [];
        annotations(i).digitbboxes = [];
        annotations(i).cropbbox = [];
        continue
    end

    % process tag and rotated tag   
    results = struct.empty(2,0);
    
    for j = 1:2
        % ocr
        results(j).ocr = ocr(img, 'Language', lang, 'TextLayout', 'Block');

        % keep at most 3 digits by confidence level
        conf = results(j).ocr.CharacterConfidences;
        conf(isnan(conf)) = 0;      % convert NaN to 0 for correct sorting
        
        if length(conf) > 2            
            % sort digits by confidence level
            [~,idx] = sort(conf, 'descend');
            idx = sort(idx(1:3), 'ascend');
            results(j).DigitConfidences = conf(idx);
            
            % compute average confidence
            results(j).AverageConfidence = mean(conf(idx));
            
            % get and clean digits with highest confidence
            text = results(j).ocr.Text(idx);
            text = strtrim(text);
            text(text == ' ') = ''; 
            
            % get bounding boxes
            results(j).BBoxes = results(j).ocr.CharacterBoundingBoxes(idx,:);
        else
            % add digit confidence
            results(j).DigitConfidences = padarray(conf, 3-length(conf),'post');

            % compute average confidence
            results(j).AverageConfidence = mean(results(j).DigitConfidences);
            
            % clean digits
            text = strtrim(results(j).ocr.Text);
            text(text == ' ') = '';
            
            % get bounding boxes
            results(j).BBoxes = results(j).ocr.CharacterBoundingBoxes;
        end %if-else
        
        % add extracted digits
        results(j).Digits = text; 
        
        % flip image
        img = rot90(img,2);
    end %for

    % determine best orientation
    if results(1).AverageConfidence >= results(2).AverageConfidence
        orIdx = 1;
    else
        orIdx = 2;
        
        % flip crop bbox
        cropbbox = [[w h] - (cropbbox(1:2)+cropbbox(3:4)), cropbbox(3:4)];
        
        % flip image back
        img = rot90(img,2);
    end %if-else
    
    % add annotations
    annotations(i).istag = true;
    annotations(i).digits = results(orIdx).Digits;
    annotations(i).orientation = orIdx;
    annotations(i).confidence = results(orIdx).DigitConfidences;
    annotations(i).digitbboxes = bsxfun(@plus, results(orIdx).BBoxes, [cropbbox(1:2) 0 0]);
    annotations(i).cropbbox = cropbbox;
end %for

% save tag annotations
save(fullfile(outpath, 'tags', 'tag_annotations.mat'), 'annotations');

end %function
