%% Run scripts for each panel (if needed):
addpath(genpath('./auxFun/'))
run ./F4A.m
fName='Arial';
set(0,'defaultAxesFontName',fName,'defaultTextFontName',fName);
%% Arrange panels in single fig:
close all
fA=openfig('./fig/Fig1A.fig');
axA=findobj(fA,'Type','Axes');
fB=openfig('./fig/Fig4A.fig');
axB=findobj(fB,'Type','Axes');


fh=figure('Units','Normalized','OuterPosition',[0 0 .7 .9],'Color',ones(1,3));
condColors=[.6,.6,.6; 0,.5,.4; .5,0,.6];
figuresColorMap
colormap(flipud(map))
Clim=.5;
clear pA
pB=copyobj(axB,fh);
for i=1:length(pB)
set(pB(i),'Position',get(pB(i),'Position').*[.6 1 .6 .8/.9] + [.02 -.13 0 0])
axes(pB(i))
caxis(Clim*[-1 1])
if i==1
    pB(i).Position=pB(i).Position+[0 0 0 0];
    cc=colorbar();
    %cc.Ticks=[-.5 0 .5];
    %cc.TickLabels={'-50%','0%','+50%'};
    cc.Ticks=[0];
    cc.TickLabels={'0%'};
    cc.Position=cc.Position.*[1 1 1 .98] + [0 .02 0 0];
    text(1.2,31,'+50%','FontSize',16,'FontWeight','bold','Clipping','off')
    text(1.2,0,'- 50%','FontSize',16,'FontWeight','bold','Clipping','off')
    set(cc,'FontSize',16,'FontWeight','bold')
    text(-1.3,43, 'A', 'FontSize',22,'FontWeight','bold','Clipping','off')
    text(-.05,43, 'B', 'FontSize',22,'FontWeight','bold','Clipping','off')
    text(1.65,43, 'C', 'FontSize',22,'FontWeight','bold','Clipping','off')
    text(1.65,18, 'D', 'FontSize',22,'FontWeight','bold','Clipping','off')
        title('\Delta EMG (eP - lA)')
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
    title('\Delta EMG (eA - B)')
end
hold on
x=[0 2/12]; %roughly 50 to 200 ms
y=[0 14.95];
z=1;
cc1=get(gca,'ColorOrder');
%r=rectangle('Position',[x(1) y(1) diff(x) diff(y)],'LineWidth',3,'EdgeColor',cc1(3-i,:));
%plot3( [x(1) x(2) x(2) x(1) x(1)], [y(1) y(1) y(2) y(2) y(1)], [z z z z z],'LineWidth',3,'Color',cc1(3-i,:));
%rectangle('Position',[x(1) 16+y(1) diff(x) diff(y)],'LineWidth',3,'EdgeColor',cc1(i,:));
%plot3( [x(1) x(2) x(2) x(1) x(1)], 15+[y(1) y(1) y(2) y(2) y(1) ], [z z z z z],'LineWidth',3,'Color',cc1(i,:));
end

pA(1)=copyobj(axA,fh);
pA(2)=copyobj(axA,fh);
for i=1:length(pA)
    axes(pA(i))
    set(pA(i),'Position',get(pB(i),'Position').*[1.03 0 .95 .25] + [0 .75 0 0])
    tt=findobj(gca,'Type','text');
    delete(tt([1,2,5,7,8]))
    tt=findobj(gca,'Type','text');
    set(tt,'FontWeight','bold','Clipping','on')
    for j=1:length(tt)
       tt(j).Position=tt(j).Position+[10 .3 0]; 
    end
    aa=axis;
    axis([10+[55,345]+(2-i)*600 aa(3:4)])
    ax=gca;
    ax.YTick=[];
    ax.XLabel.String='';
    if i==1
        ax.YLabel.String='';
        title({'SPLIT-TO-TIED';'TRANSITION'})
        ax.Title.FontSize=16;
    else
        ax.YLabel.FontWeight='bold';
        ax.YLabel.FontSize=16;
        title({'TIED-TO-SPLIT';'TRANSITION'})
        ax.Title.FontSize=16;
    end
end

%% Add regression to model comparison:
f1=openfig('../intfig/intersubj/fig/RegressorSpace_controls.fig');
p1=findobj(f1,'Type','Axes');
pC=copyobj(p1,fh);
pC.Colormap=f1.Colormap;
cc=findobj(f1,'Type','colorbar');
cl=cc.TickLabels;
ct=cc.Ticks;
close(f1);
%
c=colorbar(pC);
c.Ticks=ct;
c.TickLabels=cl;
drawnow
pause(2)
pC.Position=[.65 .55 .24 .35];
pC.FontSize=16;
pC.Title.String={'SPLIT-TO-TIED EMG';'REGRESSION'};
pC.Title.FontSize=16;
pC.YTick=[0 1];
pC.FontWeight='bold';
pC.YLabel.Position=[-.6 .6];
pC.XTick=[-.5 0 1];
pC.YAxis.FontSize=12;
pC.XAxis.FontSize=12;
axes(pC)
text(1.2,1.1,'Age','FontSize',12,'FontWeight','bold','Clipping','off')
%axes(pC)

%% Add mid hip positions
f1=openfig('../intfig/all/kin/fig/mHIP2ANK_all_15strides.fig');
p1=findobj(f1,'Type','Axes');
pD=copyobj(p1(6),fh);
close(f1);
%%
ll=findobj(pD,'Type','Line');
delete(ll([1,3,5]))
ll(2).Color=condColors(3,:);
pp=findobj(pD,'Type','Patch');
delete(pp([1,3,5]))
pp(4).FaceColor=condColors(3,:);

pD.Position=[.66 .07 .25 .35];
pD.FontSize=16;
pD.FontWeight='bold';
pD.Title.String={'HIP POSITION CHANGE'};
pD.YTick=[-100 0 100];
pD.YLim=[-100 100];

axes(pD)
hold on

plot([.12 .49]*240,110*[1 1],'LineWidth',6,'Color',[0,.447,.741],'Clipping','off')
text(.13*240,120,{'FAST STANCE'},'FontWeight','bold','Fontsize',12,'Color',[0,.447,.741])
plot((.5+[0.12 .49])*240,110*[1 1],'LineWidth',6,'Color',[0.85,.325,.098],'Clipping','off')
text(.63*240,120,{'SLOW STANCE'},'FontWeight','bold','Fontsize',12,'Color',[0.85,.325,.098])
%legend(ll)
pD.YAxis.FontSize=10;
pD.XAxis.FontSize=12;
drawnow
pause(1)
pD.YTick=[-80:40:80];
pD.YTickLabel={'80','40','0','-40','-80'};
pD.YDir='reverse';
pD.YLabel.String='HIP A-P pos. (from ANKLE) [mm]';
%pD.XTickLabel={'fHS','sTO','sHS','fTO'};
pD.XTickLabel='';

drawnow
axes(pD)
pp=pD.Position;
legend(ll([2,4]),{'eP-lA','eA-B'},'Location','East')
drawnow
pD.Position=pp;
%%
saveFig(fh,'./','Fig4',1)