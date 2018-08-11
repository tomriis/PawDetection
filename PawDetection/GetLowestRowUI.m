function [lowestRow] = GetLowestRowUI(Images, default)
lowestRow = default;
disp('Press any key to select the lowest row');
imSize = size(Images);
h = figure;
imshow(Images(:,:,:,1));
line = imline(gca, [-100, default; imSize(2)+100,default]);
id = addNewPositionCallback(line,@(pos) title(mat2str(pos(1,2),3)));
title(num2str(default,3));
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