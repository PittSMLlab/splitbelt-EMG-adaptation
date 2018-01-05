%% Assuming that the variables groups() exists (From N19_loadGroupedData)

%% Directory to save figs
figDir='../../fig';
dirStr=[figDir '/all/kin/'];
if ~exist(dirStr,'dir');
    mkdir(dirStr);
end
%%
removeMissing=false;
matDataDir='../../paramData/';
loadName=[matDataDir 'groupedParams'];
loadName=[loadName '_wMissingParameters']; %Never remove missing for this script
load(loadName)
load([loadName 'Unbiased'])
patientFastList=strcat('P00',{'01','02','05','08','10','13','15'}); %Patients above .8m/s
%patients=patients.getSubGroup(patientFastList);

noP07=true;
%noP07=false;
if noP07
patientsUnbiased=patientsUnbiased.removeSubs({'P0007'});
patients=patients.removeSubs({'P0007'});
end


load ../../paramData/bioData.mat %speeds, ages and Fugl-Meyer
%% Colormap:
colorScheme
cc=cell2mat(colorConds');

%% Parameters and conditions to plot

paramList={'spatialContribution','stepTimeContribution','velocityContribution','netContribution'};
suffix='Norm2';
%suffix='NormAlt';
paramList=strcat(paramList,suffix);
removeBiasFlag=0;
exemptFirst=5;
exemptLast=5;
numberOfStrides=20;
conds={'TM base','Adaptation','Washout'};
%conds={'Washout'};
%conds={'Adaptation'};

for removeBase=0:1
    if removeBase==1
        patients2=patientsUnbiased;
        controls2=controlsUnbiased;
        suffix2=[suffix '_Unbiased'];
    else
        patients2=patients;
        controls2=controls;
        suffix2=suffix;
    end
%% New plot 1: Kin early post
%labels=groups{2}.adaptData{1}.data.getLabelsThatMatch('Contribution$')';
markers={'.','o','x'};
labels=paramList;
bw=1;
f1=figure;
pData2=patients2.medianFilter(bw).getGroupedData(labels,conds,0,numberOfStrides,exemptFirst,exemptLast);
%pData2{1}(:,:,:,7)=-pData2{1}(:,:,:,7); %Flipping P07 to account for the opposite stroke side
cData2=controls2.medianFilter(bw).getGroupedData(labels,conds,0,numberOfStrides,exemptFirst,exemptLast);

%Getting condition c: strides x parameters x subjects
for c=1:length(conds)
    subplot(length(conds),1,c)
pData=squeeze(pData2{1}(c,:,:,:)); 
cData=squeeze(cData2{1}(c,:,:,:));
%Removing obvious outliers
pData(abs(pData)>1)=NaN;
cData(abs(cData)>1)=NaN;
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
[b]=bar(1:32,cat(1,dP,dC));
%dP=dP(1:15,:);
b2=bar([34,36],cat(1,mean(dP),mean(dC)));
for i=1:4
    errb=cat(1,squeeze(nanstd(pData(:,i,:),1)),squeeze(nanstd(cData(:,i,:),1)))./sqrt(cat(1,squeeze(sum(~isnan(pData(:,i,:)))),squeeze(sum(~isnan(cData(:,i,:))))));
    errorbar([1:32] +i/5 -.5,cat(1,dP(:,i),dC(:,i)),errb,'Color',colorConds{i},'LineStyle','None')
    errorbar(34+1.8*i/5 -.9,mean(dP(:,i)),nanstd(dP(:,i))/sqrt(size(dP,1)),'Color',colorConds{i})
    errorbar(36+1.8*i/5 -.9,mean(dC(:,i)),nanstd(dC(:,i))/sqrt(size(dC,1)),'Color',colorConds{i})
end
names=cellfun(@(x) x([1,4,5]),[patients2.ID(aux1) controls2.ID(aux2)],'UniformOutput',false);
set(gca,'XTick',[1:1:32,34,36],'XTickLabel',[names {'Patients','Controls'}],'XTickLabelRotation',90)
if c==length(c)
legend(labels)
end
%axis tight
for i=1:4
    b(i).FaceColor=colorConds{i};
    b2(i).FaceColor=colorConds{i};
    [mx,iii]=(max(nanmean(cData(:,i,:),1)));
    
    
    %mx2=(max(nanmean(cData(:,i,[1:iii-1,iii+1:end]),1)));
    mx2=mean(nanmean(cData(:,i,:),1))+2*nanstd(nanmean(cData(:,i,:),1));
%p=plot([0,33],mx*[1,1],'Color',colorConds{i});
%uistack(p,'bottom')
[mn,iii]=(min(nanmean(cData(:,i,:),1)));
%mn2=(min(nanmean(cData(:,i,[1:iii-1,iii+1:end]),1)));
mn2=mean(nanmean(cData(:,i,:),1))-2*nanstd(nanmean(cData(:,i,:),1));
text(17,.3+i/20,['Min=' num2str(mn,2) '; Max=' num2str(mx,2) ],'Color',colorConds{i})
text(23,.3+i/20,['Min=' num2str(mn2,2) '; Max=' num2str(mx2,2) ],'Color',colorConds{i})
%p=plot([0,33],mn*[1,1],'Color',colorConds{i});
%uistack(p,'bottom')
aux=[1:size(dP,1)] + i/5 -.5;
aux(dP(:,i)<=mx & dP(:,i)>=mn)=nan; %Inside ranges = NaN
plot(aux,min(dP(:))-.05,'*','Color',colorConds{i})
[h,p]=ttest(dP(:,i));
if h==1
plot(34+1.8*i/5 -.9,min(dP(:))-.05,'o','Color',colorConds{i});
end
text(1,.3+i/20,['N=' num2str(sum(~isnan(aux))) '; N(+)=' num2str(sum(dP(:,i)>mx)) '; N(-)=' num2str(sum(dP(:,i)<mn))],'Color',colorConds{i})

aux=[1:size(dP,1)] + i/5 -.5;
aux(dP(:,i)<=mx2 & dP(:,i)>=mn2)=nan; %Inside ranges = NaN
plot(aux,min(dP(:))-.05,'o','Color',colorConds{i})
[h,p]=ttest(dC(:,i));
if h==1
plot(36+1.8*i/5 -.9,min(dP(:))-.05,'o','Color',colorConds{i});
end
[h,p]=ttest2(dP(:,i),dC(:,i),'VarType','Unequal');
if h==1
plot([34,36]+1.8*i/5 -.9,(min(dP(:))+.05*(i-1))*[1,1],'Color',colorConds{i},'LineWidth',2);
end
text(7,.3+i/20,['N=' num2str(sum(~isnan(aux))) '; N(+)=' num2str(sum(dP(:,i)>mx2)) '; N(-)=' num2str(sum(dP(:,i)<mn2))],'Color',colorConds{i})

if i==4
    text(1,.3+5/20,'# of patients outside control range (*):')
    text(7,.3+5/20,'# of patients outside alt range (o):')
    text(17,.3+5/20,'Control range:')
    text(23,.3+5/20,'Alt. (mean+-2*std) range:')
end
end
%errorbar([[1:32]-.3;[1:32]-.1;[1:32]+.1;[1:32]+.3]',cat(1,squeeze(mean(pData,1))',squeeze(mean(cData,1))'),cat(1,squeeze(ste(pData,1))',squeeze(ste(cData,1))'),'.','LineWidth',1,'Color','k')
axis([0 38 min(dP(:))-.1 .8])
hold off
title(['Early ' conds{c}])
end
saveFig(f1,dirStr,['allEarlyContribs' suffix2]);

%% Correlation plots
f2=figure;
names=cellfun(@(x) x([1,4,5]),[patients2.ID controls2.ID],'UniformOutput',false);
for c=3 %Early post
    pData=squeeze(pData2{1}(c,:,:,:)); 
    %pData(:,:,7)=-pData(:,:,7);
    cData=squeeze(cData2{1}(c,:,:,:));
    indsP=[1:6,8:16];
    indsP=1:16;
    pData=pData(:,:,indsP);
    namesP=names(indsP);
    ageP=ageS(indsP);
    velsP=velsS(indsP);
    FMP=FM(indsP);
    %Removing obvious outliers
pData(abs(pData)>1)=NaN;
cData(abs(cData)>1)=NaN;
dP=(squeeze(nanmean(pData,1))');
dC=(squeeze(nanmean(cData,1))');
for i=1:4
subplot(4,4,4+i)
hold on
plot(dP(:,i),ageP,[markers{c} 'r']);
plot(dC(:,i),ageC,[markers{c} 'b']);
text(dP(:,i),ageP,namesP,'FontSize',6);
axis tight

pp=polyfit(dP(:,i)',ageP,1);
plot([-.2 .2],pp(1)*[-.2 .2]+pp(2),'r')
[r,cc]=corr(dP(:,i),ageP');
text(0,81,['r=' num2str(r,3) ', p=' num2str(cc,3)])
[r,cc]=corr(dP(:,i),ageP','type','Spearman');
text(0,78,['r_{sp}=' num2str(r,3) ', p=' num2str(cc,3)])


plot(mean(dC(:,i)')*[1,1],mean(ageC)+[-1,1]*2*std(ageC),'b','LineWidth',1);
plot(mean(dC(:,i)')+[-1,1]*2*std(dC(:,i)'),mean(ageC)*[1,1],'b','LineWidth',1);
hold off
xlabel(labels(i))
ylabel('Age')

subplot(4,4,8+i)
hold on
plot(dP(:,i)',velsP,[markers{c} 'r']);
text(dP(:,i)',velsP,namesP,'FontSize',6);
plot(dC(:,i)',velsC,[markers{c} 'b']);
axis tight

pp=polyfit(dP(:,i)',velsP,1);
plot([-.2 .2],pp(1)*[-.2 .2]+pp(2),'r')
[r,cc]=corr(dP(:,i),velsP');
text(0,1.4,['r=' num2str(r,3) ', p=' num2str(cc,3)])
[r,cc]=corr(dP(:,i),velsP','type','Spearman');
text(0,1.3,['r_{sp}=' num2str(r,3) ', p=' num2str(cc,3)])

plot(dC(:,i)',velsC,[markers{c} 'b']);
plot(mean(dC(:,i)')*[1,1],mean(velsC)+[-1,1]*2*std(velsC),'b','LineWidth',1);
plot(mean(dC(:,i)')+[-1,1]*2*std(dC(:,i)'),mean(velsC)*[1,1],'b','LineWidth',1);
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

saveFig(f2,dirStr,['allEarlyPostContribs_corrs' suffix2]);

end