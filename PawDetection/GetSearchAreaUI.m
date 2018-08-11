function [Box] = GetSearchAreaUI(Image)
    h = figure;
    imshow(Image);
    rect = imrect(gca);
    disp('Press any key to continue');
    while true
        w = waitforbuttonpress;
        if w==1
            break;
        end
    end
    response = input('If satisfied press Y \nTo type in x1,y1 x2,y2 coordinates press any other key\n','s');
    if response == 'y' || response == 'Y'
        positions = zeros(1,4);
        position = rect.getPosition();
        positions(1) = position(1);
        positions(2) = position(2);
        positions(3) = position(1)+position(3);
        positions(4) = position(2)+position(4);
    else
        answer = inputdlg('Enter space-separated numbers: x1 y1 x2 y2',...
             'Sample', [1 50]);
        positions = str2num(answer{1});
    end
    Box(1,1)=positions(2);
    Box(1,2)=positions(4);
    Box(2,1)=positions(1);
    Box(2,2)=positions(3);
    close(h);
         
end