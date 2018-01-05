
%% Basics
clearvars -except sub* expData rawExpData

%% Start diary
matDataDir='../../matData';
matDataDir='S:\Shared\Exp0001\mat'; %This works in main lab PC 2
%matDataDir='Z:\Shared\Exp0001\mat'; %This works in lab laptop
diaryFileName=[sub '_N13.log'];
diary([matDataDir diaryFileName])

%% Load
if ~exist('expData','var') || ~strcmp(expData.subData.ID,sub)
    expData=loadProcessed(sub,[matDataDir]);
end

%% Recompute:
expData=expData.recomputeParameters; %This forces parameters to be computed again, useful if some big change 

%% Save
save([matDataDir '/' sub '.mat'],'expData','-v7.3');

%%
diary off