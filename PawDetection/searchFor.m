function [ thisIm ] = searchFor(Prediction,vecsLeft,thisIm)
%This function checks to see if we agree that the "found" paw really is the
%paw we're looking for.
%   Detailed explanation goes here

pointsLeft = vecsLeft;
numFramesSince = Prediction(:,6);
% Prediction row exponential
FindThresh = 40*sqrt(numFramesSince);

PossibleFinds = Prediction(:,1) > 0;
ProwEx = Prediction(PossibleFinds,4);
PcolEx = Prediction(PossibleFinds,5);
IndsInQuest = 1:4;
IndsInQuest = IndsInQuest(PossibleFinds);
numLeft = size(pointsLeft,1);
numPreds = sum(PossibleFinds);


% Prediction rows; here rows So this isn't as easy as it sounds. We want
% (1,1) entry to be the distance between the first prediction and first
% leftover coordinate. We want (1,2) to be the distance between the first
% prediction and second leftover coordinate. We want (2,1) to be the
% distance between the second prediction and first leftover coordinate.
% This means that we want the matrix to be NxM, where N is the number of
% predictions and M is the number of leftover coordinates.
Prows = repmat(ProwEx,1,numLeft)';
Hrows = repmat(pointsLeft(:,1),1,numPreds);
Pcols = repmat(PcolEx,1,numLeft)';
Hcols = repmat(pointsLeft(:,2),1,numPreds);
Dists = sqrt((Prows - Hrows).^2 + (Pcols - Hcols).^2);

minDists = min(Dists);

matchingMat = matchDists(Dists,true(1,sum(PossibleFinds)));

% Because the Prediction variable always has four rows (zeros where
% irrelevant), matchingMat will always have four columns. Thus we index
% over all four, and k lets us know which paw we're talking about. I
% changed my mind here, actually. 
for k = 1:sum(PossibleFinds)
    thisInd = matchingMat(1,k);
    thisMin = minDists(thisInd);
    thisPaw = IndsInQuest(thisInd);
    thisThresh = FindThresh(thisPaw);
    if thisMin < thisThresh
        thisIm(thisPaw,:) = vecsLeft(k,:);
    end
end

end

