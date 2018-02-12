%From makeN19DPrettyAgain
saveDir='./';
name='allChangesEMG.fig';
desiredPlotDescription={'late A'};
desiredPlotDescription2={'early P'};
plotTitles={'Late Adaptation','    Early Post-Adap'};
saveName='Fig3B';
lineFlag=0;
makeN19DPrettyAgain_execute
%%
tt=findobj(gcf,'Type','Text');
set(tt(strcmp(get(tt,'String'),'SLOW/PARETIC')),'String','SLOW/NON-DOM')
set(tt(strcmp(get(tt,'String'),'FAST/NON-PARETIC')),'String','FAST/DOMINANT')
colorbar
ss=findobj(gca,'Type','Image');
%ss.CData(16,:)=0;
title('')

tt=findobj(gca,'Type','Text');
for i=1:length(tt)
    if tt(i).Position(2)<-1
        delete(tt(i))
    end
end

ll=findobj(gca,'Type','Line');
for i=1:length(ll)
    if all(ll(i).YData<-1)
        delete(ll(i))
    end
end

allSS=findobj(gcf,'Type','Image');
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
Clim=.5;
caxis(Clim*[-1 1])
cc=findobj(gcf,'Type','Colorbar');
set(cc,'Ticks',[-.5 -.25 0 .25 .5],'FontSize',16,'FontWeight','bold');
set(cc,'TickLabels',{'-50%','-25%','0%','+25%','+50%'});
set(gcf,'Color',ones(1,3))

set(gcf,'Position',[0 0 .5 .8])
%%
saveFig(newFig,saveDir,saveName,0)
