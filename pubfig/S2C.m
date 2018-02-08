%From makeN19DPrettyAgain
saveDir='./';
name='allChangesEMGswSlows_lateAdapBase.fig';
desiredPlotDescription={'(c)','Early','Adap'};
desiredPlotDescription2=[];
plotTitles={'Controls' };
saveName='Fig2SC';
lineFlag=0;
makeN19DPrettyAgain_execute
f1=gcf;
%% Panel A
set(f1,'Color',ones(1,3),'Position',get(f1,'Position').*[1 1 1 1]);
ax=findobj(f1,'Type','axes');
set(ax,'Position',get(ax,'Position').*[1 1 1 1] + [.02 .02 0 0])
tt=findobj(f1,'Type','Text');
title('')
colorbar('off')
cc=colorbar('southoutside');
cc.Ticks=[-.5 0 .5];
cc.TickLabels={'-50%','No change','+50%'};
cc.Position=cc.Position.*[1 1 1 .8]+[0 0 0 0];
ax=findobj(f1,'Type','Axes');
ax.Position=ax.Position.*[ 1 1 1 1];
%Switch top and bottom parts:
ss=findobj(f1,'Type','Surface');
ss.CData=-ss.CData;
ss.CData(16,:)=0;
idx=strcmp(get(tt,'String'),'SLOW/PARETIC');
%delete(tt)
pp=findobj(f1,'Type','patch');
uistack(pp,'top')
set(pp,'Color',ones(1,3));
figuresColorMap
colormap(flipud(map))
title('Early to Late Adapt.')
idx=strcmp(get(tt,'String'),'SLOW/PARETIC');
set(tt(idx),'String','SLOW/NON-DOM')
idx=strcmp(get(tt,'String'),'FAST/NON-PARETIC');
set(tt(idx),'String','FAST/DOMINANT')

%%
saveFig(newFig,saveDir,saveName,0)