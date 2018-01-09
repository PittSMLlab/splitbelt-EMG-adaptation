%% Basics

error('This script has been deprecated, renaming happens automatically in N13 now')
clearvars -except sub* adaptData

%% Start diary
matDataDir='../../paramData/';
%matDataDir='S:\Shared\Exp0001\mat'; %This works in main lab PC 2
%matDataDir='Z:\Shared\Exp0001\mat'; %This works in lab laptop
diaryFileName=[sub '_N16.log'];
diary([matDataDir diaryFileName])
     possibleNames={{'OG base','OG','OG base ','OG '},{'TM slow','TM base slow','slow'},{'mid','TM mid','TM med', 'TM base med','TM base mid','TM base mid 1', 'TM base med 1'},{'short exp','short split','Short Exposure'},{'fast','TM fast'},{'Baseline','TM base','base','TM base med 2','TM base mid 2','TM base (mid)'},{'Adap','Adapt','Adaptation','adaptation '},{'Wash','Post-','TM post','Washout','Post-Adaptation','post-adap','Washout 1','TM washout'},{'OG post','OG wash','OG Postadap'},{'uphill mid','uphill mild','mid uphill','uphill low'},{'uphill steep','big uphill','uphill high'}};
     newNames={'OG Base','TM slow','TM mid','Short exposure','TM fast','TM base','Adaptation','Washout','OG post','Uphill mid','Uphill steep'};

%% Load adaptation data
if ~exist('adaptData','var') || ~strcmp(adaptData.subData.ID,sub)
    load([matDataDir '/' sub 'Params.mat'],'adaptData');
end
if ~exist('expData','var') || ~strcmp(expData.subData.ID,sub)
    %expData=loadProcessed(sub,matDataDir);
end

%% Check if there are repeated names, & ask user(?)
% aaa=unique(adaptData.metaData.conditionName);
% change=false;
% if length(aaa)<length(adaptData.metaData.conditionName) %There are repetitions
%     change=true;
%     for i=1:length(aaa)
%         aux=find(strcmpi(aaa{i},adaptData.metaData.conditionName));
%         if length(aux)>1
%             disp(['Found a repeated condition name ' aaa{i} ' on sub ' sub '.'])
%            for j=1:length(aux)
%               aaux{j}=adaptData.metaData.trialsInCondition{aux(j)} ;
%               disp(['Occurrence ' num2str(j) ' contains trials ' num2str(aaux{j}) '.'])
%               ss=input(['Please input a new name for this condition: ']);
%               adaptData.metaData.conditionName{aux(j)}=ss;
%            end
%             
%         end
%     end
%     expData.metaData.conditionName=adaptData.metaData.conditionName;
% end
       

%% Change names
[adaptData.metaData,change]=adaptData.metaData.numerateRepeatedConditionNames; %Enumerate repeated condition names
[adaptData.metaData,change2]=adaptData.metaData.replaceConditionNames(possibleNames,newNames);
%expData.metaData=expData.metaData.replaceConditionNames(possibleNames,newNames);
%% Save:
if change || change2
    save([matDataDir '/' sub 'Params.mat'],'adaptData','-v7.3');
    %save([matDataDir '/' sub '.mat'],'expData','-v7.3');
end
%%
diary off