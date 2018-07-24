function [ Image ] = blackLine( Image,intercept,slope,pixels,page,lineThickness )
%Receives an image, highlighted pixels from that image, and coordinates to
%determine the trajectory of the line. Returns an image where that line has
%been blacked out, along with a revised HitPixels list where those
%highlighted pixels have been eliminated, for use in downstream functions.
%   It currently assumes that the image is binary, though it does not have
%   to be logical.

% Empirically made up sqrt(3)
totalThickness = sqrt(3)*lineThickness;
lineThickness = floor(lineThickness/2)*2 + 1;
% HalfLineThickness
hlt = floor(lineThickness/2);
% Make it an odd number, increasing by one if even.
totalThickness = floor(totalThickness/2)*2 + 1;
halfThick = floor(totalThickness/2);
offsetVec = (-halfThick:halfThick)';
outLine = [-halfThick:-hlt-1,hlt+1:halfThick]+(halfThick+1);
inLine = (-hlt:hlt)+(halfThick+1);
LineThresh = 0.9;
searchThresh = 0.05;
ObjectThresh = .10;


if page == 1
    theta = atan(slope);
elseif page == 2
    theta = atan(1/slope);
end

Inc = 1;
startPoint = intercept;
[Rmax,Cmax] = size(Image(:,:,1));
maxCoord = Rmax+Cmax;
r = -maxCoord:Inc:maxCoord;
% Negative because a positive slope moves DOWN the row coordinates
Rcoord = -round(sin(theta)*r) + startPoint(1);
Ccoord = round(cos(theta)*r) + startPoint(2);
SizeThreshes = [totalThickness + 1, Rmax - totalThickness - 1; ...
    totalThickness + 1,Cmax - totalThickness - 1];
[Rcoord,Ccoord] = ElimOut(SizeThreshes,Rcoord,Ccoord);
numCoords = length(Rcoord);
GrowCol = ones(1,numCoords);
sumMat = offsetVec*GrowCol;
sumMat = reshape(sumMat,1,numCoords*totalThickness);
if page == 1
    sliceRows = repmat(Rcoord,totalThickness,1);
    sliceRows = reshape(sliceRows,1,totalThickness*numCoords);
    sliceRows = sum([sliceRows;sumMat]);
    sliceCols = repmat(Ccoord,totalThickness,1);   
    sliceCols = reshape(sliceCols,1,totalThickness*numCoords);
elseif page == 2
    sliceRows = repmat(Rcoord,totalThickness,1);
    sliceRows = reshape(sliceRows,1,totalThickness*numCoords);
    sliceCols = repmat(Ccoord,totalThickness,1);
    sliceCols = reshape(sliceCols,1,totalThickness*numCoords);
    sliceCols = sum([sliceCols;sumMat]);
end
    
sliceInds = sub2ind([Rmax,Cmax],sliceRows,sliceCols);
cleanSlice = reshape(sliceInds,totalThickness,numCoords);
sliceVals = Image(cleanSlice);
outside = sliceVals(outLine,:);
inside = sliceVals(inLine,:);
weightIn = sum(inside);
weightOut = sum(outside);
weightRatio = weightIn./(weightOut + 0.01);
kernel = [1/24 1/16 1/12 1/9 1/6 1/3 1/6 1/9 1/12 1/16 1/24];
smoothRatio = conv(kernel,weightRatio);
[highestLikelihood,peakLoc] = max(smoothRatio);
peakThresh = highestLikelihood*LineThresh;
flipSmooth = flip(smoothRatio);
smoothWOut =  conv(weightOut,kernel,'same');
totalWeight = sum(smoothWOut);

keepLooking = 1;
startObject = 1;
zeroWeight = smoothWOut == 0;
Image(cleanSlice(inLine,zeroWeight)) = 0;
%Image(cleanSlice(inLine,:)) = 255;
%imshow(Image)
while keepLooking
    startObject = find(smoothWOut(startObject:end) > searchThresh,1,'first') + startObject - 1;
    if isempty(startObject)
        keepLooking = 0;
        startObject = 1;
        endObject = startObject;
    else
        endObject = find(smoothWOut(startObject:end) < searchThresh,1,'first') + startObject - 1;
        if isempty(endObject)
            keepLooking = 0;
            endObject = numCoords;
        elseif endObject == numCoords
            keepLooking = 0;
        end
    end
    VolumeOut = sum(smoothWOut(startObject:endObject));
    WeightRatio = VolumeOut/totalWeight;
    if WeightRatio < ObjectThresh
        Image(cleanSlice(inLine,startObject:endObject)) = 0;
    end
    startObject = endObject + 1;
    if startObject >= numCoords
        keepLooking = 0;
    end
end

% onLineInd = sub2ind(size(Image),FYC,FXC);%,FAP);
% Image(onLineInd) = 0;
% 
% HitPixels = pixels;
% numOut = 0;
% for k = 1:length(pixels)
%     existY = find(pixels(k,1) == Ccoord,1,'first');
%     if ~isempty(existY)        
%         existX = find(pixels(k,2) == Rcoord,1,'first');
%         if ~isempty(existX)
%             HitPixels(k-numOut,:) = [];
%             numOut = numOut + 1;
%         end
%     end
% end




end

