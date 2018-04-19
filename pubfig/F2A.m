%From makeN19DPrettyAgain
saveDir='./';
name='allChangesEMG.fig';
desiredPlotDescription={'early','A[15]'};
desiredPlotDescription2={};
plotTitles={'Tied-to-split transition'};
saveName='Fig2A';
lineFlag=0;
makeN19DPrettyAgain_execute

%%
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
%Colormap:
figuresColorMap
colormap(flipud(map))
Clim=.5;
caxis(Clim*[-1 1])
cc=findobj(gcf,'Type','Colorbar');
set(cc,'Ticks',[-.5 -.25 0 .25 .5],'FontSize',16,'FontWeight','bold');
set(cc,'TickLabels',{'-50%','-25%','No change','+25%','+50%'});
set(gcf,'Color',ones(1,3))
drawnow

%Change EXTENSORE/FLEXOR label position
        ll2=findobj(gca,'Type','line','LineWidth',10);
        xOff=-.5;
        yOff=-3;
    for j=[length(ll2)+[-1:0]]
        ll2(j).XData=ll2(j).XData+xOff;
        ll2(j).YData=ll2(j).YData+yOff;
    end
    tt=findobj(gca,'Type','text','String','EXTENSORS');
    tt.Position=tt.Position+[xOff yOff 0];
    tt=findobj(gca,'Type','text','String','FLEXORS');
    tt.Position=tt.Position+[xOff yOff 0];
%%
%saveFig(gcf,saveDir,saveName,0)
