%% Run scripts for each panel (if needed):
addpath(genpath('./auxFun/'))
%run ./F4A.m
fName='Arial';
set(0,'defaultAxesFontName',fName,'defaultTextFontName',fName);
%% Arrange panels in single fig:
close all
figSize
fB=openfig('./fig/Fig4A.fig');
heightFactor=1.8;
fB.InnerPosition(4)=fB.InnerPosition(4)*heightFactor;
fB.PaperPosition(4)=fB.PaperPosition(4)*heightFactor;
fB.PaperSize(2)=fB.PaperSize(2)*heightFactor;

axB=findobj(fB,'Type','Axes');
for i=1:length(axB)
    axB(i).Position=axB(i).Position.*[1 1 1 1/heightFactor]+[0 .3 0 0];
end
cc=findobj(fB,'Type','Colorbar');
cc.Position=cc.Position.*[1 1 1 1/heightFactor]+[0 .3 0 0];

myFiguresColorMap
colormap(flipud(map))
Clim=.5;
pB=axB;
txt=findobj(fB,'Type','text');
set(txt,'FontSize',8)
txt=txt(strcmp(get(txt,'String'),'A')| strcmp(get(txt,'String'),'B')| strcmp(get(txt,'String'),'C'));
delete(txt)
for i=1:length(pB)
%set(pB(i),'Position',get(pB(i),'Position').*[.6 1 .6 .95] + [.02 -.13 0 0])
axes(pB(i))
caxis(Clim*[-1 1])
if i==1
    yAlignment=[40.7,-5];
    %text(-1.5,yAlignment(1), 'A', 'FontSize',16,'FontWeight','bold','Clipping','off')
    %text(-.2,yAlignment(1), 'B', 'FontSize',16,'FontWeight','bold','Clipping','off')
    %text(1.15,yAlignment(1), 'C', 'FontSize',16,'FontWeight','bold','Clipping','off')
    %text(-1.45,yAlignment(2), 'D', 'FontSize',16,'FontWeight','bold','Clipping','off')
    %text(.8,yAlignment(2), 'E', 'FontSize',16,'FontWeight','bold','Clipping','off')
else

end
hold on
x=[0 2/12]; %roughly 50 to 200 ms
y=[0 14.95];
z=1;
cc1=get(gca,'ColorOrder');
end
pl=plot3([2.15 2.15]+.31,[-2 32],[6 6],'k','LineWidth',1,'Clipping','off');
pB(1).YAxis.FontSize=15;
uistack(axB(1),'top')

%% Add subpanels on top:
myFiguresColorMap
clear ax
tall=1.5;
wide=.3;
for i=1:length(pB)
   ax(i)=axes;
   ax(i).Position=pB(i).Position.*[1 1 1 0]+[.05 .43 -.1 .08];
axes(ax(i))
    hold on
patch([0 2 2 0],[-1 -1 1 1]*tall,.7*ones(1,3),'FaceAlpha',.8)

       ax(i).YRuler.Axle.LineStyle = 'none';
    ax(i).XRuler.Axle.LineStyle = 'none';
    ax(i).XLim=[-1 1];
    ax(i).YLim=[-1 1]*tall*.9;
    ax(i).Title.String=pB(i).Title.String;
        ax(i).Title.FontSize=10;
            ax(i).Title.FontWeight='normal';
    pB(i).Title.String='';
    ax(i).XTick=[];
    ax(i).XTickLabel={};
    %if i==3
        ax(i).YTick=[];
    %else
    %    ax(i).YTick=[];
    %end
    ax(i).YAxis.FontSize=8;
    %ax(i).YAxis.FontWeight='bold';
end

%-EMG up
axes(ax(3))
hold on
plot([-1 0 0 1],[0 0 1 1],'LineWidth',2,'Color',.5*ones(1,3))
plot([-1 0 0 1]*wide,[0 0 1 1],'LineWidth',4,'Color',colorTransitions(1,:))
ax(3).Title.Color=colorTransitions(1,:);
ax(3).YLim(1)=-.5;
text(-.95,-.25,'tied','FontSize',8)
text(.15,.75,'split(+)','FontSize',8)
%EMG down
axes(ax(1))
hold on
plot([-1 0 0 1],[0 0 -1 -1],'LineWidth',2,'Color',.5*ones(1,3))
plot([-1 0 0 1]*wide,[0 0 -1 -1],'LineWidth',4,'Color',colorTransitions(2,:))
ax(1).Title.Color=colorTransitions(2,:);
ax(1).YLim(2)=.5;
text(-.95,-.25,'tied','FontSize',8)
text(.15,-.75,['split(' char(8211) ')'],'FontSize',8)
%EMG long up off
axes(ax(2))
hold on
plot([1 2 2 3],[1 1 0 0],'LineWidth',2,'Color',.5*ones(1,3))
plot([-1 0 0 1]*wide+2,[1 1 0 0],'LineWidth',4,'Color',zeros(1,3))
ax(2).XLim=[1 3];
ax(2).YLim(1)=-.5;
text(.15+2,-.25,'tied','FontSize',8)
text(-1.35+2,.75,'split(+)','FontSize',8)
ax(2).Title.Position(2)=ax(2).Title.Position(2)-.2;
%% Add regression to model comparison:
f1=openfig('../intfig/intersubj/fig/RegressorSpace_controls.fig');
resizeFigure(f1,1/2.5)
p1=findobj(f1,'Type','Axes');
pC=copyobj(p1,fB);
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
pC.Position=[.1 .12 .3 .21];
pC.FontSize=10;
pC.Title.String={''};
pC.Title.FontSize=14;
pC.YTick=[0 1];
pC.FontWeight='normal';
%pC.YLabel.Position=[-.6 .4];
%pC.XLabel.Position=[.5 -.6];
pC.XTick=[0 1];
pC.YAxis.FontSize=10;
pC.XAxis.FontSize=10;
axes(pC)
pC.YLabel.String='\beta_{adapt}';
%pC.YLabel.Position(1)=pC.YLabel.Position(1)+.1;
pC.XLabel.String='\beta_{no-adapt}';
pC.XLabel.Position=[.5 -.23];
pC.YAxis.LineWidth=1;
pC.XAxis.LineWidth=1;
%text(1.2,1.1,'Age','FontSize',12,'FontWeight','bold','Clipping','off')
%sc=findobj(pC,'Type','scatter');
%sc(5).CData=condColors(3,:);
%sc(5).MarkerFaceAlpha=.5;%condColors(3,:);
%axes(pC)

sct=findobj(pC,'Type','scatter');
delete(sct(5:6))
sct(1).MarkerFaceColor=colorTransitions(2,:);
sct(2).MarkerFaceColor=colorTransitions(1,:);
sct(3).SizeData=100;
sct(4).SizeData=100;
txt=findobj(pC,'Type','text');
txt(1).String='Adaptive (O2)';
txt(1).Color=colorTransitions(2,:);
txt(1).Position(1:2)=[-.2 1.15];
txt(4).Position([1:2])=[1.1 .12];
txt(4).String='Short exposure';
txt(4).String='{\Delta}EMG_{off(+)}^{short}';
txt(2).String={'Environment';'dependent (O1)'};
txt(2).Color=colorTransitions(1,:);
txt(2).Position(1:2)=[.1 -.03];
txt(3).String='{\Delta}EMG_{off(+)}^{long}';
txt(3).Position(1:2)=[.2 .75];
set(txt,'Fontsize',10,'FontWeight','normal')
txt(1).FontSize=8;
txt(2).FontSize=8;
pC.XLim=[-.3 1.5];
pC.YLim=[-.2 1.2];
pC.XAxis.Color=colorTransitions(1,:);
pC.YAxis.Color=colorTransitions(2,:);
text(-.65,-.7,['{\Delta}EMG_{off(+)} = \beta_{adapt} {\Delta}EMG_{on(' char(8211) ')} ' char(8211) '\beta_{no-adapt} {\Delta}EMG_{on(+)}'],'Clipping','off','Fontsize',9)

%% Add mid hip positions
f1=openfig('../intfig/all/kin/fig/mHIP2ANK_all_15strides.fig');
resizeFigure(f1,1/2.5)
p1=findobj(f1,'Type','Axes');
pD=copyobj(p1(6),fB);
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
%% HIP Position

pD.Position=[.6 .12 .3 .23];
pD.FontSize=12;
pD.FontWeight='normal';
pD.Title.String={'KINEMATIC CHANGE'};
pD.Title.String='';
pD.Title.FontSize=10;
pD.YTick=[-100 0 100];
pD.YLim=[-100 100];

axes(pD)
hold on

plot([.01 .49]*240,105*[1 1],'LineWidth',3,'Color',legColors(1,:),'Clipping','off')
text(.15*240,130,{'  FAST'; 'STANCE'},'FontWeight','normal','Fontsize',8,'Color',legColors(1,:))
plot((.5+[0.01 .49])*240,105*[1 1],'LineWidth',3,'Color',legColors(2,:),'Clipping','off')
text(.65*240,130,{'  SLOW'; 'STANCE'},'FontWeight','normal','Fontsize',8,'Color',legColors(2,:))
%legend(ll)
pD.YAxis.FontSize=10;
pD.XAxis.FontSize=12;
drawnow
pause(1)
pD.YTick=[-80:40:80];
pD.YTickLabel={'80','40','0','-40','-80'};
pD.YDir='reverse';
pD.YLabel.String={'\Delta HIP';'A-P position [mm]'};
pD.YLabel.Position(1)=pD.YLabel.Position(1)+5;
pD.YLabel.Position(2)=pD.YLabel.Position(2);%-25;
pD.YLabel.FontSize=8;
pD.YAxis.FontSize=8;
%pD.XTickLabel={'fHS','sTO','sHS','fTO'};
pD.XTickLabel='';

drawnow
axes(pD)
pp=pD.Position;
pD.FontName='OpenSans';
pt=findobj(pD,'Type','Patch');
delete(ln)
delete(pt(1))
set(ll([2,4]),'LineWidth',2);
ll(2).Color=colorTransitions(1,:);
l1=copyobj(ll(2),gca);
ll(2).YData=-ll(2).YData;
l1.XData=fftshift(l1.XData);
l1.Color=colorTransitions(2,:);
ll(4).Color=[0 0 0];
pt(2).FaceColor=.5*ones(1,3);
pt(3).FaceColor=colorTransitions(1,:)*.9;
p1=copyobj(pt(3),gca);
pt(3).YData=-pt(3).YData;
p1.FaceColor=colorTransitions(2,:);
p1.XData=p1.XData([121:240,1:120,361:480,241:360]);
lg=legend([ll([4,2]);l1],{'{\Delta}HIP_{off(+)}^{long}','-{\Delta}HIP_{on(+)}',['{\Delta}HIP_{on(' char(8211) ')}']},'Location','SouthEast');
lg.Position(1:2)=[.78,.225];
lg.Position(4)=lg.Position(4)*1.05;
lg.FontSize=9;
lg.FontName='OpenSans';
lg.Box='on';
%delete(ln)
%delete(pn)
drawnow
pD.Position=pp;
%aa=axis;
%axis([aa(1:3) 150])
%%
set(findobj(fB,'Type','Axes'),'FontName','OpenSans')
set(findobj(fB,'Type','Text'),'FontName','OpenSans')
%saveFig2(fB,'./','Fig4noLetters',1)
export_fig ./Fig4noLetters.png -png -transparent -r600