function ShowPawPlacement(Images, pawCenters, imNum)
    pawPoints = cell(1,4);
    pawLabel={'FL','FR','BL','BR'};
    
    h = figure; 
    set(h,'KeyPressFcn',@KeyPressCb);
    imshow(Images(:,:,:,imNum)); hold on;
    
    for i = 1:4
        pawPoints{i}=impoint(gca,pawCenters(i,2,imNum),pawCenters(i,1,imNum));
        setString(pawPoints{i},pawLabel{i});
    end
    %plot(pawCenters(:,2, imNum),pawCenters(:,1,imNum), 'r+', 'MarkerSize', 10, 'LineWidth', 1);
    
    disp('exited')
end
function y = KeyPressCb(~,evnt)
        fprintf('key pressed: %s\n',evnt.Key);
        
        if strcmp(evnt.Key,'rightarrow')==1
        s = evnt.Key;
        elseif strcmp(evnt.Key, 'leftarrow')==1
        s = evnt.Key;
        elseif strcmp(evnt.Key,'space')==1
        s = evnt.Key;    
        end
end