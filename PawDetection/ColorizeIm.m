function [ Image ] = ColorizeIm( image,Show )
%This function is just mean to receive a labelled image, with labels
%ranging from 0:n, where n is the number of groups. It will keep all the
%zeros 0, while assigning a color to each label group. This is purely to
%help with visualization.
%   Detailed explanation goes here

if ~exist('Show','var')
    Show = 1;
end
image = uint8(image);
keepLooking = 1;
itsNone = 0;
itNum = 1;
Image = zeros([size(image),3],'uint8');

while keepLooking
    Inds2Change = find(image == itNum);
    if isempty(Inds2Change)
        itsNone = itsNone + 1;
    else
        itsNone = 0;
        Color = uint8(255*rand(1,3));
        for k = 1:3
            Temp = zeros(size(image),'uint8');
            Temp(Inds2Change) = Color(k);
            Image(:,:,k) = Image(:,:,k) + Temp;
        end
    end
    if itsNone > 10
        keepLooking = 0;
    end
    itNum = itNum + 1;
end
    
if Show
    imshow(Image)
end

end

