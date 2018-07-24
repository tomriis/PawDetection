function [ Image,centerPix,meanMax,HaLinha ] = FindClust( Image,Pixels,radius,numClust,HaLinha,Color,thesePaws,expPaws,pawCenters,ImNum )
%This function looks for pixels that are arranged in a disk geometry by
%placing a disk around each pixel and seeing where the highest density
%of Votes occurs.
%   Image is obviously the binary thresheld image in question.
%   Pixels is the list of those pixels in Image which are highlighted. It
%   is passed as an n x 2 matrix, where the first column is the row
%   coordinates; second column is column coordinates.
%   radius is obviously the disk radius of interest.
%   numClust informs the function the maximum number of disks to look for.
%   Color informs the function which color channel ought to be highlighted
%   for the Image that is passed back. If zero is passed, it will skip this
%   operation. By default, it is a 1: the red channel.
%   centerPix will only have a length equal to the number of clusters the
%   algorithm found, which could be less than numClust.

if ~exist('Color','var')
    Color = 1;
end
if ~exist('expPaws','var')
    expPaws = 0;
end
if ~exist('thesePaws','var')
    thesePaws = 0;
end
if ~exist('pawCenters','var')
    pawCenters = 0;
end
if ~exist('ImNum','var')
    ImNum = 1;
end
% This number is expanded into a differently sized vector in each iteration
% of the while loop, so it is necessary to keep Color untouched, and use
% the dummy OColor instead.
OColor = Color;
searchRad = 5;
decExpect = .3;

if HaLinha(1)
    if HaLinha(2) == 1
        HighRow = 0;
    else
        HighRow = 1;
    end
end

% We are describing the object of interst in these next lines, and
% zero-padding the parent image to avoid bleeding over the edge.
% Adding one makes life so much easier, so that there is an easy center
% point. Otherwise, the center is not lying on a pixel.
diam = radius*2+1;
numPixels = size(Pixels,1);
[imRow,imCol,~] = size(Image);
totRow = imRow + 2*diam;
totCol = imCol + 2*diam;
Votes = zeros(totRow,totCol,'int16');
votesSize = size(Votes);

% The goal is to create a zone of zeros around the calculated middles.
% minMult says how many radii away we are confident that no new object will
% be detected.
maxRad = min([10*radius,min(votesSize)]);
SDThresh = 2.15;
minBlock = 2*radius;

% There are two differently sized disks that are useful to us. We need the
% populating disk, described by offRows and offCols; and we need the
% blanking disk, large enough to cover up all relevenat pixels from the
% pseudo-random center. This disk is described by boffRows and boffCols.
[offRows,offCols] = makeMask(radius);
% This is the output. We need to know where the centers are of the numClust
% clusters. If there are fewer than numClust, the zeros are eliminated at
% the end.
if length(pawCenters) > 1
    centerPix = pawCenters;
    SeeingPaws = 1;
else
    centerPix = zeros(numClust(2),7);
    SeeingPaws = 0;
end

% Here are some threshold variables we use to help decide whether a paw has
% lifted or not. 
distThresh = 7;
decThresh = -0.2;
percInThresh = 0.2;
Tester = [percInThresh;percInThresh;distThresh;decThresh];
ofMax = 0.5;
ofBase = 20;
% This is used to put the indicators on equal value footing.
Value = [0.1;0.1;2;1];
% The larger the number, the more the previous entries count for
% determining whether the paw is up.
Tau = 1;
% This one exaggerates the effect of positive numbers to make up for the
% other negatives.
multPos = 3;
if size(Pixels,2) == 2
    Pixels(:,3) = 1;
end
% Each pixel votes once in all the pixles described by the little mask.
for k = 1:numPixels
    labelVal = Pixels(k,3);
    % Add diam so that the image edges line up with the original.
    PixRow = Pixels(k,1) + diam;
    PixCol = Pixels(k,2) + diam;
    % These are now arrays centered around the pixel under examination.
    resRows = PixRow + offRows;
    resCols = PixCol + offCols;
    onList = sub2ind(votesSize,resRows,resCols);
    Votes(onList) = Votes(onList) + labelVal;
end
num2start = sum(sum(Votes));
% kernel = [1/6, 1/3, 1/6; 1/3, 1, 1/3; 1/6, 1/3, 1/6];
% kernel = kernel./sum(sum(kernel));
% Votes = uint16(conv2(Votes,kernel,'same'));

% keepLooking is a counter, as well as a nonzero true.
keepLooking = 1;
prevMax = 0;
meanMax = zeros(1,numClust(2));
Flag = logical(mean2(expPaws));
% Known paw box offset value
KnPawOff = 30;
if mean2(thesePaws)
    % I don't remember what this is for. If this breakpoint is ever
    % activated, investigate.
    centerPix(:,1:2) = thesePaws;
    for k = 1:4
        trueLoc = thesePaws(1,:);
        moveRow = round(trueLoc(1) + diam);
        moveCol = round(trueLoc(2) + diam);
        centerPix(k,3) = Votes(moveRow,moveCol);
    end
else
pawUp = zeros(1,4);
Sum = zeros(1,4);
someStation = zeros(1,4);
Analysis = zeros(4,4);
while keepLooking
    Allgood = 1;
    Color = OColor;
    % We have to decide what point to examine next. The first way is just
    % to find the maximum in the Votes matrix; the other (and the one we
    % use first now) is to look at the locations where a stationary paw
    % ought to lie, then see if a really nearby pixel is a local maximum.
    if Flag
        % We use the flag conditional so that we only have to do this once;
        % future loop iterations will ignore this code and just use the
        % result at the end of this statement.
        Base = mean2(Votes);
        currentMax = max(max(Votes));
        expVoteLocs = expPaws;
        expVoteLocs(:,1) = expVoteLocs(:,1) + diam;
        expVoteLocs(:,2) = expVoteLocs(:,2) + diam;
        numEntries = (2*searchRad - 1)^2;
        surroundingPix = zeros(numEntries,4);
        [maskRows,maskCols] = makeMask(searchRad);
        for k = 1:4
            surRows = maskRows + round(expVoteLocs(k,1));
            surCols = maskCols + round(expVoteLocs(k,2));
            [surRows,surCols] = ElimOut(votesSize,surRows,surCols);
            surroundingPix(:,k) = Votes(sub2ind(votesSize,surRows,surCols));
        end
        someStation(1,:) = (expPaws(:,2) > 0)';
        % It is convenient to place these variables here, since we can
        % compute them at once, instead of doing them after a point has
        % been chosen later on in the code.
        Analysis(1,:) = sum(surroundingPix > ofMax*currentMax)./numEntries;
        Analysis(2,:) = sum(surroundingPix > ofBase*Base)./numEntries;
        Flag = 0;
        % If all three entries of likelyThere are greater than zero,
        % especially if they're close to 1, we feel really confident that
        % that paw has remained stationary. So, let's set up these paws
        % immediately. We'll go in order, starting with FL and down, and
        % only allow the program to see the space surrounding the
        % corresponding coordinate.   
    elseif mean(someStation)
        % If the flag is off, but there's still at least one stationary
        % paw, we do nothing.
    else
        currentMax = max(max(Votes));
        useVotes = Votes;
        pawRow = 0;
        pawCol = 0;
        someStation = 0;
    end
    if currentMax == 0
        % This code guarantees that both checks will fail in the next if
        % statement. Even if we really think there are 2 LEDs, for
        % instance, if there's truly zero brightness out there, we'll have
        % to make do. Obviously checking all the zero values just wastes
        % time.
        currentMax = -1;
        numClust(1) = 0;
    end
    if mean(someStation)
        % This means that we know a stationary paw.
        firstPaw = find(someStation > 0,1,'first');
        pawLoc = expVoteLocs(firstPaw,:);
        pawRow = round(pawLoc(1));
        pawCol = round(pawLoc(2));
        useVotes = Votes(pawRow - KnPawOff:pawRow + KnPawOff,...
            pawCol - KnPawOff:pawCol + KnPawOff);
        currentMax = max(max(useVotes));        
    else
        % I think this is safe, since we do the known paws first. This
        % variable is unecessary once the known paws are complete.
        KnPawOff = 0;
        firstPaw = 1;
    end
    % Right now, the only check for continuing to label clusters is that it
    % be at least ~ of the last maximum. With four paws, this means that
    % the fourth paw could be ~^4 of the brightest paw.
    if currentMax >= prevMax*decExpect || keepLooking <= numClust(1) || mean(someStation)
        
        [I,J] = find(useVotes >= 0.975 * currentMax);
        % Now, we have to add back the rows and columns we took out to
        % affect the real counter.
        I = I + pawRow - KnPawOff;
        J = J + pawCol - KnPawOff;
        [IndRow,IndCol] = ChooseMid(I,J,radius);
        if mean(someStation)
            % We need to evaluate if the paw we found based on previous
            % location should actually be considered, based on some
            % statistics.
            RowDist = expPaws(firstPaw,1) - (IndRow - diam);
            ColDist = expPaws(firstPaw,2) - (IndCol - diam);
            DistFromExp = sqrt(RowDist^2 + ColDist^2);
            prevMax = pawCenters(firstPaw,10,ImNum - 1);
            diffMax = double(currentMax) - prevMax;
            percDM = diffMax/prevMax;
            Analysis(1:2,firstPaw) = -Analysis(1:2,firstPaw);
            Analysis(3:4,firstPaw) = [DistFromExp;percDM];
            Analysis(:,firstPaw) = ((Analysis(:,firstPaw) - Tester)./Tester).*Value;
            Analysis(Analysis > 0) = Analysis(Analysis > 0)*multPos;
            Sum(firstPaw) = sum(Analysis(:,firstPaw))./size(Analysis,1);
            centerPix(firstPaw,13,ImNum) = Sum(firstPaw);
            % Now, we're going to say that this result carries some
            % likelihood of the pawing being up. Often, the process of the
            % paw going up takes a couple frames, so we'll combine this
            % result with the last five frames (exponentially decaying the
            % result back towards t=0) to make a final decision.
            if sum(someStation) == 1
                % Use this breakpoint to look at Analysis after all
                % iterations are complete.
                a=5;
            end
            if ImNum <= 3
                lookBack = 1;
            else
                lookBack = ImNum - 3;
            end
            stretchVec = exp(((lookBack:ImNum) - ImNum)./Tau);
            lastLikelies = squeeze(centerPix(firstPaw,13,lookBack:ImNum))';
            % So it's set up such that a large negative number indicates
            % that the paw is definitely not up. A large positive number
            % means it probably is.
            pawUp(firstPaw) = sum(lastLikelies .* stretchVec);
            if pawUp(firstPaw) < 0
                Allgood = 1;
            else
                Allgood = 0;
            end
        end
        Blockable = lookAround(Votes,IndRow,IndCol,maxRad);
        if Blockable < minBlock
            Blockable = minBlock;
        end
        if HaLinha(1)
            RowsIn = -Pixels(:,1) + IndRow + 1;
            ColsIn = -Pixels(:,2) + IndCol + 1;
            Size = [2*Blockable+1,2*Blockable+1];
            [RowsIn,ColsIn] = ElimOut(Size,RowsIn,ColsIn);
            if HighRow
                SDRatio = std(RowsIn)/std(ColsIn);
            else
                SDRatio = std(ColsIn)/std(RowsIn);
            end
            if SDRatio > SDThresh
                % Then this is probably part of the line. We'll let the
                % routine erase it, and then remove it from the output.
                Allgood = 0;
            end
        end
        [boffRows,boffCols] = makeMask(Blockable);
        resRows = IndRow + boffRows;
        resCols = IndCol + boffCols;
        [resRows,resCols] = ElimOut([totRow,totCol],resRows,resCols);
        onList = sub2ind(size(Votes),resRows,resCols);
        Votes(onList) = 0;
        
        % This code is now to label the original image for visualization.
        % It can be skipped by passing a 0 into color.
        if Color
            OresRows = IndRow-diam+offRows;
            OresCols = IndCol-diam+offCols;
            [OresRows,OresCols] = ElimOut([imRow,imCol],OresRows,OresCols);
            Color = Color*ones(length(OresRows),1);
            OonList = sub2ind(size(Image),OresRows,OresCols,Color);        
            Image(OonList) = 255;
        end
        
        if Allgood
            centerPix(keepLooking,1:2,ImNum) = [IndRow-diam,IndCol-diam];  
            meanMax(keepLooking) = currentMax;
            if SeeingPaws
                centerPix(keepLooking,10,ImNum) = currentMax;
                % These surety scores are in columns 6-9. We only enter
                % information if we're getting this paw based on a
                % stationary paw's location.
                if mean(someStation)
                    centerPix(keepLooking,firstPaw + 5,ImNum) = 0.9;
                end
            end
            keepLooking = keepLooking + 1;
        end
        
        if keepLooking > numClust(2)
            totalIts = keepLooking-1;
            keepLooking = 0;
        end        
    else
        totalIts = keepLooking;
        keepLooking = 0;
    end
    % This is where we advance to the next entry. 
    expVoteLocs(firstPaw,:) = 0;
    prevMax = currentMax;
    someStation(firstPaw) = 0;
end

% We're going to try and decide if there is a line in the Votes image by
% looking at how many pixels have not been cancelled.
num2end = sum(sum(Votes));
percentLeft = num2end/num2start;
Volume = votesSize(1)*votesSize(2);
% This is what I've seen so far. It is subject to change, of course.
typVol = 200*300;
Modifier = typVol/Volume;
percentLeft = percentLeft*Modifier;

if percentLeft > 0.05
    HaLinha = 1;
else
    HaLinha = 0;
end

meanMax(meanMax == 0) = [];
% I don't think we ever want fewer than four entries when the paws are
% being examined.
% offset = 0;
% for k = 1:numClust(2)
%     if centerPix(k - offset,1) == 0 && ~SeeingPaws
%         centerPix(k - offset,:) = [];
%         offset = offset + 1;
%     end
% end

end
end

