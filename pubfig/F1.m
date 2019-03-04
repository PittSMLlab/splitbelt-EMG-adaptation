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
fh=figure('Name',name,'Units',figUnits,'InnerPosition',figPosThreeCols,'PaperUnits',paperUnits,'PaperPosition',paperPositionThreeCols,'PaperSize',paperPositionThreeCols(3:4));
heightFactor=1.4;
fh.InnerPosition(4)=fh.InnerPosition(4)*heightFactor; %taller
fh.PaperPosition(4)=fh.PaperPosition(4)*heightFactor; %taller
fh.PaperSize(2)=fh.PaperSize(2)*heightFactor; %taller
myFiguresColorMap
fName='OpenSans';
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
set(ph,'Position',[leftMargThreeCol+0*btwMargThreeCol .8 3*colWidthThreeCol+2.5*btwMargThreeCol .18],'FontSize',16,'ColorOrder',legColors)
ll=plot([1:size(V,2)]-50,V','LineWidth',4);
ll(1).Color=legColors(1,:);
ll(2).Color=legColors(2,:);
xlabel('Stride cycles')
ylabel('Belt speed')
%ph.XLabel.FontWeight='bold';
ph.YTickLabel={'-33%','Med.','+33%'};
ph.YTick=[.667 1 1.333]*v0;
ph.YTickLabelRotation=00;
ph.FontSize=8;
%ph.YLabel.FontWeight='bold';
ph.YAxis.FontSize=8;
ph.YLabel.FontSize=10;
%ph.YLabel.Position(2)=ph.YLabel.Position(2)-.0001;

%text(-170, 1.55*v0,'A','FontSize',24,'FontWeight','bold','Clipping','off')

%ptc=patch([200 1100 1100 200],[.5 .5 1.5 1.5],.6*ones(1,3),'FaceAlpha',.4,'EdgeColor','None');
%uistack(ptc,'bottom')
%ptc=patch([40 50 50 40],[.5 .5 1.5 1.5],.6*ones(1,3),'FaceAlpha',.4,'EdgeColor','None');
%uistack(ptc,'bottom')

textY=.85*v0;
epochAlpha=.2;
ptWidth=50;
condColors=repmat(.3*ones(1,3),5,1);
condFontSize=10;
fw='normal';
text(-45,textY-.05,'SLOW','FontSize',condFontSize,'Clipping','off','Color',condColors(2,:),'FontWeight',fw)
text(80,textY+.62,'SHORT','FontSize',condFontSize,'Clipping','off','Color',condColors(2,:),'FontWeight',fw)
text(104.5,textY+.38,'[10]','FontSize',condFontSize*.75,'Clipping','off','Color',condColors(2,:),'FontWeight',fw)
ptc=patch([0 ptWidth ptWidth 0]+conditionOffset(3),[.51 .51 1.6 1.6],.8*ones(1,3),'FaceAlpha',1,'EdgeColor','None');
uistack(ptc,'bottom')
ptcw=patch([5 .9*ptWidth .9*ptWidth 5]-1000,[.55 .55 1.55 1.55],1*ones(1,3),'FaceAlpha',epochAlpha,'EdgeColor','k');
uistack(ptc,'bottom')
%text(condFontSize7,textY+.03,'EarlyA','FontSize',condFontSize,'FontWeight',fw,'Color',condColors(2,:))
text(480,textY+.62,'LONG EXPOSURE','FontSize',condFontSize,'Clipping','off','Color',condColors(2,:),'FontWeight',fw)
text(520,textY+.38,'[900 STRIDES]','FontSize',condFontSize*.75,'Clipping','off','Color',condColors(2,:),'FontWeight',fw)
ptc=patch(500*[0 1 1 0]+conditionOffset(4)+ptWidth,[.51 .51 1.6 1.6],.8*ones(1,3),'FaceAlpha',1,'EdgeColor','None');
uistack(ptc,'bottom')
%text(135,textY+.03,'B','FontSize',condFontSize,'FontWeight',fw,'Color',condColors(1,:))
text(180,textY+.28,'BASELINE','FontSize',condFontSize,'Clipping','off','Color',condColors(1,:),'FontWeight',fw)
%ptc=patch(-[0 ptWidth ptWidth 0]+conditionOffset(5),[.5 .5 1.6 1.6],condColors(2,:),'FaceAlpha',epochAlpha,'EdgeColor','None');
%uistack(ptc,'bottom')
%text(conditionOffset(5)-140,textY+.03,'LateA','FontSize',condFontSize,'FontWeight',fw,'Color',condColors(2,:))
%ptc=patch([0 ptWidth ptWidth 0]+conditionOffset(5),[.5 .5 1.6 1.6],condColors(3,:),'FaceAlpha',epochAlpha,'EdgeColor','None');
%uistack(ptc,'bottom')
%text(conditionOffset(5)+10,textY+.03,'EarlyP','FontSize',condFontSize,'FontWeight',fw,'Color',condColors(3,:))
text(900,textY+.28,'WASHOUT','FontSize',condFontSize,'Clipping','off','Color',condColors(3,:),'FontWeight',fw)
%text(885,textY+.04,'[600 STRIDES]','FontSize',condFontSize*.75,'Clipping','off','Color',condColors(3,:),'FontWeight',fw)

lg=legend([ll' ptcw ptc],{'DOMINANT LEG','NON-DOM. LEG','tied','split (+)'},'FontSize',condFontSize*.75,'FontWeight',fw,'Location','South','NumColumns',2);
lg.Position=lg.Position-[-.05 .005 0 0];
set(ph,'XTick','')
%ph.XLabel.Position=ph.XLabel.Position-[300 0 0];
axis([-50 conditionOffset(end) .5 1.55])
ph.Box='off';
%saveFig(fh,'./','Fig1A',0)
%% Panel B: EMG samples
for k=1:2
    f1d=open(['./fig/Fig1B_' num2str(k) '.fig']);
    resizeFigure(f1d,.5)
    ph=findobj(f1d,'Type','Axes');
    p1d=copyobj(ph,fh);
    for i=1:length(p1d)
        p1d(i).Colormap=ph(i).Colormap;
    end
    scale=.3;
    set(p1d,'FontSize',8);
    for i=1:length(p1d)
        p1d(i).Position=p1d(i).Position.*[0 scale 0 scale]+[leftMargThreeCol+colWidthThreeCol+1.3*btwMargThreeCol .1-(k==1)*.3+.32 1.1*colWidthThreeCol 0];
        ll=findobj(p1d(i),'Type','text');
        set(ll,'FontSize',12)
        for kk=1:length(ll)
            ll(kk).Position(1)=ll(kk).Position(1)-.2;
        end
    end
    axes(p1d(1))
    ax=gca;
    %ax.YAxisLocation='right';
    grid on
    ll=findobj(ax,'Type','text');
    set(ll,'FontSize',8)
    ll=findobj(ax,'Type','Line');
    ll(end-1).LineStyle='-.';
    ll(end-1).Color=ll(end).Color;
    pt=findobj(ax,'Type','Patch');
    pt(2).FaceAlpha=.7;
    pt(1).FaceAlpha=.6;
    if k==2
        ax.Title.String='SINGLE MUSCLE ACTIVITY';
        lg=legend(ll(end-1:end),{'early Long','Base.'},'Location','NorthEast');
        lg.Box='off';
        lg.Position(1)=lg.Position(1)+.02;
        lg.Position(2)=lg.Position(2)+.012;
    end
    aux=diff(ax.YLim);
    ax.YLabel.String={'EMG (a.u.)'};
    ax.YLabel.String='';
    ax.YLabel.FontWeight='bold';
    ax.YLabel.Color=legColors(k,:);
    txt=findobj(p1d,'Type','Text');
    set(txt,'FontSize',8)
    
    txt=findobj(p1d,'Type','Text','String',{'STANCE'});
    txt.Position(1)=txt.Position(1)-4;
    set(txt,'String','SINGLE')
    txt=findobj(p1d,'Type','Text','String',{'SWING'});
    txt.Position(1)=txt.Position(1)-3;
    
    txt=findobj(p1d,'Type','Text','String','Baseline');
    txt.Position(1)=txt.Position(1)-.5;
    txt.FontSize=6;
    txt=findobj(p1d,'Type','Text','String','Early Adapt.');
    txt.Position(1)=txt.Position(1)-.5;
    txt.String='early Long';
    txt.FontSize=6;
    txt=findobj(p1d,'Type','Text','String','Difference');
    txt.Position(1)=txt.Position(1)-1;
    txt.Position(2)=txt.Position(2)+.5;
    txt.String={'Difference';'{\Delta}EMG_{on (+)}'};
    txt.FontSize=6;
end

%% Add Panel C: baseline checkerboard
f1c=open('./fig/Fig1D.fig');
resizeFigure(f1c,.5)
ph=findobj(f1c,'Type','Axes');
p1c=copyobj(ph,fh);
axes(p1c)
set(p1c,'Colormap',flipud(niceMap(condColors(1,:))),'Clim',[0 1])
p1c.Position=p1c.Position.*[0 1 0 1.2*1/heightFactor] + [leftMargThreeCol+0*colWidthThreeCol+0*btwMargThreeCol -.05 colWidthThreeCol -.05];

cc=colorbar('southoutside');
set(cc,'Ticks',[0 .5 1],'FontSize',8,'FontWeight','normal');
set(cc,'TickLabels',{'0%','50%','100%'});
set(gcf,'Color',ones(1,3))
cc.Limits=[0 1];
cc.Position=cc.Position+[.08 -.11 -.02 -.01];
title('ALL BASELINE ACTIVITY')
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
text(-.4, 31,'B','FontSize',16,'FontWeight','bold','Clipping','off')
%text(-1.8, 31,'B','FontSize',24,'FontWeight','bold','Clipping','off')
text(-.4, 45.5,'A','FontSize',16,'FontWeight','bold','Clipping','off')

p1c.YAxis.FontSize=8;
tt=findobj(gca,'Type','Text','String','SLOW/NON-DOM');
tt.String='  NON-DOMINANT';
tt.Position=tt.Position+[-.02 .5 0];
tt.FontWeight='normal';
tt.Color=legColors(2,:);
tt=findobj(gca,'Type','Text','String','FAST/DOMINANT');
tt.String=' DOMINANT';
tt.Position=tt.Position+[-.02 2 0];
tt.FontWeight='normal';
tt.Color=legColors(1,:);

tt=findobj(gca,'Type','Text','String','EXTENSORS');
tt.FontSize=8;
tt=findobj(gca,'Type','Text','String','FLEXORS');
tt.FontSize=8;

ll=findobj(gca,'Type','Line','Color',ax.ColorOrder(1,:));
set(ll,'Color',legColors(1,:));
ll=findobj(gca,'Type','Line','Color',zeros(1,3));
for i=1:length(ll)
   if ll(i).YData(1)<0
      ll(i).YData=ll(i).YData+.1; 
   end
end
p1c.XRuler.Axle.LineStyle = 'none';  
p1c.YRuler.Axle.LineStyle = 'none';
set(gca, 'TickLength',[0 0])
close(f1c)

%% Panel D: \Delta EMG up
fA=openfig('./fig/Fig2A.fig');
%resizeFigure(fA,.5)
axA=findobj(fA,'Type','Axes');
Clim=.5;
myFiguresColorMap
p1c=copyobj(axA,fh);
set(p1c,'Colormap',flipud(map),'Clim',.5*[-1 1])
p1c.Position=p1c.Position.*[0 1 0 1.2*1/heightFactor] + [leftMargThreeCol+2*colWidthThreeCol+2.25*btwMargThreeCol -.05 colWidthThreeCol -.05];
axes(p1c)
cc=colorbar('southoutside');
set(cc,'Ticks',[-.5 0 .5],'FontSize',8,'FontWeight','normal');
set(cc,'TickLabels',{'-50%','0%','+50%'});
set(gcf,'Color',ones(1,3))
cc.Limits=.5*[-1 1];
cc.Position=cc.Position+[.05 -.11 -.02 -.01];
ax=gca;
%ax.Title.Color=condColors(1,:);
for i=1:length(ax.YTickLabel)
    if i<16
        aux=strcat(num2str(legColors(1,:)'),',')';       
    else
        aux=strcat(num2str(legColors(2,:)'),',')';     
        aux=aux(2:end);
    end
    ax.YTickLabel{i}=regexprep(ax.YTickLabel{i},'\{.*\}',['\{' aux(1:end-1) '\}']);
    ax.YAxis.Label.FontSize=8;
end
p1c.YAxis.FontSize=8;
title({'{\Delta}EMG_{on(+)}'; '( = early Long - Baseline)'})
tt=findobj(gca,'Type','Text','String','SLOW/NON-DOM');
%tt.String='NON-DOMINANT';
tt.Position=tt.Position+[-.02 .5 0];
tt.FontWeight='normal';
tt.Color=legColors(2,:);
tt=findobj(gca,'Type','Text','String','FAST/DOMINANT');
%tt.String='DOMINANT';
tt.Position=tt.Position+[-.02 .5 0];
tt.FontWeight='normal';
tt.Color=legColors(1,:);
tt=findobj(gca,'Type','Text','String','FLEXORS');
delete(tt)
tt=findobj(gca,'Type','Text','String','EXTENSORS');
delete(tt)
ll=findobj(gca,'Type','Line');
delete(ll(1:4))
ll=findobj(gca,'Type','Line');
delete(ll(13:14))
ll=findobj(gca,'Type','Line','Color',ax.ColorOrder(1,:));
set(ll,'Color',legColors(1,:));
ll=findobj(gca,'Type','Line','Color',zeros(1,3));
for i=1:length(ll)
   if ll(i).YData(1)<0
      ll(i).YData=ll(i).YData+.1; 
   end
end
legend off
p1c.XRuler.Axle.LineStyle = 'none';  
p1c.YRuler.Axle.LineStyle = 'none';
pl=plot3([-.1 1.2],[15 15],[6 6],'k','LineWidth',1,'Clipping','off');
set(gca, 'TickLength',[0 0])
%% Save fig
txt=findobj(gcf,'Type','Text');
set(txt,'FontName',fName);
ax=findobj(gcf,'Type','Axes');
set(ax,'FontName',fName);
for i=1:length(ax)
    ax(i).Title.FontWeight='normal';
end
  saveFig2(fh,'./',name,0)
