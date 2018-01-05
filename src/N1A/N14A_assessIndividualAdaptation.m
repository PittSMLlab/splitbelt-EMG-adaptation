%% Load if not calculated
%Check current directory first?

%if (~exist('loadedSub'))||(loadedSub~=sub)
matDataDir='../../paramData';
%matDataDir='S:\Shared\Exp0001\mat';
%% Load adaptation data
if ~exist('adaptData','var') || ~strcmp(adaptData.subData.ID,sub)
    load([matDataDir '/' sub 'Params.mat'],'adaptData');
end

%% Directory to save figs
saveDir=['../../fig/indiv/' sub '/adap/'];
saveDir2=['../../fig/indiv/' sub '/emg/'];
if ~exist(saveDir,'dir')
    if ~exist(saveDir(1:end-5),'dir')
        mkdir(saveDir(1:end-5))
    end
    mkdir(saveDir);
end

%% Define parameters for plots

removeBiasFlag=0;
exemptFirst=5;
exemptLast=5;
numberOfStrides=[20 -40]; %20 for early, 40 for late
conds={'TM base','Adaptation','Washout'};
binwidth=1;
medianFlag=1;
trialMarkerFlag=0;

%% Characterize stride timing at early & late conditions (all)
paramList={'doubleSupportFast','swingTimeFast','doubleSupportSlow','swingTimeSlow','strideTimeSlow'};
monoLSflag=3;
[fh,ph]=adaptData.plotTimeAndBars(paramList,conds,binwidth,trialMarkerFlag,medianFlag,[],numberOfStrides,monoLSflag);
ph(1,1).Title.String=[adaptData.subData.ID ' temp params'];
for j=1:length(paramList)
    ph(j,1).YLabel.FontSize=10;
end
saveFig(fh,saveDir,[adaptData.subData.ID 'TempParams']) 

% %Relative to stride time
for j=1:length(paramList)
    if ~adaptData.data.isaLabel([paramList{j} 'Rel'])
        adaptData=adaptData.addNewParameter([paramList{j} 'Rel'],@(x,y) x./y,{paramList{j},'strideTimeSlow'},{[paramList{j} ' relative to stance time']});
    end
end
[fh,ph]=adaptData.plotTimeAndBars(strcat(paramList,'Rel'),conds,binwidth,trialMarkerFlag,medianFlag,[],numberOfStrides,monoLSflag);
ph(1,1).Title.String=[adaptData.subData.ID ' relative temp params'];
for j=1:length(paramList)
    ph(j,1).YLabel.FontSize=10;
end
saveFig(fh,saveDir,[adaptData.subData.ID 'RelTempParams']) 

%% Plot temporal evolution of some parameters of interest
%% Cadence, speed:

paramList={'cadenceFast','cadenceSlow','equivalentSpeed','singleStanceSpeedSlowAbs','singleStanceSpeedFastAbs','stanceSpeedSlow','stanceSpeedFast','stepSpeedSlow','stepSpeedFast'};
medianFlag=1;
monoLSflag=3;
[fh,ph]=adaptData.plotTimeAndBars(paramList,conds,binwidth,trialMarkerFlag,medianFlag,[],numberOfStrides,monoLSflag);

ph(1,1).Title.String=[adaptData.subData.ID ' speed params'];
for j=1:length(paramList)
    ph(j,1).YLabel.FontSize=10;
end
saveFig(fh,saveDir,[adaptData.subData.ID 'SpeedParams'])   


%% Contribs
suffixList={'','Norm2','P','PNorm'};
paramList={'spatialContribution','stepTimeContribution','velocityContribution','netContribution','velocityAltContribution'};
 M=length(paramList);
 monoLSflag=3;
for i=1:length(suffixList)
    labels=strcat(paramList,suffixList{i});
    [fh,ph]=adaptData.plotTimeAndBars(labels,conds,binwidth,trialMarkerFlag,medianFlag,[],numberOfStrides,monoLSflag);
    ph(1,1).Title.String=[adaptData.subData.ID ' ' suffixList{i} 'Contributions'];
    for j=1:length(paramList)
        ph(j,1).YLabel.String=paramList{j}(1:end-12);
    end
    saveFig(fh,saveDir,[adaptData.subData.ID 'contributions' suffixList{i}])
end



%% Plot temporal evolution of EMG
% for i=1:6
% labsS=adaptData.data.getLabelsThatMatch(['^s.*p' num2str(i) '$']);
% labsF=adaptData.data.getLabelsThatMatch(['^f.*p' num2str(i) '$']);
% h1=adaptData.plotTimeAndBars([labsS; labsF],conds,binwidth,trialMarkerFlag,medianFlag,[],numberOfStrides,monoLSflag);
% saveFig(h1,saveDir2,['EMGp' num2str(i) 'VsStrides'])
% end


%%
%close all
clear adaptData matDataDir saveDir