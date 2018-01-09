error('Deprecated') %All this is done in N11
%% Basics
clearvars -except sub* expData rawExpData

%% Start diary
matDataDir='../../../rawData/synergies/mat/';
%matDataDir='S:\Shared\Exp0001\mat'; %This works in main lab PC 2
%matDataDir='Z:\Shared\Exp0001\mat'; %This works in lab laptop
diaryFileName=[sub '_N13.log'];
diary([matDataDir diaryFileName])

%% Some aux variables:
possibleNames={{'OG base','OG','OG base ','OG '},{'TM slow','TM base slow','slow'},{'mid','TM mid','TM med', 'TM base med','TM base mid','TM base mid 1', 'TM base med 1'},{'short exp','short split','Short Exposure'},{'fast','TM fast'},{'Baseline','TM base','base','TM base med 2','TM base mid 2','TM base (mid)'},{'Adap','Adapt','Adaptation','adaptation '},{'Wash','Post-','TM post','Washout','Post-Adaptation','post-adap','Washout 1','TM washout'},{'OG post','OG wash','OG Postadap'},{'uphill mid','uphill mild','mid uphill','uphill low'},{'uphill steep','big uphill','uphill high'}};
newNames={'OG Base','TM slow','TM mid','Short exposure','TM fast','TM base','Adaptation','Washout','OG post','Uphill mid','Uphill steep'};

%% Load
if ~exist('expData','var') || ~strcmp(expData.subData.ID,sub)
    fprintf('Loading subject data...');tic
    expData=loadProcessed(sub,[matDataDir]);
    fprintf('done! ');toc
end

%% Recompute:
    fprintf('Recomputing parameters...'); tic
    expData=expData.flushAndRecomputeParameters; %This forces parameters to be computed again, useful if some big change happened
    %expData=expData.process; %This reprocesses from scratch, including recomputation of events
    expData.metaData=expData.metaData.replaceConditionNames(possibleNames,newNames);
    fprintf('done! ');toc
    
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

%% Save
fprintf('Saving parameter object...'); tic
save([matDataDir '/' sub 'Params.mat'],'adaptData','-v7.3');
clear adaptData
fprintf('done! '); toc

warning('N13: NOT saving subject data')
%fprintf('Saving subject data...');tic
%save([matDataDir '/' sub '.mat'],'expData','-v7.3');
%fprintf('done! ');toc

%%
diary off