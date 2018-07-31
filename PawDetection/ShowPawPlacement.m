function [pawPoints]=ShowPawPlacement(Images, pawCenters, imNum)
    pawPoints = cell(1,4);
    pawLabel={'FL','FR','BL','BR'};

    imshow(Images(:,:,:,imNum)); hold on;
    
    for i = 1:4
        pawPoints{i}=impoint(gca,pawCenters(i,2,imNum),pawCenters(i,1,imNum));
        setString(pawPoints{i},pawLabel{i});
    end
    
end
