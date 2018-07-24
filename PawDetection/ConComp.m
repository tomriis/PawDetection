function [ Image,IDpix,numGroups ] = ConComp( Image,IDpix,Adjacent,ElimIf,ImWanted )
%This function finds connected components in an image, processing the image
%column by column from left to right. The weakness inherent in this
%approach is that a left-facing U shape will be perceived as 2 groups until
%the pixels meet up. Therefore, this function is meant to be run twice to
%get a clean CC routine.
%   This function requires the Image, the list of pixels to run through, a
%   definition of adjacency, and a threshold below which to not consider
%   unconnected pixels a group. HitPix contains, columnwise: indices, rows,
%   columns, labels.

hitInds = IDpix(:,1);
hitRow = IDpix(:,2);
hitCol = IDpix(:,3);

columnOfInt = hitCol(1);
beginSearch = 1;
currentLabel = 2;
while columnOfInt
    % First, we find out what the next column is that contains the next
    % hit by searching throgh the hitRow vector.
    NfirstCol = find(hitCol(beginSearch:end) > columnOfInt,1,'first')-1;
    nextColInd = beginSearch + NfirstCol;
    % First filtering occurs by eliminating this "column" if it contains
    % very few pixels.
    if NfirstCol < ElimIf
        Image(hitInds(beginSearch:nextColInd-1)) = 0;
    else
        rowsHitInCol = hitRow(beginSearch:nextColInd-1);
        Dist = diff(rowsHitInCol);
        Gaps = [0;find(Dist > Adjacent);length(Dist)+1];
        for k = 1:length(Gaps)-1
            % We're looking for the indices of hitCol/hitRow/hitInds that
            % correspond to these consecutive bright pixels. This group
            % will be considered as a unit, looking at their leftward
            % neighbors.
            firstPixInd = beginSearch + Gaps(k);
            lastPixInd = beginSearch + Gaps(k+1)-1;
            RowStart = hitRow(firstPixInd);
            RowEnd = hitRow(lastPixInd);
            % First, make sure that this isn't the first column. If so,
            % just label them with a one. Then, don't label if very small.
            if columnOfInt > 1
                if lastPixInd - firstPixInd > ElimIf
                    if columnOfInt <= Adjacent
                        GoBack = columnOfInt-1;
                    else
                        GoBack = Adjacent;
                    end
                    if RowStart <= Adjacent
                        GoUp = RowStart - 1;
                    else
                        GoUp = Adjacent;
                    end
                    if RowEnd >= size(Image,1) - Adjacent
                        GoDown = size(Image,1) - RowEnd - 1;
                    else
                        GoDown = Adjacent;
                    end
                    prevLabels = Image(RowStart-GoUp:RowEnd+GoDown,...
                        columnOfInt - GoBack:columnOfInt-1);
                    checkBlank = mean2(prevLabels);
                    if checkBlank == 0
                        useLabel = currentLabel;
                        currentLabel = currentLabel + 1;
                    else
                        useLabel = min(min(prevLabels(prevLabels > 0)));
                    end                    
                else
                    useLabel = 0;
                end
            else
                useLabel = currentLabel;
                currentLabel = currentLabel + 1;
            end
            IDpix(firstPixInd:lastPixInd,4) = useLabel;
            Image(RowStart:RowEnd,columnOfInt) = useLabel;
        end        
    end
    % Now, we advance to the next column of interest.
    beginSearch = nextColInd;
    columnOfInt = hitCol(beginSearch);
end

numGroups = currentLabel - 1;

if ImWanted
else
    Image = 0;
end


end

