function [ varargout ] = VideoAnalysis( Frames,varargin )
%This is the governing function for analyzing the rat videos. It needs to
%know either the directory containing the images from the Prosilica, or it
%may receive a pre-stacked collection of frames (which allows it to skip
%the loading process). It also needs to know which ones to analyze, and
%what colorization is important to the user. It returns the colorized image
%stack, as well as the unaltered image stack. Written by Robert Moesinger,
%University of Utah.
%
%   This function requires Frames, the directory containing the images
%   that need to analyzed. Alternatively, a pre-made stack of images may be
%   passed in this argument. Alter-alternatively, you can pass a structure
%   into this argument that contains some, none, or all of the optional
%   fields below; as long is it contains a field named 'Frames,' then the
%   program will run. This structure is useful, because it is the output,
%   but also works as the input to the function if you want it to, in order
%   to pick up where you left off, for instance. I recommend using the
%   structure syntax.
%
%   Following this mandatory variable, the program will look for several
%   possible inputs: numAn, colorChan, ledCenters, pawCenters, and
%   earlyQuit. Pass the variable name preceding the argument to alert the
%   program what information is being presented.
%
%   numAn is the number of images the function will analyze. If
%   passed as a scalar, the function will look at the first num_analyze
%   images. If as a vector, the function will start at num_analyze(1) and
%   go to num_analyze(2). If the num_analyze input is ignored, all will be
%   analyzed.
%
%   colorChan lets you determine what colors the paws and LEDs will be
%   highlighted for visualizing afterwards with Browse.m. colorChan may be
%   passed as a 1 x 2 vector. Each element corresponds to a color channel:
%   0-3. If 0 is passed, the images will not be colorized. If any other
%   number is passed, the LEDs and paws, respectively, will be highlighted
%   in that color channel. If this argument is ignored, no colorization
%   will happen.
%
%   ledCenters and pawCenters allows the program to skip certain aspects of
%   the analysis, if the video has already been analyzed and you wish to
%   prevent it from re-acquiring the same information. To reset and force
%   a full analysis, send a scalar to either one of these values.
%
%   earlyQuit allows the user to exit the function early. Specifically,
%   there is an exit point after the LEDs have been localized. If
%   exercised, this option allows the user to acquire LED position values
%   without having to wait for the paws to be found also. To engage, pass a
%   1 through this variable. If you desire to exit after the paws are
%   found, but before any analysis is performed, pass a 2 through this
%   variable.
%
%   'Output' lets the user explicitly determine the output of the function.
%   By default, it is a structure with several fields--passing the argument
%   'struct' will also engage this default action. Alternatively, you can
%   receive the output in several variables which would be the fields of
%   the default structure output.
%
%   The output of this function can take two forms as described above.
%   Regardless, the fields or variables are, in order:  Images: the
%   modified (colored) version of the movie that was passed in; Frames: the
%   unmodified movie; ledCenters: the array of the coordinates of the LEDs
%   in every frame; pawCenters: the array of the coordinates of the paws in
%   every frame.

% First we parse the optional inputs.
if ~mod(nargin,2)
    error('You must pass variables as name-value pairs');
end
if isstruct(Frames)
    Struct = 1;
    Fields = fieldnames(Frames);
    numArgs = size(Fields,1);
else
    Struct = 0;
end
numPairs = (nargin-1)/2;
if Struct
    Bound = numArgs;
else
    Bound = numPairs;
end
for k = 1:Bound
    if Struct
        varName = char(Fields(k,:));
        varVal = Frames.(varName);
    else
        varName = cell2mat(varargin(2*k-1));
        varVal = cell2mat(varargin(2*k));
    end
    switch varName
        case 'colorChan'
            colorChan = varVal;
        case 'numAn'
            numAn = varVal;
        case 'ledCenters'
            ledCenters = varVal;
        case 'pawCenters'
            pawCenters = varVal;
        case 'earlyQuit'
            earlyQuit = varVal;
        case 'Output'
            Output = varVal;
        case 'Params'
            Params = varVal;
    end
end
    
if Struct
    % This will destroy the input, but it's already been parsed so that's
    % okay.
    Frames = Frames.Frames;
end
if ~exist('colorChan','var')
    colorChan = [0,0];
end
if ~exist('numAn','var')
    % This is just an indicator so Matlab doesn't complain about too few
    % variables. This means that all will be analyzed.
    numAn = [0,0];
elseif length(numAn) == 1
    numAn = [1,numAn];
end
if ~exist('earlyQuit','var')
    earlyQuit = 0;
end    
if ~exist('Output','var')
    Output = 'struct';
end
if ~exist('Params','var')
    Params = 0;
end

% The user has the option of inputting a directory of the images, or a
% pre-made stack of images. We find out what it is and react accordingly. 
if length(size(Frames)) < 3
    % This means it's two-dimensional: clearly a directory. (1 row, many
    % columns--a color stack would have four dimensions
    [Frames] = LoadVideo(Frames,numAn);
end
Images = Frames;
Size = size(Images);
numIn = Size(end);
% Now, if [0,0] was passed for the analysis, we have to let the
% ImageTracking function know that we actually want all the frames in the
% movie to be analyzed.
if ~sum(numAn)
    numAn = [1,numIn];
end
if ~exist('ledCenters','var') || length(ledCenters) == 1
    ledCenters = zeros(2,4,numIn);
end
if ~exist('pawCenters','var')|| length(pawCenters) == 1
    pawCenters = zeros(4,13,numIn);
end

% Now we're ready for the fun to begin. We find the objects of interest.
% The Params variable is for use in picking up the code where it left off
% without redoing the cRatios and bght_thresh calculations.
[Images,pawCenters,ledCenters,Params] = ImageTracking(Images,numAn, ...
    colorChan,ledCenters,pawCenters,earlyQuit,Params);
if length(Output) == 6 % Struct
    S.Frames = Frames;
    S.Images = Images;
    S.ledCenters = ledCenters;
    S.pawCenters = pawCenters;
    S.numAn = numAn;
    S.earlyQuit = earlyQuit;
    S.Params = Params;
    varargout{1} = S;
else
    varargout{1} = Frames;
    varargout{2} = Images;
    varargout{3} = ledCenters;
    varargout{4} = pawCenters;
end
if earlyQuit
    return
end

pawCenters = ManualPlace(Images,pawCenters,numAn);
FauxPCs = InterpolatePaws(pawCenters);
save('R08170817_1_1000','ledCenters','pawCenters','FauxPCs');

InnerCylinderDiam = 53.80; % cm
ledDiam = 0.55; % cm
ArcLength = 36.6; % cm

[CylVel,RatVel,CentersOfMass] = AnalyzeCens(InnerCylinderDiam,...
    ledDiam,ArcLength,FauxPCs,ledCenters,numAn);





end

