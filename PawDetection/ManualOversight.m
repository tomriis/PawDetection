function ManualOversight(Images, pawCenters,imNum)
    h = figure;
    h.UserData(end+1) = imNum;
    set(h,'KeyPressFcn',{@KeyPressCb, Images, pawCenters});
    pawPoints = ShowPawPlacement(Images, pawCenters, imNum);
end

function KeyPressCb(hObject,evnt,Images, pawCenters)
    %fprintf('key pressed: %s\n',evnt.Key);
    if strcmp(evnt.Key,'rightarrow')==1
        hObject.UserData(end+1) = hObject.UserData(end) + 1;
    elseif strcmp(evnt.Key, 'leftarrow')==1
        hObject.UserData(end+1) = hObject.UserData(end) - 1;
    elseif strcmp(evnt.Key,'space')==1
 
    end
    disp(strcat('Viewing image--',num2str(hObject.UserData(end))))
    pawPoints = ShowPawPlacement(Images, pawCenters, hObject.UserData(end));
end