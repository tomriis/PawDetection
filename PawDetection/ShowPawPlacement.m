function ShowPawPlacement(Images, pawCenters, imNum)
    figure;
    imshow(Images(:,:,:,imNum)); hold on;
    plot(pawCenters(:,2, imNum),pawCenters(:,1,imNum), 'r+', 'MarkerSize', 10, 'LineWidth', 1);
    disp('exited')
end
