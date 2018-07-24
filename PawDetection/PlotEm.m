function [  ] = PlotEm( thesePaws,theseLeds,thisAngle,Text )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

paws = sum(sum(thesePaws));
leds = sum(sum(theseLeds));
angle = sum(thisAngle);

if paws
    for k = 1:size(thesePaws,1)
        hold on
        text(thesePaws(k,2),thesePaws(k,1),Text(k,:),'Color',[1,1,1]);
        plot(thesePaws(k,2),thesePaws(k,1),'r.','MarkerSize',12)
    end
end
if leds
    Str = ['*b';'*g'];
    for k = 1:size(theseLeds,1)
        hold on
        plot(theseLeds(k,2),theseLeds(k,1),Str(k,:))
    end
end
if angle
    hold on
    text(-10,-10,strcat(['Angle = ',num2str(thisAngle)]));
end


end

