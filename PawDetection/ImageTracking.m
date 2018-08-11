function [ Images,pawCenters,ledCenters,Params ] = ImageTracking( Images,numAn,colorChan,ledCenters,pawCenters,earlyQuit,Params )
%FTIR Paw Image Analysis, Robert Moesinger
%   After providing the directory of the many bitmaps that you would like
%   analyzed (presuming that the titles of the images are related to the
%   date and time during which they were taken, like the Prosilica), the
%   program will compile the images into a z-stack and move through them
%   sequentially. It will find the LED(s) in the image and highlight the
%   center with white, find and black out the seam of the Plexiglas, and
%   locate up to four paws and highlight them in red. It will return the
%   modified z-stack. Eventually, analysis will be performed on the images.
%
%   This function requires framesDir, the directory containing the images
%   that need to analyzed. Alternatively, a pre-made stack of images may be
%   passed in this argument.
%
%   Following this mandatory variable, the program will look for several
%   possible inputs: numAn, colorChan, ledCenters, pawCenters, and
%   earlyQuit. Because this function is being driven by VideoAnalysis, it
%   expects to receive all of these arguments.
%
%   num_analyze is the number of images the function will analyze. If
%   passed as a scalar, the function will look at the first num_analyze
%   images. If as a vector, the function will start at num_analyze(1) and
%   go to num_analyze(2). If the num_analyze input is ignored, all will be
%   analyzed.
%
%   colorChan may be passed as a 1 x 2 vector. Each element corresponds to
%   a color channel: 0-3. If 0 is passed, the images will not be colorized.
%   If any other number is passed, the LEDs and paws will be highlighted in
%   that color channel. If this is ignored, no colorization will happen.
%
%   ledCenters and pawCenters allows the program to skip certain aspects of
%   the analysis, if the video has already been analyzed and you wish to
%   prevent it from re-acquiring the same information.
%
%   earlyQuit allows the user to exit the function early. Specifically,
%   there is an exit point after the LEDs have been localized. If
%   exercised, this option allows the user to acquire LED position values
%   without having to wait for the paws to be found also. To engage, pass a
%   non-zero value through this variable.

% See AddLeds and AddPaws for more details on these constants
AlwaysAsk = 0;
pawRadius = 15;
ledRadius = 8;
resetCol = 1;
nextGoal = 10;
numIn = numAn(2) - numAn(1) + 1;
bestMean = 0;
Counter = 0;
resetThresh = 0.5;
ledsDone = find(sum(sum(ledCenters)),1,'last');
numIts = 1;
Disaster = 0;
if(isempty(ledsDone))
    ledsDone = 0;
end
pawsDone = find(sum(sum(pawCenters)),1,'last');
% Now, if some of the paws have already been analyzed that means that the
% code which places the paws into the uncut images' frame has already been
% run. This isn't good, since the paw localization code will run with the
% cut images and rely on the most recent location to make some important
% guesses. So, we'll insert a flag and modify the previous row
% appropriately during the first runthrough.
if(isempty(pawsDone))
    pawsDone = 0;
    alreadyOffset = 0;
    Initialize = 0;
elseif pawsDone > 0
    alreadyOffset = 1;
    resetCol = 0;
    Initialize = 1;
    % This means that we're picking up where we left off. We assume that we
    % want to start with the brightness and color thresholds that we left
    % off with last time.
    if length(Params) > 1
        bght_thresh = Params{1};
        cRatios = Params{2};
    end
end

if Params{3}
    linDisp = ones(1,numIn);
    lowestRow = GetLowestRowUI(Images, 100);
    if length(Params)<4
        Params{4} = 0;
    end
else
    % This is the whole LED section. The paws finding algorithm needs to know
    % this information to search more accurately.
    if ledsDone < numIn
        for k = ledsDone + 1:numIn
            if 100*k/numIn >= nextGoal
                disp(strcat(['LEDs are ',num2str(nextGoal),'% Processed']));
                nextGoal = nextGoal + 10;
            end
            [Images(:,:,:,k),theseLeds] = FindLeds(Images(:,:,:,k), ...
            ledRadius,colorChan(1));
            ledCenters = AddLeds(k,ledCenters,theseLeds,ledRadius,Images(:,:,:,k));
        end
    end
    if earlyQuit == 1
        return
    end
    linDisp = ledAnalyze(ledCenters);
    lowestRow = max(max(ledCenters(:,1)));
end
% We assume that the LEDs found the same low row for our purposes
if alreadyOffset
    Zeros = pawCenters(:,1,pawsDone) == 0;
    pawCenters(:,1,pawsDone) = pawCenters(:,1,pawsDone) - lowestRow;
    pawCenters(Zeros,1,pawsDone) = 0;
end

nextGoal = 10 * (round(10*pawsDone/numIn) + 1);
% Now the paws.
if pawsDone < numIn
    k = pawsDone + 1;
    % We use a while loop so we can redo incorrect iterations.
    while k <= numIn
        Image = Images(lowestRow:end,:,:,k);
        % This just measures the progress and updates the user.
        if 100*k/numIn >= nextGoal
            disp(strcat(['Paws are ',num2str(nextGoal),'% Processed']));
            nextGoal = nextGoal + 10;
        end
        % This simple 'if' clause is used to find the most likely candidates
        % for paws in this image.
        if resetCol == 1
            [Images(lowestRow:end,:,:,k),pawCenters,cRatios,bght_thresh,meanMax, Params] = ...
                FindPaw(Image,pawRadius,colorChan(2),resetCol,k,pawCenters,linDisp, Params);
            if Params{3}
                Initialize = 1; 
            else
                if ~Initialize
                    numPawsFound = sum(pawCenters(:,1,k) > 0);
                    if numPawsFound == 4
                        Initialize = 1;
                    else
                        pawCenters(:,:,k) = 0;
                        resetCol = 0;
                    end
                end
            end
        else
            disp(strcat(['On ','image ', num2str(k)]))
            [Images(lowestRow:end,:,:,k),pawCenters,cRatios,bght_thresh,meanMax, Params] = ...
                FindPaw(Image,pawRadius,colorChan(2), ...
                resetCol,k,pawCenters,linDisp,Params);
            if ~Initialize
                numPawsFound = sum(pawCenters(:,1,k) > 0);
                if numPawsFound == 4
                    Initialize = 1;
                else
                    pawCenters(:,:,k) = 0;
                end
            end
        end
        % We only run this part of the code if there is a previous frame
        % from which to draw information. Otherwise, we'll just keep
        % advancing through the frames until all four paws are finally
        % down.
        if Initialize
            if Params{3}
                if resetCol == 1
                %needed to redo paw selection with smaller window after it finds Color ratios
                %and bght_thresh
                disp('here in redo')
                pawCenters(:,:,k) = 0;
                    [Images(lowestRow:end,:,:,k),pawCenters,cRatios,bght_thresh,meanMax, Params] = ...
                FindPaw(Image,pawRadius,colorChan(2),0,k,pawCenters,linDisp,Params);
                end
                resetCol = 0;
            else
                % Now we have to identify which paws are which. We have a good hint
                % already if the paw showed up in the place that we would expect it to
                % be if it were stationary.
                [pawCenters,resetCol,Disaster] = AddPaws(k,pawCenters,pawRadius,Image,resetCol);
                % The rest of the code is meant to catch errors and inform the next
                % iteration that it needs to try again with the same image.
                [resetCol,Disaster,pawCenters] = AssessValidity(pawCenters,k,resetCol,Disaster);
                AskAbout = pawCenters(:,12,k);
                if sum(AskAbout > 0)
                    offset = [lowestRow,0];
                    pawCenters = ManualPlace(Images,pawCenters,k,offset);
                end
                if Disaster
                    disp('Disaster Invoked')
                    k = k - 1;
                    resetCol = 1;
                    numIts = numIts + 1;
                    if numIts > 5
                        resetCol = 0;
                        k = k + 1;
                        numIts=1;
                    end
                end
                if Counter == 0
                    bestMean = [median(meanMax),max(meanMax)];
                    Counter = 1;
                end
                if median(meanMax) < resetThresh*bestMean(1) && max(meanMax) < 0.9*bestMean(2)
                    resetCol = 0;
                    Counter = 0;
                end
                if ~Disaster && ~resetCol
                    numIts = 1;
                end            
           
                if AlwaysAsk
                    pawCenters = AskUser(Image,pawCenters,k);
                end
            end
        end
        k = k + 1;
    end
end
Zeros = pawCenters(:,:,:) == 0;
if alreadyOffset
    % This means that we had to take away the offset in the last frame in
    % order to seed our functions. Thus we will reapply it.
    Mod = -1;
else
    Mod = 0;
end
pawCenters(:,1,pawsDone + numAn(1) + Mod:numAn(2)) = pawCenters(:,1,pawsDone + numAn(1) + Mod:numAn(2)) + lowestRow;
pawCenters(Zeros) = 0;
pawCenters = matchPawsRelative(pawCenters);
disaster_idx = [];
for i = 1:numIn
    try
        [pawCenters,resetCol,Disaster] = AddPaws(i,pawCenters,pawRadius,Image,resetCol);
        [resetCol,Disaster,pawCenters] = AssessValidity(pawCenters,i,resetCol,Disaster);
        if Disaster || mean2(pawCenters(:,1:2,i))==0
            disaster_idx(end+1) = i;
        end
     catch e
        warning(strcat('Image',{' '},num2str(i),{': '},string(e.identifier),{' -- '},string(e.message)));
        disaster_idx(end+1) = i;
    end
end
disp('________________________________')
disp('Found issues with images:');
disp(disaster_idx);
disp('________________________________')

%clc
disp('Files are 100% Processed');

clear Params;
Params{1} = bght_thresh;
Params{2} = cRatios;

end
