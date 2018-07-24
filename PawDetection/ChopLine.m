function [ RatPix,RatIm ] = ChopLine( RatPix,ImageWanted,Size )
%This function is meant to find and remove a vertical line that is stuck to
%the rat. 
%   Detailed explanation goes here

numPix = size(RatPix,1);
ExpRSize = [90,130];
ExpCSize = [200,400];
meanRSize = mean(ExpRSize);
meanCSize = mean(ExpCSize);
ScoreThresh = 0.20;

if ~exist('ImageWanted','var')
    ImageWanted = 0;
    Size = 0;
end

firstTopLeft = [min(RatPix(:,2)),min(RatPix(:,3))];
firstBotRight = [max(RatPix(:,2)),max(RatPix(:,3))];
firstVolume = (firstBotRight(1) - firstTopLeft(1)) * ...
    (firstBotRight(2) - firstTopLeft(2));
firstDensity = size(RatPix,1)/firstVolume;
firstRsize = firstBotRight(1) - firstTopLeft(1);
firstCsize = firstBotRight(2) - firstTopLeft(2);
firstRerror = abs((firstRsize - meanRSize))/meanRSize;
firstCerror = abs((firstCsize - meanCSize))/meanCSize;
firstScore = firstDensity*(1-firstRerror-0.3*firstCerror);

if firstScore < ScoreThresh
    Chop = 1;
else
    Chop = 0;
end

if Chop
    % We'll eliminate all the pixels in successive COLUMNS. This will be
    % good for eliminating the whole bar if the rat is on the far side of
    % the enclosure. It won't be good for when the seam is passing through
    % the rat. Therefore, we'll check if there are still pixels left on
    % both sides of the eliminated columns, and restore them if there are.
    %SDorig = std(RatPix(:,2)); Maybe use as scoring mechanism?
    Elim = 1;
    FirstPix = 1;
    LastPix = numPix;
    numPixIn = LastPix - FirstPix + 1;
    Scores = zeros(1,5);
    numIt = 1;
    while Elim
        ChopIndsC = floor(numPixIn*[1/3,1/2,2/3])+FirstPix;
        ChopInds = [FirstPix,ChopIndsC,LastPix];
        % Five sections will be considered--only the rows. The first row of
        % the cell is the portion of the image we consider to be the rat.
        % We use this is as the metric against which to compare the chopped
        % portion. The second row is the chopped portion of the image. If
        % it wins, this is what we'll examine to find the Line.
        Pieces = cell(2,5);
        SliceInds = [1,4;1,2;2,5;1,3;3,5];
        SliceInds(:,:,2) = [4,5;2,4;1,2;3,5;1,3];
        for k = 1:5
            Pieces{1,k} = RatPix(ChopInds(SliceInds(k,1,1)): ...
                ChopInds(SliceInds(k,2,1)),2);
            Pieces{2,k} = RatPix(ChopInds(SliceInds(k,1,2)): ...
                ChopInds(SliceInds(k,2,2)),2);
            if k == 2 % Necessary for middle section missing
                Pieces{1,2} = [Pieces{1,2};...
                RatPix(ChopInds(4) : ChopInds(5),2)];
            end
        end
        
        for k = 1:5
            subPix = cell2mat(Pieces(1,k));
            delSubPix = cell2mat(Pieces(2,k));
            numSubPix = size(subPix,1);
            percElim = 1-numSubPix/numPixIn;
            subSD = std(subPix);
            delsubSD = std(delSubPix);
            Scores(1,k) = delsubSD/subSD/percElim;
        end
        [~,BestChop] = max(Scores);
        FirstPix = ChopInds(SliceInds(BestChop,1,2));
        LastPix = ChopInds(SliceInds(BestChop,2,2));
        numPixIn = LastPix - FirstPix + 1;
        
        if BestChop == 2
            nowRatPix = [RatPix(ChopInds(1):ChopInds(2),:);...
                RatPix(ChopInds(4):ChopInds(5),:)];
        else
            FirstPixRatInd = ChopInds(SliceInds(BestChop,1,1));
            LastPixRatInd = ChopInds(SliceInds(BestChop,2,1));
            nowRatPix = RatPix(FirstPixRatInd:LastPixRatInd,:);
        end
        
        
        nowTopLeft = [min(nowRatPix(:,2)),min(nowRatPix(:,3))];
        nowBotRight = [max(nowRatPix(:,2)),max(nowRatPix(:,3))];
        nowVolume = (nowBotRight(1) - nowTopLeft(1)) * ...
            (nowBotRight(2) - nowTopLeft(2));
        nowDensity = size(nowRatPix,1)/nowVolume;
        nowRsize = nowBotRight(1) - nowTopLeft(1);
        nowCsize = nowBotRight(2) - nowTopLeft(2);
        nowRerror = abs((nowRsize - meanRSize))/meanRSize;
        nowCerror = abs((nowCsize - meanCSize))/meanCSize;
        nowScore = nowDensity*(1-nowRerror-0.3*nowCerror);
        
        oldRatPix = nowRatPix;
        if nowScore > ScoreThresh && nowScore > 1.5*firstScore
            RatPix = nowRatPix;
            Elim = 0;
        elseif nowScore < firstScore
            RatPix = oldRatPix;
            Elim = 0;
        end
        numIt = numIt + 1;
    end
end   


if ImageWanted
    RatIm = false(Size);
    RatIm(nowRatPix(:,1)) = true();
else
    RatIm = 0;
end




end

