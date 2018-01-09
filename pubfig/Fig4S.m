%% Run scripts for each panel (if needed):

%From makeN19DPrettyAgain
saveDir='./';
name='allChangesEMGswSlows_early7_shortSplit.fig';
name2='allChangesEMGswSlows_early7_shortSplit_altBase.fig';
desiredPlotDescription={'(c)','Short','exposure'};
desiredPlotDescription2={'(c)','Early','baseline'};
plotTitles={'Tied-to-split transition','    Split-to-tied transition'};
saveName='Fig4S';
lineFlag=0;
makeN19DPrettyAgain_execute

%%
allSS=findobj(gcf,'Type','Surface');
for i=1:length(allSS)
    ss=allSS(i);
ss.CData(16,:)=0;
tt=findobj(gcf,'Type','Text');
idx=strcmp(get(tt,'String'),'SLOW/PARETIC');
set(tt(idx),'String','SLOW/NON-DOM');
idx=strcmp(get(tt,'String'),'FAST/NON-PARETIC');
set(tt(idx),'String','FAST/DOMINANT');
end
%Colormap:
figuresColorMap
colormap(flipud(map))
Clim=.5;
caxis(Clim*[-1 1])
cc=findobj(gcf,'Type','Colorbar');
set(cc,'Ticks',[-.5 -.25 0 .25 .5],'FontSize',16,'FontWeight','bold');
set(cc,'TickLabels',{'-50%','-25%','No change','+25%','+50%'});
set(gcf,'Color',ones(1,3))

%% Arrange panels in single fig:
fh=gcf;
set(fh,'Units','Normalized','OuterPosition',[0 0 .53 .85],'Color',ones(1,3));
figuresColorMap
colormap(flipud(map))
Clim=.5;
pB=findobj(fh,'Type','axes');
for i=1:length(pB)
set(pB(i),'Position',get(pB(i),'Position').*[1.1 1 .8/.7 1/.85] + [-.02 -.12 0 0])
axes(pB(i))
caxis(Clim*[-1 1])
if i==1
    pB(i).Position=pB(i).Position+[0 0 0 0];
    cc=colorbar();
    cc.Ticks=[-.5 0 .5];
    cc.TickLabels={'-50%','0%','+50%'};
    cc.Position=cc.Position.*[1 1 1 .98] + [0 .02 0 0];
    set(cc,'FontSize',16,'FontWeight','bold')
    text(-1.3,33, 'A', 'FontSize',22,'FontWeight','bold','Clipping','off')
    %text(-1.3,-4, 'C', 'FontSize',22,'FontWeight','bold','Clipping','off')
    text(-.05,33, 'B', 'FontSize',22,'FontWeight','bold','Clipping','off')
else
        ll2=findobj(pB(i),'Type','line','LineWidth',10);
        xOff=1.28;
        yOff=2;
    for j=[length(ll2)+[-1:0]];
        ll2(j).XData=ll2(j).XData+xOff;
        ll2(j).YData=ll2(j).YData+yOff;
    end
    tt=findobj(pB(i),'Type','text','String','EXTENSORS');
    tt.Position=tt.Position+[xOff yOff 0];
    tt=findobj(pB(i),'Type','text','String','FLEXORS');
    tt.Position=tt.Position+[xOff yOff 0];
end
end

%% Add Panel C
% f2=openfig('./Fig4SC.fig');
% ph=findobj(f2,'Type','axes');
% pB=copyobj(ph,fh);
% set(pB,'Position',[.13 .05 .5 .18],'XLim',[.5 2.5],'YLim',[-.2 1],'YTick',[0 1])
% pB.YLabel.FontWeight='bold';
% pB.FontWeight='bold';
% axes(pB)
% legend({'After long exposure','After short exposure'},'Location','bestoutside')
%%
saveFig(fh,'./','Fig4S',1)