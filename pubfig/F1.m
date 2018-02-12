%%
%This script generates the METHODS figure (Fig1)
%%
run ./F1C.m
run ./F1D.m
%Requires F1C.m and F1D.m to be run BEFORE
%%
name='Fig1';
fh=figure('Name',name,'Units','Normalized','OuterPosition',[0 0 .55 1]);
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
text(207,textY,'eA','FontSize',20,'FontWeight','bold','Color',condColors(2,:))
text(250,textY+.6,'ADAPTATION (900 strides)','FontSize',20,'Clipping','off','Color',condColors(2,:),'FontWeight','bold')
ptc=patch(-[0 ptWidth ptWidth 0]+conditionOffset(4),[.5 .5 1.6 1.6],condColors(1,:),'FaceAlpha',epochAlpha,'EdgeColor','None');
uistack(ptc,'bottom')
text(135,textY,'B','FontSize',20,'FontWeight','bold','Color',condColors(1,:))
text(80,textY+.6,'BASE.','FontSize',20,'Clipping','off','Color',condColors(1,:),'FontWeight','bold')
ptc=patch(-[0 ptWidth ptWidth 0]+conditionOffset(5),[.5 .5 1.6 1.6],condColors(2,:),'FaceAlpha',epochAlpha,'EdgeColor','None');
uistack(ptc,'bottom')
text(conditionOffset(5)-70,textY,'lA','FontSize',20,'FontWeight','bold','Color',condColors(2,:))
ptc=patch([0 ptWidth ptWidth 0]+conditionOffset(5),[.5 .5 1.6 1.6],condColors(3,:),'FaceAlpha',epochAlpha,'EdgeColor','None');
uistack(ptc,'bottom')
text(conditionOffset(5)+10,textY,'eP','FontSize',20,'FontWeight','bold','Color',condColors(3,:))
text(830,textY+.5,{'POST-ADAP.'; '(600 strides)'},'FontSize',20,'Clipping','off','Color',condColors(3,:),'FontWeight','bold')

legend(ll,{'Dominant (fast) belt','Non-dom (slow) belt'},'FontSize',14,'FontWeight','bold','Location','South')
set(ph,'XTick','')
%ph.XLabel.Position=ph.XLabel.Position-[300 0 0];
axis([1 conditionOffset(end) .5 1.55])
saveFig(fh,'./','Fig1A',0)
%% Panel B:
ph=subplot(5,2,5);

set(ph,'Position',[.07 .4 .4 .28],'FontSize',16)
axis([-.7 1.2 -.5 1])
grid on
ph.XTick=0;
ph.YTick=0;
ph.GridAlpha=.7;
text(-.9, 1.2,'B','FontSize',24,'FontWeight','bold','Clipping','off')
B=[0;0];
eA=[.7;.6];
eAT=eA.*[1;-.7];
lA=[.15;.5];
eP1=lA-eA;
eP2=lA+eAT;
eP3=lA-.1*(eAT-eA);
dd=[B eA lA];
hold on
pp=plot(dd(1,:),dd(2,:),'o','MarkerSize',14,'Color',condColors(2,:));
set(pp,'MarkerFaceColor',pp.Color);
text(B(1)+.05,B(2)-.1,'Baseline','FontSize',20,'Color',condColors(1,:),'FontWeight','bold')
text(eA(1)+.05,eA(2)+.1,{'early';'Adapt.'},'FontSize',20,'Color',pp.Color,'FontWeight','bold')
text(lA(1)-.5,lA(2)+.15,{'late';'Adapt.'},'FontSize',20,'Color',pp.Color,'FontWeight','bold')
dd1=[eP1 eP2 eP3];
plot(dd(1,1:2),dd(2,1:2),'--','LineWidth',4,'Color','k');
plot(dd(1,2:3),dd(2,2:3),'-','LineWidth',4,'Color',pp.Color);
plot([lA(1) eP1(1)],[lA(2) eP1(2)],'--','LineWidth',4,'Color','k');
plot([lA(1) eP2(1)],[lA(2) eP2(2)],'--','LineWidth',4,'Color','k');
plot([lA(1) eP3(1)],[lA(2) eP3(2)],'--','LineWidth',4,'Color','k');
pp1=plot(dd1(1,:),dd1(2,:),'o','MarkerSize',14,'Color',condColors(3,:));
set(pp1,'MarkerFaceColor',pp1.Color);
text(eP1(1)+.05,eP1(2)-.1,'eP_{2}','FontSize',20,'Color',pp1.Color,'FontWeight','bold','Interpreter','tex')
text(eP2(1)+.05,eP2(2)-.1,'eP_{3}','FontSize',20,'Color',pp1.Color,'FontWeight','bold','Interpreter','tex')
text(eP3(1)+.05,eP3(2)+.1,'eP_{1}','FontSize',20,'Color',pp1.Color,'FontWeight','bold','Interpreter','tex')


pp=plot(dd(1,2:end),dd(2,2:end),'o','MarkerSize',14,'Color',condColors(2,:));
set(pp,'MarkerFaceColor',pp.Color);
pp=plot(dd(1,1),dd(2,1),'o','MarkerSize',14,'Color',condColors(1,:));
set(pp,'MarkerFaceColor',pp.Color);
xlabel('PC 1')
ylabel('PC 2')
ax=gca;
ax.YTickLabel={};
ax.XTickLabel={};
ax.YLabel.FontWeight='bold';
ax.XLabel.FontWeight='bold';
title('ADAPTATION IN MUSCLE SPACE')
%% Add Panel C
f1c=open('./fig/Fig1C.fig');
ph=findobj(f1c,'Type','Axes');
p1c=copyobj(ph,fh);
axes(p1c)
figuresColorMap
%map=repmat(mean(map,2),1,3);
colormap(flipud(map))
caxis([-1 1])
p1c.Position=p1c.Position + [.5 -.1 0 -.1];

cc=colorbar('southoutside');
set(cc,'Ticks',[0 .5 1],'FontSize',16,'FontWeight','bold');
set(cc,'TickLabels',{'0%','50%','100%'});
set(gcf,'Color',ones(1,3))
cc.Limits=[0 1];
cc.Position=cc.Position+[.08 .01 -.02 0];
title('BASELINE MUSCLE ACTIVITY')
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
%% Add Panel D
f1d=open('./fig/Fig1D.fig');
ph=findobj(f1d,'Type','Axes');
p1d=copyobj(ph,fh);
axes(p1d(2))
figuresColorMap
mm=.1;
map=1- (1- [mm:.01:1,1:-.01:mm]') *(1-condColors(1,:));
colormap(flipud(map))
caxis([-1 1])
scale=.35;
for i=1:length(p1d)
    p1d(i).Position=p1d(i).Position.*[1 .3 1 scale]+[.02 0 0 0];
end
axes(p1d(1))
text(-.1*p1d(1).XAxis.Limits(2), 1.3*p1d(1).YAxis.Limits(2),'C','FontSize',24,'FontWeight','bold','Clipping','off')
ll=findobj(gca,'Type','Line');
ll(end).Color=condColors(1,:);
ll2=findobj(gca,'Type','Patch');
ll2.FaceColor=condColors(1,:);
title('REPRESENTATIVE MUSCLE')
ax=gca;
ax.YLabel.String={'DOMINANT LG'; 'EMG (a.u.)'};
ax.YLabel.FontWeight='bold';
ax.YLabel.Color=ax.ColorOrder(1,:);
ax.Title.String='SINGLE MUSCLE ACTIVITY';
%lg=legend(ll(end),'BASELINE');
%% Save fig
saveFig(fh,'./',name,0)
