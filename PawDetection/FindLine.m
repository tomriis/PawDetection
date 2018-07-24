function [ Image,Changed,HaLinha ] = FindLine( Image,pixels )
%This function is meant to find the liniest set of hit pixels in a binary
%thresholded image. Currently, I do not think I need it. We'll see.
%Unsurprisingly, I decided I do. Right now, only lines nearly parallel with
%the vertical axis are visible; I'll change it to run through the image
%twice. The first time, it will use Cartesian coordinates to consider
%slopes yielding angles of -pi/4:pi/4 or 3pi/4:5pi/4. Then, it will do the
%same on the transpose. Polar coordinates aren't doing it for me here.
%   pixels is delivered as a list of RCs in a long, 2 column array.
%   Maybe, for optimization, I could threshold much more roughly. Then look
%   at the high angle, take all rows in those relevant columns, and see
%   which pixels voted for the high intercept somehwere in the subset of
%   those columns. Then, only look at those pixels when doing a finer
%   threshold over a smaller range.

% Empirically determined
LineThresh = 0.5;
SlopeInc = 0.01;
IntInc = 1;
numPix = size(pixels,1);
[totRows,totCols] = size(Image(:,:,1));
midPix = round([totRows/2,totCols/2]);
slopeSamps = -1:SlopeInc:1;
% Given that the steepest possible slope is 1, from the furthest corner the
% highest intercept possible is two times the length of the image. (sort
% of--see the correct analysis below)
maxPossInt = sum(midPix)+1;
intSamps = -maxPossInt:IntInc:maxPossInt;
numSlopeSamps = length(slopeSamps);
numIntSamps = length(intSamps);
rCoords = pixels(:,1) - midPix(1);
cCoords = pixels(:,2) - midPix(2);
% Empirically Determined
spaceRad = 3;
MinLineWidth = 13;
MaxLineWidth = 21;
Steepness = 5;
MedRatio = 3;
HaLinha = 0;
ConThresh = 20;
% The first iteration has a rough threshold; the second iteration zooms in
% on hotspots. (maybe implemented in a future version)

% Therefore, the horizontal axis of Votes will be indexed by slopeSamps;
% the vertical axis will be indexed by intSamps. There is a sheet for each
% pixel to vote in. That way, the sum can be taken in the third dimension.
% There are two 4Ds in Votes. The first one is the given image; the
% second page is its transpose, with the relevant slopes considered in
% each.
Votes = zeros(numIntSamps,numSlopeSamps,2,'int16');
Size = size(Votes);
SlopeVecForEach = repmat(slopeSamps,numPix,1);
rCoordForEach = repmat(rCoords,1,numSlopeSamps);
cCoordForEach = repmat(cCoords,1,numSlopeSamps);
slopeInds = repmat(1:numSlopeSamps,numPix,1);
IndsToSee = [1,numSlopeSamps];

% Run once on the image; once on the image transpose.
kernel = [1/3, 1/2, 1/3; 1/2, 2/3, 1/2; 1/3, 1/2, 1/3];
kernel = kernel./sum(sum(kernel));
for k = 1:2
    PageInds = ones([numPix,Size(2)]);
    % Only points with a slope of up to p/m 1 (inclusive in the first
    % iteration; not inclusive in the second iteration) are considered.
    if k == 2
        PageInds = 2*PageInds;
        temp = rCoordForEach;
        rCoordForEach = cCoordForEach;
        cCoordForEach = temp;
    end
    % Each point in the horizontal axis, or possible slope, will receive
    % exactly one vote on the vertical intercept scale.
    Intercepts = rCoordForEach - SlopeVecForEach.*cCoordForEach;
    IntInds = round((Intercepts+maxPossInt)/IntInc);

    % Eliminate the double counts from the overlapping domains of the two
    % operations.
    if k == 2
        IndsToSee = IndsToSee + [1,-1];
    end
    % Now, each row of IntInds represents a new page in Votes. The value of
    % each element should be the vertical index value in which a vote is
    % being cast for that slope (slope as determined by the horizontal
    % index)
    votes2cast = sub2ind(Size,IntInds(:,IndsToSee(1):IndsToSee(2)), ...
        slopeInds(:,IndsToSee(1):IndsToSee(2)), ...
        PageInds(:,IndsToSee(1):IndsToSee(2)));
    for k1 = 1:numPix
        Votes(votes2cast(k1,:)) = Votes(votes2cast(k1,:)) + 1;
    end
%     Votes(:,:,k) = conv2(Votes(:,:,k),kernel,'same');
end
[maxIntForEachAngle,Loc1] = max(Votes);
[maxInt,Loc2] = max(maxIntForEachAngle);
[Brightest,Loc3] = max(maxInt);
Loc = [Loc1(Loc2(Loc3)), Loc2(Loc3), Loc3];
VoteFrac = double(Brightest)/numPix;
if VoteFrac > LineThresh
    % For now, I'm just assuming that there is a single line to eliminate.
    Changed = 1;
    Intercept = [intSamps(Loc(1))+midPix(1),midPix(2)];
    Slope = slopeSamps(Loc(2));
    Page = Loc(3);
    Object = GetObj(Votes(:,:,Page),[Loc(1),Loc(2)],spaceRad);
    Spread = mean2(Object);
    Ratio = double(Brightest)/Spread;
    Confidence = std2(Object);
    if Confidence < ConThresh
        LineWidth = (MaxLineWidth-MinLineWidth)/(1+exp((Ratio-MedRatio)*Steepness))+MinLineWidth;
        Image = blackLine(Image,Intercept,Slope,pixels,Page,LineWidth);
    else
        HaLinha = [1,Page];
    end
else
    Changed = 0;
end

end

