%
saveDir='./';
saveName='F2B';
%% 
fh=openfig('../intfig/all/kin/fig/mHIP2ANK_all_15strides.fig');
phs=findobj(fh,'Type','Axes');
%%
bgColor=.9*ones(1,3); %Default background color
f1=figure('Name',saveName,'Units','Normalized','OuterPosition',[.3 .1 .5 .8],'Color',bgColor);
aux=cell2mat(get(phs,'Position'));
idx=find(aux(:,1)>.25 & aux(:,1)<.5 & aux(:,2)>.1 & aux(:,2)<.66);
p1=copyobj(phs(idx),f1);
close(fh)

%% Make pretty
figuresColorMap
title('Change in relative HIP position')
p1.YDir='reverse';
p1.YLabel.String='HIP A-P pos. (from ANKLE) [mm]';
p1.XTickLabel={'fHS','sTO','sHS','fTO'};
ll=findobj(p1,'Type','Line');
delete(ll(1:end-2))
ll=findobj(p1,'Type','Line');
ll(1).YData(end)=NaN;
ll(1).YData(numel(ll(1).YData)/2)=NaN;
ll(1).Color=condColors(2,:);
ll(2).Color=condColors(1,:);
pp=findobj(p1,'Type','Patch');
delete(pp(3:end))
drawnow
pause(3)
drawnow
p1.Position=[.6 .6 .35 .3];
%% Add FAST STANCE/ SLOW STANCE labels
%%
hold on
phaseDurations=[177 314 135 458]; %Avg. across healthy subjects, during eA (15 strides), starting at FHS
%intervalDurations=[phaseDurations(1)/2 *[1 1], phaseDurations(2)/4*ones(1,4), phaseDurations(3)/2*[1 1], phaseDurations(4)/4*ones(1,4)];
ccc=get(gca,'ColorOrder');
winEdges=90+[0 310]; %300ms response (Chvatal 2012)
%Adding rectangles with respect to FHS:
x=interp1(cumsum([0 phaseDurations]),[0,30,120,150,240],winEdges); %100 to 450ms window
rectHeight=-95+[0 0 175 175 0];
plot3([x fliplr(x) x(1)], rectHeight, 5*ones(1,5),'LineWidth',3,'Color',ccc(1,:) );
%Adding rectangles with respect to SHS:
x=interp1(cumsum([0 fftshift(phaseDurations)]),[0,30,120,150,240],winEdges); %100 to 450ms window
plot3(120+[x fliplr(x) x(1)], rectHeight, 5*ones(1,5),'LineWidth',3,'Color',ccc(2,:) );
%%
legend(ll,'Early Adapt.','Baseline')
%%
saveFig(f1,saveDir,saveName,0)
