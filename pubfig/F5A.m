%% Data
%%
saveDir='./';
saveName='Fig5A';
%%
fh=figure('Units','Normalized','OuterPosition',[0 .1 .53 .4]);
figuresColorMap
ph=axes();
set(ph,'ColorOrder',condColors([1,3],:))
data=[auxCosine(ePS-lS,-eA) auxCosine(ePS-lS,eAT) auxCosine(eP-lA,-eA) auxCosine(eP-lA,eAT)];
%mData=[auxCosine(mean(ePS-lS,2),mean(-eA,2)) auxCosine(mean(ePS-lS,2),mean(eAT,2)) auxCosine(mean(eP-lA,2),-mean(eA,2)) auxCosine(mean(eP-lA,2),mean(eAT,2))];
subjIdx=2:16;
for i=1:size(eP,2)
    aux=[-eA(subjIdx,i) eAT(subjIdx,i)]\(eP(subjIdx,i)-lA(subjIdx,i));
    Dsim(i)=diff(aux);
    auxS=[-eA(subjIdx,i) eAT(subjIdx,i)]\(ePS(subjIdx,i)-lS(subjIdx,i));
    DsimS(i)=diff(auxS);
    data(i,:)=[auxS; aux];
end
mData=[[-mean(eA(:,subjIdx),2) mean(eAT(:,subjIdx),2)]\[mean(ePS(:,subjIdx)-lS,2) mean(eP-lA,2) ]];
mData=mData(:);

hold on
bb=bar(reshape(mean(data,1),2,2),'EdgeColor','none');

errorbar(reshape(.15*[-1; 1]+[1 2],4,1),reshape(mean(data,1),4,1),reshape(std(data,1),4,1),'Color','k','LineWidth',2,'LineStyle','none')
set(ph,'ColorOrderIndex',1);
plot(.15*[-1 1]+[1; 2],reshape(mData,2,2),'o','LineWidth',2,'MarkerSize',10)
ph=gca;
title('Split-to-tied transitions')
set(ph,'Position',get(ph,'Position').*[1 1.3 .5 .85],'XTick',[1 2],'XTickLabel',{'Short exposure','Long exposure'},'FontSize',16);
ylabel('Regressors (\beta)')
pp=get(ph,'Position');
legend({'\beta_S','\beta_M'},'Location','bestoutside')
ph.Position=pp;
hold on
data1=reshape(data,16,2,2);
cc=get(ph,'ColorOrder');
%plot(.85+[0:1],data1(:,:,1)','Color',cc(1,:))
%plot(1.15+[0:1],data1(:,:,2)','Color',cc(2,:))

%%
saveFig(fh,saveDir,saveName,0)