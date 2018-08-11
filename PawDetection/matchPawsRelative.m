function [pawCenters, argFourPaws] = matchPawsRelative(pawCenters)
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
    downPawsI = 1:4;
    downPaws = and(pawCenter(:,1) > 0,pawCenter(:,2));
    downPawsI = downPawsI(downPaws);
    pawCenters(downPawsI,:, k) = 0;
    
    distances = zeros(4, size(argFourPaws,2));
    weights = weightFunction(argFourPaws, k, 'unweighted');
    for i=1:size(downPawsI,2)
        for j = 1:size(argFourPaws,2)
            distances(:,j) = sum(abs(pawCenters(:,1:2,argFourPaws(j)) - pawCenter(downPawsI(i),1:2)),2);
        end
        [~, argmin] = min(sum(weights.*distances,2));
        pawCenters(argmin,:,k) = pawCenter(downPawsI(i),:);
    end
end

function [weights] = weightFunction(argFourPaws, imNum, method)
    numFourPaws = size(argFourPaws,2);
    weights = ones(1, numFourPaws);
    indx = 1:numFourPaws;
    if strcmp(method, 'nearestNeighbor')
        neighborsBefore = 10;
        neighborsAfter = 10;
        argsBefore = argFourPaws < k - neighborsBefore;
        argsAfter = argsFourPaws > k + neighborsAfter;
        outOfRange = or(argsBefore, argsAfter);
        weights(outOfRange) = 0;
    elseif strcmp(method, 'linear')
        diff = abs(argsFourPaws - k);
        weights = weights./diff;
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
