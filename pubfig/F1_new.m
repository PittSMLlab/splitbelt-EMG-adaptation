%%
%This script generates the METHODS figure (Fig1)
%
%run ./F1B.m
%run ./F1C.m
%run ./F1D.m
%Requires F1C.m and F1D.m to be run BEFORE
close all
clear all
%%
addpath(genpath('./auxFun/'));
figSize
name='Fig1';
fh=figure('Name',name,'Units',figUnits,'InnerPosition',figPosTwoCols,'PaperUnits',paperUnits,'PaperPosition',paperPositionTwoCols,'PaperSize',paperPositionTwoCols(3:4));
fh.OuterPosition(4)=fh.OuterPosition(4)*1.1; %taller
figuresColorMap
%% Panel A: protocol
conditionOffset=[1 41 61 301 801 1101];
dV=nan(1,conditionOffset(end)-1);
for i=1:length(conditionOffset)-1
    dV(conditionOffset(i):conditionOffset(i+1)-1)=mod(i-1,2);
end
v0=1;
V=v0+.333*[1;-1]*dV +[.01;-.01];
V=[.67*[ones(1,50)*1.015;ones(1,50)*.985] V];
ph=subplot(5,1,1);
set(ph,'Position',[leftMarg*3/2+.4*btwMarg*3/2 .78 2*colWidth*3/2+1*btwMarg*3/2 .2],'FontSize',8)
ll=plot([1:size(V,2)]-50,V','LineWidth',2);
xlabel('STRIDE CYCLES')
ylabel({'BELT'; 'SPEED'})
ph.XLabel.FontWeight='bold';
ph.YTickLabel={'-33%','Mid','+33%'};
ph.YTick=[.667 1 1.333]*v0;
ph.YTickLabelRotation=00;
ph.FontSize=8;
ph.YLabel.FontWeight='bold';
ph.YAxis.FontSize=8;
ph.YLabel.FontSize=9;

%text(-170, 1.55*v0,'A','FontSize',24,'FontWeight','bold','Clipping','off')

%ptc=patch([200 1100 1100 200],[.5 .5 1.5 1.5],.6*ones(1,3),'FaceAlpha',.4,'EdgeColor','None');
%uistack(ptc,'bottom')
%ptc=patch([40 50 50 40],[.5 .5 1.5 1.5],.6*ones(1,3),'FaceAlpha',.4,'EdgeColor','None');
%uistack(ptc,'bottom')

textY=.85*v0;
epochAlpha=.2;
ptWidth=500;
ptc=patch([0 ptWidth ptWidth 0]+conditionOffset(4),[.5 .5 1.6 1.6],condColors(2,:),'FaceAlpha',epochAlpha,'EdgeColor','None');
uistack(ptc,'bottom')
text(307,textY+.03,'EarlyA','FontSize',8,'FontWeight','bold','Color',condColors(2,:))
text(405,textY+.58,'ADAPTATION','FontSize',8,'Clipping','off','Color',condColors(2,:),'FontWeight','bold')
text(420,textY+.4,'(900 STRIDES)','FontSize',8,'Clipping','off','Color',condColors(2,:),'FontWeight','bold')
ptWidth=240;
ptc=patch(-[0 ptWidth ptWidth 0]+conditionOffset(4),[.5 .5 1.6 1.6],condColors(1,:),'FaceAlpha',epochAlpha,'EdgeColor','None');
uistack(ptc,'bottom')
text(235,textY+.03,'B','FontSize',8,'FontWeight','bold','Color',condColors(1,:))
text(70,textY+.3,{'BASELINE'},'FontSize',8,'Clipping','off','Color',condColors(1,:),'FontWeight','bold')
%ptc=patch(-[0 ptWidth ptWidth 0]+conditionOffset(5),[.5 .5 1.6 1.6],condColors(2,:),'FaceAlpha',epochAlpha,'EdgeColor','None');
uistack(ptc,'bottom')
text(conditionOffset(5)-140,textY+.03,'LateA','FontSize',8,'FontWeight','bold','Color',condColors(2,:))
ptWidth=300;
ptc=patch([0 ptWidth ptWidth 0]+conditionOffset(5),[.5 .5 1.6 1.6],condColors(3,:),'FaceAlpha',epochAlpha,'EdgeColor','None');
uistack(ptc,'bottom')
text(conditionOffset(5)+10,textY+.03,'EarlyP','FontSize',8,'FontWeight','bold','Color',condColors(3,:))
text(830,textY+.58,'POST-ADAP.','FontSize',8,'Clipping','off','Color',condColors(3,:),'FontWeight','bold')
text(825,textY+.4,'(600 STRIDES)','FontSize',8,'Clipping','off','Color',condColors(3,:),'FontWeight','bold')

ptWidth=21;
ptc=patch(+[0 ptWidth ptWidth 0]+40,[.5 .5 1.6 1.6],condColors(4,:),'FaceAlpha',epochAlpha,'EdgeColor','None');
text(25,textY+.6,{'SE'},'FontSize',8,'Clipping','off','Color',condColors(4,:),'FontWeight','bold')


lg=legend(ll,{'DOMINANT (FAST) BELT','NON-DOM. (SLOW) BELT'},'FontSize',6,'FontWeight','bold','Location','South');
lg.Position=lg.Position-[-.01 .005 0 0];
set(ph,'XTick','')
%ph.XLabel.Position=ph.XLabel.Position-[300 0 0];
axis([-50 conditionOffset(end) .5 1.55])
ph.Box='off';
%saveFig(fh,'./','Fig1A',0)
%% Panel B: EMG samples
for k=1:2
f1d=open(['./fig/Fig1B_' num2str(k) '.fig']);
ph=findobj(f1d,'Type','Axes');
p1d=copyobj(ph,fh);
for i=1:length(p1d)
    p1d(i).Colormap=ph(i).Colormap;
end
figuresColorMap
scale=.2;
for i=1:length(p1d)
    p1d(i).Position=p1d(i).Position.*[0 scale 0 scale]+[leftMarg*3/2 .2-(k==1)*.18+.32+(i>1)*.02 1.1*colWidth*3/2 0];
end
axes(p1d(1))
ax=gca;
ll=findobj(gca,'Type','text');
if k==2
    delete(ll) %Deleting DS,STANCE,DS,SWING labels for top panel
    text(-.2*p1d(1).XAxis.Limits(2), 1.3*p1d(1).YAxis.Limits(2),'B','FontSize',12,'FontWeight','bold','Clipping','off')
    text(-.2*p1d(1).XAxis.Limits(2), 1.3*p1d(1).YAxis.Limits(2)+4e-4,'A','FontSize',12,'FontWeight','bold','Clipping','off')
    text(-.2*p1d(1).XAxis.Limits(2), 1.3*p1d(1).YAxis.Limits(2)-7.3e-4,'C','FontSize',12,'FontWeight','bold','Clipping','off')
    ax.Title.String='SINGLE MUSCLE';
else
     for i=1:length(ll)
        ll(i).Position=ll(i).Position-[0 7.5e-5 0];
    end
end
ll=findobj(gca,'Type','Line');
ll(end).Color=condColors(1,:);
ll2=findobj(gca,'Type','Patch');
for i=1:length(ll2)
ll2(i).FaceColor=condColors(i,:);
end
if k==2
        delete(ll(1:end-2))
else
    for i=1:length(ll)-2
        ll(i).YData=ll(i).YData-7e-5;
    end
end


ax.YLabel.String={'EMG';'(a.u.)'};
ax.YLabel.FontWeight='bold';
ax.YLabel.Color=ax.ColorOrder(k,:);
ax.FontSize=8;
end

%% Add Panel D: checkerboard
f1c=open('./fig/Fig1D.fig');
ph=findobj(f1c,'Type','Axes');
p1c=copyobj(ph,fh);
axes(p1c)
figuresColorMap
%map=repmat(mean(map,2),1,3);
set(p1c,'Colormap',flipud(niceMap(condColors(1,:))),'Clim',[0 1])
p1c.Position=p1c.Position.*[0 1 0 1] + [leftMarg*3/2+colWidth*3/2+btwMarg*3/2 -.1 colWidth -.1];

cc=colorbar('southoutside');
set(cc,'Ticks',[0 .5 1],'FontSize',8,'FontWeight','bold');
set(cc,'TickLabels',{'0%','50%','100%'});
set(gcf,'Color',ones(1,3))
cc.Limits=[0 1];
cc.Position=cc.Position+[.05 .01 -.02 0];
title('BASELINE ACTIVITY')
ax=gca;
ax.FontSize=8;
%ax.Title.Color=condColors(1,:);
for i=1:length(ax.YTickLabel)
    if i<16
    ax.YTickLabel{i}=['\color[rgb]{0,0.447,0.741} ' ax.YTickLabel{i}];
    else
        ax.YTickLabel{i}=['\color[rgb]{0.85,0.325,0.098} ' ax.YTickLabel{i}];
    end
end
text(-.3, 31,'D','FontSize',12,'FontWeight','bold','Clipping','off')

tt=findobj(gca,'Type','Text','String','SLOW/NON-DOM');
tt.String='NON-DOMINANT';
tt.Position=tt.Position+[0 0 0];
tt.FontWeight='bold';
tt.FontSize=10;
tt=findobj(gca,'Type','Text','String','FAST/DOMINANT');
tt.String='DOMINANT';
tt.Position=tt.Position+[0 2 0];
tt.FontWeight='bold';
tt.FontSize=10;
p1c.YAxis.FontSize=6;
tt=findobj(gca,'Type','Text');
for i=1:length(tt)
    set(tt(i),'FontSize',ceil(get(tt(i),'FontSize')/3))
end
tt=findobj(gca,'Type','Line');
for i=1:length(tt)
    set(tt(i),'LineWidth',ceil(get(tt(i),'LineWidth')/3))
end
close(f1c)
%% Add Panel C
% f1c=open('./fig/Fig1C.fig');
% ph=findobj(f1c,'Type','Axes');
% p1d=copyobj(ph,fh);
% close(f1c)
% scaleX=1;
% scaleY=.3;
% for i=1:length(p1d)
%     p1d(i).Position=p1d(i).Position.*[scaleX scaleY scaleX scaleY]+[.02 0 0 0];
% end
figuresColorMap;    
auxF=[0;.35;-.3];
auxS=[-.35;.35;.2];
for k=1:4
    switch k
        case 1 %eA
            aux1=auxF;
            aux2=auxS;
            tt='';
tt2='EarlyA';
        case 2
            tt='C1';
            aux1=zeros(size(auxF));
            aux2=zeros(size(auxS));
tt2='0';
        case 3
            tt='C2';
            aux1=-auxF;
            aux2=-auxS;
tt2='-EarlyA';
        case 4
            tt='C3';
            aux1=auxS;
            aux2=auxF;
tt2='EarlyA^*';
    end
ax=axes;
ax.Position=[(.01*leftMarg+(k-1)*.05+(k>1)*.03)*3/2 .03 1.1*colWidth*3/2 .1];
I=imshow(size(map,1)*(aux1+.5),flipud(map),'Border','tight');
rectangle('Position',[.5 .5 1 3],'EdgeColor','k')
%%Add arrows
hold on
quiver(ones(size(aux1)),[1:numel(aux1)]'+.4*sign(aux1),zeros(size(aux1)),-.7*sign(aux1),0,'Color','k','LineWidth',2,'MaxHeadSize',.5)
ax=axes;
ax.Position=[.01*leftMarg+(k-1)*.05+(k>1)*.03 .14 1.1*colWidth .1];
I=imshow(size(map,1)*(aux2+.5),flipud(map),'Border','tight');
rectangle('Position',[.5 .5 1 3],'EdgeColor','k')
%%Add arrows
hold on
quiver(ones(size(aux1)),[1:numel(aux1)]'+.4*sign(aux2),zeros(size(aux1)),-.7*sign(aux2),0,'Color','k','LineWidth',2,'MaxHeadSize',.5)

set(gca,'XTickLabel','','YTickLabel','','XTick','','YTick','')
text(-.1+(k==2)*.8+(k==3)*-.3,0,tt2,'Clipping','off','FontSize',6,'FontWeight','bold')
text(.6,7.2,tt,'Clipping','off','FontSize',6,'FontWeight','bold')
if k==1
    for j=1:3
        text(1.7,j,['m' num2str(j)],'Clipping','off','FontSize',6,'FontWeight','bold')
        text(1.7,j+3.3,['m' num2str(j)],'Clipping','off','FontSize',6,'FontWeight','bold')
    end

end

end

text(-2.5,-1.5,'CASES','Clipping','off','FontSize',6,'FontWeight','bold')
text(-3.4,-.9,'EarlyP-LateA=','Clipping','off','FontSize',6,'FontWeight','bold')
plot([-4.5 1.5],-.6*[1 1],'k','LineWidth',2,'Clipping','off')
%plot(-4*[1 1],[.5 7],'k','LineWidth',1,'Clipping','off')

%Add lines on fast/slow:
ccc=get(gca,'ColorOrder');
plot(-9.*[1 1],[.5 3.5],'LineWidth',4,'Color',ccc(2,:),'Clipping','off')
text(-9.5,3.7,'NON-DOM','Color',ccc(2,:),'Rotation',90,'FontSize',6,'FontWeight','bold')
plot(-9*[1 1],3.3+[.5 3.5],'LineWidth',4,'Color',ccc(1,:),'Clipping','off')
text(-9.5,6.25,'DOM','Color',ccc(1,:),'Rotation',90,'FontSize',6,'FontWeight','bold')


%% Save fig
%saveFig(fh,'./',name,0)
