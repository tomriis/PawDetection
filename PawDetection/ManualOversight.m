function ManualOversight(Images, pawCenters,imNum)
    h = figure;
    h.UserData = imNum;
    set(h,'KeyPressFcn',{@KeyPressCb, Images, pawCenters, imNum});
    
    %disp(num2str(pawPoints{1}(1)));
    disp(num2str(h.UserData));
end

function imNum = KeyPressCb(src,evnt,Images, pawCenters, imNum)
    fprintf('key pressed: %s\n',evnt.Key);
    h.UserData = imNum;
    if strcmp(evnt.Key,'rightarrow')==1
        s = evnt.Key;
        h.UserData = h.UserData + 1;
    elseif strcmp(evnt.Key, 'leftarrow')==1
        s = evnt.Key;
        imNum = imNum + 1;
    elseif strcmp(evnt.Key,'space')==1
        s = evnt.Key;    
    end
    disp(num2str(h.UserData))
    pawPoints = ShowPawPlacement(Images, pawCenters, h.UserData);
end