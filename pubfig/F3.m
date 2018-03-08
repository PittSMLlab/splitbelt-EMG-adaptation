%% 
%This script generates the checkerboards with late Adaptation (steady-state) and early Post-adaptation (aftereffects)

%% Run scripts for each panel (if needed):
%run ./F3A.m
%run ./F3B.m

%% Arrange panels in single fig:
close all
%fA=openfig('./fig/Fig3A.fig');
%axA=findobj(fA,'Type','Axes');
fB=openfig('./fig/Fig3B.fig');
axB=findobj(fB,'Type','Axes');


fh=figure('Units','Normalized','OuterPosition',[0 0 .5 .8],'Color','None');
condColors=[.6,.6,.6; 0,.5,.4; .5,0,.6];
figuresColorMap
colormap(flipud(map))
Clim=.5;
% pA=copyobj(axA,fh);
% for i=1:length(pA)
%     axes(pA(i))
%     title('')
%     tt=findobj(pA(i),'Type','Text');
%     for j=1:length(tt)
%         set(tt(j),'FontSize',16,'Position',get(tt(j),'Position')-[0 0 0])
%     end
%     drawnow
%     pause(1)
%     
%     pA(i).YLabel.FontWeight='bold';
%     caxis(Clim*[-1 1])
%     if i==1
%         ll=findobj(gca,'Type','Line');
%         lg=legend(ll(end-1:end));
%     end
%     drawnow
%     pause(1)
%     set(pA(i),'Position',get(pA(i),'Position').*[1.05 .3 1 .26] + [.03 .71 0 0]);
%     lg.Position=lg.Position+[.003 0 0 0];
% end
pB=copyobj(axB,fh);
for i=1:length(pB)
%set(pB(i),'Position',get(pB(i),'Position').*[1.1 1 1.05 .8] + [0 -.1 0 0])
set(pB(i),'Position',get(pB(i),'Position').*[1 1 1 .9/.8] + [0 -.1 0 0])
axes(pB(i))
caxis(Clim*[-1 1])
if i==1
    cc=colorbar();
    cc.Ticks=[-.5 0 .5];
    cc.TickLabels={'-50%','0%','+50%'};
    set(cc,'FontSize',16,'FontWeight','bold')
    cc.Position=cc.Position.*[1 1 1 .98] + [0 .02 0 0];
    text(-1.35,31.5, 'A', 'FontSize',22,'FontWeight','bold','Clipping','off')
    text(-.08,31.5, 'B', 'FontSize',22,'FontWeight','bold','Clipping','off')
    %text(-1.35,43, 'A', 'FontSize',22,'FontWeight','bold','Clipping','off')
    title('    Early Post-Adaptation')
    %Delete contours for post-adap
    ll=findobj(gca,'type','contour');
    delete(ll)
        for j=1:length(pB(i).YTickLabel)
        if j<16
            pB(i).YTickLabel{j}=['\color[rgb]{0,0.447,0.741} ' pB(i).YTickLabel{j}];
        else
            pB(i).YTickLabel{j}=['\color[rgb]{0.85,0.325,0.098} ' pB(i).YTickLabel{j}];
        end
    end
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
saveFig(fh,'./','Fig3',1)
