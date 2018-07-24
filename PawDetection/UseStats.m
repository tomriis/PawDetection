function [ pointArray,Flag ] = UseStats( pointArray,Image )
%If fewer than four paws are provided, I think this function will have to
%guess where the missing paws are, based on at least two paws that are
%down.
%   Note that this function just receives the page of pointArray under
%   consideration; not the whole thing. Thus it returns the sort numbers,
%   always in a 1x4 column, including zeros where it is unsure. The number
%   in the column says which index of the given pointArray belongs in that
%   spot.

% This flag is passed back to the previous function. If turned on, it says
% that there is likely an error in the paw placement.
Flag = 0;
% We don't want to consider paws that were not detected.
tempPointArray = pointArray;
numPaws = sum(tempPointArray(:,1) > 0);
needElim = sort(tempPointArray(:,1) == 0,'descend');
for k = 1:length(needElim)
    tempPointArray(needElim(k),:) = [];
end

% Row, Column
Locs = tempPointArray(:,1:2);
Brights = tempPointArray(:,3);
Sds = tempPointArray(:,4);
CenterLoc = [mean(Locs(:,1)),mean(Locs(:,2))];
% Columnwise, this is the displacement of the row coordinates from the
% center of mass and columns coordinates from the center of mass.
Disps = [-Locs(:,1) + CenterLoc(1),Locs(:,2) - CenterLoc(2)];
Angles = atan2(Disps(:,1),Disps(:,2));
Convert = Angles < 0;
Indices = 1:numPaws;
Angles(Convert) = Angles(Convert) + 2*pi;
Angles = [Angles,Indices'];

% It should be straightforward to pair paws, since their distances and
% column displacements are often distinctive.
rowRep = repmat(tempPointArray(:,1),1,numPaws);
colRep = repmat(tempPointArray(:,2),1,numPaws);
rowDists = abs(rowRep - rowRep');
colDists = abs(colRep - colRep');
allRDists = sum(rowDists);
allCDists = sum(colDists);
SDrd = std(Disps(:,1));
SDcd = std(Disps(:,2));
if SDcd < SDrd
    % This means that the rat probably isn't aligned perpendicular to the
    % axis of the cylinder. I have a breakpoint here to investigate further
    % when that happens.
    Flag = 1;
end
Dists = sqrt((rowDists).^2 + (colDists).^2);
proto = eye(numPaws);
aSymDist = Dists(~proto);
% These are empirically guessed numbers. Liable to change.
if max(aSymDist) > 350 || min(aSymDist) < 20
    Flag = 1;
end

% We construct a fake diagonal, so that the minDists are not confounded by
% the necessary zeros.
MaxDist = max(max([rowDists,colDists]));
LrowDists = rowDists + MaxDist*proto;
LcolDists = colDists + MaxDist*proto;
RminDist = min(min(LrowDists));
CminDist = min(min(LcolDists));
RowInfo = mean(allRDists)/RminDist;
ColInfo = mean(allCDists)/CminDist;
numPairsPoss = floor(numPaws/2);
% These pairs are row-wise. In other words, the two front and back paws
% should be paired in each column.
RLpairs = zeros(numPairsPoss,2);
if RowInfo > ColInfo
    [lhsRow,lhsCol] = find(LrowDists == min(min(LrowDists)),1);
    FBpair = [lhsRow,lhsCol];
    Indices([lhsRow,lhsCol]) = [];
    RLpairs(:,1) = FBpair';
    Inds = true(1,4);
    Inds(FBpair(1)) = false();
    Inds(FBpair(2)) = false();
    LcolDists(FBpair(1),~Inds) = max(max(LcolDists));
    [~,firstLikely] = min(LcolDists(FBpair(1),:));
    Inds(firstLikely) = false();
    LcolDists(FBpair(2),~Inds) = max(max(LcolDists));
    [~,secondLikely] = min(LcolDists(FBpair(2),:));
    Repeats = [mean(Indices == lhsRow),mean(Indices == lhsCol)];
    if firstLikely == secondLikely || mean(Repeats) > 0
        Flag = 1;
    else
        RLpairs(:,2) = [firstLikely;secondLikely];
    end
else
    [lhsRow,lhsCol] = find(LcolDists == min(min(LcolDists)),1);
    if lhsCol > lhsRow
        Sub = 1;
    else
        Sub = 0;
    end
    RLpairs(1,:) = [lhsRow,lhsCol];
    Indices(lhsRow) = [];
    Indices(lhsCol-Sub) = [];
    RLpairs(2,:) = Indices;
end

% At this point, the FR paw is either in the first or third quadrant,
% assuming that the rat is oriented perpendicular to the cylinder axis. We
% will now make a quadrilateral (if there are four paws) and see what the
% angles are to the adjacent paws (assuming no paw crosses) and see if that
% helps inform paw identity.

Angles = sortrows(Angles,1);
% If the rat is positioned normally, the first entry is either the BL paw
% or FR paw. The third entry would be the other.

[highSD,highSDloc] = max(Sds);
[lowBr,lowBrloc] = min(Brights);

SdsConf = highSD/sum(Sds);
BrConf = 1-lowBr/sum(Brights);

PossibleEntries = [Angles(1,2),Angles(3,2)];
SDmatch = max(highSDloc == PossibleEntries)*SdsConf;
Brmatch = max(lowBrloc == PossibleEntries)*BrConf;
if SDmatch > Brmatch
    arraySort(1) = highSDloc;  
else
    arraySort(1) = lowBrloc;
end
AngleEntry = find(Angles(:,2) == arraySort(1));
BLpaw = Angles(3/AngleEntry,2);
[~,BLcol] = find(RLpairs == BLpaw);

[row,col] = find(RLpairs == arraySort(1));
arraySort(2) = RLpairs(row,2/col);
arraySort(3) = BLpaw;
arraySort(4) = RLpairs(2/row,2/BLcol);


tempPointArray = pointArray;
for k = 1:numPaws
    pointArray(k,:) = tempPointArray(arraySort(k),:);
end

end

