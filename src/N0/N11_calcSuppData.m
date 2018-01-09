%% processing of data
clearvars -except sub* rawExpData

%% Start diary
matDataDir='../../../rawData/synergies/mat/';
matDataDir='/DataDump/rawData/Exp0001/matData/raw/';
%matDataDir='Z:\Shared\Exp0001\mat\'; %This works in lab laptop
%matDataDir='S:\Shared\Exp0001\mat'; %This works in main lab PC 2
diaryFileName=[sub '_N11.log'];
diary([matDataDir diaryFileName])

%% Some aux variables:
replacementConditionNames

%% load sub raw data
disp('Loading data...')
if ~exist('rawExpData','var') || ~strcmp(rawExpData.subData.ID,sub)
    rawExpData=loadRaw(sub,matDataDir);
end
disp('Success!')

%% Process 
disp('Processing...')
expData=rawExpData.process;
expData.metaData=expData.metaData.replaceConditionNames(possibleNames,newNames);
disp('Success!')

%Fix issue:
if strcmp(expData.subData.ID,'P0001')
    expData.metaData.conditionName{4}='TM base'; %P01 has bad condition name which confounds with TM mid when it exists.
end
    
%% Generate params file:
fprintf('Generating parameter object...'); tic
adaptData = expData.makeDataObj;
[adaptData.metaData,change]=adaptData.metaData.numerateRepeatedConditionNames; %Enumerate repeated condition names
[adaptData.metaData,change2]=adaptData.metaData.replaceConditionNames(possibleNames,newNames);
fprintf('done! ');toc

%% -------------Save this supplemental data----------------------
fprintf('Saving data...'); tic
eval(['save ' matDataDir '/' sub '.mat expData -v7.3']);
fprintf('done! ');toc

%% Save data object
fprintf('Saving parameter object...'); tic
save([matDataDir '/' sub 'Params.mat'],'adaptData','-v7.3');
clear adaptData
fprintf('done! '); toc
%% 
diary off
