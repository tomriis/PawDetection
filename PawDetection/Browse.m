function [ ] = Browse( Images,varargin )
%Allows the user to browse through a stack of colored images in a 4D
%matrix.
%   Decrease Matlab window size to scroll through more easily. Add arrays
%   to varargin to state what you wish labeled in the images. Do so in
%   pairs: 'leds',[2x2+xY]; 'paws', [4x2+xY]; 'angles', [1,Y] where Y is
%   the number of frames.

keepRunning = 1;
imageNum = 1;
imshow(Images(:,:,:,imageNum));
text(15,15,num2str(imageNum),'Color',[1,1,1]);
Text = ['FR';'FL';'BL';'BR'];
if ~mod(nargin,2)
    error('Must pass arguments as name/value pairs');
end
numPairs = (nargin-1)/2;
numIn = size(Images,4);
for k = 1:numPairs
    varName = cell2mat(varargin(2*k-1));
    varVal = cell2mat(varargin(2*k));
    switch varName
        case 'leds'
            ledArray = varVal;
        case 'paws'
            pawArray = varVal;
        case 'angles'
            angleArray = varVal;
    end
end
if ~exist('pawArray','var')
    pawArray = zeros(4,2,numIn);
end
if ~exist('ledArray','var')
    ledArray = zeros(2,2,numIn);
end
if ~exist('angleArray','var')
    angleArray = zeros(1,numIn);
end
thesePaws = pawArray(:,1:2,imageNum);
theseLeds = ledArray(:,1:2,imageNum);
thisAngle = angleArray(imageNum);
PlotEm(thesePaws,theseLeds,thisAngle,Text);

while keepRunning
    clc
    Event = input('0 to quit. Enter to advance. Number and enter to skip\n');
    if Event == 0
        keepRunning = 0;
    end
    if isempty(Event)
        imageNum = imageNum + 1;
        imshow(Images(:,:,:,imageNum));
        text(15,15,num2str(imageNum),'Color',[1,1,1]);
        thesePaws = pawArray(:,1:2,imageNum);
        theseLeds = ledArray(:,1:2,imageNum);
        thisAngle = angleArray(imageNum);
        PlotEm(thesePaws,theseLeds,thisAngle,Text);
    end
    if Event ~= 0
        imageNum = imageNum + Event;
        imshow(Images(:,:,:,imageNum));
        text(15,15,num2str(imageNum),'Color',[1,1,1]);
        thesePaws = pawArray(:,1:2,imageNum);
        theseLeds = ledArray(:,1:2,imageNum);
        PlotEm(thesePaws,theseLeds,thisAngle,Text);
    end
end

close all

end

