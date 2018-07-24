function FauxPCs = InterpolatePaws(pawCenters)
%UNTITLED8 Summary of this function goes here
%   Detailed explanation goes here

NumIn = size(pawCenters,3);
NeedInterp = squeeze(pawCenters(:,5,:) > 0);
if sum(sum(sum(NeedInterp))) == 0
    keepGoing = 1;
    while keepGoing
        currentPage = pawCenters(:,2,keepGoing);
        needInt = currentPage <= 0;
        pawCenters(needInt,5,keepGoing) = 1;  
        keepGoing = keepGoing + 1;
        if keepGoing > NumIn
            keepGoing = 0;
        end            
    end
    NeedInterp = squeeze(pawCenters(:,5,:) > 0);
end
        
keepGoing = 1;
startInd = 1;

for k = 1:4
    while keepGoing;
        firstNeeded = find(NeedInterp(k,startInd:end),1,'first') + startInd - 1;
        if isempty(firstNeeded)
            keepGoing = 0;
        else            
            prevSpot = pawCenters(k,1:2,firstNeeded-1);
            foundAgain = firstNeeded + find(~NeedInterp(k,firstNeeded:end),1,'first')-1;
            if isempty(foundAgain)
                foundAgain = NumIn;
                landSpot = prevSpot;
                keepGoing = 0;
            else
                landSpot = pawCenters(k,1:2,foundAgain);
            end
            numFramesElapsed = foundAgain - firstNeeded;           
            rowInterp = linspace(prevSpot(1),landSpot(1),numFramesElapsed+2);
            colInterp = linspace(prevSpot(2),landSpot(2),numFramesElapsed+2);
            Interp = zeros(1,2,numFramesElapsed+2);
            Interp(1,1,:) = rowInterp;
            Interp(1,2,:) = colInterp;
            pawCenters(k,1:2,firstNeeded-1:foundAgain) = Interp;
            startInd = foundAgain;
        end
    end
    keepGoing = 1;
    startInd = 1;
end

FauxPCs = pawCenters;

end

