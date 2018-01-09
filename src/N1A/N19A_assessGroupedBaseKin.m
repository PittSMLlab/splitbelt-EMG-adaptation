%% Assuming that the variables groups() exists (From N19_loadGroupedData)

%% Directory to save figs
figDir='../../fig';
dirStr=[figDir '/all/kin/'];
if ~exist(dirStr,'dir');
    mkdir(dirStr);
end
%%
matchSpeedFlag=0;
removeMissing=false;
matDataDir='../../paramData/';
loadName=[matDataDir 'groupedParams'];
loadName=[loadName '_wMissingParameters']; %Never remove missing for this script
if (~exist('patients','var') || ~isa('patients','groupAdaptationData')) || (~exist('controls','var') || ~isa('controls','groupAdaptationData'))
    load(loadName)
end

patientFastList=strcat('P00',{'01','02','05','08','09','10','13','14','15','16'}); %Patients above .72m/s, which is the group mean. N=10. Mean speed=.88m/s. Mean FM=29.5 (vs 28.8 overall)
controlsSlowList=strcat('C00',{'01','02','04','05','06','07','09','10','12','16'}); %Controls below 1.1m/s (chosen to match pop size), N=10. Mean speed=.9495m/s
patientUphillControlList={'C0001','C0002','C0003','C0004','C0009','C0010','C0011','C0012','C0013','C0014','C0015','C0016'};
patientUphillList_={'P0001','P0002','P0003','P0004','P0009','P0010','P0011','P0012','P0013','P0014','P0015','P0016'}; %patients that did the uphill
patientUphillList=strcat(patientUphillList_,'u'); %patients that did the uphill

removeP07Flag=1;
if removeP07Flag
    patients2=patients.removeSubs({'P0007','P0008'});
    controls2=controls.removeSubs({'C0007','C0008'});
    patientsUnbiased2=patients2.removeBias;
    controlsUnbiased2=controls2.removeBias;
end
switch matchSpeedFlag
    case 1 %Speed matched groups
        patients2=patients2.getSubGroup(patientFastList).removeBadStrides;
        controls2=controls2.getSubGroup(controlsSlowList).removeBadStrides;
        patientsUnbiased2=patientsUnbiased2.getSubGroup(patientFastList).removeBadStrides;
        controlsUnbiased2=controlsUnbiased2.getSubGroup(controlsSlowList).removeBadStrides;
    case 0 %Full groups
        patients2=patients2.removeBadStrides;
        controls2=controls2.removeBadStrides;
        patientsUnbiased2=patientsUnbiased2.removeBadStrides;
        controlsUnbiased2=controlsUnbiased2.removeBadStrides;
    case 2 %Uphill-matched groups (not all P's did uphill)
%         if (~exist('patientsUp','var') || ~isa('patientsUp','groupAdaptationData'))
%             loadName=[loadName '_wUphill']; 
%             load(loadName)
%             load([loadName 'Unbiased'])
%         end
%         patientsUp.ID{6}='P0010';
%         patientsUp.ID=strcat(patientsUp.ID,'u');
%         oldL=patientsUp.adaptData{5}.data.getLabelsThatMatch('SAR');
%         newL=regexprep(oldL,'SAR','HIP');
%         patientsUp.adaptData{5}=patientsUp.adaptData{5}.renameParams(oldL,newL);
%         patients=patients.getSubGroup(patientUphillList_).removeBadStrides;
%         controls=patientsUp.getSubGroup(patientUphillList).removeBadStrides;
    error('Unimplemented')
    %Need to add the unbiased parameters for this option to work
end



load ../../paramData/bioData.mat %speeds, ages and Fugl-Meyer
%% Colormap:
%colorScheme
figuresColorMap
ccd=condColors;
ccd=[ccd; [.6,.6,0]];

%% Parameters and conditions to plot

paramList={'spatialContribution','stepTimeContribution','velocityContribution','netContribution','correctedVelocityContribution'};
paramList={'spatialContribution','stepTimeContribution','velocityContribution','netContribution'};

%patients=patients.addNewParameter('correctedVelocityContribution',@(x,y,z) x +(y-z),{'velocityContribution','singleStanceSpeedFastAbs','singleStanceSpeedSlowAbs'},'');
%controls=controls.addNewParameter('correctedVelocityContribution',@(x,y,z) x +(y-z),{'velocityContribution','singleStanceSpeedFastAbs','singleStanceSpeedSlowAbs'},'');
%patientsUnbiased=patientsUnbiased.addNewParameter('correctedVelocityContribution',@(x,y,z) x +(y-z),{'velocityContribution','singleStanceSpeedFastAbs','singleStanceSpeedSlowAbs'},'');
%controlsUnbiased=controlsUnbiased.addNewParameter('correctedVelocityContribution',@(x,y,z) x +(y-z),{'velocityContribution','singleStanceSpeedFastAbs','singleStanceSpeedSlowAbs'},'');

suffix='Norm2';
%suffix='NormAlt';
paramList=strcat(paramList,suffix);
removeBiasFlag=0;
exemptFirst=5;
exemptLast=5;
numberOfStrides=-40;
conds={'TM base','Adaptation','Washout'};
%conds={'Washout'};
%conds={'Adaptation'};

switch suffix        
    case 'P'
        earlyLateList=0;
    case ''
        earlyLateList=0;
    otherwise
        earlyLateList=0:1;
end

for earlyOrLateFlag=0:1
    switch earlyOrLateFlag
        case 0 %Late
            numberOfStrides=-40;
            saveNamePrefix='allBaseContribs';
            baselineConditions=[0:1];
        case 1 %Early
            numberOfStrides=20;
            saveNamePrefix='allEarlyContribs';
            baselineConditions=1; %Always remove baseline on early data
    end
for removeBase=baselineConditions
    if removeBase==1
        patients2=patientsUnbiased2;
        controls2=controlsUnbiased2;
        suffix2=[suffix '_Unbiased'];
    else
        patients2=patients2;
        controls2=controls2;
        suffix2=suffix;
    end
%% New plot 1: Kin baseline
%labels=groups{2}.adaptData{1}.data.getLabelsThatMatch('Contribution$')';
markers={'.','o','x'};
labels=paramList;
bw=1;
f1=figure;
pData2=patients2.medianFilter(bw).getGroupedData(labels,conds,0,numberOfStrides,exemptFirst,exemptLast);
idx=cellfun(@(x) strcmp(x,'P0007'),patients2.ID); %Is cellfun necessary?
if ~isempty(idx)
    pData2{1}(:,:,:,idx)=-pData2{1}(:,:,:,idx); %Flipping P07 to account for the opposite stroke side
end
cData2=controls2.medianFilter(bw).getGroupedData(labels,conds,0,numberOfStrides,exemptFirst,exemptLast);

%Getting condition c: strides x parameters x subjects
for c=1:length(conds)
    subplot(length(conds),1,c)
pData=squeeze(pData2{1}(c,:,:,:)); 
cData=squeeze(cData2{1}(c,:,:,:));
%Removing obvious outliers
    [~,extOutlier]=outlierFences(pData);
    pData(extOutlier)=nan;
    disp(['Discarding ' num2str(sum(extOutlier(:))) '/' num2str(numel(extOutlier(:))) ' strides'])
    [~,extOutlier]=outlierFences(cData);
    cData(extOutlier)=nan;
    disp(['Discarding ' num2str(sum(extOutlier(:))) '/' num2str(numel(extOutlier(:))) ' strides'])
    %This works for normalized data only
    % pData(abs(pData)>1)=NaN;
    % cData(abs(cData)>1)=NaN;
%Sorting of subjects according to step-length asymmetry
if c==1
[~,aux1]=sort(nanmean(pData(:,4,:),1)); 
[~,aux2]=sort(nanmean(cData(:,4,:),1));
end
pData=pData(:,:,aux1);
cData=cData(:,:,aux2);


%subplot(4,4,1:2)
hold on
dP=squeeze(nanmean(pData,1))';
dC=squeeze(nanmean(cData,1))';
[b]=bar([1:length(dP)+length(dC)],cat(1,dP,dC));
%dP=dP(1:15,:);
b2=bar([34,36],cat(1,nanmean(dP),nanmean(dC)));
for i=1:4
    errb=cat(1,squeeze(nanstd(pData(:,i,:),1)),squeeze(nanstd(cData(:,i,:),1)))./sqrt(cat(1,squeeze(sum(~isnan(pData(:,i,:)))),squeeze(sum(~isnan(cData(:,i,:))))));
    errorbar([1:length(dP)+length(dC)] +i/5 -.5,cat(1,dP(:,i),dC(:,i)),errb,'Color',ccd(i,:),'LineStyle','None')
    errorbar(34+1.8*i/5 -.9,nanmean(dP(:,i)),nanstd(dP(:,i))/sqrt(size(dP,1)),'Color',ccd(i,:))
    errorbar(36+1.8*i/5 -.9,nanmean(dC(:,i)),nanstd(dC(:,i))/sqrt(size(dC,1)),'Color',ccd(i,:))
end
names=cellfun(@(x) x([1,4,5]),[patients2.ID(aux1) controls2.ID(aux2)],'UniformOutput',false);
set(gca,'XTick',[1:1:length(names),34,36],'XTickLabel',[names {'Patients','Controls'}],'XTickLabelRotation',90)
if c==length(c)
legend(labels)
end
%axis tight
for i=1:4
    b(i).FaceColor=ccd(i,:);
    b2(i).FaceColor=ccd(i,:);
    [mx,iii]=(max(nanmean(cData(:,i,:),1)));
    
    
    %mx2=(max(nanmean(cData(:,i,[1:iii-1,iii+1:end]),1)));
    mx2=mean(nanmean(cData(:,i,:),1))+2*nanstd(nanmean(cData(:,i,:),1));
%p=plot([0,33],mx*[1,1],'Color',ccd(i,:));
%uistack(p,'bottom')
[mn,iii]=(min(nanmean(cData(:,i,:),1)));
%mn2=(min(nanmean(cData(:,i,[1:iii-1,iii+1:end]),1)));
mn2=mean(nanmean(cData(:,i,:),1))-2*nanstd(nanmean(cData(:,i,:),1));
text(17,.3+i/15,['Min=' num2str(mn,2) '; Max=' num2str(mx,2) ],'Color',ccd(i,:))
text(23,.3+i/15,['Min=' num2str(mn2,2) '; Max=' num2str(mx2,2) ],'Color',ccd(i,:))
%p=plot([0,33],mn*[1,1],'Color',ccd(i,:));
%uistack(p,'bottom')

aux=[1:size(dP,1)] + i/5 -.5;
[hh,pp]=ttest(squeeze(pData(:,i,:)));
hh(isnan(hh))=0;
aux(~hh)=nan;
plot(aux,1.1*min(dP(:))-.01,'.','Color',ccd(i,:))

aux=size(dP,1) + [1:size(dC,1)] + i/5 -.5;
[hh,pp]=ttest(squeeze(cData(:,i,:)));
hh(isnan(hh))=0;
aux(~hh)=nan;
plot(aux,1.1*min(dP(:))-.01,'.','Color',ccd(i,:))

aux=[1:size(dP,1)] + i/5 -.5;
aux(dP(:,i)<=mx & dP(:,i)>=mn)=nan; %Inside ranges = NaN
plot(aux,1.2*min(dP(:))-.05,'*','Color',ccd(i,:))

[h,p]=ttest(dP(:,i));
if h==1
plot(34+1.8*i/5 -.9,1.2*min(dP(:))-.05,'o','Color',ccd(i,:));
end
text(1,.3+i/15,['N=' num2str(sum(~isnan(aux))) '; N(+)=' num2str(sum(dP(:,i)>mx)) '; N(-)=' num2str(sum(dP(:,i)<mn))],'Color',ccd(i,:))

aux=[1:size(dP,1)] + i/5 -.5;
aux(dP(:,i)<=mx2 & dP(:,i)>=mn2)=nan; %Inside ranges = NaN
plot(aux,1.2*min(dP(:))-.05,'o','Color',ccd(i,:))
[h,p]=ttest(dC(:,i));
if h==1
plot(36+1.8*i/5 -.9,1.2*min(dP(:))-.05,'o','Color',ccd(i,:));
end
[h,p]=ttest2(dP(:,i),dC(:,i),'VarType','Unequal');
if h==1
plot([34,36]+1.8*i/5 -.9,(1.2*min(dP(:))*(1-.05*(i-1)))*[1,1],'Color',ccd(i,:),'LineWidth',2);
end
text(7,.3+i/15,['N=' num2str(sum(~isnan(aux))) '; N(+)=' num2str(sum(dP(:,i)>mx2)) '; N(-)=' num2str(sum(dP(:,i)<mn2))],'Color',ccd(i,:))

if i==4
    text(1,.3+5/15,'# of patients outside control range (*):')
    text(7,.3+5/15,'# of patients outside 95% CI (o):')
    text(17,.3+5/15,'Control range:')
    text(23,.3+5/15,'95% CI (mean+-2*std):')
end
end
%errorbar([[1:32]-.3;[1:32]-.1;[1:32]+.1;[1:32]+.3]',cat(1,squeeze(mean(pData,1))',squeeze(mean(cData,1))'),cat(1,squeeze(ste(pData,1))',squeeze(ste(cData,1))'),'.','LineWidth',1,'Color','k')
axis([0 38 1.25*min(dP(:))-.1 max([1.4*max(dP(:))+.3, .8])])
hold off
title(conds{c})
end

saveName=[saveNamePrefix suffix2];
if matchSpeedFlag==1
   saveName=[saveName '_speedMatched']; 
elseif matchSpeedFlag==2
    saveName=[saveName '_uphill'];
end
if removeP07Flag
    saveName=[saveName '_noP07'];
end

%saveFig(f1,dirStr,saveName);

%% Correlation plots
f2=figure;
names=cellfun(@(x) x([1,4,5]),[patients2.ID controls2.ID],'UniformOutput',false);
namesP=cellfun(@(x) x([1,4,5]),[patients2.ID ],'UniformOutput',false);
namesC=cellfun(@(x) x([1,4,5]),[controls2.ID ],'UniformOutput',false);
indsP=cellfun(@(x) find(strcmp(x,strokesNames)),patients2.ID);
indsC=cellfun(@(x) find(strcmp(x,controlsNames)),controls2.ID);
    ageP=ageS(indsP);
    ageCC=ageC(indsC);
    velsP=velsS(indsP);
    velsCC=velsC(indsC);
    FMP=FM(indsP);
    
for c=1
    pData=squeeze(pData2{1}(c,:,:,:)); 
    cData=squeeze(cData2{1}(c,:,:,:));

    %Removing obvious outliers using fence strategy:
    [~,extOutlier]=outlierFences(pData);
    pData(extOutlier)=nan;
    [~,extOutlier]=outlierFences(cData);
    cData(extOutlier)=nan;
    
    %This is reasonable for normalized contributions only:
    %pData(abs(pData)>1)=NaN;
    %cData(abs(cData)>1)=NaN;

dP=(squeeze(nanmean(pData,1))');
dC=(squeeze(nanmean(cData,1))');
for i=1:4
subplot(4,4,4+i)
hold on
plot(dP(:,i),ageP,[markers{c} 'r']);
plot(dC(:,i),ageCC,[markers{c} 'b']);
text(dP(:,i),ageP,namesP,'FontSize',6);
axis tight

pp=polyfit(dP(:,i)',ageP,1);
plot([-.2 .2],pp(1)*[-.2 .2]+pp(2),'r')
[r,cc]=corr(dP(:,i),ageP');
text(0,81,['r=' num2str(r,3) ', p=' num2str(cc,3)])
[r,cc]=corr(dP(:,i),ageP','type','Spearman');
text(0,78,['r_{sp}=' num2str(r,3) ', p=' num2str(cc,3)])


plot(mean(dC(:,i)')*[1,1],mean(ageCC)+[-1,1]*2*std(ageCC),'b','LineWidth',1);
plot(mean(dC(:,i)')+[-1,1]*2*std(dC(:,i)'),mean(ageCC)*[1,1],'b','LineWidth',1);
hold off
xlabel(labels(i))
ylabel('Age')

subplot(4,4,8+i)
hold on
plot(dP(:,i)',velsP,[markers{c} 'r']);
text(dP(:,i)',velsP,namesP,'FontSize',6);
plot(dC(:,i)',velsCC,[markers{c} 'b']);
axis tight

pp=polyfit(dP(:,i)',velsP,1);
plot([-.2 .2],pp(1)*[-.2 .2]+pp(2),'r')
[r,cc]=corr(dP(:,i),velsP');
text(0,1.4,['r=' num2str(r,3) ', p=' num2str(cc,3)])
[r,cc]=corr(dP(:,i),velsP','type','Spearman');
text(0,1.3,['r_{sp}=' num2str(r,3) ', p=' num2str(cc,3)])

plot(dC(:,i)',velsCC,[markers{c} 'b']);
plot(mean(dC(:,i)')*[1,1],mean(velsCC)+[-1,1]*2*std(velsCC),'b','LineWidth',1);
plot(mean(dC(:,i)')+[-1,1]*2*std(dC(:,i)'),mean(velsCC)*[1,1],'b','LineWidth',1);
hold off
xlabel(labels(i))
ylabel('TM Speed(m/s)')

subplot(4,4,12+i)
hold on
plot(dP(:,i)',FMP,[markers{c} 'r']);
text(dP(:,i)',FMP,namesP,'FontSize',6);

pp=polyfit(dP(:,i)',FMP,1);
plot([-.2 .2],pp(1)*[-.2 .2]+pp(2),'r')
[r,cc]=corr(dP(:,i),FMP');
text(.1,35,['r=' num2str(r,3) ', p=' num2str(cc,3)])
[r,cc]=corr(dP(:,i),FMP','type','Spearman');
text(.1,34,['r_{sp}=' num2str(r,3) ', p=' num2str(cc,3)])

plot(mean(dC(:,i)')+[-1,1]*2*std(dC(:,i)'),34*[1,1],'b','LineWidth',1);
hold off
xlabel(labels(i))
ylabel('Fugl-Meyer score')
axis tight
end

subplot(4,4,3)
hold on
plot(dP(:,1)',dP(:,2)',[markers{c} 'r']);
text(dP(:,1)',dP(:,2)',namesP,'FontSize',6);

pp=polyfit(dP(:,1)',dP(:,2)',1);
plot([-.2 .2],pp(1)*[-.2 .2]+pp(2),'r')
[r,cc]=corr(dP(:,1),dP(:,2));
text(0,-.2,['r=' num2str(r,3) ', p=' num2str(cc,3)])
[r,cc]=corr(dP(:,1),dP(:,2),'type','Spearman');
text(0,-.25,['r_{sp}=' num2str(r,3) ', p=' num2str(cc,3)])

plot(dC(:,1)',dC(:,2)',[markers{c} 'b']);
plot(mean(dC(:,1)')*[1,1],mean(dC(:,2)')+[-1,1]*2*std(dC(:,2)'),'b','LineWidth',1);
plot(mean(dC(:,1)')+[-1,1]*2*std(dC(:,1)'),mean(dC(:,2)')*[1,1],'b','LineWidth',1);
hold off
xlabel(labels(1))
ylabel(labels(2))
axis tight
subplot(4,4,4)
hold on
plot(dP(:,3)',dP(:,2)',[markers{c} 'r']);
text(dP(:,3)',dP(:,2)',namesP,'FontSize',6);

pp=polyfit(dP(:,3)',dP(:,2)',1);
plot([-.2 .2],pp(1)*[-.2 .2]+pp(2),'r')
[r,cc]=corr(dP(:,3),dP(:,2));
text(0,-.2,['r=' num2str(r,3) ', p=' num2str(cc,3)])
[r,cc]=corr(dP(:,3),dP(:,2),'type','Spearman');
text(0,-.25,['r_{sp}=' num2str(r,3) ', p=' num2str(cc,3)])

plot(dC(:,3)',dC(:,2)',[markers{c} 'b']);
plot(mean(dC(:,3)')*[1,1],mean(dC(:,2)')+[-1,1]*2*std(dC(:,2)'),'b','LineWidth',1);
plot(mean(dC(:,3)')+[-1,1]*2*std(dC(:,3)'),mean(dC(:,2)')*[1,1],'b','LineWidth',1);
hold off
xlabel(labels(3))
ylabel(labels(2))
axis tight

end
saveName=[saveNamePrefix '_corrs' suffix2];
if matchSpeedFlag==1
   saveName=[saveName '_speedMatched']; 
elseif matchSpeedFlag==2
    saveName=[saveName '_uphill'];
end
if removeP07Flag
    saveName=[saveName '_noP07'];
end


%saveFig(f2,dirStr,saveName);
end
end