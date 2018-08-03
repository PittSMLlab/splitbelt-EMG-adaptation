%% Run scripts for each panel (if needed):
addpath(genpath('./auxFun/'))
%run ./F4A.m
fName='Arial';
set(0,'defaultAxesFontName',fName,'defaultTextFontName',fName);
%% Arrange panels in single fig:
close all
figSize
fA=openfig('./fig/Fig1A.fig');
axA=findobj(fA,'Type','Axes');
fB=openfig('./fig/Fig4A.fig');
axB=findobj(fB,'Type','Axes');


fh=figure('Units','Pixels','OuterPosition',figPos.*[1 1 1 1],'Color',ones(1,3));
figuresColorMap
colormap(flipud(map))
Clim=.5;
clear pA
pB=copyobj(axB,fh);
for i=1:length(pB)
set(pB(i),'Position',get(pB(i),'Position').*[.6 1 .6 .95] + [.02 -.13 0 0])
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
    text(-1.35,40, 'A', 'FontSize',20,'FontWeight','bold','Clipping','off')
    text(-.05,40, 'B', 'FontSize',20,'FontWeight','bold','Clipping','off')
    text(-1.35,32, 'C', 'FontSize',20,'FontWeight','bold','Clipping','off')
    text(-.05,32, 'D', 'FontSize',20,'FontWeight','bold','Clipping','off')
    text(1.55,40, 'E', 'FontSize',20,'FontWeight','bold','Clipping','off')
    text(1.55,18, 'F', 'FontSize',20,'FontWeight','bold','Clipping','off')
        title('FBK_{split-to-tied}')
else
        ll2=findobj(pB(i),'Type','line','LineWidth',10);
        xOff=1.28;
        yOff=2;
        if ~isempty(ll2) %Shouldn't be
    for j=[length(ll2)+[-1:0]]
        ll2(j).XData=ll2(j).XData+xOff;
        ll2(j).YData=ll2(j).YData+yOff;
    end
        end
    tt=findobj(pB(i),'Type','text','String','EXTENSORS');
    tt.Position=tt.Position+[xOff yOff 0];
    tt=findobj(pB(i),'Type','text','String','FLEXORS');
    tt.Position=tt.Position+[xOff yOff 0];
    title('FBK_{tied-to-split}')
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
pl=plot3([-.1 2.3],[15 15],[6 6],'k','LineWidth',2,'Clipping','off');
pB(1).YAxis.FontSize=13;

pA(1)=copyobj(axA,fh);
pA(2)=copyobj(axA,fh);
for i=1:length(pA)
    axes(pA(i))
    set(pA(i),'Position',get(pB(i),'Position').*[1.03 0 .95 .2] + [0 .8 0 0])
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
        title({'SPLIT-TO-TIED'})
        ax.Title.FontSize=16;
    else
        ax.YLabel.FontWeight='bold';
        ax.YLabel.FontSize=16;
        title({'TIED-TO-SPLIT'})
        ax.Title.FontSize=16;
    end
end

%% Add regression to model comparison:
f1=openfig('../intfig/intersubj/fig/RegressorSpace_controls.fig');
p1=findobj(f1,'Type','Axes');
pC=copyobj(p1,fh);
pC.Colormap=f1.Colormap;
cc=findobj(f1,'Type','colorbar');
if ~isempty(cc)
cl=cc.TickLabels;
ct=cc.Ticks;
end
close(f1);
%
%c=colorbar(pC);
%c.Ticks=ct;
%c.TickLabels=cl;
%drawnow
%pause(2)
pC.Position=[.63 .55 .2 .35];
pC.FontSize=16;
pC.Title.String={'FBK_{split-to-tied}';'REGRESSION'};
pC.Title.FontSize=16;
pC.YTick=[0 1];
pC.FontWeight='bold';
pC.YLabel.Position=[-.6 .4];
pC.XLabel.Position=[.5 -.6];
pC.XTick=[0 1];
pC.YAxis.FontSize=12;
pC.XAxis.FontSize=12;
axes(pC)
%text(1.2,1.1,'Age','FontSize',12,'FontWeight','bold','Clipping','off')
%sc=findobj(pC,'Type','scatter');
%sc(5).CData=condColors(3,:);
%sc(5).MarkerFaceAlpha=.5;%condColors(3,:);
%axes(pC)

%% Add mid hip positions
f1=openfig('../intfig/all/kin/fig/mHIP2ANK_all_15strides.fig');
p1=findobj(f1,'Type','Axes');
pD=copyobj(p1(6),fh);
ll=findobj(pD,'Type','Line');
delete(ll([1,3,5]))
ll(2).Color=condColors(3,:);
pp=findobj(pD,'Type','Patch');
delete(pp([1,3,5]))
pp(4).FaceColor=condColors(3,:);
ls=findobj(p1(7),'Type','Line');
ln=copyobj(ls(2),pD);
ln.DisplayName='eP-B';
ln.Color=condColors(1,:);
ps=findobj(p1(7),'Type','Patch');
pn=copyobj(ps(4),pD);
pn.FaceColor=condColors(1,:);
%pn=copyobj(ps,pD);
close(f1);
%%



pD.Position=[.63 .07 .2 .35];
pD.FontSize=16;
pD.FontWeight='bold';
pD.Title.String={'\Delta HIP POSITION'};
pD.YTick=[-100 0 100];
pD.YLim=[-100 100];

axes(pD)
hold on

plot([.12 .49]*240,110*[1 1],'LineWidth',6,'Color',[0,.447,.741],'Clipping','off')
text(.1*240,120,{'FAST STANCE'},'FontWeight','bold','Fontsize',12,'Color',[0,.447,.741])
plot((.5+[0.12 .49])*240,110*[1 1],'LineWidth',6,'Color',[0.85,.325,.098],'Clipping','off')
text(.6*240,120,{'SLOW STANCE'},'FontWeight','bold','Fontsize',12,'Color',[0.85,.325,.098])
%legend(ll)
pD.YAxis.FontSize=10;
pD.XAxis.FontSize=12;
drawnow
pause(1)
pD.YTick=[-80:40:80];
pD.YTickLabel={'80','40','0','-40','-80'};
pD.YDir='reverse';
pD.YLabel.String='HIP A-P pos. [mm]';
%pD.XTickLabel={'fHS','sTO','sHS','fTO'};
pD.XTickLabel='';

drawnow
axes(pD)
pp=pD.Position;
lg=legend([ll([2,4]); ln],{'SPLIT-TO-TIED','TIED-TO-SPLIT','EarlyP_B'},'Location','East');
lg.FontSize=10;
%delete(ln)
%delete(pn)
drawnow
pD.Position=pp;
%%
saveFig(fh,'./','Fig4',1)