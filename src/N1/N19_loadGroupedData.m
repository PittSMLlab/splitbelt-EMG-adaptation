clearvars -except sub* stroke* health* control* age* vels* FM* removeMissing patients*
close all

%% Load if not calculated
matDataDir='../../paramData/';
%matDataDir='S:\Shared\Exp0001\mat\'; %This works in main lab PC 2
subs={strokesNames,controlsNames,strokesUpNames};
groups=cell(2,1);
removeMissing=false; %Nothing else is allowed

for j=1:2% strokes and controls
    nameList=subs{j};
    subList={};
    for i=1:length(nameList)
        subList{i}=[matDataDir nameList{i} 'Params'];
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
    possibleNames={{'OG base','OG','OG base '},{'TM slow','TM base slow','slow'},{'mid','TM mid','TM med', 'TM base med','TM base mid','TM base mid 1', 'TM base med 1'},{'short exp','short split','Short Exposure'},{'fast','TM fast'},{'Baseline','TM base','base','TM base med 2','TM base mid 2','TM base (mid)'},{'Adap','Adapt','Adaptation'},{'Wash','Post-','TM post','Washout','Post-Adaptation','post-adap','Washout 1'},{'OG post','OG wash','OG Postadap'},{'uphill mid','uphill mild','mid uphill','uphill low'},{'uphill steep','big uphill','uphill high'}};
    newNames={'OG Base','TM slow','TM mid','Short exposure','TM fast','TM base','Adaptation','Washout','OG post','Uphill mid','Uphill steep'};
    groups{j}=groups{j}.renameConditions(possibleNames, newNames);
    %Check: commonConditions needs to include all of the newNames ?
    groups{j}.getCommonConditions
    
    %Generating unbiased data:
    groupsUnbiased{j}=groups{j}.removeBias;
    
end
%%
patients=groups{1};
controls=groups{2};
%patientsUp=groups{3};
patientsUnbiased=groupsUnbiased{1};
controlsUnbiased=groupsUnbiased{2};
%patientsUpUnbiased=groupsUnbiased{3};
clear groups*

%%
saveName=[matDataDir 'groupedParams'];
saveName=[saveName '_wMissingParameters'];
save(saveName,'controls','patients','-v7.3')
save([saveName 'Unbiased'],'controlsUnbiased','patientsUnbiased','-v7.3')

%saveName=[saveName '_wUphill'];
%save(saveName,'controls','patients','patientsUp','-v7.3')
%save([saveName 'Unbiased'],'controlsUnbiased','patientsUnbiased','patientsUpUnbiased','-v7.3')