function [ linDisp ] = ledAnalyze( ledCenters )
%This function is meant to take the information from the LEDs and turn it
%into a rotational velocity vector, and from there describe the linear
%displacement that the rat feels. This will help inform the paw-finding
%functions, as well as yield rat velocity with some massaging.
%   Detailed explanation goes here

% First we'll cut off any hanging zeros at the end.
seeIfThere = mean(mean(ledCenters));
lastData = find(seeIfThere > 0,1,'last');
if ~isempty(lastData)
    ledCenters(:,:,lastData+1:end) = [];
end
% First we have to check that there are sufficient frames to be sure that
% this analysis will be meaningful. If there are not, a warning will
% appear, but the analysis will continue regardless. In general, it should
% be correct if the visible LED passes closely in front of the camera.
Size = size(ledCenters);
numFrames = Size(3);
Angles = zeros(1,numFrames);
rotVec = zeros(1,numFrames);
if numFrames < 250
    warning('It is likely that a good LED pass was not observed')
end

% So, only one LED is super-bright as it passes close to the camera.
% Therefore, we will identify which row of ledCenters contains this LED and
% identify a time when it passes close to the camera and does not change
% direction during that pass. 

kernel = [.08, .16, .33, .5, .33, .16, .08];
kernel = kernel./sum(kernel);
Brightnesses = squeeze(ledCenters(:,3,:));
Cols = squeeze(ledCenters(:,2,:));
SmBr = conv2(Brightnesses,kernel,'same');
brights = max(SmBr,[],2);
brightest = max(brights);
[~,highRow] = max(brights);
[~,midPasses] = findpeaks(Brightnesses(highRow,:),'MinPeakHeight',0.9*brightest,'MinPeakDistance',100);
% [highRow,midPasses] now contains the places where we know that LED is
% passing in front of the camera. We'll use that information to see whether
% it is passing CW or CCW at that moment, and then extrapolate that
% movement to the rest of the movie.
needGoodPeak = 1;
Counter = 1;
Near = 30;
possPeaks = length(midPasses);
while needGoodPeak
    if Counter > possPeaks
        error('No good LED pass availble.')
    end
    thisPeak = midPasses(Counter);
    adjacent = [thisPeak - Near, thisPeak + Near];
    if adjacent(1) < 1
        adjacent(1) = 1;
    elseif adjacent(2) > numFrames
        adjacent(2) = numFrames;
    end
    Nearby = Cols(highRow,adjacent(1):adjacent(2));
    % Now we check for a (nearly) monotonic derivative
    Direc = sign(diff(Nearby));
    Predominant = sign(mean(Direc));
    Cont = length(find(Direc ~= Predominant));
    Undecided = length(find(Direc == 0));
    Error = (Cont-Undecided)/length(Nearby);
    if Error < 0.02
        needGoodPeak = 0;
        if Predominant ==  -1
            % Clockwise rotation
            Clock = 1;
        else
            % Anticlockwise rotation
            Clock = -1;
        end
    else
        Counter = Counter + 1;
    end
end
Distances = abs(diff(Cols));
maxDist = max(Distances);
[~,Intersects] = findpeaks(maxDist-Distances,'MinPeakDistance',50,'MinPeakHeight',maxDist*0.8);
% Intersects should hopefully contain the points where we switch which LED
% we are measuring from. We want to see which column value that is, so that
% as we step through an LED we have a column value at which to switch over.
intCol = Cols(:,Intersects);
minVals = min(Cols,[],2);
Cols = Cols - minVals(:,1)*ones(1,numFrames);
range = [min(Cols,[],2), max(Cols,[],2)];
colsCovered = range(:,2) - range(:,1);
numPoints = size(intCol,1)*size(intCol,2);
artListCols = [ones(numPoints,1),reshape(intCol,numPoints,1)];
spread = 5;
Smallest = min(min(range));
Largest = max(max(range));
[~,Centers] = FindClust((Smallest:Largest)*0,artListCols,spread,[2,2],0);
Switches = Centers(:,2);
% This is the distance from either edge at which you ought to change the
% LED from which you infer the angle of the wheel. Really this exists just
% in case you only have one crossing--otherwise both should have been
% found.
if length(Switches) < 2
    edgeDist = mean([min(Switches) - Smallest, Largest - max(Switches)]);
    Switches = [Smallest + edgeDist, Largest - edgeDist];
end

% Now we should be ready to start assigning vectors to each frame, starting
% with the frame in which we know the direction the wheel was turning. We
% will call the location in the middle of the range through which the LEDs
% can pass 270 degrees (i.e. acos(0) = 270 at that point).
midPoint = mean(range,2);
MPVec = midPoint*ones(1,numFrames); 
percSwitches = (Switches-midPoint)./midPoint;
prepCols = (Cols - MPVec);
prepCols = prepCols./MPVec;
Col2use = Thresh2Bin(prepCols,1,[min(percSwitches),max(percSwitches)]);
% So, the LEDs are not exactly 90 degrees out of phase. This means that
% there are some overlaps: sections where neither LED is within the desired
% range, and sections where both are. We should use both points in those
% spots and average the result.
num2use = sum(Col2use);
num2use(~num2use) = 2;
tsi = find(abs(Nearby-mean(midPoint)) == min(abs(Nearby-mean(midPoint)))) + adjacent(1) - 1;
% We add pi because the acos function will always give 90 for acos(0).
Angles(tsi) = acos(prepCols(highRow,tsi)) + pi;
% We pass off the responsibility of examining each set of angles and
% deducing the true position of the cylinder to a specialized function.
Angles = ProcessAngs(Angles,tsi,prepCols,Clock,num2use,Col2use);
AngleChanges = diff(Angles);
Circled = AngleChanges > pi;
AngleChanges(Circled) = AngleChanges(Circled) - 2*pi;
rotVec = AngleChanges;

CylDiam = 53.80; % cm
CylRad = CylDiam/2;
arcLen = rotVec*CylRad;
cmsPerPix = CylDiam/640;

linDisp = arcLen./cmsPerPix;

% % These are known constants.
% CylDiam = 53.80; % cm
% % ledDiam = 0.55; % cm
% % ArcLength = 36.6; % cm
% % AngleErrorThresh = 5;
% % DistTrav = InnerCylinderDiam - ledDiam;
% CylRad = CylDiam/2;
% 
% DperPix = DistTrav/mean((MaxPix-MinPix)); % cm/pixel
% Coords(1,:) = (Cols(1,:)-ZerPix(1))*DperPix;
% Coords(2,:) = (Cols(2,:)-ZerPix(2))*DperPix;
% Ratio = Coords/CylRad;
% Ratio(Ratio > 1) = 1;
% Ratio(Ratio < -1) = -1;
% Angles = acos(Ratio)*180/pi;
% AngleDiffs = abs(mean([diff(Angles(1,:));diff(Angles(2,:))]));
% cmsperdeg = pi*CylDiam/360;
% LinDist = cmsperdeg*AngleDiffs;


end

