%% Run scripts for each panel (if needed):


%% Arrange panels in single fig:
close all
fB=openfig('./Fig4A.fig');
axB=findobj(fB,'Type','Axes');


fh=figure('Units','Normalized','OuterPosition',[0 0 .53 .7],'Color',ones(1,3));
figuresColorMap
colormap(flipud(map))
Clim=.5;
pB=copyobj(axB,fh);
for i=1:length(pB)
set(pB(i),'Position',get(pB(i),'Position').*[1.1 1 .8/.7 .8/.7] + [-.02 -.1 0 0])
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

%%
saveFig(fh,'./','Fig4',1)