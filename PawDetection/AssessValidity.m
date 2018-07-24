function [ resetCol,Disaster,pawCenters ] = AssessValidity( pawCenters,ImNum,resetCol,Disaster )
%This function runs at the end of every iteration of the findPaw loop. It
%is the last line of defense to see if something is amiss and the iteration
%needs to be rerun in order to arrive at an answer closer to the truth.
%   Detailed explanation goes here

Rematch = 0;
% Our first tactic is to see how greatly the rat's body axis angle has
% changed since all four paws were down. If it's too much, then we're
% confident something bad is happening.
Angle = pawCenters(1,11,ImNum);
if ImNum > 1
    LastAngle = pawCenters(1,11,ImNum - 1);
else
    % This is just an indicator to future code.
    LastAngle = -1;
end
if LastAngle == -1
    LastAngle = Angle;
end
numFramesSince4Down = ImNum - min(pawCenters(:,5));
% Now we know this Angle and LastAngle.

[~,Dist] = chooseDir([Angle,LastAngle]);
if Dist > pi/10*(numFramesSince4Down + 1)
    Disaster = 1;
end

% Now we're going to look at how far apart all the paws are. If it's too
% much, we're pretty sure that things are off. I'm not really going to use
% this code at the moment, because we already chop off a big chunk of the
% image and everything that's inside and possibly seen is reasonable
% enough.
% pawsIn = pawCenters(:,1) > 0;
% numIn = sum(pawsIn);
% ReprowTL = repmat(pawCenters(pawsIn,1,ImNum),1,numIn);
% RepcolTL = repmat(pawCenters(pawsIn,2,ImNum),1,numIn);
% rowDists = (ReprowTL' - ReprowTL);
% colDists = (RepcolTL' - RepcolTL);
% Dists = sqrt((rowDists.^2) + (colDists.^2));
% lowBound = Dists > 0;
% highBound = Dists < 15;
% FailsBoth = lowBound + highBound;
% Problems = FailsBoth > 1;
% if mean2(Problems) > 0
%     Disaster = 1;
% end

% Our next strategy is to look at which way the rat is moving. If there's a
% direction of motion, we want to ensure that the back paws catching up to
% the front paws weren't mistaken for the front paws. I also plan on
% improving the prediction algorithm so that the search area is directional
% instead of circular.
% So, let's first see which paw was most recently placed on the glass
% (within the last number of relevant frames). If none, we really have no
% idea what way the rat is going to go--I think it's about as likely that
% it'll back up as it is to go forward.
% imageWidth = 640;
% currentLocs = pawCenters(:,1:2,ImNum);
currentAngle = pawCenters(1,11,ImNum);

Size = size(pawCenters);
goBack = 30;
if ImNum <= goBack
    startAt = 1;
else
    startAt = ImNum - goBack;
end
lastUps = squeeze(pawCenters(:,5,startAt:ImNum));
possibleChoices = lastUps(:,end) == 0;
IndexOn = (1:4)';
IndexOn = IndexOn(possibleChoices);
timesUp = lastUps(possibleChoices,:) > 0;
mostRecent = find(timesUp);
if isempty(mostRecent)
    % Nothing we can do with this.
else
    numSubs = length(mostRecent);
    Elims = false(numSubs+1,1);
    % We find all the RC values that cite the frame in which a now placed
    % paw lifted from the glass.
    [upRow,upCol] = ind2sub(size(timesUp),mostRecent);
    % Since we aren't necessarily starting on the first page.
    upCol = upCol + startAt - 1;
    upRow = IndexOn(upRow);
    % Eliminate redundancies
    consecFrames = diff(upCol);
    sameRow = double(~diff(upRow));
    Elims(2:end-1) = (consecFrames + sameRow) == 2;
    % We're going to sneakily see when each entry was placed down for
    % future use. Then we'll prepare the falsely too large Elims for other
    % uses.
    fakeElims = Elims;
    fakeElims(1) = [];
    pageEnded = upCol(~fakeElims) + 1;
    Elims(end) = [];
    upRow(Elims) = [];
    upCol(Elims) = [];
    % Now let's get some index-generating vectors done.
    trueSubs = length(upRow);
    spec5Col = 5*ones(trueSubs,1);
    spec1_2Col = [ones(trueSubs,1),2*ones(trueSubs,1)];
    % Convert to indices
    pawCentInds = sub2ind(Size,upRow,spec5Col,upCol);
    % Discover the page numbers
    pageNums = pawCenters(pawCentInds);
    % Create indices to discover the RC previous locations.
    pawPointInds = sub2ind(Size,[upRow,upRow],spec1_2Col,[pageNums,pageNums]);
    lastLocs = pawCenters(pawPointInds);
    placedLocInds = sub2ind(Size,[upRow,upRow],spec1_2Col,[pageEnded,pageEnded]);
    placedLocs = pawCenters(placedLocInds);
    pixChange = placedLocs - lastLocs;
    % Now, before we do anything else with this potentially valuable
    % information, let's make sure that the rat is oriented horizontally,
    % and determine which way the front paws are facing.
    if currentAngle > 7*pi/4 || currentAngle < pi/4
        % Facing positive x (col) direction.
        currentFacing = 1;
    elseif currentAngle > 3*pi/4 && currentAngle < 5*pi/4
        % Facing negative x (col) direction.
        currentFacing = -1;
    else
        % Facing vertically. Don't use this functionality.
        currentFacing = 0;
    end
    if currentFacing ~= 0
        checkAgreement = sign(pixChange(:,2));
        if max(checkAgreement) == min(checkAgreement)
            % Then we're good! probably..
        else
            % Let's try to match the paws again, reducing the probability
            % of the oddball.
            %Rematch = 1;            
            correctDir = mode(checkAgreement);
            if correctDir == 0;
            end
            wrongRow = IndexOn(checkAgreement ~= correctDir);
            pawCenters(wrongRow,12,ImNum) = 1;
        end
    end
end

if Rematch
    thisIm = pawCenters(:,:,ImNum);
    lastIm = pawCenters(:,:,ImNum - 1);
    Prediction = PredictLanding(pawCenters,ImNum);
    thisIm = matchPaws(thisIm,lastIm,0,ImNum,Prediction,0);
    pawCenters(:,:,ImNum) = thisIm;
end
    
    
end

