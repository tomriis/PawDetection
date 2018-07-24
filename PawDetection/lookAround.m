function [ Blockable ] = lookAround(Votes,IndRow,IndCol,MaxRad)
%This function tries to find the greatest possible blankable radius around
%a given point in an image. That way we don't leave the paw edges in the
%Votes variable to confound the analysis, and we don't accidentally erase
%other paws while blanking an early one.
%   the approach is to examine spokes around the center point and see when
%   at least one of them is likely running into another paw. We cut off the
%   Blockable radius once that happens.

moderate = 0.25;
Size = size(Votes);
% This is going to be passed to the ElimOut function. We don't want the
% edge of the picture to give us unrealistic confidence in the emptiness
% around the pixel, or make us unreasonably cautious.
maxInd = floor(2*min(Size)/sqrt(2));
k = 1;
while k < maxInd
    Val = Votes(k,k);
    if Val == 0
        Substitute = k;
        k = maxInd;
    else
        k = k + 1;
    end
end
stepSize = 2;
numSpokes = 25;
stepVec = 1:stepSize:MaxRad;
Angles = linspace(0,2*pi,numSpokes+1);
Angles(1) = [];
Sines = sin(Angles);
Coss = cos(Angles);
% If you take matching columns "k" of xDisps and yDisps, you'll get the
% integer approximations of the x and y coordinates of a straight line
% originating from (0,0) at an angle Angles(k).
xDisps = round(stepVec'*Coss);
yDisps = round(stepVec'*Sines);

rCoords = yDisps + IndRow;
cCoords = xDisps + IndCol;
[rCoords,cCoords] = ElimOut(Size,rCoords,cCoords,Substitute);

Inds = sub2ind(Size,rCoords,cCoords);
Vals = double(Votes(Inds));
% Now, each column of Vals contains the values along the aforedescribed
% straight line.
HighestVals = max(Vals,[],2);
% Highest Vals contains the highest value among all the spokes at each
% step. It should pretty much monotonically decrease until it encounters
% another paw.
Deriv = diff(HighestVals);
meanD = mean(abs(Deriv));
meanV = mean(HighestVals);
bigInc = Deriv > meanD*moderate;
bigVals = HighestVals > meanV*moderate;
firstLow = find(~bigVals,1,'first');
stopChange = [find(bigInc,1,'first'),find(bigVals(firstLow:end),1,'first')+firstLow];
% Deriv = diff(Vals);
% sumDs = sum(Deriv,2);
% stopChange = find(sumDs > 0,1,'first');
if length(stopChange) == 2
    stopChange = round(mean(stopChange));
elseif length(stopChange) == 1
else
    stopChange = length(HighestVals)/stepSize;
end

Blockable = stopChange*stepSize;




end

