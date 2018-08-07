function [ cropped ] = Crop( image,wantedRows,wantedColumns )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
% New change here

cropped = uint8(zeros(wantedRows(2) - wantedRows(1) + 1,wantedColumns(2) - wantedColumns(1) + 1,3));

for k = 1:3
    cropped(:,:,k) = image(wantedRows(1):wantedRows(2),wantedColumns(1):wantedColumns(2),k);
end

end

