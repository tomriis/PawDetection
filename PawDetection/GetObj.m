function [ Object ] = GetObj( Image,centerPoint,radius )
%This function gets a square matrix out of a color image with side length
%radius, centered around a center point centerPoint. The option is given to
%have a rectangular ROI. If radius is passed as a 1x2 vector, the first
%argument is the row radius; second is the column radius. Otherwise, it
%assumes the box is square.
%   Detailed explanation goes here

if length(radius) == 1
    radius = [radius,radius];
end

Rad = round(1.5*radius);
imSize = size(Image);
Inds = [centerPoint(1) - Rad(1); centerPoint(1) + Rad(1); ...
    centerPoint(2) - Rad(2); centerPoint(2) + Rad(2)];
tooSmall = Inds < 1;
Inds(tooSmall) = 1;
if Inds(2) > imSize(1)
    Inds(2) = imsSize(2);
end
if Inds(4) > imSize(2)
    Inds(4) = imSize(2);
end

Object = Image(Inds(1):Inds(2),Inds(3):Inds(4),:);



end

