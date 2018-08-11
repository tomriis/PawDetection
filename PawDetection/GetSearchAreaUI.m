function [Box] = GetSearchAreaUI(Image, varargin)
    h = figure;
    imshow(Image);
    disp('Create search area and press any key to continue');
    if nargin
        rect = imrect(gca, varargin{1});
    else
        rect = imrect(gca);
    end
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
             'Get Search Area', [1 50]);
        positions = str2double(answer{1});
    end
    Box(1,1)=ceil(positions(2));
    Box(1,2)=ceil(positions(4));
    Box(2,1)=ceil(positions(1));
    Box(2,2)=ceil(positions(3));
    Box = constrain2ImgDim(Box, Image);
    close(h);
end

function [box] = constrain2ImgDim(box, Image)
    imgSize = size(Image);
    if box(1,1) < 1
        box(1,1)=1;
    end
    if box(1,2) > imgSize(1)
        box(1,2) = imgSize(1);
    end
    if box(2,1) < 1
        box(2,1) = 1;
    end
    if box(2,2) > imgSize(2)
        box(2,2) = imgSize(2);
    end
end
