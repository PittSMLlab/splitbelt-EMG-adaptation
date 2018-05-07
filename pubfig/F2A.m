%From makeN19DPrettyAgain
addpath(genpath('./auxFun/'))
%%
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
    
%% Add some lines marking an (approximate) window of 350ms length, with 100ms delay after heel-strike
phaseDurations=[177 314 135 458]; %Avg. across healthy subjects, during eA (15 strides), starting at FHS
intervalDurations=[phaseDurations(1)/2 *[1 1], phaseDurations(2)/4*ones(1,4), phaseDurations(3)/2*[1 1], phaseDurations(4)/4*ones(1,4)];

winEdges=90+[0 310]; %300ms response (Chvatal 2012)
%Adding rectangles with respect to FHS:
x=interp1(cumsum([0 intervalDurations]),[0:12]/12,winEdges); %100 to 450ms window
rectHeight=[0 0 14.8 14.8 0];
plot3([x fliplr(x) x(1)], 0.1+rectHeight, 5*ones(1,5),'LineWidth',3,'Color',ccc(1,:) );
plot3(.5+[x fliplr(x) x(1)], 15.1+rectHeight, 5*ones(1,5),'LineWidth',3,'Color',ccc(1,:) ); %Same time inteval, contralateral side

%Adding rectangles with respect to SHS:
x=interp1(cumsum([0 fftshift(intervalDurations)]),[0:12]/12,winEdges); %100 to 450ms window
plot3([x fliplr(x) x(1)], 15.1+rectHeight, 5*ones(1,5),'LineWidth',3,'Color',ccc(2,:) );
plot3(.5+[x fliplr(x) x(1)], 0.1+rectHeight, 5*ones(1,5),'LineWidth',3,'Color',ccc(2,:) ); %Same time inteval, contralateral side

%%
saveFig(gcf,saveDir,saveName,0)
