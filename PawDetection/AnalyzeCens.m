function [Data] = AnalyzeCens(pawCenters,ledCenters,num_analyze)
%This function creates the final output of the algorithm. It takes the
%information gathered from the locations of the paws and leds and uses it
%to make statements about the gait of the animal.
%   Data is a vector of: [meanAngle, SDAngle, meanVel, SDVel, FRpercOn, FL,
%   BL, BR,percentFewerthan3]

InnerCylinderDiam = 53.80; % cm
ledDiam = 0.55; % cm
ArcLength = 36.6; % cm
AngleErrorThresh = 5;
DistTrav = InnerCylinderDiam - ledDiam;
CylRad = DistTrav/2;
MaxPix = [max(squeeze(ledCenters(1,2,:))),max(squeeze(ledCenters(2,2,:)))];
MinPix = [min(squeeze(ledCenters(1,2,num_analyze(1):num_analyze(2)))), ...
    min(squeeze(ledCenters(2,2,num_analyze(1):num_analyze(2))))];
if num_analyze(2) < 200
    % It's likely a full period was not established. These are suggested.
    MaxPix = [635, 635];
    MinPix = [1,1];
end
ZerPix = mean([MaxPix;MinPix]);
Cols = squeeze(ledCenters(:,2,:));

DperPix = DistTrav/mean((MaxPix-MinPix)); % cm/pixel
Coords(1,:) = (Cols(1,:)-ZerPix(1))*DperPix;
Coords(2,:) = (Cols(2,:)-ZerPix(2))*DperPix;
Ratio = Coords/CylRad;
Ratio(Ratio > 1) = 1;
Ratio(Ratio < -1) = -1;
Angles = acos(Ratio)*180/pi;
AngleDiffs = abs(mean([diff(Angles(1,:));diff(Angles(2,:))]));
cmsperdeg = pi*InnerCylinderDiam/360;
LinDist = cmsperdeg*AngleDiffs;

CentersOfMass = mean(pawCenters(:,1:2,:));
Rows = squeeze(CentersOfMass(1,1,:));
Cols = squeeze(CentersOfMass(1,2,:));
PixBetween = sqrt(diff(Rows).^2 + diff(Cols).^2);
DistBetween = PixBetween*DperPix;
FrontPawCenters = squeeze([mean(pawCenters(1:2,1,:)),mean(pawCenters(1:2,2,:))]);
BackPawCenters = squeeze([mean(pawCenters(3:4,1,:)),mean(pawCenters(3:4,2,:))]);

RatVel = abs(LinDist - DistBetween');
whileRunning = RatVel > 1;
VwR = RatVel(whileRunning);

PawsOn = squeeze(pawCenters(:,1,:) > 0);
totalOn = sum(PawsOn,2);
numOn = sum(PawsOn);
FewerThan3 = sum(numOn < 3);
percOn = totalOn./(num_analyze(2)-num_analyze(1));
perft3 = FewerThan3./(num_analyze(2)-num_analyze(1));

Vector = FrontPawCenters - BackPawCenters;
pawAngles = atan2(-Vector(1,:),Vector(2,:));
Negs = pawAngles < 0;
pawAngles(Negs) = 2*pi + pawAngles(Negs);
pawAngles = pawAngles*180/pi;

Data = [mean(pawAngles),std(pawAngles),mean(VwR),std(VwR),percOn',perft3];





end

