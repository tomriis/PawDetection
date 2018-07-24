function [ bght_thresh ] = ChooseThresh( meanIm )
%This function is hopefully going to find the best range of brightnesses
%in which to find the rat using just histogram analysis. It is possible
%that the cropped image (bright sides and top blacked out) should be
%passed, since those are usually the confoundingly similarly bright pixels.
%   Detailed explanation goes here

% I really hope these constants are sufficiently universal.
FracOfMax = 0.05;
FracOfPix = 0.9;
FracOfPixEnd = 1;
numConNeg = 3;
allowSep = 0.2;

Hist = sum(hist(meanIm,0:255),2);
totPix = size(meanIm,1)*size(meanIm,2);
[Max,MaxLoc] = max(Hist);
CumSum = cumsum(Hist);
Deriv = diff(Hist);
SignDeriv = sign(Deriv);

GuessM = find(Hist(MaxLoc:end) < FracOfMax*Max,1,'first');
GuessC = find(CumSum > FracOfPix*totPix,1,'first');
Guess = floor(mean([GuessM,GuessC]));

[~,minLoc] = min(Deriv);
Uncertain = 1;
while Uncertain
    if mean(SignDeriv(minLoc:minLoc + numConNeg)) == -1
        Uncertain = 0;
    else
        minLoc = minLoc + 1;
    end
end

Trough = find(SignDeriv(minLoc:end) == 1,1,'first') + minLoc;
% There could be 2 peaks, and we want the second. Check to see how far
% apart these are.
Dist = Guess - Trough;
ShouldBeLessThan = allowSep*Guess;
if Dist > ShouldBeLessThan*Guess
    Trough2 = find(SignDeriv(Trough + 1:end) == 1,1,'first') + minLoc;
    if Trough2 < Guess
        Trough = Trough2;
    end
end

firstCoord = floor(mean([Trough,Guess]));
endCoord = find(CumSum >= FracOfPixEnd*totPix,1,'first');

bght_thresh = [firstCoord,endCoord];

end

