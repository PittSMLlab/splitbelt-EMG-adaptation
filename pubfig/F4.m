%% Run scripts for each panel (if needed):
run ./F4A.m

%% Arrange panels in single fig:
close all
fA=openfig('./fig/Fig1A.fig');
axA=findobj(fA,'Type','Axes');
fB=openfig('./fig/Fig4A.fig');
axB=findobj(fB,'Type','Axes');


fh=figure('Units','Normalized','OuterPosition',[0 0 .53 .9],'Color',ones(1,3));
condColors=[.6,.6,.6; 0,.5,.4; .5,0,.6];
figuresColorMap
colormap(flipud(map))
Clim=.5;
clear pA
pB=copyobj(axB,fh);
for i=1:length(pB)
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
    text(-1.3,43, 'A', 'FontSize',22,'FontWeight','bold','Clipping','off')
    text(-.08,43, 'B', 'FontSize',22,'FontWeight','bold','Clipping','off')
        title('EMG change: eP - lA')
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
    title('EMG change: eA - B')
end
hold on
x=[0 2/12]; %roughly 50 to 200 ms
y=[0 14.95];
z=1;
cc1=get(gca,'ColorOrder');
%r=rectangle('Position',[x(1) y(1) diff(x) diff(y)],'LineWidth',3,'EdgeColor',cc1(3-i,:));
plot3( [x(1) x(2) x(2) x(1) x(1)], [y(1) y(1) y(2) y(2) y(1)], [z z z z z],'LineWidth',3,'Color',cc1(3-i,:));
%rectangle('Position',[x(1) 16+y(1) diff(x) diff(y)],'LineWidth',3,'EdgeColor',cc1(i,:));
plot3( [x(1) x(2) x(2) x(1) x(1)], 15+[y(1) y(1) y(2) y(2) y(1) ], [z z z z z],'LineWidth',3,'Color',cc1(i,:));
end

pA(1)=copyobj(axA,fh);
pA(2)=copyobj(axA,fh);
for i=1:length(pA)
    axes(pA(i))
    set(pA(i),'Position',get(pB(i),'Position').*[1.1 0 1 .3] + [-.03 .74 0 0])
    tt=findobj(gca,'Type','text');
    delete(tt([1,4,6]))
    tt=findobj(gca,'Type','text');
    set(tt,'FontWeight','bold','Clipping','on')
    for j=1:length(tt)
       tt(j).Position=tt(j).Position+[0 .35 0]; 
    end
    aa=axis;
    axis([10+[55,345]+(2-i)*600 aa(3:4)])
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
saveFig(fh,'./','Fig4',1)