function [ hitsIm ] = DivideColors( Image,cRatios,dR )
%This function is meant to receive the image under examination and find a
%set of significant points, given expected color ratios among the three
%color channels. It gives back a 3D matrix of logicals for later use.
%   Image is meant to be an RBG color image. cRatio is a double precision
%   2x1 matrix containing the desired target ratios for green over red and
%   blue over red respectively. dR is the space permitted on either side of
%   cRatio in the threshold.
imSize = size(Image);
Thresholds = [cRatios - dR, cRatios + dR];
gr_threshes = Thresholds(1,:);
br_threshes = Thresholds(2,:);
doubleIm = double(Image);

green_red_im = doubleIm(:,:,2)./(doubleIm(:,:,1)+0.1);
blue_red_im = doubleIm(:,:,3)./(doubleIm(:,:,1)+0.1);
hitsIm = zeros([imSize(1:2),2],'uint8');
hitsIm(:,:,1) = Thresh2Bin(green_red_im,1,gr_threshes); % green over red
hitsIm(:,:,2) = Thresh2Bin(blue_red_im,1,br_threshes); % blue over red


end

