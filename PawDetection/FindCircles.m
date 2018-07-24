function [ Image,PixelGroups ] = FindCircles( image,pixels,numCir,radii )
%This function receives a binary image and finds the true points in it that
%seem to form a circle of a radius within the given limits.
%   Detailed explanation goes here

% We don't want the small circles to double count points, and we don't want
% gaps in pixel coverage in the large circles; thus the number of angles
% that get populated must change as the radius changes.

pointsPer = 100; % Possible center points to check for
radChunks = 1;
numRads = (radii(2)-radii(1))/radChunks;
angInc = linspace(0,2*pi,pointsPer);
radInc = linspace(radii(1),radii(2),numRads);
% The next two matrices will hopefully make indexing easier for the loops.
% The first row the first matrix will
cosDis = cos(angInc)*radInc';
% chunkSpace is going to be a 3D matrix into which the hit points will
% cast their votes on where the centers might be. The rows of chunkSpace
% will index the possible rows that the center might have (possibly any
% point in the image); likewise the columns will index possible center
% columns. Each page will represent a new radius. 
iSize = size(image);
chunkSpace = zeros(iSize(1),iSize(2),numRads);

numHits = size(pixels,1);
for k = 1:numHits
    for k1 = 1:numRads
        aroundOr = radInc(k1)*
    





end

