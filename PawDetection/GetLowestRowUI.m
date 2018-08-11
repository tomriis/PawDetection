function [lowestRow] = GetLowestRowUI(Images, default)
lowestRow = default;
disp('Press any key to select the lowest row');
imSize = size(Images);
h = figure;
imshow(Images(:,:,:,1));
line = imline(gca, [-100, default; imSize(2)+100,default]);
while true
    w = waitforbuttonpress;
    if w==1
        break;
    end
end
position = line.getPosition();
lowestRow = position(1,2);

close(h);
end