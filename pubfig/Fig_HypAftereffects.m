%% Run scripts for each panel (if needed):
%run ./Fig2A.m
%run ./Fig2B.m

%% Arrange panels in single fig:
%close all
fA=openfig('./Fig2A.fig');
axA=findobj(fA,'Type','Axes');
fB=openfig('./Fig2B.fig');
axB=findobj(fB,'Type','Axes');
sslA=findobj(axB(2),'Type','Surface');
fC=openfig('./Fig4A.fig');
axC=findobj(fC,'Type','Axes');
sseA=findobj(axC(2),'Type','Surface');


fh=figure('Units','Normalized','OuterPosition',[0 0 .53 .9],'Color',ones(1,3));
condColors=[.6,.6,.6; 0,.5,.4; .5,0,.6];
figuresColorMap
colormap(flipud(map))
Clim=.5;
pA=copyobj(axA,fh);
for i=1:length(pA)
    axes(pA(i))
    title('')
    tt=findobj(pA(i),'Type','Text');
    for j=1:length(tt)
        set(tt(j),'FontSize',16,'Position',get(tt(j),'Position')-[0 0 0])
    end
    set(pA(i),'Position',get(pA(i),'Position').*[1.05 .3 1 .26] + [.03 .71 0 0]);
    pA(i).YLabel.FontWeight='bold';
    caxis(Clim*[-1 1])
    if i==1
        ll=findobj(gca,'Type','Line');
        lg=legend(ll(end-1:end));
    end
    lg.Position=lg.Position+[.003 0 0 0];
end
pB=copyobj(axB,fh);
for i=1:length(pB)
%set(pB(i),'Position',get(pB(i),'Position').*[1.1 1 1.05 .8] + [0 -.1 0 0])
set(pB(i),'Position',get(pB(i),'Position').*[1.1 1 .8/.7 .8/.9] + [-.02 -.13 0 0])
axes(pB(i))
caxis(Clim*[-1 1])
if i==1
    cc=colorbar();
    cc.Ticks=[-.5 0 .5];
    cc.TickLabels={'-50%','0%','+50%'};
    set(cc,'FontSize',16,'FontWeight','bold')
    cc.Position=cc.Position.*[1 1 1 .98] + [0 .02 0 0];
    text(-1.35,32.5, 'B', 'FontSize',22,'FontWeight','bold','Clipping','off')
    text(-.08,32.5, 'C', 'FontSize',22,'FontWeight','bold','Clipping','off')
    text(-1.35,45, 'A', 'FontSize',22,'FontWeight','bold','Clipping','off')
    title('    Early Post-Adaptation')
    %Delete contours for post-adap
    ll=findobj(gca,'type','contour');
    delete(ll)
    ss=findobj(gca,'Type','Surface');
    ss.CData=sslA.CData-.3*sseA.CData+.7*sseA.CData([17:31,16,1:16],:);
    title('eP=lA-eA')
        ll=findobj(gca,'Type','Line','LineStyle','none');
    delete(ll)
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
    ll=findobj(gca,'type','contour');
    delete(ll)
    ss=findobj(gca,'Type','Surface');
    ss.CData=sslA.CData+sseA.CData([17:31,16,1:16],:);
    title('eP=lA+eA^T')
        ll=findobj(gca,'Type','Line','LineStyle','none');
    delete(ll)

end
end


%%
saveFig(fh,'./','Fig_HypAftereffects',1)