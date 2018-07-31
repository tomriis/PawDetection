function [ Prediction] = PredictLanding(pointArray,ImNum)
%Prediction will (archaically) consist of [final expected R,C,framesSince,
%expected R,C this frame]
%   Detailed explanation goes here

lastPoints = pointArray(:,:,ImNum - 1);
%thesePoints = pointArray(:,:,ImNum);
Inds2predict = lastPoints(:,1) == 0;
num2predict = sum(Inds2predict);
if num2predict
    reallyThere = mean2(lastPoints(:,1));
    if ~reallyThere
        num2predict = 0;
    end
end
Prediction = zeros(4,5);
return
if num2predict
    tau = 15;
    % [constant,ahead of paired front paw; constant, ahead of paired back
    % paw]; This has since been changed to mean multiple of start distance
    % of forward paw; multiple of start distance of back paw.
    PixelsForward = [150,1.2;150,1];
    PixFor = PixelsForward;
    
    PairIndex = [1,2,1;2,1,1;3,4,2;4,3,2];
    
    lastKnownInd = lastPoints(:,5);
    numFramesSince = ones(4,1)*ImNum - lastKnownInd;
    numFramesSince(numFramesSince == ImNum) = 0;
    IndsInQuest = 1:4;
    IndsInQuest = IndsInQuest(Inds2predict);
    
    for k = 1:num2predict
        Page = lastKnownInd(IndsInQuest(k));
        if max(pointArray(1:2,2,Page)) < max(pointArray(3:4,2,Page))
            PixFor = -PixelsForward;
        end
        % I should probably use the starting column to gain information
        % about the placement.
        lastKnownPoints = pointArray(IndsInQuest(k),1:2,Page);
        PairedPaw = PairIndex(IndsInQuest(k),2);
        pfRow = PairIndex(IndsInQuest(k),3);
        ppLoc0 = pointArray(PairedPaw,1:2,Page);
        distanceBetweenAtJumpOff = abs(lastKnownPoints - ppLoc0);
        % Pixels forward
        PF = PixFor(pfRow,2)*distanceBetweenAtJumpOff(2);
        % paired paw Location in the previous frame; this will change the
        % prediction from frame to frame.
        ppLoc = lastPoints(PairedPaw,1:2);        
        % Prediction at time infinity (unmodified by time elapsed)
        ProwUn = lastKnownPoints(1);
        PcolUn = ppLoc(2) + PF;
        % Distance to row since liftoff
        DRSL = abs(ProwUn - lastKnownPoints(1));
        DCSL = abs(PcolUn - lastKnownPoints(2));
        ProwEx = ProwUn + DRSL*(1-exp(-numFramesSince(IndsInQuest(k))/tau));
        PcolEx = PcolUn + DCSL*(1-exp(-numFramesSince(IndsInQuest(k))/tau));
        
        Prediction(IndsInQuest(k),:) = [ProwUn,PcolUn,Page,ProwEx,PcolEx];
        PixFor = PixelsForward;
    end
    
    Prediction = [Prediction,numFramesSince];
    
end


end

