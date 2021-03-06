%% 
%This script generates the FEEDBACK activity figure
addpath(genpath('./auxFun/'))
%% Run scripts for each panel (if needed):
%run ./F2A.m
%run ./F2B.m

%% Arrange panels in single fig:
close all
figSize
fA=openfig('./fig/Fig2A.fig');
axA=findobj(fA,'Type','Axes');

fh=figure('Units',figUnits,'OuterPosition',figPos,'Color','None');
figuresColorMap
colormap(flipud(map))
Clim=.5;
%% Panel D:
pA=copyobj(axA,fh);
for i=1:length(pA)
    axes(pA(i))
    title('')
    tt=findobj(pA(i),'Type','Text');
    for j=1:length(tt)
        set(tt(j),'FontSize',16,'Position',get(tt(j),'Position')-[0 0 0])
    end
    pA.Position=[colWidth+leftMarg+btwMarg bottomMarg colWidth colHeight];
    set(pA(i),'Position',get(pA(i),'Position').*[1 1 1 1.15] + [0 -.12 0 0]);
    pA(i).YLabel.FontWeight='bold';
    caxis(Clim*[-1 1])
    if i==1
        ll=findobj(gca,'Type','Line');
        lg=legend(ll(end-1:end));
    end
    lg.Position=lg.Position+[.003 0 0 0];
end

cc=colorbar('southoutside');
set(cc,'Ticks',[-.5 0 .5],'FontSize',16,'FontWeight','bold');
set(cc,'TickLabels',{'-50%','0%','50%'});
set(gcf,'Color',ones(1,3))
%cc.Position=cc.Position+[.08 .01 -.02 0];
title({'EMG CHANGE'; '(FBK_{tied-to-split})'})
ax=gca;
ax.YAxis.FontSize=13;
%ax.Title.Color=condColors(1,:);
for i=1:length(ax.YTickLabel)
    if i<16
        ax.YTickLabel{i}=['\color[rgb]{0,0.447,0.741} ' ax.YTickLabel{i}];
    else
        ax.YTickLabel{i}=['\color[rgb]{0.85,0.325,0.098} ' ax.YTickLabel{i}];
    end
end
text(-.2, 32,'D','FontSize',20,'FontWeight','bold','Clipping','off')
text(-1.8, 32,'A','FontSize',20,'FontWeight','bold','Clipping','off')
text(-1.8, 23.5,'B','FontSize',20,'FontWeight','bold','Clipping','off')
text(-1.8, 7.5,'C','FontSize',20,'FontWeight','bold','Clipping','off')
%ax.Position(1)=ax.Position(1)+.5;

tt=findobj(gca,'Type','Text','String','SLOW/NON-DOM');
tt.String='NON-DOMINANT (SLOW)';
tt.Position=tt.Position+[0 -2 0];
tt.FontWeight='bold';
tt=findobj(gca,'Type','Text','String','FAST/DOMINANT');
tt.String='DOMINANT (FAST)';
tt.Position=tt.Position+[0 -.1 0];
tt.FontWeight='bold';
legend off
pl=plot3([-.1 1.2],[15 15],[6 6],'k','LineWidth',1,'Clipping','off');

%% Panel A:
fB=openfig('./fig/Fig1A.fig');
axA=findobj(fB,'Type','Axes');

pA=copyobj(axA,fh);
pA.Position=[leftMarg bottomMarg+1.6*midColHeight+midColMargin colWidth .4*midColHeight];
ax=pA;
axes(pA)
tt=findobj(gca,'Type','text');
delete(tt([1,2,5,7,8]))
tt=findobj(gca,'Type','text');
set(tt,'FontWeight','bold','Clipping','on')
for j=1:length(tt)
   tt(j).Position=tt(j).Position+[10 .3 0]; 
end
aa=axis;
axis([110+[55,345] aa(3:4)])
ax.YTick=[];
ax.XLabel.String='';
    ax.YLabel.String='';
    title({'TIED-TO-SPLIT TRANSITION';'CHANGE IN BELT SPEEDS'})
    ax.Title.FontSize=16;
    ax.YLabel.FontWeight='bold';
    ax.YLabel.String={'SPEED';'[a.u.]'};
    ax.YLabel.FontSize=13;
    ax.Title.Position(2)=ax.Title.Position(2)+.2;
    %text(ax.Title.Position(1)-140,ax.Title.Position(2)-.35,'CHANGE IN BELT SPEEDS','FontWeight','bold','FontName','Helvetica','FontSize',ax.Title.FontSize)

%% Panel B
fB=openfig('./fig/F2B.fig');
axB=findobj(fB,'Type','Axes');
pB=copyobj(axB,fh);
close(fB)
axes(pB)
hold on
ll=findobj(pB,'Type','Line');
pp=pB.YLim;
plot([.01 .49]*240,155*[1 1],'LineWidth',6,'Color',[0,.447,.741],'Clipping','off')
text(.05*240,168,{'FAST STANCE'},'FontWeight','bold','Fontsize',12,'Color',[0,.447,.741])
plot((.5+[0.01 .49])*240,155*[1 1],'LineWidth',6,'Color',[0.85,.325,.098],'Clipping','off')
text(.54*240,168,{'SLOW STANCE'},'FontWeight','bold','Fontsize',12,'Color',[0.85,.325,.098])
pB.YLim=pp;
pB.FontSize=14;
pB.FontWeight='bold';
legend(ll)
pB.YAxis.FontSize=12;
pB.YLabel.FontSize=13;
pB.XAxis.FontSize=12;
drawnow
pause(1)
pB.YTick=[-80:40:80];
pB.YTickLabel={'80','40','0','-40','-80'};
pB.YAxis.Label.String='A-P POSITION [mm]';
title('KINEMATIC CHANGE')
ll=findobj(gca,'Type','Line');

pB.Position=[leftMarg bottomMarg+.58*midColHeight+midColMargin colWidth .8*midColHeight];

%Add arrows and fwd/bwd text
aa=axis;
text(265,60,'BACK','Rotation',90,'Clipping','off','FontWeight','bold','FontSize',12);
quiver(250,5,0,70,'Color','k','Clipping','off','LineWidth',3,'AutoScale','off','MarkerSize',5,'MaxHeadSize',.5)
text(265,-15,'FRONT','Rotation',90,'Clipping','off','FontWeight','bold','FontSize',12);
quiver(250,-10,0,-70,'Color','k','Clipping','off','LineWidth',3,'AutoScale','off','MarkerSize',5,'MaxHeadSize',.5)
axis([aa(1:2) -100 120])

lg=legend(ll(end-1),{'\Delta HIP TIED-TO-SPLIT'},'Location','South');
%delete(lg)
delete(ll(end))

%% Panel C: little dude
% fC=imread('../intfig/littleGuy.png');
% N=size(fC,1);
% if mod(N,2)==1
% fC=fC(1:N-1,:,:);
% N=N-1;
% end
% fC=cat(2,fC(1:N/2,:,:),255*ones(N/2,50,3),fC(N/2+1:N,:,:));
[fC,alpha,beta]=imread('../intfig/littleGuys2.png');
fC=fC(:,[1:1100,1300:end],:);
%fC=cat(2,fC(1:N/2,:,:),255*ones(N/2,50,3),fC(N/2+1:N,:,:));
pC=axes();
%pC.Position=[.06 .07 .4 .45];
pC.Position=[leftMarg/1.5 bottomMarg-.28 1.35*colWidth 2*midColHeight];
%Trimming figure:
image(fC)
axis equal
pC.Box='off';
pC.Visible='off';
text(450,1500,{'DISPLACEMENT OF COM'},'Clipping','off','Fontsize',12,'FontWeight','bold')

%%
set(findobj(fh,'Type','Axes'),'FontName','Helvetica')
saveFig(fh,'./','Fig2',1)
