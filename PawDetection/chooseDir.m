function [ Clock,Dist ] = chooseDir( AngleVec )
%UNTITLED2 Summary of this function goes here
%   Calculates, via the shortest distance from the angles in the first
%   column to the second column, whether the move was clockwise (1) or
%   counter-clockwise (-1) or no change (0). The output, therefore, is a
%   column vector of the same 1st dimension as the input vector. The second
%   column is the distance from the first to second angle in the specified
%   direction--a positive distance therefore is always given.

numEnts = size(AngleVec,1);
[smallerAng,SAInd] = min(AngleVec,[],2);
Periodic = smallerAng + 2*pi;
AltVec = AngleVec;
Rows = (1:numEnts)';
Coords = [Rows,SAInd];
Inds = sub2ind([numEnts,2],Coords(:,1),Coords(:,2));
AltVec(Inds) = Periodic;
CompVec(:,:,1) = AngleVec;
CompVec(:,:,2) = AltVec;

Which2use = abs([diff(AngleVec,[],2),diff(AltVec,[],2)]);
[~,Use] = min(Which2use,[],2);
CreInds = repmat(Rows,1,2);
Inds = sub2ind(size(CompVec),CreInds,repmat([1,2],numEnts,1),repmat(Use,1,2));
UseVec = CompVec(Inds);

TestVec1 = UseVec(:,2) > UseVec(:,1);
TestVec2 = UseVec(:,2) < UseVec(:,1);
TestVec3 = UseVec(:,2) == UseVec(:,1);
Clock(TestVec1) = -1;
Clock(TestVec2) = 1;
Clock(TestVec3) = 0;
Dist = abs(UseVec(:,2) - UseVec(:,1));




end

