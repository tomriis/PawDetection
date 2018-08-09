function [h]=ManualOversight(Images, pawCenters,imNum)
    h = figure;
    h.UserData(1) = imNum;
    set(h,'KeyPressFcn',{@KeyPressCb, Images, pawCenters});
    pawPoints = ShowPawPlacement(Images, pawCenters, imNum);
end

function KeyPressCb(hObject,evnt,Images, pawCenters)
    %fprintf('key pressed: %s\n',evnt.Key);
    if strcmp(evnt.Key,'rightarrow')==1
        hObject.UserData(1) = hObject.UserData(1) + 1;
    elseif strcmp(evnt.Key, 'leftarrow')==1
        hObject.UserData(1) = hObject.UserData(1) - 1;
    elseif strcmp(evnt.Key,'space')==1
        disp('space hit')
    end
    
    if hObject.UserData(1) < 1 || hObject.UserData(1) > size(Images,4)
        disp('End of Images')
    else
        disp(strcat('Viewing image--',num2str(hObject.UserData(1))))
        pawPoints = ShowPawPlacement(Images, pawCenters, hObject.UserData(1));
    end
end