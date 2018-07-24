function [ pointArray ] = AddLeds( ImNum,pointArray,tpStats,Radius,Image )
%This function intelligently places LEDS in their appropriate entries.
%   pointArray is structured such that each row is a new object. The first
%   row of pointArray is R,C for the first (arbitrarily) LED; the second
%   row is RC for the other LED, and each page is a new frame. Appended to
%   this in the adjacent columns is some information about the object. The
%   third column is the brightness of the object. That helps identify it in
%   adjacent frames. The fourth column contains the page index in which the
%   last instance of that object was found. This is helpful for projecting
%   position.

thesePoints = tpStats(:,1:2);
maxDist = 3*Radius;
numPoints = sum(thesePoints(:,1) > 0);
% This was emprically determined. Even if a point is far away from where we
% think it is, if it's really bright, we definitely just acquiesce and say
% that it's an LED.
typBrightness = 30;
% if numPoints < 2
%     tpStats(2,:) = [0,0,0];
%     if numPoints < 1
%         tpStats(1,:) = [0,0,0];
%     end
% end

ImSize = size(Image);
% The entire algorithm is inside a while loop. The vast majority of the
% time, it will execute only once. Sometimes, the algorithm will want to
% try again with a new set of thesePoints.

TryAgain = 1;
while TryAgain
    thesePoints = tpStats(:,1:2);
    % This resets TpointArray each time, allowing for a fresh analysis.
    TpointArray = pointArray;
    TryAgain = 0;
    if ImNum == 1
        % This operates on the first frame.
        if numPoints < 1
            error('No LEDs visible in first frame');
        elseif numPoints < 2
            %Notice that this is not functional yet, since the later code
            %assumes that the LED was visible at some point.
            error('Only 1 LED visible in first frame');
        end
        TpointArray(:,1:2,ImNum) = thesePoints;
        for k1 = 1:numPoints
            Object = GetObj(Image,thesePoints(k1,:),Radius);
            meanObj = mean(mean(mean(Object,3)));
            TpointArray(k1,3,ImNum) = meanObj;
        end
    else
        % This operates on every frame except the first one.
        likelyRowAssoc = zeros(2,1);
        prevPoints = TpointArray(:,1:2,ImNum-1);
        % This is to let the rest of the code know if only one LED was
        % found in the previous frame.
        if mean2(prevPoints == 0) == 0
            Flag = 0;
        else
            Flag = 1;
            [~,RowNoLed] = min(prevPoints(:,1));
            % Put it far away to prevent close-to-origin accidents.
            prevPoints(RowNoLed,:) = [-500,-500];
        end
        
        % Each point in thesePoints must be matched to one of the previous
        % LEDs
        for k1 = 1:2 % not numPoints
            % This code runs until it is satisfied we have found the LED,
            % or there is no LED to find.
            
            % This will produce a matrix whose first and second columns are
            % identically the coordinates of the LED center under
            % consideration.
            expCoor = repmat(thesePoints(k1,:),2,1);
            dists = sqrt(sum((expCoor - prevPoints).^2,2));
            [Min,Ind] = min(dists);
            
            if Min > maxDist || mean2(expCoor) == 0
                % This is a flag that the wrong red spot might have been
                % highlighted, or that an LED has reappeared some distance
                % away.
                Found = 0;
                if Flag
                    % The LED (maybe) just reappeared. We evaluate the
                    % likelihood for this point.
                    lastKnownInd = TpointArray(RowNoLed,4,ImNum - 1);
                    lastKnownPoint = TpointArray(RowNoLed,1:2,lastKnownInd);
                    elDist = abs(lastKnownPoint - thesePoints(k1,:));
                    if thesePoints(k1,1) == 0
                        Penalty = 100;
                    else
                        if min(elDist) <  15
                            Penalty = 1;
                        else
                            Penalty = min(elDist);
                        end
                    end
                    % We have to recalculate dists using the last known
                    % point. It is only relevant here; we want it to be
                    % really far away for any other analyses so we don't
                    % happen to jump to a new place.
                    FramesWithout = ImNum - lastKnownInd - 1;
                    prevPointsF = prevPoints;
                    prevPointsF(RowNoLed,:) = lastKnownPoint;
                    distsF = sqrt(sum((expCoor - prevPointsF).^2,2));
                    if isempty(tpStats)
                        divisor = 1;
                    else
                    if tpStats(RowNoLed,3) > 0
                        divisor = tpStats(RowNoLed,3);
                    else
                        Object = GetObj(Image,thesePoints(k1,:),Radius);
                        divisor = mean2(Object(:,:,1));
                    end
                    end
                    Score = Penalty*(1/sqrt(FramesWithout))*distsF(RowNoLed)*10/divisor;
                    % This threshold was empirically determined.
                    if Score < 4*maxDist
                        % We refound the LED. We stop attempting to
                        % associate this point and backfill pointArray.
                        Found = 1;
                        Ind = RowNoLed;
                        RowInterp = round(linspace(lastKnownPoint(1), ...
                            thesePoints(k1,1),FramesWithout+2));
                        ColInterp = round(linspace(lastKnownPoint(2), ...
                            thesePoints(k1,2),FramesWithout+2));
                        RowInterp(1) = [];
                        ColInterp(1) = [];
                        TpointArray(RowNoLed,1, ...
                            (lastKnownInd + 1):ImNum) = RowInterp;
                        TpointArray(RowNoLed,2, ...
                            (lastKnownInd + 1):ImNum) = ColInterp;
                    end
                end
                if ~Found
                    % If that didn't work, next we check on the brightness
                    % of this spot to see if we can assuage our doubt.
                    Object = GetObj(Image,thesePoints(k1,:),Radius);                    
                    % We just consider the red channel. By coincidence,
                    % sometimes the wrong channel will be found because
                    % average channel brightness happens to be similar.
                    meanObj = mean2(Object(:,:,1));
                    lastBrightness = TpointArray(Ind,3,ImNum-1);
                    if lastBrightness == 0
                        lastBrightness = .01;
                        Ind = 0;
                    end
                    Error = abs(lastBrightness - meanObj)/lastBrightness;
                    distError = (Min - maxDist)/maxDist;
                    Berror = typBrightness/meanObj;
                    otherPoss = Min/max(dists);
                    Score = distError * Error * Berror * otherPoss;
                    % This score cutoff was empirically determined
                    if Score <= 0.1
                        % Ind was already set. We just confirmed it.
                    else
                        % If that didn't work, we poke around the image a
                        % little more to see if we can find a better match.
                        [bRows,bCols] = makeMask(3*maxDist);
                        offRows = bRows + thesePoints(k1,1);
                        offCols = bCols + thesePoints(k1,2);
                        [offRows,offCols] = ElimOut(ImSize(1:2),offRows,offCols);
                        redPage = ones(length(offRows),1);
                        bInds = sub2ind(ImSize,offRows,offCols,redPage);
                        Image(bInds) = 0;
                        [Image,tpStats] = FindLeds(Image,Radius,0);
                        
                        % If the new result doesn't give us another red
                        % point, then we assume that we've exhausted all
                        % the possibilities and the LED is not detectable.
                        % Otherwise, we break the for loop and start again
                        % with the newly found thesePoints. We can't add
                        % the label yet, because we don't know which
                        % pointArray row is missing its LED. We have to do
                        % this after the for loop.
                        if sum(tpStats(:,1) > 0) < 2
                            Ind = 0;
                        else
                            TryAgain = 1;
                            break
                        end
                    end
                end
            end
            % The only case in which this does not execute is if the code
            % decided there is no LED associated with this k1 center. If
            % so, Ind = 0 and the fourth column is modified after the loop,
            % once we know which row needs it.
            if Ind
                likelyRowAssoc(k1) = Ind;
                TpointArray(Ind,1:2,ImNum) = thesePoints(k1,:);
                Object = GetObj(Image,thesePoints(k1,:),Radius);
                meanObj = mean2(Object(:,:,1));
                TpointArray(Ind,3,ImNum) = meanObj;
            end
        end
        % If we decided that there was no LED for this iteration, then the
        % relevant pointArray entries should remain zero; however, we need
        % to know which Ind these zero entries correspond with to label
        % them appropriately. We make sure that we haven't just quit early
        % in order to try new points.
        if ~TryAgain
            if min(likelyRowAssoc) == 0
                if mean(likelyRowAssoc) > 0
                    Ind = 2/max(likelyRowAssoc);
                    prevVal = TpointArray(Ind,4,ImNum - 1);
                    if prevVal == 0
                        label = ImNum - 1;
                    else
                        label = prevVal;
                    end
                    TpointArray(Ind,4,ImNum) = label;
                    likelyRowAssoc(likelyRowAssoc == 0) = Ind;
                else
                    for k3 = 1:2
                        prevVal = TpointArray(k3,4,ImNum-1);
                        if prevVal == 0
                            label = ImNum-1;
                        else
                            label = prevVal;
                        end
                        TpointArray(k3,4,ImNum) = label;
                        likelyRowAssoc(k3) = k3;
                    end
                end
                
            end
            
            % Just to check. It should never execute.
            if likelyRowAssoc(1) == likelyRowAssoc(2)
                error(strcat('k =_',num2str(ImNum),'_LEDs in same space'));
            end            
        end
    end
end

pointArray = TpointArray;

end

