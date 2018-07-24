function [ pawCenters ] = ManualPlace( Images,pawCenters,ImNum,offset )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

if ~exist('ImNum','var')
    ImNum = 1;
end
if ~exist('offset','var')
    offset = [0,0];
end
offset(offset == 0) = 1;

Paws = ['FR';'FL';'BL';'BR'];
% The code will first audibly alert the user that something is amiss.
x = 1:100;
x1 = 1:250;
for k = 1:3
    pause(.1);
    sound(cos(x),1350)
end
pause(.1)
sound(cos(x1),1950);
disp('I require assistance in placing these paws.')

% Now let's display the image and plot the points in question.
imshow(Images(1+offset(1):end,1+offset(2):end,:,ImNum))
AskUser = pawCenters(:,12,ImNum);
AskInds = logical(AskUser);
thesePaws = pawCenters(AskInds,1:2,ImNum);
PlotEm(thesePaws,0,0,'?');

disp('What is the highlighted paw?')
disp('Use the following index to identify it.')
disp('FR    FL    BL    BR    Nothing')
RowNum = input('1     2     3     4     5\n');

pawCenters(RowNum,1:2,ImNum) = thesePaws;

% for k = 1:4
%     Counter = 1;
%     k1 = 1;
%     while k1 <= toAna
%         disp(strcat(['Find the ',Paws(k,:),' Paw. If not visible, strike Enter']))
%         imshow(Images(:,:,:,k1));
%         Center = ginput(1);
%         if isempty(Center)
%             Center = [0,0];
%         end        
%         pawCenters(k,1,k1) = Center(2);
%         pawCenters(k,2,k1) = Center(1);
%         if mean(Center >= 0) < 1
%             k1 = k1 - 3;
%         end
%         if k1 >= Threshes(Counter)
%             if Counter == 10
%                 
%                 pause(2);
%             end
%             disp(strcat(num2str(Percent(Counter)),'% Complete.'));
%             Counter = Counter+1;
%         end
%         k1 = k1 + 1;
%     end
% end

end

