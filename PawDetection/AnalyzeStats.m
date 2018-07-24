Data = [Data41;Data42;Data51;Data52;Data81;Data82];
Tic = 0.15;
x = [1-Tic,1+Tic,2-Tic,2+Tic,3-Tic,3+Tic];
FontSize = 18;
LFont = 13;

subplot(2,2,1)
bar(reshape(Data(:,1),2,3)')
linDat = Data(:,1)';
SDS = Data(:,2)';
hold on
errorbar(x,linDat,SDS,'+','MarkerEdgeColor',[0,0,0],'Color',[0,0,0],'LineWidth',2);
xlabel('Rat Number','FontSize',FontSize)
ylabel('Avg. Angle to Parallel','FontSize',FontSize)
title('Body Axis Angle','FontSize',FontSize)
h=legend('Pre-Injection','Post-Injection','Location','Southeast');
set(h,'FontSize',LFont);
text(.55,330,'Saline','FontSize',FontSize)
text(1.55,330,'PD','FontSize',FontSize)
text(2.55,330,'PD','FontSize',FontSize)

subplot(2,2,2)
bar(reshape(Data(:,3),2,3)')
linDat = Data(:,3);
SDS = Data(:,4);
hold on
errorbar(x,linDat,SDS,'+','MarkerEdgeColor',[0,0,0],'Color',[0,0,0],'LineWidth',2);
xlabel('Rat Number','FontSize',FontSize)
ylabel('cm/sec','FontSize',FontSize)
title('Average Speed While Running','FontSize',FontSize)
h=legend('Pre-Injection','Post-Injection','Location','Southeast');
set(h,'FontSize',LFont);
text(.55,16,'Saline','FontSize',FontSize)
text(1.55,16,'PD','FontSize',FontSize)
text(2.55,16,'PD','FontSize',FontSize)

subplot(2,2,4)
bar(reshape(Data(:,9),2,3)')
xlabel('Rat Number','FontSize',FontSize)
ylabel('Time(2 Paws/Wheel)','FontSize',FontSize)
title('Rearing/Sprinting Fraction','FontSize',FontSize)
h=legend('Pre-Injection','Post-Injection','Location','West');
set(h,'FontSize',LFont);
text(.55,.35,'Sal.','FontSize',FontSize)
text(1.55,.35,'PD','FontSize',FontSize)
text(2.55,.35,'PD','FontSize',FontSize)

x = 1:6;
Toc = .3;
subplot(2,2,3)
bar(x,reshape(Data(:,5:8),6,4));
hold off
xlabel('Rat Number','FontSize',FontSize)
ylabel('Time(Grounded paw/Wheel)','FontSize',FontSize)
title('Time with Each Paw on the Ground','FontSize',FontSize)
h=legend('FR','FL','BL','BR','Location','Southeast');
set(h,'FontSize',LFont);
text(1-Toc,.95,'Pre','FontSize',FontSize)
text(2-Toc,.95,'Sal.','FontSize',FontSize)
text(3-Toc,.95,'Pre','FontSize',FontSize)
text(4-Toc,.95,'PD','FontSize',FontSize)
text(5-Toc,.95,'Pre','FontSize',FontSize)
text(6-Toc,.95,'PD','FontSize',FontSize)