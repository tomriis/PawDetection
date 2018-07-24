function [ Dists ] = reduceRange( Dists )
%Takes the log2 of the input distance array, shifts negative values to
%zero, then weights them column-wise.
%   Detailed explanation goes here
numEnts = size(Dists,1);

Ranges = range(Dists);
if mean(Ranges) > 100
    Logged = log2(Dists);
    Smalls = min(Logged);
    findNegs = Smalls < 0;
    Smalls(~findNegs) = 0;
    Subs = repmat(Smalls,numEnts,1);
    Dists = Logged - Subs;
end
    


end

