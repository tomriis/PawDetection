function [ I_bin ] = Thresh2Bin( I, Logical, Threshes )
%Takes an image and checks to see if pixels fall between a range specified
%by at exactly two thresholds. Returns a binary image based on this
%analysis.
%   Given an image with intensity values from 0 to 255--including a 3D
%   array, for which the analysis will only be conducted on the first
%   page--and two threshold values, the function will examine every pixel
%   and determine whether it falls between or is equal to those
%   thresholds--returning a 1--or does not--returning a zero. The function
%   then returns this binary image. If a "1" is given as the logical
%   argument, then this image will contain logical values; otherwise, it
%   will retain int8 data.

iSize = size(I);
I_test = zeros(iSize(1),iSize(2),3);
I_test(:,:,1) = I >= Threshes(1);
I_test(:,:,2) = I <= Threshes(2);
I_test(:,:,3) = -1*ones(iSize(1),iSize(2));
I_sum = sum(I_test,3);
I_bin = logical(I_sum);
if ~Logical
    I_bin = uint8(I_bin);
end
end

