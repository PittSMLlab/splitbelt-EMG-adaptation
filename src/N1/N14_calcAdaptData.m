%% Basics
clearvars -except sub* expData rawExpData

%% Start diary
matDataDir='../../matData/';
matDataDir='S:\Shared\Exp0001\mat'; %This works in main lab PC 2
%matDataDir='Z:\Shared\Exp0001\mat'; %This works in lab laptop
diaryFileName=[sub '_N14.log'];
diary([matDataDir diaryFileName])

%% Load processed data
if ~exist('expData','var') || ~strcmp(expData.subData.ID,sub)
    expData=loadProcessed(sub,matDataDir);
end

%% Create adaptation Data object
adaptData = expData.makeDataObj;

%% Save:
save([matDataDir '/' sub 'Params.mat'],'adaptData','-v7.3');
clear adaptData

%%
diary off