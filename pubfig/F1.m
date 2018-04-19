%%
%This script generates the METHODS figure (Fig1)
%
%run ./F1B.m
%run ./F1C.m
%run ./F1D.m
%Requires F1C.m and F1D.m to be run BEFORE
%%
name='Fig1';
fh=figure('Name',name,'Units','Normalized','OuterPosition',[0 0 .45 1]);
figuresColorMap
%% Panel A: protocol
conditionOffset=[1 41 61 201 801 1101];
dV=nan(1,conditionOffset(end)-1);
for i=1:length(conditionOffset)-1
    dV(conditionOffset(i):conditionOffset(i+1)-1)=mod(i-1,2);
end
v0=1;
V=v0+.333*[1;-1]*dV +[.01;-.01];
ph=subplot(5,1,1);
set(ph,'Position',[.15 .78 .8 .2],'FontSize',16)
ll=plot(V','LineWidth',4);
xlabel('STRIDE CYCLES')
ylabel('BELT SPEED')
ph.XLabel.FontWeight='bold';
ph.YTickLabel={'-33%','select','Self','+33%'};
ph.YTick=[.667 .95 1.05 1.333]*v0;
ph.YTickLabelRotation=0;
ph.FontSize=16;
ph.YLabel.FontWeight='bold';

text(-170, 1.55*v0,'A','FontSize',24,'FontWeight','bold','Clipping','off')

%ptc=patch([200 1100 1100 200],[.5 .5 1.5 1.5],.6*ones(1,3),'FaceAlpha',.4,'EdgeColor','None');
%uistack(ptc,'bottom')
%ptc=patch([40 50 50 40],[.5 .5 1.5 1.5],.6*ones(1,3),'FaceAlpha',.4,'EdgeColor','None');
%uistack(ptc,'bottom')

textY=.85*v0;
epochAlpha=.2;
ptWidth=80;
ptc=patch(+[0 ptWidth ptWidth 0]+conditionOffset(4),[.5 .5 1.6 1.6],condColors(2,:),'FaceAlpha',epochAlpha,'EdgeColor','None');
uistack(ptc,'bottom')
text(207,textY+.03,'eA','FontSize',20,'FontWeight','bold','Color',condColors(2,:))
text(330,textY+.58,'ADAPTATION','FontSize',20,'Clipping','off','Color',condColors(2,:),'FontWeight','bold')
text(345,textY+.4,'(900 STRIDES)','FontSize',16,'Clipping','off','Color',condColors(2,:),'FontWeight','bold')
ptc=patch(-[0 ptWidth ptWidth 0]+conditionOffset(4),[.5 .5 1.6 1.6],condColors(1,:),'FaceAlpha',epochAlpha,'EdgeColor','None');
uistack(ptc,'bottom')
text(135,textY+.03,'B','FontSize',20,'FontWeight','bold','Color',condColors(1,:))
text(70,textY+.58,'BASE.','FontSize',20,'Clipping','off','Color',condColors(1,:),'FontWeight','bold')
ptc=patch(-[0 ptWidth ptWidth 0]+conditionOffset(5),[.5 .5 1.6 1.6],condColors(2,:),'FaceAlpha',epochAlpha,'EdgeColor','None');
uistack(ptc,'bottom')
text(conditionOffset(5)-70,textY+.03,'lA','FontSize',20,'FontWeight','bold','Color',condColors(2,:))
ptc=patch([0 ptWidth ptWidth 0]+conditionOffset(5),[.5 .5 1.6 1.6],condColors(3,:),'FaceAlpha',epochAlpha,'EdgeColor','None');
uistack(ptc,'bottom')
text(conditionOffset(5)+10,textY+.03,'eP','FontSize',20,'FontWeight','bold','Color',condColors(3,:))
text(810,textY+.58,'POST-ADAP.','FontSize',20,'Clipping','off','Color',condColors(3,:),'FontWeight','bold')
text(815,textY+.4,'(600 STRIDES)','FontSize',16,'Clipping','off','Color',condColors(3,:),'FontWeight','bold')

lg=legend(ll,{'DOMINANT (FAST) BELT','NON-DOM. (SLOW) BELT'},'FontSize',12,'FontWeight','bold','Location','South');
lg.Position=lg.Position-[.03 .005 0 0];
set(ph,'XTick','')
%ph.XLabel.Position=ph.XLabel.Position-[300 0 0];
axis([1 conditionOffset(end) .5 1.55])
saveFig(fh,'./','Fig1A',0)
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
    p1d(i).Position=p1d(i).Position.*[1 scale 1 scale]+[.02 (k-1)*.2+.32 0 0];
end
axes(p1d(1))
ax=gca;
if k==2
    ll=findobj(gca,'Type','text');
delete(ll)
text(-.2*p1d(1).XAxis.Limits(2), 1.3*p1d(1).YAxis.Limits(2),'B','FontSize',24,'FontWeight','bold','Clipping','off')
text(-.2*p1d(1).XAxis.Limits(2), 1.3*p1d(1).YAxis.Limits(2)-7.3e-4,'C','FontSize',24,'FontWeight','bold','Clipping','off')
ax.Title.String='SINGLE MUSCLE';

end
ll=findobj(gca,'Type','Line');
ll(end).Color=condColors(1,:);
ll2=findobj(gca,'Type','Patch');
for i=1:length(ll2)
ll2(i).FaceColor=condColors(i,:);
end


ax.YLabel.String={'EMG';'(a.u.)'};
ax.YLabel.FontWeight='bold';
ax.YLabel.Color=ax.ColorOrder(k,:);

end

%% Add Panel D: checkerboard
f1c=open('./fig/Fig1D.fig');
ph=findobj(f1c,'Type','Axes');
p1c=copyobj(ph,fh);
axes(p1c)
figuresColorMap
%map=repmat(mean(map,2),1,3);
set(p1c,'Colormap',flipud(niceMap(condColors(1,:))),'Clim',[0 1])
p1c.Position=p1c.Position + [.48 -.1 0.02 -.1];

cc=colorbar('southoutside');
set(cc,'Ticks',[0 .5 1],'FontSize',16,'FontWeight','bold');
set(cc,'TickLabels',{'0%','50%','100%'});
set(gcf,'Color',ones(1,3))
cc.Limits=[0 1];
cc.Position=cc.Position+[.08 .01 -.02 0];
title('BASELINE ACTIVITY')
ax=gca;
%ax.Title.Color=condColors(1,:);
for i=1:length(ax.YTickLabel)
    if i<16
    ax.YTickLabel{i}=['\color[rgb]{0,0.447,0.741} ' ax.YTickLabel{i}];
    else
        ax.YTickLabel{i}=['\color[rgb]{0.85,0.325,0.098} ' ax.YTickLabel{i}];
    end
end
text(-.3, 31,'D','FontSize',24,'FontWeight','bold','Clipping','off')

tt=findobj(gca,'Type','Text','String','SLOW/NON-DOM');
tt.String='NON-DOMINANT';
tt.Position=tt.Position+[0 0 0];
tt.FontWeight='bold';
tt=findobj(gca,'Type','Text','String','FAST/DOMINANT');
tt.String='DOMINANT';
tt.Position=tt.Position+[0 2 0];
tt.FontWeight='bold';
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
tt2='eA_B';
        case 2
            tt='H1';
            aux1=zeros(size(auxF));
            aux2=zeros(size(auxS));
tt2='0';
        case 3
            tt='H2';
            aux1=-auxF;
            aux2=-auxS;
tt2='-eA_B';
        case 4
            tt='H3';
            aux1=auxS;
            aux2=auxF;
tt2='eA_B^*';
    end
ax=axes;
ax.Position=[.02+(k-1)*.075+(k>1)*.06 .03 .2 .1];
I=imshow(size(map,1)*(aux1+.5),flipud(map),'Border','tight');
rectangle('Position',[.5 .5 1 3],'EdgeColor','k')
%%Add arrows
hold on
quiver(ones(size(aux1)),[1:numel(aux1)]'+.4*sign(aux1),zeros(size(aux1)),-.7*sign(aux1),0,'Color','k','LineWidth',2,'MaxHeadSize',.5)
ax=axes;
ax.Position=[.02+(k-1)*.075+(k>1)*.06 .14 .2 .1];
I=imshow(size(map,1)*(aux2+.5),flipud(map),'Border','tight');
rectangle('Position',[.5 .5 1 3],'EdgeColor','k')
%%Add arrows
hold on
quiver(ones(size(aux1)),[1:numel(aux1)]'+.4*sign(aux2),zeros(size(aux1)),-.7*sign(aux2),0,'Color','k','LineWidth',2,'MaxHeadSize',.5)

set(gca,'XTickLabel','','YTickLabel','','XTick','','YTick','')
text(.4+(k==2)*.3+(k==3)*-.1,0,tt2,'Clipping','off','FontSize',14,'FontWeight','bold')
text(.6,7.2,tt,'Clipping','off','FontSize',14,'FontWeight','bold')
if k==1
    for j=1:3
        text(1.7,j,['m' num2str(j)],'Clipping','off','FontSize',14,'FontWeight','bold')
        text(1.7,j+3.3,['m' num2str(j)],'Clipping','off','FontSize',14,'FontWeight','bold')
    end

end

end

text(-3,-1.5,'HYPOTHESES','Clipping','off','FontSize',14,'FontWeight','bold')
text(-1.8,-.9,'eP-lA=','Clipping','off','FontSize',14,'FontWeight','bold')
plot([-3.5 1.5],-.6*[1 1],'k','LineWidth',2,'Clipping','off')
%plot(-4*[1 1],[.5 7],'k','LineWidth',1,'Clipping','off')

%Add lines on fast/slow:
ccc=get(gca,'ColorOrder');
plot(-7.5*[1 1],[.5 3.5],'LineWidth',4,'Color',ccc(2,:),'Clipping','off')
text(-8,3.55,'NON-DOM','Color',ccc(2,:),'Rotation',90,'FontSize',14,'FontWeight','bold')
plot(-7.5*[1 1],3.3+[.5 3.5],'LineWidth',4,'Color',ccc(1,:),'Clipping','off')
text(-8,6.25,'DOM','Color',ccc(1,:),'Rotation',90,'FontSize',14,'FontWeight','bold')


%% Save fig
saveFig(fh,'./',name,0)
