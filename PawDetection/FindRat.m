function [ RatPixels,RatIm ] = FindRat( Image,bght_thresh,Colorize )
%This function is meant to receive the thresholded brightness image and
%find the largest, blobbiest, middlest set of connected pixels. It returns
%this set of pixels, assuming it to be the rat.
%   HitPixels should be received as an nx2 array, where n is the number of
%   pixels being considered. The first column are the row coordinates; the
%   second is the column coordinates. The definition of connected includes
%   diagonal and orthogonal to a distance of 3 (at the moment).
%
%   RatPixels is delivered as a 3 x 2 matrix. The top row consists of the
%   top left corner RC coordinates; the second row is the bottom right RC
%   coordinates. The third row has the top left index, bottom right index.
%
%   If Colorize is true, RatIm is a 3D matrix showing the progression of
%   the image in 3 stages through these functions. If false, it's just
%   zeros(1,1,3).

Adjacent = 20;
ElimIf = 4;

% Transpose so that we order along rows; not columns.
brightness = Thresh2Bin(mean(Image,3),1,bght_thresh);
[hitRow,hitCol] = find(brightness);
hitInds = sub2ind(size(brightness),hitRow,hitCol);
brightness = uint8(brightness);
numPix = size(hitInds,1);
HitPix = [hitInds,hitRow,hitCol,zeros(numPix,1)];

% The tilde holds the place of the CC'd image. Use ColorizeIm to visualize.
[RatIm(:,:,1),IDpix,numGroups] = ConComp(brightness,HitPix,Adjacent,ElimIf,Colorize);

% The tilde holds the place of the final image. Change the zero to 1 to
% see. Use imshow to visualize.
[RatPixels,RatIm(:,:,2)] = ThreshLab(IDpix,numGroups,Colorize,size(brightness));
[RatPixels,RatIm(:,:,3)] = ChopLine(RatPixels,Colorize,size(brightness));

minRowInd = min(RatPixels(:,2));
maxRowInd = max(RatPixels(:,2));
minColInd = min(RatPixels(:,3));
maxColInd = max(RatPixels(:,3));
MMInds = sub2ind(size(Image),[minRowInd,maxRowInd],[minColInd,maxColInd]);

RatPixels = [minRowInd,minColInd;maxRowInd,maxColInd;MMInds(1),MMInds(2)];

end

