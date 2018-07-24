function [ offRows,offCols ] = makeMask( radius )
%Creates a list of points with reference to a center point consisting of
%row,column pairs. When added to the center point, a list of indices can be
%obtained.
%   Detailed explanation goes here

diam = radius*2 + 1;
Box = ones(diam);
cenPoint = [radius+1,radius+1];
% I'm just making two matrices here to state R,C. It should make sense in
% distance formula context.
forMat1 = ones(diam,1);
forMat2 = 1:diam;
Rows = forMat1*forMat2;
Cols = Rows';
Rows(:,:,2) = -cenPoint(1)*Box;
Cols(:,:,2) = -cenPoint(2)*Box;

distances = sqrt(sum(Rows,3).^2 + sum(Cols,3).^2);
InDisk = logical(distances <= radius);
[offRows,offCols] = find(InDisk);
offRows = offRows - cenPoint(1);
offCols = offCols - cenPoint(2);


end

