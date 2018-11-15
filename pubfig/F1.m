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
myFiguresColorMap
%% Panel A: protocol
conditionOffset=[1 51 105 301 801 1101];
dV=nan(1,conditionOffset(end)-1);
for i=1:length(conditionOffset)-1
    dV(conditionOffset(i):conditionOffset(i+1)-1)=mod(i-1,2);
end
v0=1;
V=v0+.333*[1;-1]*dV +[.01;-.01];
V=[.67*[ones(1,100)*1.015;ones(1,100)*.985] V];
ph=subplot(5,1,1);
set(ph,'Position',[leftMargTwoCol+0*btwMargTwoCol .78 2*colWidthTwoCol+1.5*btwMargTwoCol .2],'FontSize',16,'ColorOrder',legColors)
ll=plot([1:size(V,2)]-50,V','LineWidth',4);
ll(1).Color=legColors(1,:);
ll(2).Color=legColors(2,:);
xlabel('STRIDE CYCLES')
ylabel({'BELT'; 'SPEED'})
ph.XLabel.FontWeight='bold';
ph.YTickLabel={'-33%','Mid','+33%'};
ph.YTick=[.667 1 1.333]*v0;
ph.YTickLabelRotation=00;
ph.FontSize=16;
ph.YLabel.FontWeight='bold';
ph.YAxis.FontSize=16;
ph.YLabel.FontSize=18;

%text(-170, 1.55*v0,'A','FontSize',24,'FontWeight','bold','Clipping','off')

%ptc=patch([200 1100 1100 200],[.5 .5 1.5 1.5],.6*ones(1,3),'FaceAlpha',.4,'EdgeColor','None');
%uistack(ptc,'bottom')
%ptc=patch([40 50 50 40],[.5 .5 1.5 1.5],.6*ones(1,3),'FaceAlpha',.4,'EdgeColor','None');
%uistack(ptc,'bottom')

textY=.85*v0;
epochAlpha=.2;
ptWidth=80;
condColors=repmat(.3*ones(1,3),5,1);
condFontSize=16;
text(-48,textY-.05,'SLOW','FontSize',condFontSize,'Clipping','off','Color',condColors(2,:),'FontWeight','bold')
text(63,textY+.58,'(SHORT)','FontSize',condFontSize,'Clipping','off','Color',condColors(2,:),'FontWeight','bold')
text(104,textY+.4,'[10]','FontSize',condFontSize*.75,'Clipping','off','Color',condColors(2,:),'FontWeight','bold')
%ptc=patch(+[0 ptWidth ptWidth 0]+conditionOffset(4),[.5 .5 1.6 1.6],condColors(2,:),'FaceAlpha',epochAlpha,'EdgeColor','None');
%uistack(ptc,'bottom')
%text(condFontSize7,textY+.03,'EarlyA','FontSize',condFontSize,'FontWeight','bold','Color',condColors(2,:))
text(450,textY+.58,'(LONG) ADAPTATION','FontSize',condFontSize,'Clipping','off','Color',condColors(2,:),'FontWeight','bold')
text(515,textY+.4,'[900 STRIDES]','FontSize',condFontSize*.75,'Clipping','off','Color',condColors(2,:),'FontWeight','bold')
%ptc=patch(-[0 ptWidth ptWidth 0]+conditionOffset(4),[.5 .5 1.6 1.6],condColors(1,:),'FaceAlpha',epochAlpha,'EdgeColor','None');
%uistack(ptc,'bottom')
%text(135,textY+.03,'B','FontSize',condFontSize,'FontWeight','bold','Color',condColors(1,:))
text(180,textY+.26,'BASELINE','FontSize',condFontSize,'Clipping','off','Color',condColors(1,:),'FontWeight','bold')
%ptc=patch(-[0 ptWidth ptWidth 0]+conditionOffset(5),[.5 .5 1.6 1.6],condColors(2,:),'FaceAlpha',epochAlpha,'EdgeColor','None');
%uistack(ptc,'bottom')
%text(conditionOffset(5)-140,textY+.03,'LateA','FontSize',condFontSize,'FontWeight','bold','Color',condColors(2,:))
%ptc=patch([0 ptWidth ptWidth 0]+conditionOffset(5),[.5 .5 1.6 1.6],condColors(3,:),'FaceAlpha',epochAlpha,'EdgeColor','None');
%uistack(ptc,'bottom')
%text(conditionOffset(5)+10,textY+.03,'EarlyP','FontSize',condFontSize,'FontWeight','bold','Color',condColors(3,:))
text(880,textY+.26,'POST-ADAP.','FontSize',condFontSize,'Clipping','off','Color',condColors(3,:),'FontWeight','bold')
text(885,textY+.05,'[600 STRIDES]','FontSize',condFontSize*.75,'Clipping','off','Color',condColors(3,:),'FontWeight','bold')

lg=legend(ll,{'DOMINANT (FAST) BELT','NON-DOM. (SLOW) BELT'},'FontSize',condFontSize*.75,'FontWeight','bold','Location','South');
lg.Position=lg.Position-[-.05 .005 0 0];
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
scale=.3;
set(p1d,'FontSize',16);
for i=1:length(p1d)
    p1d(i).Position=p1d(i).Position.*[0 scale 0 scale]+[.8*leftMargTwoCol .1-(k==1)*.35+.32 1.1*colWidthTwoCol 0];
end
axes(p1d(1))
ax=gca;
%ax.YAxisLocation='right';
grid on
ll=findobj(gca,'Type','text');
set(ll,'FontSize',16)
if k==2
    ax.Title.String='SINGLE MUSCLE';
end
aux=diff(ax.YLim);
ax.YLabel.String={'EMG (a.u.)'};
ax.YLabel.FontWeight='bold';
ax.YLabel.Color=legColors(k,:);

end

%% Add Panel D: checkerboard
f1c=open('./fig/Fig1D.fig');
ph=findobj(f1c,'Type','Axes');
p1c=copyobj(ph,fh);
axes(p1c)
figuresColorMap
%map=repmat(mean(map,2),1,3);
set(p1c,'Colormap',flipud(niceMap(condColors(1,:))),'Clim',[0 1])
p1c.Position=p1c.Position.*[0 1 0 1] + [leftMargTwoCol+colWidthTwoCol+btwMargTwoCol -.1 colWidthTwoCol -.1];

cc=colorbar('southoutside');
set(cc,'Ticks',[0 .5 1],'FontSize',16,'FontWeight','bold');
set(cc,'TickLabels',{'0%','50%','100%'});
set(gcf,'Color',ones(1,3))
cc.Limits=[0 1];
cc.Position=cc.Position+[.08 -.085 -.02 0];
title('BASELINE ACTIVITY')
ax=gca;
%ax.Title.Color=condColors(1,:);
for i=1:length(ax.YTickLabel)
    if i<16
        aux=strcat(num2str(legColors(1,:)'),',')';       
    else
        aux=strcat(num2str(legColors(2,:)'),',')';     
        aux=aux(2:end);
    end
    %ax.YTickLabel{i}=['\color[rgb]{' aux(1:end-1) '} ' ax.YTickLabel{i}];
    ax.YTickLabel{i}=regexprep(ax.YTickLabel{i},'\{.*\}',['\{' aux(1:end-1) '\}']);
    ax.YAxis.Label.FontSize=8;
end
text(-.3, 31,'C','FontSize',24,'FontWeight','bold','Clipping','off')
text(-1.8, 31,'B','FontSize',24,'FontWeight','bold','Clipping','off')
text(-1.8, 43,'A','FontSize',24,'FontWeight','bold','Clipping','off')


tt=findobj(gca,'Type','Text','String','SLOW/NON-DOM');
tt.String='NON-DOMINANT';
tt.Position=tt.Position+[0 0 0];
tt.FontWeight='bold';
tt.Color=legColors(2,:);
tt=findobj(gca,'Type','Text','String','FAST/DOMINANT');
tt.String='DOMINANT';
tt.Position=tt.Position+[0 2 0];
tt.FontWeight='bold';
tt.Color=legColors(1,:);
p1c.YAxis.FontSize=12;
ll=findobj(gca,'Type','Line','Color',ax.ColorOrder(1,:));
set(ll,'Color',legColors(1,:));
close(f1c)


%% Save fig
fh.PaperPosition
resizeFigure(fh,1/2.5)
fh.PaperPosition
saveFig(fh,'./',name,0)
