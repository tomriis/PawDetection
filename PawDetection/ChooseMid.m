function [ IndRow,IndCol ] = ChooseMid( I,J,pawRadius )
%Often, two of the paws will generate the same maximum in Votes. The
%selection of the index pursued as the true maximum must be as close to the
%middle of a paw as possible in order to reduce fringe brightness
%confusion. This algorithm is meant to do that.
%   Detailed explanation goes here

keepPushing = 1;
% If many points qualify, we need to be more generous with the error
% allowed. In reality, the average will likely be close to the center we
% want if many close points are highlighted.
ErrAllowed = 0.3*sqrt(size(I,1));
numIts = 1;

while keepPushing
    meanRow = mean(I);
    meanCol = mean(J);
    distToMean = sqrt((I - meanRow).^2 + (J - meanCol).^2);
    Err = mean(distToMean);    
    if Err < ErrAllowed*pawRadius || numIts > 100;
        keepPushing = 0;
    else
        [~,furthestInd] = max(distToMean);
        I(furthestInd) = [];
        J(furthestInd) = [];
    end
    numIts = numIts + 1;
end

minInd = find(distToMean == min(distToMean),1,'first');
IndRow = I(minInd);
IndCol = J(minInd);

end


