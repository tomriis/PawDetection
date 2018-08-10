function [ pawCenters,resetCol,Disaster ] = AddPaws( ImNum,pawCenters,Radius,Image,resetCol )
%This function intelligently places the paws or in their appropriate
%entries.
%   pointArray is structured such that each row is a new object. The first
%   row of pointArray is R,C for the front right paw; the second row is RC
%   for the front left paw; third is the back left paw; fourth the bottom
%   right. Each page is a new frame. Appended to this in the adjacent
%   columns is some information about the object. The third column is the
%   brightness of the object. That helps identify it in adjacent frames.
%   The fourth column contains the standard deviation of the brightnesses
%   of the pixels in a box of length M*Radius around the center pixel. The
%   fifth column contains the page index in which the last instance of that
%   object was found. This is helpful for projecting position. The
%   sixth-ninth columns contain the confidence scores, from 0 to 1, of the
%   program for the assignment in that frame. This score is used to make
%   the best possible guess on the assignment, and it is adjusted as the
%   code moves from function to function. The sixth column gives the
%   confidence for the FL; seventh is FR; and so on. If the first two
%   columns contain zeros, that means that the program thinks that row's
%   paw is not currently pressed agains the Plexiglas. In summary:
%   [1 2 3  4   5   6   7   8   9   10   11   12     13
%   [R C Br SD Ind FRc FLc BLc BRc Votes Ang Ask LikelyUp]
%   The 12th entry used to contain the page number of the last defined
%   Angle. However, for simplicity, we're just going to copy angles into
%   the pages where not all paws are down (and thus a new angle cannot be
%   calculated). This means that we'll want to recalculate all angles at
%   the end of the routine. This is time-trivial, so I think it's a good
%   tradeoff.

% Time without paw being seen threshold
Disaster = 0;
TwoThreshold = 6;
thesePoints = pawCenters(:,1:2,ImNum);
resetPawIDs = 0;
firstFrame = 0;
numVisPaws = sum(thesePoints(:,1) > 0);
if ImNum == 1
    firstFrame = 1;
else
    if mean2(pawCenters(:,:,ImNum-1)) == 0
        firstFrame = 1;
    end
end
if firstFrame
    resetPawIDs = 1;
end

% We start by just placing thesePoints into the pointArray at random. That
% will make it easier on future functions to have fewer things to handle.
% For this frame, columns 3-9 always refer to the point in columns 1-2 for
% that row. All of these values are moved to the appropriate row at the end
% of the function.
% pawCenters(1:numVisPaws,1:2,ImNum) = thesePoints;
pawCenters = AddInfo(pawCenters,Radius,Image,ImNum,numVisPaws);

% It is important that the order of pointArray always remain [FL;FR;BL;BR].
% This is the code that establishes these relationships. It requires that
% all four paws be present in the image to guarantee accuracy.
resetCol = 0;
numPawsIn = sum(pawCenters(:,1,ImNum) > 0);
if resetPawIDs
    if numPawsIn == 4
        pawCenters(:,:,ImNum) = UseStats(pawCenters(:,:,ImNum),Image);
    else
        return
    end
end



% This next batch of code checks where the paws picked up, if any appear to
% be up at all, and places that stat in the appropriate column (5). 
lastFrames = max(pawCenters(:,5,ImNum));
if lastFrames == 0
    lastFrames = ImNum;
end
maxSince = ImNum - lastFrames;
if maxSince > TwoThreshold
    resetCol = 1;
end

% Finally, we determine the rat's body axis angle and add that information
% to the pawCenters array.
% Let's start by checking that all four paws are down. If not, we really
% can't determine body angle in this frame with precision.

if numPawsIn == 4
    FrontRows = pawCenters([1,2],1,ImNum);
    FrontCols = pawCenters([1,2],2,ImNum);
    BackRows = pawCenters([3,4],1,ImNum);
    BackCols = pawCenters([3,4],2,ImNum);
    % The first row contains the RC of the midpoint of the back paws;
    % second row is the RC of the midpoint of the front paws. This order
    % serves the default subtraction order of the diff function.
    pawCents(2,:) = [mean(FrontRows),mean(FrontCols)];
    pawCents(1,:) = [mean(BackRows),mean(BackCols)];
    Vector = diff(pawCents);
    Angle = atan2(Vector(1),Vector(2));
else
    Angle = pawCenters(1,11,ImNum - 1);
end
pawCenters(:,11,ImNum) = Angle;

% if ImNum > 1
%     lastPaws = pawCenters(:,1:2,ImNum - 1);
%     if Angle > 7*pi/4 || Angle < 5*pi/4
%         if Angle > 3*pi/4 || Angle < pi/4
%             UseRows = 1;
%         else
%             UseRows = 0;
%         end
%     else
%         UseRows = 0;
%     end
%     if UseRows
%         RightLowL = lastPaws([1,4],1) - lastPaws([2,3],1);
%         RightLowT = Locs([1,4],1) - Locs([2,3],1);
%         SignRLL = sign(RightLowL);
%         SignRLT = sign(RightLowT);
%         if mean(SignRLL == SignRLT) < 1
%             if mean(abs(RightLowT)) > 20
%                 Disaster = 1;
%             end
%         end
%     else
%         RightRightL = lastPaws([1,4],2) - lastPaws([2,3],2);
%         RightRightT = Locs([1,4],2) - Locs([2,3],2);
%         SignRRL = sign(RightRightL);
%         SignRRT = sign(RightRightT);
%         if mean(SignRRL == SignRRT) < 1
%             if mean(abs(RightRightT)) > 20
%                 Disaster = 1;
%             end
%         end
%     end
% end

end

