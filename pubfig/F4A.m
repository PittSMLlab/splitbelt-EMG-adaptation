%From makeN19DPrettyAgain
saveDir='./';
name={'allChangesEMG.fig','allChangesEMG.fig','allChangesEMG_lateAdapBase.fig'};
desiredPlotDescription={'early','A[5]';'early','A[5]';'early','P[5]'};
plotTitles={'-\Delta EMG_{\uparrow on}','\Delta EMG_{\downarrow on}','    \Delta EMG_{\uparrow off}^{long}'};
saveName='Fig4A';
lineFlag=0;
makeN19DPrettyAgain_execute

%%
allSS=findobj(gcf,'Type','Surface');
allSS(3).CData=-allSS(3).CData;
allSS(2).CData=allSS(2).CData([16:30,1:15],:);
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
axB=findobj(gcf,'Type','Axes');
threePanelArrange
%%
%saveFig(gcf,saveDir,saveName,0)