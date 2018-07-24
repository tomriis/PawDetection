function [ matchingMat ] = matchDists( cumulativeDists,lastIndexOn )
%This function will take a matrix of distances and use their relative sizes
%to determine which entries represent truth.
%   This function accepts matrices of any size. The output, matchingMat, is
%   of the form originally desired in the matchPaws function. It has a
%   number of columns equal to the number of rows of Dists. Its first row
%   states which column index of Dists best corresponds to the first row
%   entry. lastIndexOn informs this function of which row corresponds to
%   which of the four paws--rows must be skipped when a paw lifts up. For
%   other purposes, you'll have to decide if this is important. I think in
%   any case, I'll use it to inform the function of how many matches to
%   make; the paw function will always send a 1x4 logical in this entry.
%   The second row says how much confidence this function places in its
%   assessment from 0 to 1. If there's only one entry, though, it will say
%   zero.

numThisEnts = size(cumulativeDists,1);
numLastEnts = size(cumulativeDists,2);
numMatches = length(lastIndexOn);
dummyDist = cumulativeDists;
MinDists = min(cumulativeDists);
maxDist = max(max(cumulativeDists))+1;
MinDistsLocs = cumulativeDists == (ones(numThisEnts,1)*MinDists);
seeSecond = cumulativeDists;
seeSecond(MinDistsLocs) = maxDist;
secondPlace = min(seeSecond);
Desperation = (secondPlace-MinDists)./(secondPlace+MinDists);
matchingMat = zeros(2,numMatches);
meanDist = median(reshape(cumulativeDists,1,numThisEnts*numLastEnts));

for k = 1:min([numThisEnts,numLastEnts])
    [~,goingNow] = max(Desperation);
    dummyMins = min(dummyDist);
    thisMin = dummyMins(goingNow);
    Elim = find(dummyDist(:,goingNow) == thisMin,1,'first');
    dummyDist(Elim,:) = maxDist;
    dummyDist(:,goingNow) = maxDist;
    matchingMat(1,lastIndexOn(goingNow)) = Elim;
    matchingMat(2,lastIndexOn(goingNow)) = thisMin/meanDist;
    Desperation(goingNow) = 0;
end
matchingMat(2,:) = 1-matchingMat(2,:);
% Confidences (1,1) says "I think that the _th entry in the given paws is
% the FR paw." (1,2) syas "... is the FL paw." etc.


end

