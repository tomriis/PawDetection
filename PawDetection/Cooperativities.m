fourb4 = [91,154;97,125];
fouraft = [107,157;90,127];
fiveb4 = [54,87;81,130];
fiveaft = [75,125;89,138;74,139];
eightb4 = [60,130;59,128];
eightaft = [56,178;40,132];

b4s = [mean(fourb4(:,1)./fourb4(:,2));
    mean(fiveb4(:,1)./fiveb4(:,2));
    mean(eightb4(:,1)./eightb4(:,2))];
afts = [mean(fouraft(:,1)./fouraft(:,2));
    mean(fiveaft(:,1)./fiveaft(:,2));
    mean(eightaft(:,1)./eightaft(:,2))];

b4s2 = [std(fourb4(:,1)./fourb4(:,2));
    std(fiveb4(:,1)./fiveb4(:,2));
    std(eightb4(:,1)./eightb4(:,2))];
afts2 = [std(fouraft(:,1)./fouraft(:,2));
    std(fiveaft(:,1)./fiveaft(:,2));
    std(eightaft(:,1)./eightaft(:,2))];

fours = [b4s(1),afts(1);b4s2(1),afts2(1)];
fives = [b4s(2),afts(2);b4s2(2),afts2(2)];
eights = [b4s(3),afts(3);b4s2(3),afts2(3)];

data = [fours(1),fives(1),eights(1);fours(3),fives(3),eights(3)]';
SDS = [fours(2,:),fives(2,:),eights(2,:)];
Tic = 0.15;
x = [1-Tic,1+Tic,2-Tic,2+Tic,3-Tic,3+Tic];
linDat = reshape(data',1,6);
FontSize = 24;

bar(data)
hold on
h=errorbar(x,linDat,SDS,'+','MarkerEdgeColor',[0,0,0],'Color',[0,0,0],'LineWidth',2);
xlabel('Rat Number','FontSize',FontSize)
ylabel('(Time Spent Running)/(Time In Wheel)','FontSize',FontSize)
title('Cooperativity','FontSize',FontSize)
h=legend('Before Injection','After Injection','Location','Southeast');
set(h,'FontSize',FontSize);
text(.55,.85,'Saline Control','FontSize',FontSize)
text(1.55,.85,'Hemiparkinsonian','FontSize',FontSize)
text(2.55,.85,'Hemiparkinsonian','FontSize',FontSize)