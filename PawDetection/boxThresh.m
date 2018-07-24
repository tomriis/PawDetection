function [ binI ] = boxThresh( I, mvar, bsize )
%This function receives an image and a minimum variance to distinguish
%all-backrgound from regions of interest, and a box size in which to
%calculate this variance. bsize is specifically the length of a side of
%the box. 
%   This function has been modified to only accept a binary, logical image.

if size(I,3) > 1
    I = I(:,:,1);
end

binI = false(size(I));
[size1,size2] = size(I);
numHorTrans = fix(size2/bsize);
numVerTrans = fix(size1/bsize);
if rem(size2,bsize) > 0 % This means you need a partial iteration
    numHorTrans = numHorTrans + 1;
end
if rem(size1,bsize) > 0 % This menas you need a partial iteration
    numVerTrans = numVerTrans + 1;
end

ULcor = [1,1];
LRcor = [bsize,bsize];

alreadyDoneHor = 0;
for a = 1:numVerTrans
    for b = 1:numHorTrans
        box = I(ULcor(1):LRcor(1),ULcor(2):LRcor(2));
        boxlist = uint8(reshape(box,size(box,1)*size(box,2),1));
        if sum(boxlist) > mvar
            binI(ULcor(1):LRcor(1),ULcor(2):LRcor(2)) = box;
%            masd = mean(boxlist) + std(boxlist);
%            box = uint8(I(ULcor(1):LRcor(1),ULcor(2):LRcor(2))-1); % Transform into brightnesses to pass to other function
%            box = double(Thresh2Bin(box,0,[0,masd])); % Transform back into doubles
        end
%        binI(ULcor(1):LRcor(1),ULcor(2):LRcor(2)) = box;
        
        if b+1 < numHorTrans % if true, not yet arrived to end of row, which could be a partial iteration
            ULcor(2) = b*bsize + 1;
            LRcor(2) = (b+1)*bsize;
        elseif rem(size(I,2),bsize) > 0 && alreadyDoneHor == 0 % if true, there is a partial iteration to do next
            ULcor(2) = b*bsize+1; % This shouldn't changes
            LRcor(2) = size(I,2);
            alreadyDoneHor = 1;
        elseif rem(size(I,2),bsize) == 0 && alreadyDoneHor == 0
            ULcor(2) = b*bsize + 1;
            LRcor(2) = (b+1)*bsize;
            alreadyDoneHor = 1;
        else % No partial iteration to do, move to next line
            ULcor(2) = 1;
            LRcor(2) = bsize;
            alreadyDoneHor = 0;
            if a+1 < numVerTrans % if true, not yet arrived to end of vertical translations, which could be partial                
                ULcor(1) = a*bsize + 1;
                LRcor(1) = (a+1)*bsize;                
            elseif rem(size(I,1),bsize) > 0 % There must be a partial iteration
                ULcor(1) = a*bsize + 1; % this shouldn't change
                LRcor(1) = size(I,1);
            else % No partial iteration needed
                ULcor(1) = a*bsize + 1;
                LRcor(1) = (a+1)*bsize;
            end
        end
    end
end
        imshow(binI)
    


end

