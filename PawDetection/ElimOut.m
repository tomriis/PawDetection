function [ Rows,Cols ] = ElimOut( Size,Rows,Cols,Substitute )
%This function just checks to see if there are entries in a matrix that are
%outside the boundaries of an image described by Size. If so, those entries
%are removed. Alternatively, if an argument is passed to Substitute, it
%will just give those entries that value.
%   Always returns the vectors in the same orientation as given.

if ~exist('Substitute','var')
    Flag = 0;
else
    if Substitute < 1 || Substitute > min(Size)
        error('Substitute value is outside of given boundaries');
    end
    Flag = 1;
end
if size(Size,1) == 1
    Size = [1,Size(1);1,Size(2)];
end
Sizes = [size(Rows);size(Cols)];
if mean(Sizes(1,:) == Sizes(2,:)) < 1
    error('Not equally sized');
end

% FlipBack = 0;
% if Sizes(1,2) > Sizes(1,1)
%     Rows = Rows';
%     Cols = Cols';
%     FlipBack = 1;
% end

Test = Thresh2Bin(Rows,1,[Size(1,1),Size(1,2)]);
Test(:,:,2) = Thresh2Bin(Cols,1,[Size(2,1),Size(2,2)]);
sum_test = sum(Test,3);
Elims = sum_test < 2;
if Flag
    Rows(Elims) = Substitute;
    Cols(Elims) = Substitute;
else
    % We want to eliminate as little information as possible. Therefore, we
    % operate on the larger dimension, removing few entries.
    if Sizes(1,1) >= Sizes(1,2)
        rowSums = sum(Elims,2);
        elimRows = logical(rowSums);
        Rows(elimRows,:) = [];
        Cols(elimRows,:) = [];
    else
        colSums = sum(Elims,1);
        elimCols = logical(colSums);        
        Rows(:,elimCols) = [];        
        Cols(:,elimCols) = [];
    end
end

% 
% for k = 1:numIts
%     Test = Thresh2Bin(Rows(:,k),1,[Size(1,1),Size(1,2)]);
%     Test(:,2) = Thresh2Bin(Cols(:,k),1,[Size(2,1),Size(2,2)]);
%     sum_test = sum(Test,2);
%     Elims = sum_test < 2;
%     if Flag
%         Rows(Elims,k) = Substitute;
%         Cols(Elims,k) = Substitute;
%     else
%         Rows(Elims,:) = [];
%         Cols(Elims,:) = [];
%     end
% end

% if FlipBack
%     Rows = Rows';
%     Cols = Cols';
% end

end

