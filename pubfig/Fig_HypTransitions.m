%% Run scripts for each panel (if needed):
%run ./Fig2A.m
%run ./Fig2B.m

%% Arrange panels in single fig:
%close all
fA=openfig('./Fig1A.fig');
axA=findobj(fA,'Type','Axes');
fB=openfig('./Fig4A.fig');
axB=findobj(fB,'Type','Axes');


fh=figure('Units','Normalized','OuterPosition',[0 0 .53 .9],'Color',ones(1,3));
condColors=[.6,.6,.6; 0,.5,.4; .5,0,.6];
figuresColorMap
colormap(flipud(map))
Clim=.5;
clear pA
pB=copyobj(axB,fh);
for i=length(pB):-1:1
set(pB(i),'Position',get(pB(i),'Position').*[1.1 1 .8/.7 .8/.9] + [-.02 -.13 0 0])
axes(pB(i))
caxis(Clim*[-1 1])
if i==1
    pB(i).Position=pB(i).Position+[0 0 0 0];
    cc=colorbar();
    cc.Ticks=[-.5 0 .5];
    cc.TickLabels={'-50%','0%','+50%'};
    cc.Position=cc.Position.*[1 1 1 .98] + [0 .02 0 0];
    set(cc,'FontSize',16,'FontWeight','bold')
    text(-1.3,45, 'A', 'FontSize',22,'FontWeight','bold','Clipping','off')
    text(-.08,45, 'B', 'FontSize',22,'FontWeight','bold','Clipping','off')
        title('eA^T')
    ss=findobj(gca,'Type','Surface');
    %ss.CData=.3*ss1.CData-.7*ss1.CData([17:32,1:16],:);
    ss.CData=-ss1.CData([17:31,16,1:16],:);
    ll=findobj(gca,'Type','Line','LineStyle','none');
    delete(ll)
    ll=copyobj(ll1,gca);
    aux=ll.YData>15;
    inds=[find(aux) find(~aux)];
    new=[ll.YData(aux)-16 ll.YData(~aux)+16];
    ll.YData(inds)=new;
    %ss.YData(ind)=new;
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
    title('-eA')
    ss1=findobj(gca,'Type','Surface');
    ss1.CData=-ss1.CData;
    ll1=findobj(gca,'Type','Line','LineStyle','none');
end
hold on
x=[.05 .2]; %roughly 50 to 200 ms
y=[0 14.95];
cc1=get(gca,'ColorOrder');
rectangle('Position',[x(1) y(1) diff(x) diff(y)],'LineWidth',3,'EdgeColor',cc1(3-i,:));
rectangle('Position',[x(1) 16+y(1) diff(x) diff(y)],'LineWidth',3,'EdgeColor',cc1(i,:));
end

pA(1)=copyobj(axA,fh);
pA(2)=copyobj(axA,fh);
for i=1:length(pA)
    axes(pA(i))
    set(pA(i),'Position',get(pB(i),'Position').*[1.1 0 1 .3] + [-.03 .74 0 0])
    tt=findobj(gca,'Type','text');
    delete(tt([1,4,6]))
    tt=findobj(gca,'Type','text');
    set(tt,'FontWeight','bold')
    for j=1:length(tt)
       tt(j).Position=tt(j).Position+[0 .35 0]; 
    end
    aa=axis;
    axis([[55,345]+(2-1)*900 aa(3:4)])
    ax=gca;
    ax.YTick=[];
    ax.XLabel.String='';
    if i==1
        ax.YLabel.String='';
        title('Split-to-tied transition')
    else
        ax.YLabel.FontWeight='bold';
        title('Tied-to-split transition')
    end
end


%%
saveFig(fh,'./','Fig_HypTransitions',1)