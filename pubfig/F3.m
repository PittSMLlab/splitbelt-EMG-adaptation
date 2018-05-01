%% 
%This script generates the checkerboards with late Adaptation (steady-state) and early Post-adaptation (aftereffects)
addpath(genpath('./auxFun/'))
%% Get panels from existing figure and make pretty:
saveDir='./';
name='allChangesEMG.fig';
desiredPlotDescription={'Slow';'late A'; 'early P[15]'};
plotTitles={'Slow Tied','Late Adaptation','  Early Post-Adaptation'};
saveName='Fig3B';
lineFlag=0;
makeN19DPrettyAgain_execute
fB=gcf;

%% Add some details:
axB=findobj(fB,'Type','Axes');
set(fB,'Units','Normalized','OuterPosition',[0 0 .7 .8],'Renderer','opengl');

%Fix colormap: (not needed)
%figuresColorMap
%colormap(flipud(map))
Clim=.5;

for i=1:length(axB)
    %Change positions slightly:
    set(axB(i),'Position',get(axB(i),'Position').*[1 1 1 .9/.8] + [0 -.1 0 0])


    if i==1
            %Fix colorbar:
        caxis(Clim*[-1 1])
        cc=colorbar();
        cc.Ticks=[-.5 0 .5];
        cc.TickLabels={'-50%','0%','+50%'};
        set(cc,'FontSize',16,'FontWeight','bold')
        cc.Position=cc.Position.*[1 1 1 .98] + [0 .02 0 0];
        text(-2.3,32, 'A', 'FontSize',22,'FontWeight','bold','Clipping','off')
        text(-1.2,32, 'B', 'FontSize',22,'FontWeight','bold','Clipping','off')
        text(-.08,32, 'C', 'FontSize',22,'FontWeight','bold','Clipping','off')
        %Delete contours for post-adap
        ll=findobj(gca,'type','contour');
        delete(ll)
    else
        %Move the EXTENSORS/FLEXORS legend:
        ll2=findobj(axB(i),'Type','line','LineWidth',10);
        if ~isempty(ll2)
        xOff=2.4;
        yOff=2;
        for j=[length(ll2)+[-1:0]]
            ll2(j).XData=ll2(j).XData+xOff;
            ll2(j).YData=ll2(j).YData+yOff;
        end
        tt=findobj(axB(i),'Type','text','String','EXTENSORS');
        tt.Position=tt.Position+[xOff yOff 0];
        tt=findobj(axB(i),'Type','text','String','FLEXORS');
        tt.Position=tt.Position+[xOff yOff 0];
        end

        %Change contour colors for late adapt:
        ll=findobj(gca,'type','contour');
        if ~isempty(ll)
        auxZ=ll.ZData;
        auxZ(571:end,:)=0;
        contour(ll.XData,ll.YData,auxZ,.5*[1 1]);
        auxZ=ll.ZData;
        auxZ(1:570,:)=0;
        auxZ(1649:end,:)=0;
        contour(ll.XData,ll.YData,auxZ,.5*[1 1]);
        auxZ=ll.ZData;
        auxZ(1:1649,:)=0;
        auxZ(1649+571:end,:)=0;
        contour(ll.XData,ll.YData,auxZ,.5*[1 1]);
        auxZ=ll.ZData;
        auxZ(1:1649+570,:)=0;
        contour(ll.XData,ll.YData,auxZ,.5*[1 1]);
        delete(ll)
        ll=findobj(gca,'type','contour');
        cc1=get(gca,'ColorOrder');
        ll(2).Color=cc1(2,:);
        ll(1).Color=cc1(1,:);
        ll(3).Color=cc1(2,:);
        ll(4).Color=cc1(1,:);
        set(ll,'LineWidth',4)
        end
    end
end


%%
saveFig(fB,'./','Fig3',1)
