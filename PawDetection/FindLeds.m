function [ Image,Pixels ] = FindLeds( Image,ledRadius,colorChan )
%Receives an image and finds the two reddest parts of the image, returning
%the unrounded center of mass of both groups of red pixels, along with the
%given image where the approximate LED groups are shaded blue.

cutTop = 60;
HaLinha = 0;
% [minimum,maximum]
numLeds = [2,2];
% Find all the reddest points--the red channel is larger than the sum of
% blue and green and brighter than a threshold.
highRed = double(Image);
highRed(1:cutTop,:,:) = 0;
highRed(190:end,:,:) = [];
highRed(:,:,2) = -1*highRed(:,:,2);
highRed(:,:,3) = -1*highRed(:,:,3);
highRed = sum(highRed,3);
Logic = Thresh2Bin(highRed,1,[10,255]);
[highRows,highCols] = find(Logic);
[Image,Pixels] = FindClust(Image,[highRows,highCols],ledRadius, ...
    numLeds,HaLinha,colorChan);


end

