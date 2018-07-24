function [ thesePaws ] = ConsultUser(Image)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

disp('Click the four paws. FR,FL,BR,BL')
imshow(Image)
thesePaws = ginput(4);
thesePaws = round(flip(thesePaws,2));


end

