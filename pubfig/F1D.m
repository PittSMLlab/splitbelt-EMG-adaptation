%From makeN19DPrettyAgain
saveDir='./';
name='allChangesEMG.fig';
desiredPlotDescription={'Ref','Base'};
desiredPlotDescription2={};
plotTitles={'Baseline activity'};
saveName='Fig1D';
lineFlag=0;
makeN19DPrettyAgain_execute
%%
drawnow
tt=findobj(gcf,'Type','Text');
set(tt(strcmp(get(tt,'String'),'SLOW/PARETIC')),'String','SLOW/NON-DOM')
set(tt(strcmp(get(tt,'String'),'FAST/NON-PARETIC')),'String','FAST/DOMINANT')
colorbar
ss=findobj(gca,'Type','surface');
%ss.CData(16,:)=0;
title('')

drawnow

allSS=findobj(gcf,'Type','Surface');
for i=1:length(allSS)
    ss=allSS(i);
%ss.CData(16,:)=0;
tt=findobj(gcf,'Type','Text');
idx=strcmp(get(tt,'String'),'SLOW/PARETIC');
set(tt(idx),'String','SLOW/NON-DOM');
idx=strcmp(get(tt,'String'),'FAST/NON-PARETIC');
set(tt(idx),'String','FAST/DOMINANT');
end

figuresColorMap
colormap(flipud(map))
caxis([-1 1])
cc=findobj(gcf,'Type','Colorbar');
cc.Location='southoutside';
set(cc,'Ticks',[0 .5 1],'FontSize',16,'FontWeight','bold');
set(cc,'TickLabels',{'0%','50%','100%'});
set(gcf,'Color',ones(1,3))
cc.Limits=[0 1];
cc.Position=cc.Position+[.08 .01 -.02 0];
set(gcf,'Position',[0 0 .5 .8])

        ll2=findobj(gca,'Type','line','LineWidth',10);
        xOff=-1.15;
        yOff=.8;
    for j=[length(ll2)+[-1:0]]
        ll2(j).XData=ll2(j).XData+xOff;
        ll2(j).YData=ll2(j).YData+yOff;
    end
    tt=findobj(gca,'Type','text','String','EXTENSORS');
    tt.Position=tt.Position+[xOff yOff 0];
    tt=findobj(gca,'Type','text','String','FLEXORS');
    tt.Position=tt.Position+[xOff yOff 0];
    
%%
saveFig(newFig,saveDir,saveName,0)