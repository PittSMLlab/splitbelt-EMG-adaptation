%% 
addpath(genpath('./fun/'))
addpath(genpath('../pubfig/auxFun/'))
%% Define data from params if necessary
groupName='patients';
subjIdx=[1:6,8:10,12:16]; %Excluding 7 and 11 which dont have short exp
groupName='controls';
subjIdx=2:16; %Excluding C01

%% Aux vars:
matDataDir='../data/HPF30/';
loadName=[matDataDir 'groupedParams'];
loadName=[loadName '_wMissingParameters']; %Never remove missing for this script
load(loadName)

%%
eval(['group=' groupName ';']);
age=group.getSubjectAgeAtExperimentDate/12;

%% Define params we care about:
mOrder={'TA', 'PER', 'SOL', 'LG', 'MG', 'BF', 'SEMB', 'SEMT', 'VM', 'VL', 'RF', 'HIP', 'ADM', 'TFL', 'GLU'};
nMusc=length(mOrder);
type='s';
labelPrefix=fliplr([strcat('f',mOrder) strcat('s',mOrder)]); %To display
labelPrefixLong= strcat(labelPrefix,['_' type]); %Actual names

%Renaming normalized parameters, for convenience:
ll=group.adaptData{1}.data.getLabelsThatMatch('^Norm');
l2=regexprep(regexprep(ll,'^Norm',''),'_s','s');
group=group.renameParams(ll,l2);
newLabelPrefix=strcat(labelPrefix,'s');

%% Define epochs & get data:
ep=getEpochs;
baseEp=getBaseEpoch;
padWithNaNFlag=false;
[dataEMG,labels,allData]=group.getPrefixedEpochData(newLabelPrefix,ep,padWithNaNFlag);
[BB,labels]=group.getPrefixedEpochData(newLabelPrefix,baseEp,padWithNaNFlag);


%% Compute inter-stride cosines:
eA=allData{strcmp(ep.shortName,'eA')}-permute(BB,[2,1,3]);
e15A=allData{strcmp(ep.shortName,'e15A')}-permute(BB,[2,1,3]);
clear c sc c15 sc15
for i=1:size(eA,3)
    cc=auxCosine(eA(:,:,i)');
    c(i)=nanmedian(cc(:));
    sc(i)=iqr(cc(:));
    cc=auxCosine(squeeze(mean(e15A(1:5,:,i)))',squeeze(mean(e15A(6:10,:,i)))');
    c15(i)=nanmedian(cc(:));
    sc15(i)=iqr(cc(:));
end
figure
s1=scatter(age,c,'filled','DisplayName','Median cosine of individual strides 1-5','MarkerEdgeColor','w');
hold on
s2=scatter(age,c15,'filled','DisplayName','Avg. of strides 1-5 to avg. of strides 6-10','MarkerEdgeColor','w');
plot([min(age),max(age)],median(c)*[1 1],'Color',s1.CData,'DisplayName','Median value');
plot([min(age),max(age)],median(c15)*[1 1],'Color',s2.CData,'DisplayName','Median value');
ylabel('Cosine')
title('Inter-stride variability of responses during early Adaptation')
xlabel('Subject age')
legend('Location','SouthEast')

%% Compute inter-subject cosines:
eA=squeeze(dataEMG(:,strcmp(ep.shortName,'eA'),:)-BB);
SS=squeeze(dataEMG(:,strcmp(ep.shortName,'lA'),:)-BB);
veA=squeeze(dataEMG(:,strcmp(ep.shortName,'veA'),:)-BB);
e15A=squeeze(dataEMG(:,strcmp(ep.shortName,'e15A'),:)-BB);
ic5=median(auxCosine(eA));
ic1=median(auxCosine(veA));
ic15=median(auxCosine(e15A));
c1=crossValCosine(veA);
c5=crossValCosine(eA);
c15=crossValCosine(e15A);
cSS=crossValCosine(SS);
c=[c1;c5;c15];
figure; 

subplot(2,3,1)
hold on;
plot([1,5,15],c)
xlabel('Strides')
ylabel('Cosine, indiv to complement median ')
plot(1,c1,'kx')
plot(5,c5,'kx')
plot(15,c15,'kx')
plot([1,5,15],median(c'),'LineWidth',2,'Color','k')
ic=[ic1;ic5;ic15];
plot([1,5,15],ic,'LineWidth',2,'Color','r')
%text(15.5*ones(16,1),c(3,:)',mat2cell(num2str([1:16]'),ones(16,1),2))
title('Individual variability of EMG during eA vs. stride #')
set(gca,'XTick',[1,5,15,50],'XTickLabel',{'1 ','5','15 ','lA (40)'})
subplot(2,3,2)
scatter(age,c1,'filled','DisplayName','1 stride','MarkerEdgeColor','w')
hold on
scatter(age,c5,'filled','DisplayName','5 strides','MarkerEdgeColor','w')
scatter(age,c15,'filled','DisplayName','15 strides','MarkerEdgeColor','w')
xlabel('age')
ylabel('Cosine, indiv. to complement median')
title('eA variability vs. age')
legend
subplot(2,3,3)
hold on;
title('Distances btw. group medians at diff. strides')
plot(2,auxCosine(median(eA,2),median(veA,2)),'o','MarkerFaceColor','k','MarkerEdgeColor','none')
plot(1,auxCosine(median(eA,2),median(e15A,2)),'o','MarkerFaceColor','k','MarkerEdgeColor','none')
plot(3,auxCosine(median(e15A,2),median(veA,2)),'o','MarkerFaceColor','k','MarkerEdgeColor','none')
set(gca,'XTick',[1,2,3],'XTickLabel',{'5 vs. 15','1 vs. 5','1 vs. 15'})
grid on

subplot(2,3,4)
hold on
for i=1:size(dataEMG,2)
    aux=squeeze(dataEMG(:,i,:))-BB; %Epoch data
    c(i,:)=crossValCosine(aux);
end
eP=squeeze(dataEMG(:,strcmp(ep.shortName,'eP'),:)-BB);
lA=squeeze(dataEMG(:,strcmp(ep.shortName,'lA'),:)-BB);
aux=eP-lA;
c(end+1,:)=crossValCosine(aux);

idx=[1,3,5,6,9,10,13,14,15];
names=[ep.shortName;'eP-lA'];
names=names(idx);
c=c(idx,:);
x=1:size(c,1);
plot(c)
scatter(x,median(c,2),'k','MarkerFaceColor','k') %Cosine of each suibject to median of rest
title('Indiv. variability of EMG across epochs')
set(gca,'XTick',x,'XTickLabel',names)
ylabel('Cosine, indiv. to complement median')
xlabel('Epochs')

subplot(2,3,5)
scatter(age,cSS,'k','MarkerFaceColor','k')
xlabel('Age')
ylabel('Cosine, indiv. to complement median')
title('Steady-state (lA) variability vs age')