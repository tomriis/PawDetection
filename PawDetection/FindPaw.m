function [ Image,pawCenters,cRatios,bght_thresh,globMax ] = FindPaw( Image,pawRadius,colorChan,resetCol,ImNum,pawCenters,linDisp,cRatios,bght_thresh)
%This function is meant to find the rat's paws. It includes the code to
%reset the color ratios if necessary.
%   cRatios is a 2 x 1 matrix. The top number is the expected ratio of the
%   green color channel divided by the red color channel. The bottom number
%   is the blue color channel divided by the red color channel. These
%   quotients were chosen because they ought to be similar in the paws, but
%   not for the rat fur.
%   In summary, [G/R; B/R]

sideCuts = 40;
topCut = 100;
dR = 0.05;
ShowIm = 0;
numPaws = [2,4];
addIfDown = 40;
addIfUp = 100;
ImSize = size(Image);
ImSize(3) = [];
midCol = ImSize(2)/2;
if ImNum > 1
    UsePC = logical(mean2(pawCenters(:,:,ImNum-1)));
else
    UsePC = 0;
end

% If the paws are already found in the previous frame, we'll reduce the
% image under consideration to the pixels that the paws could possibly land
% in.
if UsePC
    lastPaws = pawCenters(:,1:2,ImNum-1);
    Zeroes = lastPaws(:,1) == 0;
    LLP = lastPaws;
    LLP(Zeroes,:) = [];
    % [lowRow,highRow;lowCol,highCol]
    Box = [min(LLP(:,1)),max(LLP(:,1));min(LLP(:,2)),max(LLP(:,2))];
    Box(:,1) = Box(:,1) - addIfDown;
    Box(:,2) = Box(:,2) + addIfDown;
    notOne = 1;
    trueMin = min(lastPaws(:,1));
    if trueMin == 0
        % These are the rows where no paw is present.
        allZers = lastPaws(:,1) == 0;
        if max(lastPaws(1:2,2)) > max(lastPaws(3:4,2))
            pointedRight = 1;
        else
            pointedRight = 0;
        end
        if allZers(1) || allZers(2)
            % This means that a front paw is in the air. 
            if pointedRight
                Box(2,2) = Box(2,2) + addIfUp;
            else
                Box(2,1) = Box(2,1) - addIfUp;
            end
        end
    end
    
    % Finally, we cut off the edges of the box to create a new, easier
    % Image.
    tooSmall = Box < 1;
    tooBig = Box(:,2) > ImSize';
    Box(tooSmall) = 1;
    if tooBig(1)
        Box(1,2) = ImSize(1);
    end
    if tooBig(2)
        Box(2,2) = ImSize(2);
    end
    Box(1,1) = 90; % TODO: create manual step to isolate appropriate search area
    Box(1,2) = 380;
    Box(2,1) = 1;
    Box(2,2) = 450;
    UseImage = Image(Box(1,1):Box(1,2),Box(2,1):Box(2,2),:);
    % Now, before we take this massaged image, full of highlit pixels that
    % hopefully include the pays, and send it to the cluster finder, let's
    % give that function a head start and let it know where the paws were
    % in the last image, and how far the cylinder has rotated since then.
    % If the pointArray variable exists, then we can definitely use the
    % led rotation as well.
    thislinDisp = linDisp(ImNum - 1);
    expPaws = lastPaws;
    Zeros = expPaws == 0;
    expPaws(:,2) = expPaws(:,2) + thislinDisp - Box(2,1);
    rowCVec = adjRows(lastPaws,midCol);
    expPaws(:,1) = expPaws(:,1) - Box(1,1) + rowCVec;
    expPaws(Zeros) = 0;
    expPaws = 0;
else
    UseImage = Image;
    notOne = 0;
    expPaws = 0;
end

% The bright edges confuse the finding algorithm, and they seem to be
% pretty constant. So I'm reducing them, and hoping for the best. In the
% future, these cut values may be informed by where the paws have been
% found.
meanIm = mean(UseImage,3);
UseImSize = size(UseImage);
UseImSize(3) = [];

if resetCol 
    if ~notOne
        sendIm = meanIm;
        sendIm(:,1:sideCuts) = 0;
        sendIm(:,(UseImSize(2) - sideCuts):end) = 0;
        sendIm(1:topCut,:) = 0;
    else
        sendIm = UseImage;
    end
    % These constants are meant to work for both ratios, since they should
    % be similar for the channels.
    bght_thresh = ChooseThresh(meanIm);
    [RatPix,~] = FindRat(sendIm,bght_thresh,ShowIm);
    scanVals = 0.8:dR:1.2;
    RatIm = zeros([UseImSize,2],'uint8');
    OverlapIm = false([UseImSize,2]);
    RatIm(RatPix(1,1):RatPix(2,1),RatPix(1,2):RatPix(2,2),:) = uint8(1);
    Scores = zeros(2,length(scanVals));

    for k1 = 1:length(scanVals) % for each of the possible ratios    
        cRatios = scanVals(k1)*ones(2,1);
        HitsIm = DivideColors(UseImage,cRatios,dR);
        numHits = squeeze(sum(sum(HitsIm)));
        HitsIm = uint8(HitsIm);

        Overlap = HitsIm + RatIm;
        OverlapIm(:,:,1) = Thresh2Bin(Overlap(:,:,1),1,[2,2]);
        OverlapIm(:,:,2) = Thresh2Bin(Overlap(:,:,2),1,[2,2]);
        numHitsIn = squeeze(sum(sum(OverlapIm)));
        
        Scores(:,k1) = numHitsIn./numHits;        
    end
    [~,Max1] =  max(Scores(1,:));
    [~,Max2] = max(Scores(2,:));
    cRatios = [scanVals(Max1);scanVals(Max2)];
    disp('Color ratios have been reset');
end

hits = false([UseImSize,4]);

% The next bits of code will help to threshold based on gradient. I'm not
% sure if this information will help, but it'll stay here (at least
% commented) no matter what.
Width = 1;
vertKern = [ones(1,Width);zeros(1,Width);-1*ones(1,Width)];
horKern = [ones(Width,1);zeros(Width,1);-1*ones(Width,1)];
vertCon = conv2(meanIm,vertKern,'same');
horCon = conv2(meanIm,horKern,'same');
gradThreshV = ChooseThresh(vertCon);
gradThreshH = ChooseThresh(horCon);
vertThresh = Thresh2Bin(abs(vertCon),1,gradThreshV);
horThresh = Thresh2Bin(abs(horCon),1,gradThreshH);
GradientThresh = logical(vertThresh + horThresh);
%gradAngs = atan2(vertCon,horCon);

hits(:,:,1:2) = DivideColors(UseImage,cRatios,dR);
hits(:,:,3) = Thresh2Bin(meanIm,1,bght_thresh); % brightness
hits(:,:,4) = GradientThresh;
hits = uint16(hits);
% I don't trust the second page very much, so we'll downplay its
% significance. This is faster than multiplying the second page by 1/2
hits(:,:,[1,3,4]) = hits(:,:,[1,3,4])*2;


CompIm = sum(hits,3);
ThreshIm = Thresh2Bin(CompIm,1,[4,7]);
[hitRows,hitCols] = find(ThreshIm);
hpVals = CompIm(sub2ind(size(CompIm),hitRows,hitCols));
HitPixels = [hitRows,hitCols,hpVals];

% We are adjusting centerPix so that it has seven columns. The third is the
% number of votes for that center; four through seven contain a flag for
% that pixel probably containing the FL and so on paw. This takes advantage
% of our knowledge of the paws' previous locations.
HaLinha = 0;
[UseImage,pawCenters,globMax,HaLinha] = FindClust(UseImage,HitPixels,pawRadius,numPaws,HaLinha,colorChan,0,expPaws,pawCenters,ImNum);
if HaLinha
    [ThreshIm,Changed,HaLinha] = FindLine(ThreshIm,HitPixels);
    if Changed
        [hitRows,hitCols] = find(ThreshIm);
        HitPixels = [hitRows,hitCols];
    end
    [UseImage,pawCenters,globMax,~] = FindClust(UseImage,HitPixels,pawRadius,numPaws,HaLinha,colorChan,0,expPaws,pawCenters,ImNum);
end
% Now, we restore the image to its original dimensions to return to the
% main function.
if notOne
    foundPaws = pawCenters(:,1,ImNum) > 0;
    Image(Box(1,1):Box(1,2),Box(2,1):Box(2,2),:) = UseImage;
    pawCenters(foundPaws,1,ImNum) = pawCenters(foundPaws,1,ImNum) + Box(1,1);
    pawCenters(foundPaws,2,ImNum) = pawCenters(foundPaws,2,ImNum) + Box(2,1);
else
    Image = UseImage;
end

end

