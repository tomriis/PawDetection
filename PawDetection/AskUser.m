function [ pawCenters ] = AskUser( Image,pawCenters,ImNum )
%This function exists because I don't think the code will be good enough to
%find the paws perfectly, nor to perfectly know when it is in error.
%Therefore, to at least make it functional, the code will ask the user
%after every frame if its solution is correct.
%   If everything is correct, strike enter to continue. If not, the code
%   will ask the user to identify each of the signals it found. 

imshow(Image)
PlotEm(pawCenters(:,1:2,ImNum),0,0,['FR';'FL';'BL';'BR']);
Correct = input('If correct, strike Enter. Otherwise, strike another key and Enter\n');
if ~Correct
    pawCenters(:,12,ImNum) = 1;
    pawCenters = ManualPlace(Image,pawCenters,ImNum,0);
end
close all
clc

end

