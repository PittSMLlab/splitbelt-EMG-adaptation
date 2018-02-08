%
saveDir='./';
saveName='F2B';
%% 
fh=openfig('../intfig/all/fig/mHIP2ANK_all_15strides.fig');
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
legend(ll,'Early Adapt.','Baseline')
ll(1).YData(end)=NaN;
ll(1).YData(numel(ll(1).YData)/2)=NaN;
ll(1).Color=condColors(2,:);
ll(2).Color=condColors(1,:);
ll=findobj(p1,'Type','Patch');
delete(ll(3:end))
drawnow
pause(3)
drawnow
p1.Position=[.6 .6 .35 .3];
%% Add FAST STANCE/ SLOW STANCE labels

%%
saveFig(f1,saveDir,saveName,0)
