%From makeN19DPrettyAgain
saveDir='./';
name='allChangesEMGswSlows.fig';
desiredPlotDescription={'(c)','Slow',''};
desiredPlotDescription2=[];
plotTitles={'Controls' };
saveName='Fig2S';
lineFlag=0;
makeN19DPrettyAgain_execute
f1=gcf;
f2=openfig('./Fig2SB.fig');
f3=openfig('./Fig2SC.fig');
%% Panel A
set(f1,'Color',ones(1,3),'Position',get(f1,'Position').*[1 1 0 0]+[0 0 .57 .75]);
ax=findobj(f1,'Type','axes');
set(ax,'Position',get(ax,'Position').*[1 1 1.1 1.1] + [0 .33 0 0])
tt=findobj(f1,'Type','Text');
axes(ax)
title('')
ax=findobj(f1,'Type','Axes');
set(ax,'YLim',[0 15])
ax.Position=ax.Position.*[ 1 1 1 .5];
%Switch top and bottom parts:
ss=findobj(f1,'Type','Surface');
ss.CData([1:15],:)=ss.CData([17:31],:);
ss.CData(16,:)=0;
ss.CData(17:32,:)=[];
ss.ZData(17:32,:)=[];
ss.YData(:,17:32)=[];
colorbar('off')
idx=strcmp(get(tt,'String'),'SLOW/PARETIC');
set(tt(idx),'String','SLOW/NON-DOM','Position',get(tt(strcmp(get(tt,'String'),'FAST/NON-PARETIC')),'Position'))
delete(tt(strcmp(get(tt,'String'),'FAST/NON-PARETIC')))
%delete(tt)
ll=findobj(f1,'Type','Line');
set(ll(end-5),'Color',tt(idx).Color)
pp=findobj(f1,'Type','patch');
uistack(pp,'top')
set(pp,'Color',ones(1,3));
set(gca,'YTick',.5:1:15)
for i=1:length(ll)
    if all(ll(i).YData>15) %|| all(ll(i).YData<-1)
        delete(ll(i))
    elseif any(ll(i).YData>15)
        idx=ll(i).YData>15;
        ll(i).XData(idx)=[];
        ll(i).YData(idx)=[];
        ll(i).ZData(idx)=[];
    elseif  all(ll(i).YData<-1)
        set(ll(i),'XData',get(ll(i),'XData')-.5)
        set(ll(i),'YData',get(ll(i),'YData')-4)
    end
end
tt=findobj(ax,'Type','Text');
for i=1:length(tt)
    if tt(i).Position(2)>15 %|| tt(i).Position(2)<-1
        delete(tt(i))
    elseif  tt(i).Position(2)<-1
        set(tt(i),'Position',get(tt(i),'Position')+[-.5 -4 0])
    end
end
text(-0.2, 16, 'A','FontSize',24,'FontWeight','bold','Clipping','off')
figuresColorMap
colormap(flipud(map))
title('Slow Tied Walking')
tt=findobj(ax,'Type','text','String','SLOW/NON-DOM');
tt.String='SLOW/NON-DOM LEG';
ll2=findobj(ax,'Type','line','LineWidth',4);
delete(ll2)
ax.XTick=[];
%% Panel B
ax2=findobj(f2,'Type','axes');
ph=copyobj(ax2,f1);
set(ph,'Position',ax.Position+[0 -.46 0 0])
ph.Title.String='';
axes(ph)
text(-0.2, 16, 'B','FontSize',24,'FontWeight','bold','Clipping','off')
title('Late Adaptation Symm.')
ll2=findobj(ph,'Type','line','LineWidth',10);
delete(ll2(7:8))
tt=findobj(ph,'Type','text','String','EXTENSORS');
delete(tt)
tt=findobj(ph,'Type','text','String','FLEXORS');
delete(tt)
colorbar('off')
tt=findobj(ph,'Type','text','String','FAST - SLOW DIFFERENCE');
tt.String='     FAST - SLOW DIFF.';

%% Panel C
ax3=findobj(f3,'Type','axes');
ph3=copyobj(ax3,f1);
set(ph3,'Position',ax.Position.*[1 1 1 2]+[.49 -.387 0 0])
axes(ph3)
text(-0.2, 32, 'C','FontSize',24,'FontWeight','bold','Clipping','off')
ll2=findobj(ph3,'Type','line','LineWidth',10);
for i=[length(ll2)+[-1:0]];
    ll2(i).XData=ll2(i).XData-.1;
    ll2(i).YData=ll2(i).YData+.5;
end
tt=findobj(ph3,'Type','text','String','EXTENSORS');
tt.Position=tt.Position-[.1 -.5 0];
tt=findobj(ph3,'Type','text','String','FLEXORS');
tt.Position=tt.Position-[.1 -.5 0];
cc=colorbar('southoutside');
cc.Ticks=[-.5 0 .5];
cc.TickLabels={'-50%','No change','+50%'};
cc.Position=cc.Position.*[1 1 1 .8]+[-.1 .01 0 0];
%%
saveFig(newFig,saveDir,saveName,0)