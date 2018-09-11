%C01 is a behavioral outlier
load('../data/HPF30/groupedParams_wMissingParameters');

%% Kinematic outlier
fh=controls.plotAvgTimeCourse({'netContributionNorm2'},{'TM base','Adaptation','Washout'},31,[],1,[],[],[],[],[],1);
set(fh,'Units','Normalized','Position',[0 .4 1 .6]);
ll=findobj(fh,'Type','Line');
set(ll,'Color',.6*[1 1 1]);
ll=findobj(fh,'Type','Line','Tag','C0001');
uistack(ll,'top')
set(ll,'Color','r','LineWidth',1,'DisplayName','S01')
legend(ll(1))
ax=gca;
ax.Position=[.1 .1 .8 .8];
ll=findobj(fh,'Type','Line','Marker','o');
set(ll,'LineStyle','-','Marker','none','LineWidth',4,'Color',[0 0 0]);

ax.YLabel.String='Step-length asymmetry';
ax.YLabel.Position(1)=ax.YLabel.Position(1)-20;
ax.XTickLabel={'Base','Adaptation','Post-Adaptation'};
ax.FontName='Open Sans';
ax.FontName='Helvetica';
saveFig(fh,'./','FigS3red',1)

%% EMG outlier: (for first 5, not so much in first 15)
set(fh,'Units','Normalized','Position',[0 0 1 1]);
ax.Position=[.1 .7 .8 .25];
load(['../data/controlsEMGsummary']) 
load ../data/bioData.mat
write=true;


%%
meA=median(eA,2); %Average eA activity across subject
meP=median(eP,2); %Average eA activity across subject
mlA=median(lA,2);
c1=eA'*meA./(sqrt(sum(eA.^2,1)')*sqrt(sum(meA.^2)));
c2=eP'*meP./(sqrt(sum(eP.^2,1)')*sqrt(sum(meP.^2)));
c3=lA'*mlA./(sqrt(sum(lA.^2,1)')*sqrt(sum(mlA.^2)));

%figure
subplot(3,3,4) %plotting norms
scatter(35,sqrt(sum(meA.^2)),120,'filled','k')
hold on
scatter(age,sqrt(sum(eA.^2,1)),20,'filled','k')
scatter(age(1),sqrt(sum(eA(:,1).^2,1)),20,'filled','r')
title('||eA||')
subplot(3,3,7) %Plotting cosines
scatter(age,c1,20,'filled','k')
hold on
scatter(age(1),c1(1),20,'filled','r')
title('cos(eA,<eA>)')
subplot(3,3,5) %plotting norms
scatter(35,sqrt(sum(meP.^2)),120,'filled','k')
hold on
scatter(age,sqrt(sum(eP.^2,1)),20,'filled','k')
hold on
scatter(age(1),sqrt(sum(eP(:,1).^2,1)),20,'filled','r')
title('||eP||')
subplot(3,3,8) %Plotting cosines
scatter(age,c2,20,'filled','k')
hold on
scatter(age(1),c2(1),20,'filled','r')
title('cos(eP,<eP>)')
subplot(3,3,6) %plotting norms
scatter(35,sqrt(sum(mlA.^2)),120,'filled','k')
hold on
scatter(age,sqrt(sum(lA.^2,1)),20,'filled','k')
hold on
scatter(age(1),sqrt(sum(lA(:,1).^2,1)),20,'filled','r')
title('||lA||')
subplot(3,3,9) %Plotting cosines
scatter(age,c3,20,'filled','k')
hold on
scatter(age(1),c3(1),20,'filled','r')
title('cos(lA,<lA>)')
%%
saveFig(fh,'./','FigS3',1)