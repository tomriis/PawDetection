function [ RatPix,RatIm ] = ThreshLab( IDpix,numGroups,Label,Size )
%This function is meant to take the grouped and labelled pixels in IDpix
%and decide which group is the rat. It labels the brightness image so that
%only the rat blob is lit up, if a nonzero label is passed to the function.
%   RatPix is an n x 3 matrix, where n is the number of pixels included in
%   the rat. The first row is the indices of the pixels; second is the
%   rows; third is the columns.

ExpRow = [150,400];
ExpCol = [40,640];
ExpSD = [0.3,1];
meanRow = mean(ExpRow);
meanCol = mean(ExpCol);
meanSD = mean(ExpSD);

numPix = size(IDpix,1);
Zeros = IDpix(:,4) == 0;
IDpix(Zeros,:) = [];
statsEach = zeros(7,numGroups);
statsEach(1,:) = 1:numGroups;
% New first row is label number. First row is the number of pixels of that
% label. Second is the SD of rows; third of columns. Fourth and fifth are
% mean of R,C. Seventh is the score assigned to that group.

for k = 1:numGroups
    Inds = find(IDpix(:,4) == k);
    Consid = IDpix(Inds,:);
    statsEach(2,k) = length(Inds);
    statsEach(3,k) = std(Consid(:,2));
    statsEach(4,k) = std(Consid(:,3));
    statsEach(5,k) = mean(Consid(:,2));
    statsEach(6,k) = mean(Consid(:,3));
end

statsEach(isnan(statsEach)) = 0;

for k = 1:numGroups
    % Percent of hit pixels in image.
    InGroup = statsEach(2,k)/numPix;
    % The rat will essentially always be oriented on the long axis of the
    % image. Thus, this should be a small number SD(r)/SD(c). We expect a
    % number somewhere between 0.3 and 1.
    SDRatio = statsEach(3,k)/(statsEach(4,k)+.01);
    if SDRatio > ExpSD(1) && SDRatio < ExpSD(2)
        SDPenalty = 0;
    else
        SDPenalty = (1/(1-meanSD) * (SDRatio - meanSD))^2;
    end
    % The rat is most likely to be in rows 150:400 and columns 40:640.
    RowIn = statsEach(5,k);
    if RowIn > ExpRow(1) && RowIn < ExpRow(2)
        RowPenalty = 0;
    else
        RowPenalty = (1/(1-meanRow)*(RowIn - meanRow))^2;
    end
    ColIn = statsEach(6,k);
    if ColIn > ExpCol(1) && ColIn < ExpCol(2)
        ColPenalty = 0;
    else
        ColPenalty = (1/(1-meanCol)*(ColIn - meanCol))^2;
    end
    % Assign score. This is an empirical formula, so change it as needed.
    % Everything is approximately scaled to 10, I think.
    Score = InGroup*(10-SDPenalty-RowPenalty-ColPenalty);
    statsEach(7,k) = Score;
end

[~,RatLabel] = max(statsEach(7,:));

Inds = IDpix(:,4) == RatLabel;
RatPix = IDpix(Inds,1:3);

if Label
    RatIm = false(Size);
    RatIm(RatPix(:,1)) = true();
else
    RatIm = 0;
end


end

