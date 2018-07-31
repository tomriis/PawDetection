function [ thisIm ] = matchPaws( thisIm,lastIm,Image,ImNum,Prediction,resetCol )
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

% If any of the distances are exactly zero, we can't have that appear in
% the final matrix. It uses exact zeros to identify not visible paws.
if ~resetCol

% I've officially decided that we need to remove the non-paw entries from
% what FindClust found during this iteration, and the non-paws from the
% last frame due to the paws being lifted. That creates some challenging
% indexing problems, so this code is directed towards solving those.
numUp = sum(thisIm(:,1) == 0);
numThisEnts = sum(thisIm(:,1) > 0);
numLastEnts = sum(lastIm(:,1) > 0);
thisEntInds = thisIm(:,1) > 0;
lastEntInds = lastIm(:,1) > 0;
Indices = 1:4;
thisIndexOn = Indices(thisEntInds);
lastIndexOn = Indices(lastEntInds);
ConThresh = 0.4;
WeightingFactor = .35;
UnderwhelmNspatial = 10;
colMatchWeight = 1 + WeightingFactor;
rowMatchWeight = 1 - WeightingFactor;
NumToFind = sum(lastIm(:,1) == 0);
tempInfo = thisIm;
thisLocs = tempInfo(thisEntInds,1:2);

lastLocs = lastIm(:,1:2);
lastLocs = lastLocs(lastEntInds,:);
% So, if we only found three paws but last frame had four, we still have
% four columns (FR:BR), but only three rows (1st to 3rd entries). 
ReprowLL = (repmat(lastLocs(:,1),1,numThisEnts))';
RepcolLL = (repmat(lastLocs(:,2),1,numThisEnts))';
ReprowTL = repmat(thisLocs(:,1),1,numLastEnts);
RepcolTL = repmat(thisLocs(:,2),1,numLastEnts);
rowDists = (ReprowLL - ReprowTL);
colDists = (RepcolLL - RepcolTL);
Dists = sqrt((rowDists.^2) + (colDists.^2));
% I used to add this to the above line; I don't think I want to anymore:
% .*abs(rowDists);
% I believe that our new indexing system makes the following function
% irrelevant. It shouldn't hurt anything; just do nothing.
Dists = CheckZers(lastIm,thisIm,Dists);
% Now, in each column, is the distance of the previous paw from each of the
% four points we've found. Thus, (1,1) says how far apart the last FR paw
% and this first entry are. (2,1) says how far apart the last FR paw and
% this second entry are. (1,2) says how far apart the last FL paw and this
% first entry are, etc.
RepTVotes = repmat(tempInfo(thisEntInds,10),1,numLastEnts);
RepLVotes = (repmat(lastIm(lastEntInds,10),1,numThisEnts))';
VotesDiff = abs(RepTVotes - RepLVotes);
meanVotesDiff = mean(mean(VotesDiff));
VotesChange = UnderwhelmNspatial*VotesDiff./meanVotesDiff;
VotesChange = CheckZers(lastIm,thisIm,VotesChange);

RepTBr = repmat(tempInfo(thisEntInds,3),1,numLastEnts);
RepLBr = (repmat(lastIm(lastEntInds,3),1,numThisEnts))';
BrDiff = abs(RepTBr - RepLBr);
meanBrDiff = mean(mean(BrDiff));
BrChange = UnderwhelmNspatial*BrDiff./meanBrDiff;
BrChange = CheckZers(lastIm,thisIm,BrChange);

IndsLeft = true(1,4);
rowsLeft = true(1,4);

% Right now I'm adding in the information provided by using the expected
% locations of the paws to identify the paws.
ExistingInfo = thisIm(thisEntInds,lastIndexOn+5);
Certainty = 1 - ExistingInfo;
cumulativeDists = VotesChange.*Dists.*BrChange.*Certainty;
% This was the best-case scenario for everything. The entry in which we are
% most confident will be assigned to its correlating paw. No other entries
% may try to use that coordinate to get its distance score.

% I've made a significant change here: because the "distances" often span
% several orders of magnitude, the worst match will exaggerate how close
% the second place entry appears to be when a straight weighted percentage
% is calculated. To reduce this effect, we're taking the log2 of the
% entries so that they are on a comparable scale. We'll see if this messes
% things up. We'll also add an if statement, so that if things are close,
% we won't actually modify anything. I think I'll do this in a specialized
% function.
cumulativeDists = reduceRange(cumulativeDists);
% cumulativeDists(cumulativeDists == 0) = 0.01;
% (Just to avoid divide by zero errors)

% We're going to take a moment to insert the probabilities we've generated
% into pawCenters (thisIm) for future code to reference. These entries are
% from 0 to 1; to shorten the ridiculous scale we generated, we'll call
% everything meanDist that is greater than meanDist, then divide. (We
% actually just took the log of it all)
% Notice that we're now looking at the distances along the rows; this is
% because we're no longer searching for which paw looks like the last one;
% we're seeing how much each given paw looks like each of the last ones.
Insert = cumulativeDists;
maxVals = max(Insert,[],2);
% Now the most likely ones will be the largest. This means that the least
% likely paw will always have a probability of zero.
Insert = repmat(maxVals,1,numLastEnts) - Insert;
% Relabel = cumulativeDists > meanDist;
% Insert(Relabel) = meanDist;
rowSums = sum(Insert,2);
percInsert = Insert./repmat(rowSums,1,numLastEnts);
% This will overwrite the existing probabilities from the stationary paws.
% This is a good side effect, since this information is an update.
tempInfo(thisEntInds,lastIndexOn+5) = percInsert;
% At this point, we absolutely know that the last rows that come from
% FindClust contain zeros, if any paw was not found, so we want to say that
% those rows look nothing like any of the paws. The improved indexing
% system fixes this problem, I think.
% tempInfo(4-numUp + 1:end,6:9) = 0;
 IndsLeft = thisIm(:,1) == 0;
    lastKnown = lastIm(:,5);
    alreadyKnown = logical(lastKnown);
    passLabel = (IndsLeft + alreadyKnown) == 2;
    thisIm(passLabel,5) = lastKnown(passLabel);
    return
Confidences = matchDists(cumulativeDists,lastIndexOn);
if size(Confidences,2) < 4
   thisIm(:,1:2) = TotalManual(Image);
   IndsLeft = thisIm(:,1) == 0;
    lastKnown = lastIm(:,5);
    alreadyKnown = logical(lastKnown);
    passLabel = (IndsLeft + alreadyKnown) == 2;
    thisIm(passLabel,5) = lastKnown(passLabel);

% Now that those are labelled, we'll move onto the ones that need a first
% label.
newLabel = (IndsLeft + (thisIm(:,5)==0)) == 2;
thisIm(newLabel,5) = ImNum-1;
return
    
end
% Put the correct finds into the right category. I think this statement
% will subsitute the commented loops hereafter--the problem was putting the
% rows in order into the output rows; I'm pretty sure logical indexing
% solves all of that. Actually, because the input points could need to be
% able to be placed in any order into the output, I don't think
% straightforward logical indexing can accomplish it. Furthermore, it's
% easiest this way to keep track of which rows are being used, so that any
% unused informative row can be passed on to the placement function.
UsefulRows = Indices(thisEntInds);
for k = 1:4
    Ind = Confidences(1,k);
    if Confidences(2,k) > ConThresh && Ind > 0
        % I have ConThresh set to a really generous value since I wouldn't
        % know what to do if it failed. I'll probably come back later to do
        % something about it.
        thisIm(k,:) = tempInfo(Ind,:);
        UsefulRows(UsefulRows == Ind) = 0;
    end
end
placePaws = logical(Confidences(1,:));
BlankPaws = ~placePaws;
% thisIm(placePaws,:) = tempInfo(thisEntInds,:);
thisIm(BlankPaws,:) = 0;
% for k = 1:numThisEnts % Necessarily 4--zeroes for missing paws lol
%     if Confidences(2,k) > ConThresh
%         Link = Confidences(1,k);
%         thisIm(k,:) = tempInfo(Link,:);
%         IndsLeft(k) = false();
%         rowsLeft(Link) = false();
%     end
% end
% I'm not sure if we really want to zero these out. I left it for now.
% thisIm(IndsLeft,1:4) = zeros(sum(IndsLeft),4);
% thisIm(IndsLeft,10) = 0;
% If no point was found, this next vector should be [-500,-500].

% Alright. So the only thing left is to assign a found paw--it should look
% nothing like anything, since the paw that it actually is was just all
% zeros in the last frame. So this code runs to see if we can assign it to
% something that has just been zeroes.
% rowsLeft = ~Indices(thisEntInds);
try
leftoverRows = sum(UsefulRows > 0);
use2search = UsefulRows(UsefulRows > 0);
if NumToFind
    if mean(leftoverRows > 0)
        for k = 1:length(leftoverRows)
            Propose = tempInfo(use2search,:);
            thisIm = searchFor(Prediction,Propose,thisIm);
        end
    end
end
catch 
    disp('FAILED THIS BLOCK YALL HEYYY')
end
% Reset after adding in found paws.
% I'm pretty sure all this code has to do is update the fifth column. This
% is straightforward, and doesn't require the looping I originally used.
IndsLeft = thisIm(:,1) == 0;
lastKnown = lastIm(:,5);
alreadyKnown = logical(lastKnown);
passLabel = (IndsLeft + alreadyKnown) == 2;
thisIm(passLabel,5) = lastKnown(passLabel);

% Now that those are labelled, we'll move onto the ones that need a first
% label.
newLabel = (IndsLeft + (thisIm(:,5)==0)) == 2;
thisIm(newLabel,5) = ImNum-1;

% totApply = sum(IndsLeft);
% IndsLeft = IndsLeft.*(1:numThisEnts)';
% IndsLeft(~IndsLeft) = [];
% for k = 1:totApply
%     if lastKnown(k) == 0
%         thisIm(IndsLeft(k),5) = ImNum - 1;
%     else
%         thisIm(IndsLeft(k),5) = lastIm(IndsLeft(k),5);
%     end
% end
% end



end

