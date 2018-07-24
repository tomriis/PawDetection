function [ H ] = Histogram( I, n, mini, maxi )
% Outputs a histogram according to various input paramenters.
%   Given a 2D (or 3D--taking just the first page by default) array(image)
%   "I" containing integers or floats, an integer value "n" to determine
%   the number of bins, and the range encompassed by these bins between
%   "min" and "max," this function will output a 1D array "H" that gives
%   the number of instances that the image values take fall in the range of
%   each of the "n" bins. By default, the min and max arguments will be the
%   minimum and maximum values of the image.

% If 3 sheets exist, reduce to just the first sheet.
iSize = size(I);
if length(iSize) > 2
    I = I(:,:,1);
end
imshow(I)
figure
% If unspecified, the min and max values are set to the minimum and maximum
% pixel values of the image I, and n is set to 255.
if ~exist('mini','var')
    mini = double(min(min(I)));
end
if ~exist('maxi','var')
    maxi = double(max(max(I)));
end
if ~exist('n','var')
    n = 255;
end

DivVec = linspace(mini,maxi,n + 1); % Creates bin subdivisions
H = zeros(1,n); % Initialize output vector to zeros, preparatory for running sums.
for k = 1:iSize(1) % rows
    for a = 1:iSize(2) % columns
        if I(k,a) < mini % bounds checking for relevance
        elseif I(k,a) > maxi
        else
            for b = 1:n % number of bins
                if I(k,a) <= DivVec(b + 1)
                    H(b) = H(b) + 1;
                    break % run loop until a match is found, then stop.
                end
            end
        end
    end
end
bar(DivVec(2:end),H); % plot histogram.
ylabel('Number of instances','FontSize',14);
xlabel('Upper limit of each bin','FontSize',14);
num_bins = strcat(['Number of bins: ',num2str(n)]);
text(DivVec(round(n/2)),1.1*max(H),num_bins,'FontSize',14);
set(gca,'fontsize',12)


end

