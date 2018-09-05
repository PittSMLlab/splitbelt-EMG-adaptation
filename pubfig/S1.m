%% 
%This script generates the checkerboards with late Adaptation (steady-state) and early Post-adaptation (aftereffects)
addpath(genpath('./auxFun/'))
%% Get panels from existing figure and make pretty:
saveDir='./';
name='allChangesEMG.fig';
desiredPlotDescription={'vEarly A[1]';'early A5[5]'; 'early A[15]'};
plotTitles={'earlyA 1','earlyA 2-6','earlyA 2-16'};
saveName='FigS1';
lineFlag=0;
makeN19DPrettyAgain_execute
fB=gcf;

%% Add some details:
threePanelArrange

%%
saveFig(fB,'./','FigS1',1)

%% Get panels from existing figure and make pretty:
saveDir='./';
name='allChangesEMG.fig';
desiredPlotDescription={'vEarly P[1]';'early P5[5]'; 'early P[15]'};
plotTitles={'earlyP 1','earlyP 2-6','earlyP 2-16'};
saveName='FigS1';
lineFlag=0;
makeN19DPrettyAgain_execute
fB=gcf;

%% Add some details:
threePanelArrange
%%
saveFig(fB,'./','FigS2',1)