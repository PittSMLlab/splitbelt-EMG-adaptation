%% Data
loadIndivActivity
%%
saveDir='./';
saveName='Fig4SD';
%%
fh=figure('Units','Normalized','OuterPosition',[0 .1 .53 .4]);

e2=eP-lA;
%e2=ePS-lS;
e1=eAT;
%e1=-eA;
data=[auxCosine(e2(1:180,:),e1([1:180],:)) auxCosine(e2(180+[1:180],:),e1(180+[1:180],:))];
bar(mean(data,1))
ph=gca;
title('(eP-lA) vs. eA^T per leg')
set(ph,'Position',get(ph,'Position').*[0 1.3 .4 .85]+[.65 0 0 0],'XTick',[1 2],'XTickLabel',{'Fst/FeelsSlw','Slw/FeelsFst'},'FontSize',16);
ylabel('Similarity (cos)')
pp=get(ph,'Position');
axis([.5 2.5 0 1])
ph.Position=pp;
hold on
cc=get(ph,'ColorOrder');
errorbar([1 1.5 2],[mean(data(:,1)) NaN mean(data(:,2))],[std(data(:,1)) NaN std(data(:,2))],'LineWidth',3,'Color','k')

%%
saveFig(fh,saveDir,saveName,0)