function [ Distances ] = CheckZers( lastIm,thisIm,Distances )
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

FakeSmall = 0.01;
toCheck = uint8(Distances == 0);
lastPoints = lastIm(:,1:2);
thesePoints = thisIm(:,1:2);

[I,J] = find(toCheck);
for k = 1:length(I)
    if sum(lastPoints(J(k),:)) == 0 && sum(thesePoints(I(k),:)) == 0
        % This means we just found a paw that is still not visible.
    else
        Distances(I(k),J(k)) = FakeSmall;
    end
end




end

