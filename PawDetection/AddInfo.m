function [ pointArray ] = AddInfo( pointArray,Radius,Image,ImNum,numPoints )
%This function takes information from the FindClust function and massages
%it slightly in order to fit into the official pawCenters variable.

for k = 1:numPoints
    try
        Paw = GetObj(Image,pointArray(k,1:2,ImNum),Radius);
    catch e
        warning(strcat('Image',{' '},num2str(ImNum),{': '},string(e.identifier),{' --- '},string(e.message)));
    end
    PawBr = mean(Paw,3);
    PawStats = [mean2(PawBr),std2(PawBr)];
    pointArray(k,3:4,ImNum) = PawStats;
end


end

