function [pawCenters] = matchPawsRelative(pawCenters)
    argFourPaws = [];
    for k = 1:size(pawCenters,3)
        numPawsFound = sum(pawCenters(:,1,k)>0 & pawCenters(:,2,k)>0);
        if numPawsFound == 4
                relativePositions = findRelativePositions(pawCenters(:,:,k));
                %relativePositions = [Top Right; Bottom Right; Bottom Left; Top Left]
                %Paws = ['FR';'FL';'BL';'BR'];
                mapping = [4, 3, 2, 1]; 
                pawCenters(:,:,k) = relativePositions(mapping,:);
                argFourPaws(end+1) = k;
        end
    end
    
    for k = 1:size(pawCenters,3)
        numPawsFound = sum(pawCenters(:,1,k)>0 & pawCenters(:,2,k)>0);
        if numPawsFound < 4
            pawCenters = matchByDistance(pawCenters, k, argFourPaws);
        end
    end
        
end

function [pawCenters] = matchByDistance(pawCenters, k, argFourPaws)
    pawCenter = pawCenters(:,:,k);
    before = argFourPaws(argFourPaws < k);
    after = argFourPaws(argFourPaws > k);
    if isempty(before)
        matchTo = pawCenters(:,:, after(1));
    elseif isempty(after)
        matchTo = pawCenters(:,:,before(end));
    else
        if k-before(end) < after(1)-k
            matchTo = pawCenters(:,:,before(end));
        else
            matchTo = pawCenters(:,:,after(1));
        end
    end
    downPawsI = 1:4;
    downPaws = and(pawCenter(:,1) > 0,pawCenter(:,2));
    downPawsI = downPawsI(downPaws);
    pawCenters(downPawsI,:, k) = 0;
    
    for i=1:size(downPawsI,2)
        distances = sum(abs(matchTo(:,1:2) - pawCenter(downPawsI(i),1:2)),2);
        [~, argmin] = min(distances);
        pawCenters(argmin,:,k) = pawCenter(downPawsI(i),:);
    end
end

function [TrBrBlTl] = findRelativePositions(pawCenters)
    TrBrBlTl = zeros(size(pawCenters));
    for i = 1:4
        rightOrLeft = pawCenters(:,2) < pawCenters(i,2);
        topOrBottom = pawCenters(:,1) > pawCenters(i,1);
        if sum(topOrBottom) >= 2
            if sum(rightOrLeft) >= 2
                TrBrBlTl(1,:) = pawCenters(i,:);
            else
                TrBrBlTl(4,:) = pawCenters(i,:);
            end
        else
            if sum(rightOrLeft) >= 2
                TrBrBlTl(2,:) = pawCenters(i,:);
            else
                TrBrBlTl(3,:) = pawCenters(i,:);
            end
        end
    end
end

function pawCenter = zeroDuplicatePoint(pawCenter)
    for i = 1:4
        if sum(~sum(pawCenter(:,1:2)-pawCenter(i,1:2), 2)) > 1
            pawCenter(i,:) = 0;
        end
    end
end