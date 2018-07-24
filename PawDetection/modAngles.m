function [ flexedAng ] = modAngles( fixedAng,flexAng,Lims,Clock,coords )
%fixedAng and flexAng must have the same dimensions.
%   Basically, whenever there are two angles that are apparently further
%   (or closer) than they ought to be, the explanation is that one needs to
%   be reflected over the x-axis, or one needs 2pi added (or subtracted)
%   from it. This function will look at both possibilities, given the
%   bounds that I know for apparent distance, and choose what to do. If the
%   problem is 2pi wrapping, it won't do anything, because that implies
%   that the angles are actually correct. This function needs to know one
%   angle that is definitely correct, though, to work. The first given
%   angle will not ever change, obviously, since there's only one output
%   variable.
%   We also tell the function that if one of the angles is close to the
%   x-axis, it should look at the other angle to see if it should change
%   rotation; otherwise, it will enter the next quadrant.

minDiff = Lims(1);
maxDiff = Lims(2);
% The way it needs to work is that the difference is allowed to be much
% greater when the LED is in the middle of the frame. That will be
% reflected later.
AddOn = [-2*pi, 2*pi];
numEnts = size(fixedAng,1)*size(fixedAng,2);
flexedAng = zeros(size(fixedAng));
% if mean(fixedAng > 0.97*2*pi) > 0
%     a=5
% end
distFromCent = abs(cos(fixedAng));
[~,Priority] = min(distFromCent);

for k = 1:numEnts
    Loop = 1;
    Relax = 0;
    while Loop
        fixedAngNow = fixedAng(k);
        flexAngNow = flexAng(k);
        Diff = abs(fixedAngNow - flexAngNow);
        proClock = chooseDir([fixedAngNow,flexAngNow]);
        if Diff < minDiff || Diff > maxDiff || abs(Clock - proClock) + Relax > 1
            % First we try reflection
            flipOver = 2*pi - flexAngNow;
            flipDiff = abs(fixedAngNow - flipOver);
            proClock = chooseDir([fixedAngNow,flipOver]);
            if flipDiff < minDiff || flipDiff > maxDiff || abs(Clock - proClock) + Relax > 1
                % if that didn't work, we try adding 2pi to the flipped an
                % non-flipped entries.
                whichWay = [fixedAngNow < pi, fixedAngNow >= pi];
                addAng = [flexAngNow;flipOver] + AddOn(whichWay);
                [addDiff,bestFit] = min(abs(fixedAngNow - addAng));
                trueAng = addAng(bestFit);
                proClock = chooseDir([fixedAngNow,trueAng]);
                if addDiff < minDiff || addDiff > maxDiff || abs(Clock - proClock) + Relax > 1
                    if k ~= Priority
                        Relax = -2;
                    else
                        dbstack;
                        if exist('coords','var')
                            disp(coords)
                        end
                        error('Unable to resolve');
                    end
                else
                    flexedAng(k) = trueAng;
                    Loop = 0;
                end
            else
                flexedAng(k) = flipOver;
                Loop = 0;
            end
        else
            flexedAng(k) = flexAngNow;
            Loop = 0;
        end
    end
end

subtract = flexedAng > 2*pi;
flexedAng(subtract) = flexedAng(subtract) - 2*pi;
Add = flexedAng < 0;
flexedAng(Add) = flexedAng(Add) + 2*pi;



end

