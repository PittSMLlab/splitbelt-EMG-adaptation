%From makeN19DPrettyAgain
saveDir='./';
name={'allChangesEMG.fig','allChangesEMG.fig','allChangesEMG_lateAdapBase.fig'};
desiredPlotDescription={'early','A[5]';'early','A[5]';'early','P[5]'};
plotTitles={{'OBSERVED';'{\Delta}EMG_{on (+)}'},{'PREDICTION (O2)';['{\Delta}EMG_{on (' char(8211) ')}']},{'OBSERVED';'{\Delta}EMG_{off (+)}^{long}'}};
saveName='Fig4Aalt';
lineFlag=0;
makeN19DPrettyAgain_execute

%%
allSS=findobj(gcf,'Type','Surface');
allSS(3).CData=-allSS(3).CData;
allSS(2).CData=allSS(2).CData([16:30,1:15],:);
allLL=findobj(gcf,'Type','Line','Marker','o');
for i=31:60
aux=get(allLL(i),'YData');
set(allLL(i),'YData',get(allLL(i+15),'YData'));
set(allLL(i+15),'YData',aux);
end
%delete(allLL)
for i=1:length(allSS)
    ss=allSS(i);
%ss.CData(16,:)=0;
tt=findobj(gcf,'Type','Text');
idx=strcmp(get(tt,'String'),'SLOW/PARETIC');
set(tt(idx),'String','SLOW/NON-DOM');
idx=strcmp(get(tt,'String'),'FAST/NON-PARETIC');
set(tt(idx),'String','FAST/DOMINANT');
end
%Colormap:
myFiguresColorMap
colormap(flipud(map))
Clim=.5;
caxis(Clim*[-1 1])
cc=findobj(gcf,'Type','Colorbar');
set(cc,'Ticks',[-.5 -.25 0 .25 .5],'FontSize',16,'FontWeight','bold');
set(cc,'TickLabels',{'-50%','-25%','No change','+25%','+50%'});
set(gcf,'Color',ones(1,3))
%%
fB=gcf;
resizeFigure(gcf,1/2)
threePanelArrange
ph=findobj(gcf,'Type','Axes');
set(ph, 'TickLength',[0 0],'Fontsize',8) %Invisible ticks
%%
%saveFig2(gcf,saveDir,saveName,0)