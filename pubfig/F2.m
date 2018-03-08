%% 
%This script generates the FEEDBACK activity figure

%% Run scripts for each panel (if needed):
%run ./F2A.m
%run ./F2B.m

%% Arrange panels in single fig:
close all
fA=openfig('./fig/Fig2A.fig');
axA=findobj(fA,'Type','Axes');

fh=figure('Units','Normalized','OuterPosition',[0 0 .53 .9],'Color','None');
condColors=[.6,.6,.6; 0,.5,.4; .5,0,.6];
figuresColorMap
colormap(flipud(map))
Clim=.5;
pA=copyobj(axA,fh);
for i=1:length(pA)
    axes(pA(i))
    title('')
    tt=findobj(pA(i),'Type','Text');
    for j=1:length(tt)
        set(tt(j),'FontSize',16,'Position',get(tt(j),'Position')-[0 0 0])
    end
    %set(pA(i),'Position',get(pA(i),'Position').*[1.05 .3 1 .26] + [.03 .71 0 0]);
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
title('Muscle activity modulation')
ax=gca;
%ax.Title.Color=condColors(1,:);
for i=1:length(ax.YTickLabel)
    if i<16
        ax.YTickLabel{i}=['\color[rgb]{0,0.447,0.741} ' ax.YTickLabel{i}];
    else
        ax.YTickLabel{i}=['\color[rgb]{0.85,0.325,0.098} ' ax.YTickLabel{i}];
    end
end
text(-.2, 32.5,'C','FontSize',24,'FontWeight','bold','Clipping','off')
text(-1.9, 32.5,'A','FontSize',24,'FontWeight','bold','Clipping','off')
text(-1.9, 13,'B','FontSize',24,'FontWeight','bold','Clipping','off')
ax.Position(1)=ax.Position(1)+.5;

tt=findobj(gca,'Type','Text','String','SLOW/NON-DOM');
tt.String='NON-DOMINANT (SLOW)';
tt.Position=tt.Position+[0 -2.75 0];
tt.FontWeight='bold';
tt=findobj(gca,'Type','Text','String','FAST/DOMINANT');
tt.String='DOMINANT (FAST)';
tt.Position=tt.Position+[0 0 0];
tt.FontWeight='bold';
legend off

%% Panel B
fB=openfig('./fig/F2B.fig');
axB=findobj(fB,'Type','Axes');
pB=copyobj(axB,fh);
close(fB)
axes(pB)
hold on
ll=findobj(pB,'Type','Line');
pp=pB.YLim;
plot([.01 .49]*240,100*[1 1],'LineWidth',6,'Color',[0,.447,.741],'Clipping','off')
text(.05*240,110,{'FAST STANCE'},'FontWeight','bold','Fontsize',12,'Color',[0,.447,.741])
plot((.5+[0.01 .49])*240,100*[1 1],'LineWidth',6,'Color',[0.85,.325,.098],'Clipping','off')
text(.53*240,110,{'SLOW STANCE'},'FontWeight','bold','Fontsize',12,'Color',[0.85,.325,.098])
pB.YLim=pp;
pB.FontSize=14;
pB.FontWeight='bold';
legend(ll)
pB.YAxis.FontSize=10;
pB.XAxis.FontSize=12;
drawnow
pause(1)
pB.Position(1)=.11;
pB.YTick=[-80:40:80];
pB.YTickLabel={'80','40','0','-40','-80'};

%% Panel C: little dude
fC=imread('../intfig/littleGuy.png');
N=size(fC,1);
if mod(N,2)==1
fC=fC(1:N-1,:,:);
N=N-1;
end
fC=cat(2,fC(1:N/2,:,:),255*ones(N/2,50,3),fC(N/2+1:N,:,:));
pC=axes();
pC.Position=[.06 .07 .4 .45];
image(fC)
axis equal
pC.Box='off';
pC.Visible='off';
text(300,1500,{'POSTURAL RESPONSES TO';' DISPLACEMENTS OF COM'},'Clipping','off','Fontsize',12,'FontWeight','bold')

%%
saveFig(fh,'./','Fig2',1)
