function allDataEMG=loadEMGParams_ForDynamics(groupName)
%% Aux vars:
matDataDir='../data/HPF30/';
loadName=[matDataDir 'groupedParams'];
loadName=[loadName '_wMissingParameters']; %Never remove missing for this script
load(loadName)

%%
if nargin<1 || isempty(groupName)
    group=controls;
else
    eval(['group=' groupName ';']);
end
age=group.getSubjectAgeAtExperimentDate/12;

%% Define params we care about:
mOrder={'TA', 'PER', 'SOL', 'LG', 'MG', 'BF', 'SEMB', 'SEMT', 'VM', 'VL', 'RF', 'HIP', 'ADM', 'TFL', 'GLU'};
nMusc=length(mOrder);
type='s';
labelPrefix=fliplr([strcat('f',mOrder) strcat('s',mOrder)]); %To display
labelPrefixLong= strcat(labelPrefix,['_' type]); %Actual names

%Adding alternative normalization parameters:
%l2=group.adaptData{1}.data.getLabelsThatMatch('^Norm');
%controls=controls.renameParams(l2,strcat('N',l2)).normalizeToBaselineEpoch(labelPrefixLong,base,true); %Normalization to max=1 but not min=0

%Renaming normalized parameters, for convenience:
ll=group.adaptData{1}.data.getLabelsThatMatch('^Norm');
l2=regexprep(regexprep(ll,'^Norm',''),'_s','s');
group=group.renameParams(ll,l2);
newLabelPrefix=strcat(labelPrefix,'s');

%% Define epochs & get data:
%baseEp=getBaseEpoch;
%Adaptation epochs
strides=[-50 900 600];exemptFirst=[0];exemptLast=[0];
names={};
shortNames={};
cond={'TM Base','Adaptation','Washout'};
ep=defineEpochs(cond,cond,strides,exemptFirst,exemptLast,'nanmedian',{'B','A','P'});

padWithNaNFlag=true;
[dataEMG,labels,allDataEMG]=group.getPrefixedEpochData(newLabelPrefix,ep,padWithNaNFlag);
%Flipping EMG:
for i=1:length(allDataEMG)
    aux=reshape(allDataEMG{i},size(allDataEMG{i},1),size(labels,1),size(labels,2),size(allDataEMG{i},3));
    allDataEMG{i}=reshape(flipEMGdata(aux,2,3),size(aux,1),numel(labels),size(aux,4));
end

[~,~,dataContribs]=group.getEpochData(ep,{'netContributionNorm2'},padWithNaNFlag);

%% 
save ../data/dynamicsData.mat allDataEMG dataContribs
end