clearvars -except sub* stroke* health* control* age* vels* FM* removeMissing patients* GYAA GYRC
close all

%% Load if not calculated
matDataDir='../../paramData/';
%matDataDir='S:\Shared\Exp0001\mat\'; %This works in main lab PC 2
subs={strokesNames,controlsNames,strokesUpNames,GYAA,GYRC};
groups=cell(length(subs),1);
removeMissing=false; %Nothing else is allowed

for j=[1,2]% strokes and controls
    nameList=subs{j};
    subList={};
    for i=1:length(nameList)
        subList{i}=[matDataDir nameList{i}]; %Params is capped in my files, but not on others
    end
    groups{j}=adaptationData.createGroupAdaptData(subList);
    
    %Renaming some EMG-associated params (different names across subs)
    l1=groups{j}.getLabelsThatMatch('ILP');
    l2=regexprep(l1,'ILP','SAR');
    l3=regexprep(l1,'ILP','HIP');
    groups{j}=groups{j}.renameParams(l1,l3);
    groups{j}=groups{j}.renameParams(l2,l3);
    
    %Marking strides as bad if missing any muscle or contribution, removing bad strides:
    label=groups{j}.adaptData{1}.data.getLabelsThatMatch('Contribution$')';
    label2=groups{j}.adaptData{1}.data.getLabelsThatMatch('[s,f].+s\d+$')';
    
    %Running median filter: (?)
    
    %Get consistent names for conditions:
    replacementConditionNames
    groups{j}=groups{j}.renameConditions(possibleNames, newNames);
    %Check: commonConditions needs to include all of the newNames ?
    groups{j}.getCommonConditions
    
    %Generating normalized EMG parameters (so I don't have to recompute
    %everytime):
    baseEp=getBaseEpoch; %defines baseEp
    mOrder={'TA', 'PER', 'SOL', 'LG', 'MG', 'BF', 'SEMB', 'SEMT', 'VM', 'VL', 'RF', 'HIP', 'ADM', 'TFL', 'GLU'};
    nMusc=length(mOrder);
    type='s';
    labelPrefix=fliplr([strcat('f',mOrder) strcat('s',mOrder)]); %To display
    labelPrefixLong= strcat(labelPrefix,['_' type]); %Actual names
    groups{j}=groups{j}.normalizeToBaselineEpoch(labelPrefixLong,baseEp);
    
end
%%
patients=groups{1};
controls=groups{2};
GYAA=groups{4};
GYRC=groups{5};
%patientsUp=groups{3};
%patientsUnbiased=groupsUnbiased{1};
%controlsUnbiased=groupsUnbiased{2};
%GYAAUnbiased=groupsUnbiased{4};
%GYRCUnbiased=groupsUnbiased{5};
%patientsUpUnbiased=groupsUnbiased{3};
clear groups*

%%
patients.adaptData{1}.metaData.conditionName{4}='TM base'; %P01 has bad condition name which confounds with TM mid when it exists.
%% Sanity check: 8 common conditions
if length(controls.getCommonConditions)<8 || length(patients.getCommonConditions)<6 || length(patients.removeSubs({'P0001','P0007','P0011'}).getCommonConditions)<8
    error('Groups do not have the 8 expected common conditions, some re-naming did NOT work')
    %For controls we expect: OG base, slow, mid, short, base, adapt, wash, OG post
    %For patients the same, except: short (not in P07,P11) , mid (not present in P01,P11)
end
%%
saveName=[matDataDir 'groupedParams'];
saveName=[saveName '_wMissingParameters'];
disp('Saving control+patient data...')
tic
save(saveName,'controls','patients','-v7.3')
disp('Done!')
toc
disp('Saving control+patient UNBIASED data...')
%tic
%save([saveName 'Unbiased'],'controlsUnbiased','patientsUnbiased','-v7.3')
%disp('Done!')
%toc

saveName=[matDataDir 'groupedParamsYOUNG'];
saveName=[saveName '_wMissingParameters'];

disp('Saving young subjects data...')
tic
%save(saveName,'GYAA','GYRC','-v7.3')
disp('Done!')
toc
disp('Saving young subjects UNBIASED data...')
%tic
%save([saveName 'Unbiased'],'GYAAUnbiased','GYRCUnbiased','-v7.3')
%disp('Done!')
%toc
%saveName=[saveName '_wUphill'];
%save(saveName,'controls','patients','patientsUp','-v7.3')
%save([saveName 'Unbiased'],'controlsUnbiased','patientsUnbiased','patientsUpUnbiased','-v7.3')