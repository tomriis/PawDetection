function ManualOversight(Images, pawCenters,imNum)
    h = figure;
    h.UserData(end+1) = imNum;
    set(h,'KeyPressFcn',{@KeyPressCb, Images, pawCenters});
    
    %disp(num2str(pawPoints{1}(1)));
    disp(num2str(h.UserData));
end

function KeyPressCb(hObject,evnt,Images, pawCenters)
    fprintf('key pressed: %s\n',evnt.Key);
    if strcmp(evnt.Key,'rightarrow')==1
        s = evnt.Key;
        hObject.UserData(end+1) = hObject.UserData(end) + 1;
    elseif strcmp(evnt.Key, 'leftarrow')==1
        s = evnt.Key;
        hObject.UserData(end+1) = hObject.UserData(end) - 1;
    elseif strcmp(evnt.Key,'space')==1
        s = evnt.Key;    
    end
    disp(num2str(hObject.UserData(end)))
    pawPoints = ShowPawPlacement(Images, pawCenters, hObject.UserData(end));
end