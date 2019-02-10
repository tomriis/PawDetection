function [ Images ] = LoadVideo( framesDir,Analyze )
%UNTITLED8 Summary of this function goes here
%   Detailed explanation goes here

currentDir = cd;
S = dir(framesDir);
C = struct2cell(S);
if ~exist('Analyze','var')
    Analyze = 0;
end
if sum(Analyze) == 0
   Analyze = [1,size(S,1)];
end

lookFor = 1;
imageStart = 0;
filename = C{1,1};
while lookFor || strcmp('.',filename(1))
    imageStart = imageStart + 1;
    lookFor = C{5,imageStart};
    filename = C{1,imageStart};
end
% imageStart will now tell you where the isdir field becomes zero.
%if mean(Analyze) == 0
    numFiles = size(C,2);
    numImages = numFiles - imageStart + 1;
    Analyze(1) = 1;
    Analyze(2) = numImages;
%end
cd(framesDir);
Test = imread(C{1,imageStart});
Sizes = size(Test);
Sizes(4) = numImages;
if Sizes(3) == 0 %Black and white images
    Sizes(3) = 3;
    black_white_image = 1;
else
    black_white_image = 0;
end
Images = zeros(Sizes,'uint8');
Ind = Analyze(1);
nextGoal = 10;

for k = 1:numImages
    if 100*k/numImages > nextGoal
        disp(strcat(['Files are ',num2str(nextGoal),'% Loaded']));
        nextGoal = nextGoal + 10;
    end
    disp(Ind+imageStart)
    if black_white_image
        Images(:,:,1,k) = imread(C{1,Ind+imageStart-1});
        Images(:,:,2,k) = imread(C{1,Ind+imageStart-1});
        Images(:,:,3,k) = imread(C{1,Ind+imageStart-1});
    else
        Images(:,:,:,k) = imread(C{1,Ind+imageStart-1});
    end
    Ind = Ind + 1;
end
clc
disp(strcat(['Files are ',num2str(nextGoal),'% Loaded']));
cd(currentDir);


end



