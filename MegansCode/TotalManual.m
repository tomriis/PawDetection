function [ pawCenters ] = TotalManual( Images )

Paws = ['FR';'FL';'BL';'BR'];
numImages = size(Images,4);
pawCenters = zeros(4,2,numImages);
Threshes = 10:10:100;

for k = 1:4
    Counter = 1;
    k1 = 1;
    while k1 <= numImages
        disp(strcat(['Find the ',Paws(k,:),' Paw. If not visible, strike Enter']))
        disp(k1)
        imshow(Images(:,:,:,k1));
        %set(gcf, 'Position', [500, 700, 700, 500]);
        Center = ginput(1);
        if isempty(Center)
            Center = [0,0];
        end        
        pawCenters(k,1,k1) = Center(2);
        pawCenters(k,2,k1) = Center(1);
        if mean(Center >= 0) < 1
            k1 = k1 - 3;
        end
        k1 = k1 + 1;
    end
end

end
