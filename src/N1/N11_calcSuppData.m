%% processing of data
clearvars -except sub* rawExpData

%% Start diary
matDataDir='../../matData/';
matDataDir='Z:\Shared\Exp0001\mat\'; %This works in lab laptop
matDataDir='S:\Shared\Exp0001\mat'; %This works in main lab PC 2
diaryFileName=[sub '_N11.log'];
diary([matDataDir diaryFileName])

%% load sub raw data
disp('Loading data...')
if ~exist('rawExpData','var') || ~strcmp(rawExpData.subData.ID,sub)
    rawExpData=loadRaw(sub,matDataDir);
end
disp('Success!')
%% Process 
disp('Processing...')
expData=process(rawExpData);
disp('Success!')
%% -------------Save this supplemental data----------------------
disp('Saving data...')
eval(['save ' matDataDir '/' sub '.mat expData -v7.3']);
disp('Success! ')
%% 
diary off
