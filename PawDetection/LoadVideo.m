function [ Images ] = LoadVideo( framesDir,Analyze )
%UNTITLED8 Summary of this function goes here
%   Detailed explanation goes here

currentDir = cd;
S = dir(framesDir);
C = struct2cell(S);
if sum(Analyze) == 0
    Analyze = [1,size(S,1)];
end
numLoads = Analyze(2)-Analyze(1)+1;

lookFor = 1;
imageStart = 1;
while lookFor
    lookFor = C{4,imageStart+1};
    imageStart = imageStart + 1;
end
% imageStart will now tell you where the isdir field becomes zero.
if mean(Analyze) == 0
    numFiles = size(C,2);
    numImages = numFiles - imageStart + 1;
    Analyze(1) = 1;
    Analyze(2) = numImages;
end
cd(framesDir);
Test = imread(C{1,imageStart});
Sizes = size(Test);
Sizes(4) = numLoads;
Images = zeros(Sizes,'uint8');
Ind = Analyze(1);
nextGoal = 10;
for k = 1:numLoads
    if 100*k/numLoads > nextGoal
        disp(strcat(['Files are ',num2str(nextGoal),'% Loaded']));
        nextGoal = nextGoal + 10;
    end
    Images(:,:,:,k) = imread(C{1,Ind+imageStart});
    Ind = Ind + 1;
end
clc
disp(strcat(['Files are ',num2str(nextGoal),'% Loaded']));
cd(currentDir);


end

