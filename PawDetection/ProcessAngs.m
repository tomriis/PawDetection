function [ Angles,Clocks ] = ProcessAngs( Angles,tsi,prepCols,firstClock,~,Col2use )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

% Angle Change Threshold
ACThresh = pi/10;
% Listen to Middle Exponent
LTME = 3;
% So, because the camera is gathering light in a cone, the frame edges are
% particularly poor estimates of the position of the cylinder. So we have
% to know the true angular distance between the two LEDs for the visual
% data to make more sense; we will estimate that the burden of the apparent
% error is proportionally higher on the LED further from the midline.
trueDist = pi/2;
tryAngles = acos(prepCols);
Clocks = zeros(1,length(Angles));
Differences = zeros(size(Clocks));
Clocks(tsi) = firstClock;
% We know that we need to reflect the tsi coordinate across the x-axis.
% This has already been done for the Angles variable, but we've changed the
% structure so that the tryAngles variable will also remain up to date on
% everything.
tryAngles(Col2use(:,tsi),tsi) = 2*pi - tryAngles(Col2use(:,tsi),tsi);
OtherAtTsi = tryAngles(~Col2use(:,tsi),tsi);
tryAngles(~Col2use(:,tsi),tsi) = modAngles(Angles(tsi),OtherAtTsi,[pi/2,2*pi/3],0);
% We consider the position of the cylinder to be the central angle between
% the two LEDs.

% Now let's try and decide what the "true" distance is between the LEDs.
% Since we have to guess somewhat during the overlap sections, this will
% help determine the correct value to use. 
% angDists = diff(tryAngles);
% kernel = [ones(1,10)*-1, 0,ones(1,10)];
% ChangeEn = abs(conv(angDists.^2,kernel,'same'));
% HighGood = max(ChangeEn) - ChangeEn;
% [~,seeVal] = findpeaks(HighGood,'MinPeakDistance',50);
% First we will travel backwards to the beginning of the video; then we
% will jump back to this point and continue onwards to the end. This
% chronology is necessary so that we anchor the truth on this tsi (270-ish)
% point.

Backwards = prepCols(:,1:tsi-1);
numBack = size(Backwards,2);
Forwards = prepCols(:,tsi+1:end);
numFor = size(Forwards,2);
VecNum = [numBack,numFor];
numEnts = size(prepCols,2);

% The point of this loop is to get the LEDs to go around in a circle
% reliably in the correct quadrants. We make sure that any direction
% changes are agreed upon by both LEDs. The tryAngles vector that comes out
% of this will be the definitive voice on what angles the LEDs think they
% are describing.
for k1 = 1:2
    Lim = VecNum(k1);
    for k = 1:Lim
        Clock = firstClock;
        switch k1
            case 1 % This is for the run going backwards
                thisPoint = numBack - k + 1;
                lastAngs = tryAngles(:,thisPoint + 1);
                lastCols = prepCols(:,thisPoint + 1);
            case 2 % This is for forwards
                thisPoint = tsi + k;
                lastAngs = tryAngles(:,thisPoint - 1);
                lastCols = prepCols(:,thisPoint - 1);
        end
        thisAngles = tryAngles(:,thisPoint);
        % Before we "fix" these angles, we have to decide what the rotation
        % was between last frame and this frame. This is transmitted to the
        % following specialized function, to force quadrant changes (i.e.
        % preclude it from backspinning unless told to by the more accurate
        % LED)
        distFromCent = abs(cos(lastAngs));
        [~,reliable] = min(distFromCent);
        lastCol = lastCols(reliable);
        thisCol = prepCols(reliable,thisPoint);
        % last reliable angle
        LRAng = lastAngs(reliable);
        if LRAng > pi
            if thisCol > lastCol
                Clock = -1;
            elseif thisCol < lastCol
                Clock = 1;
            else
                Clock = 0;
            end
        elseif LRAng < pi
            if thisCol > lastCol
                Clock = 1;
            elseif thisCol < lastCol
                Clock = -1;
            else
                % No change to Clock.
            end
        end
        Clocks(thisPoint) = Clock;
        realAngs = modAngles(lastAngs,thisAngles,[0,ACThresh],Clock,[k1,k]);
        tryAngles(:,thisPoint) = realAngs;
    end
end
% Now, we have to go through and decide what the LEDs actually mean for
% each entry. If there's one within the bounds we've set, then we'll just
% use that, subtracting (or adding) to get to the midway point. If not,
% we'll use both LEDs to approximate the midpoint. Or maybe approximate
% throughout anyway, since we're on that train. The only problem is
% deciding how the error should scale.
[~,Dists] = chooseDir(tryAngles');
Error = abs(trueDist - Dists);
% This is not necessarily the true distance from the midline. You can raise
% it to an exponent so that the program listens more than proportionally to
% LEDs that are close to the center.
distFromCent = abs(prepCols).^LTME;
TotalDistFromCent = sum(distFromCent);
percDist = distFromCent./repmat(TotalDistFromCent,2,1);
% We have to decide which row has the half distance added; which
% subtracted. This should never change.
rowDir = mean(chooseDir(tryAngles'));
if rowDir == 1
    Mult = [-1;1];
elseif rowDir == -1
    Mult = [1;-1];
else
    dbstack
    error('How?');
end
halfAngAdd = repmat(repmat(trueDist/2,2,1).*Mult,1,numEnts) + tryAngles;
% Now, the places where this messes up are where one of the angles has
% crossed 2pi and the other hasn't. We have to find the really different
% values.
Diffs = diff(halfAngAdd);
ChangeUp = logical(double(Diffs > pi) + double(Diffs < -pi));
[~,toAdd] = min(halfAngAdd);
Indices = sub2ind(size(halfAngAdd),toAdd(ChangeUp),find(ChangeUp));
halfAngAdd(Indices) = halfAngAdd(Indices) + 2*pi;

trueAdd = halfAngAdd.*(1-percDist);
Angles = sum(trueAdd);
SubOut = Angles > 2*pi;
AddOn = Angles < 0;
Angles(SubOut) = Angles(SubOut) - 2*pi;
Angles(AddOn) = Angles(AddOn) + 2*pi;
%         if thisNum2use == 1
%             thisAng = thisAngles(thisCol2use);
%             if abs(thisAng - lastAng) > ACThresh
%                 % Reflect across the x-axis. We assume that this will
%                 % automatically yield the correct result, if it was off to
%                 % begin with.
%                 thisAng = 2*pi - thisAng;
%             end
%             % Now we assign our correct value to the two tracking
%             % variables.
%             tryAngles(thisCol2use,thisPoint) = thisAng;
%             Angles(thisPoint) = thisAng;
%             % Now that we're satisified we know the Angle and have
%             % officially assigned it, we have to figure out what the other
%             % angle is saying.
%             otherAngPoss = [0,2*pi];
%             otherAngPoss = otherAngPoss + tryAngles(~thisCol2use,thisPoint);
%             Difference = min(abs(thisAng - otherAngPoss));
%             Differences(thisPoint) = Difference;
%             
%             
%             
%         elseif thisNum2use == 2
%             Err = zeros(1,2);
%            for k2 = 1:2
%                if abs(thisAngles(k2) - lastAng) > ACThresh
%                    thisAngles(k2) = 2*pi - thisAngles(k2);
%                end
%                Err(k2) = abs(thisAngles(k2) - lastAng);
%            end
%            if diff(thisAngles) > ACThresh
%                dbstack
%                disp(strcat(['k1 = ',num2str(k1)]))
%                disp(strcat(['k = ',num2str(k)]))
%                error('Error here');
%            end
%            [~,Read] = min(Err);
%            Angles(thisPoint) = thisAngles(Read);
%         else
%             dbstack
%             error('Error here');
%         end
%         
%         if abs(Angles(thisPoint) - lastAng) > ACThresh
%             Angles(thisPoint) = 2*pi - Angles(thisPoint);
%         end
%         if abs(Angles(thisPoint) - lastAng) > ACThresh
%             dbstack
%             disp(strcat(['k1 = ',num2str(k1)]))
%             disp(strcat(['k = ',num2str(k)]))
%             error('Error here');
%         end
% 
%         % Now we think that things are good. However, we have to see if we have
%     % claimed a non-existent change in rotation at the quadrant borders.
%     % We start by seeing if we're close to moving quadrants.
%     flagVals = [25, 155];
%     minVal = min(flexedAng);
%     maxVal = max(flexedAng);
%     if minVal < flagVals(1) || maxVal > flagVals(2)
%         % So we have danger. Let's explore.
%         
%         prevVal = fixedAng(reliable);
%         if prevVal > nowVal
%             newClock = -1;
%         elseif prevVal < nowVal
%             newClock = 1;
%         end
%         if newClock ~= Clock
%             rotChange = 1;
%         else
%             rotChange = 0;
%         end
%         % Now we know if we imagine the cylinder to have changed rotation
%         % directions in this frame. Let's see if the border LED agrees with
%         % that assessment. If not, we'll redo the loop with a flag in place
%         % to force it to keep that rotation.
%         
%     else
%         Loop = 0;
%     end

% We pretended that the wheel was moving the opposite direction while we
% were traveling backwards in time. Let's change it to be correct now.
Scrutiny = Clocks(1:tsi-1);
Scrutiny(Scrutiny == 1) = 0;
Scrutiny(Scrutiny == -1) = 1;
Scrutiny(Scrutiny == 0) = -1;
Clocks(1:tsi-1) = Scrutiny;

    
end

