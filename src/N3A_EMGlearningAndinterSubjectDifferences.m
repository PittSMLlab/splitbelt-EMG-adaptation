%% 
addpath(genpath('./fun/'))
addpath(genpath('../pubfig/auxFun/'))
%% Define data from params if necessary
groupName='patients';
subjIdx=[1:6,8:10,12:16]; %Excluding 7 and 11 which dont have short exp
groupName='controls';
subjIdx=2:16; %Excluding C01

%% If EMGsummary file does not exist, run this:
%loadEMGParams_controls(groupName)

%% Get all needed vars
load(['../data/' groupName 'EMGsummary'])
load ../data/bioData.mat
write=true;
write=false;
%% Define eAT, lAT, etc
eAT=fftshift(eA,1);
lAT=fftshift(lA,1);
veAT=fftshift(veA,1);
e15AT=fftshift(e15A,1);
%% Select sub-sets of muscles to test for robustness
muscleIdx=1:size(eA,1);
%muscleIdx=[[49:180],180+[49:180]]; %Exclude hips
%muscleIdx=[[61:96,109:180],180+[61:96,109:180]]; %Exclude hips, RF, SEMB
%-> Most things remain the same. The most fragile result seems to be the
%correlation of \beta_M to age.
%% Shuffling test
%eA=eA(randperm(360),randperm(16));
%eAT=eA(randperm(360),randperm(16));
%eAT=randn(size(eA));
%eA=randn(size(eAT));
%eA1=eA;
%eA=-eAT;
%eAT=-eA1;
%lA=lA(randperm(360),:);
%eP=eP(randperm(360),:);
%WHAT I LEARNED FROM THIS:
%sudden changes in speeds lead to most muscles increasing activity on
%younger subjects, but not so (on average the change is 0) on older
%subjects. This age trend is more pronounced in split-to-tied thant
%tied-to-split transition.
%Thus, even if we randomly permute muscles, the expected
%regressor of (eP-lA) onto eAT is positive, and onto -eA is negative (most
%elements of eP-lA are positive, so are most of eA and eAT). Further,
%because of the age dependency, those regressors always have some trend
%with age, as observed in the normal dataset.
%Obviously, when shuffled like this, the R^2 values drop immensely, and so
%do the regressors (they just dont have 0 as expected values).
%All these things remain true if we remove all hip muscles 
%Example code to observe these things:
% [r,p]=corr(ageC',mean(eA(muscleIdx,:))','Type','Spearman')
% [r,p]=corr(ageC',mean(eP(muscleIdx,:)-lA(muscleIdx,:))','Type','Spearman')
% median(mean(eA(muscleIdx,:))
% median(mean(eA(muscleIdx,:)))
% median(mean(eP(muscleIdx,:)-lA(muscleIdx,:)))
%% Clipping data (to avoid outliers, improves R^2 for a few subjects)
% th=2;
% eA(eA>th)=th;
% eA(eA<-th)=-th;
% eAT(eAT>th)=th;
% eAT(eAT<-th)=-th;
% lA(lA>th)=th;
% lA(lA<-th)=-th;
% eP(eP>th)=th;
% eP(eP<-th)=-th;
%% Do group analysis:
rob='off';
%%%Short-exposure(to compare):
ttS=table(-median(eA(muscleIdx,subjIdx),2), median(eAT(muscleIdx,subjIdx),2), -median(lS(muscleIdx,subjIdx),2), median(ePS(muscleIdx,subjIdx),2)-median(lS(muscleIdx,subjIdx),2),'VariableNames',{'eA','eAT','lS','ePS_lS'});
ttSb=table(-median(eA(muscleIdx,subjIdx),2), median(eAT(muscleIdx,subjIdx),2), -median(lS(muscleIdx,subjIdx),2), median(ePS(muscleIdx,subjIdx),2),'VariableNames',{'eA','eAT','lS','ePS'});
ttS1=table(-median(veA(muscleIdx,subjIdx),2), median(veAT(muscleIdx,subjIdx),2), -median(veS(muscleIdx,subjIdx),2), median(vePS(muscleIdx,subjIdx),2)-median(lS(muscleIdx,subjIdx),2),'VariableNames',{'eA','eAT','lS','ePS_lS'});
%Model:

modelFitS2a=fitlm(ttS,'ePS_lS~eA+eAT-1','RobustOpts',rob)
learnS2a=modelFitS2a.Coefficients.Estimate;
learnS2aCI=modelFitS2a.coefCI;
r2S2a=uncenteredRsquared(modelFitS2a);
r2S2a=r2S2a.uncentered;
disp(['Uncentered R^2=' num2str(r2S2a,3)])

modelFitS2c=fitlm(ttS,'ePS_lS~lS+eAT-1','RobustOpts',rob)
learnS2c=modelFitS2c.Coefficients.Estimate;
learnS2cCI=modelFitS2c.coefCI;
r2S2c=uncenteredRsquared(modelFitS2c);
r2S2c=r2S2c.uncentered;
disp(['Uncentered R^2=' num2str(r2S2c,3)])

modelFitS3=fitlm(ttSb,'ePS~lS+eA+eAT-1','RobustOpts',rob)
learnS3=modelFitS3.Coefficients.Estimate;
learnS3CI=modelFitS3.coefCI;
r2S3=uncenteredRsquared(modelFitS3);
r2S3=r2S3.uncentered;
disp(['Uncentered R^2=' num2str(r2S3,3)])

modelFitS3b=fitlm(ttS,'ePS_lS~lS+eA+eAT-1','RobustOpts',rob)
learnS3b=modelFitS3b.Coefficients.Estimate;
learnS3bCI=modelFitS3b.coefCI;
r2S3b=uncenteredRsquared(modelFitS3b);
r2S3b=r2S3b.uncentered;
disp(['Uncentered R^2=' num2str(r2S3b,3)])

%%% LONG EXPOSURE
tt=table(-median(eA(muscleIdx,subjIdx),2), median(eAT(muscleIdx,subjIdx),2), -median(lA(muscleIdx,subjIdx),2), median(eP(muscleIdx,subjIdx),2)-median(lA(muscleIdx,subjIdx),2),'VariableNames',{'eA','eAT','lA','eP_lA'});
tt15=table(-median(e15A(muscleIdx,subjIdx),2), median(e15AT(muscleIdx,subjIdx),2), -median(lA(muscleIdx,subjIdx),2), median(e15P(muscleIdx,subjIdx),2)-median(lA(muscleIdx,subjIdx),2),'VariableNames',{'e15A','e15AT','lA','e15P_lA'});
ttAlt=table( median(eP(muscleIdx,subjIdx),2)-median(lA(muscleIdx,subjIdx),2)-median(eAT(muscleIdx,subjIdx),2),median(eP(muscleIdx,subjIdx),2)-median(lA(muscleIdx,subjIdx),2)-median(eA(muscleIdx,subjIdx),2),'VariableNames',{'eP_lA_eAT','eP_lA_eA'});
ttb=table(-median(eA(muscleIdx,subjIdx),2), median(eAT(muscleIdx,subjIdx),2), -median(lA(muscleIdx,subjIdx),2),median(eP(muscleIdx,subjIdx),2),'VariableNames',{'eA','eAT','lA','eP'});
tt1=table(-median(veA(muscleIdx,subjIdx),2), median(veAT(muscleIdx,subjIdx),2), -median(lA(muscleIdx,subjIdx),2),median(veP(muscleIdx,subjIdx),2), median(veP(muscleIdx,subjIdx),2)-median(lA(muscleIdx,subjIdx),2),'VariableNames',{'eA','eAT','lA','eP','eP_lA'});
ttAlt1=table( median(eP(muscleIdx,subjIdx),2)-median(lA(muscleIdx,subjIdx),2)-median(veAT(muscleIdx,subjIdx),2),median(veP(muscleIdx,subjIdx),2)-median(lA(muscleIdx,subjIdx),2)-median(veA(muscleIdx,subjIdx),2),'VariableNames',{'eP_lA_eAT','eP_lA_eA'});

%1 regressor:
modelFit1a=fitlm(tt,'eP_lA~eAT-1','RobustOpts',rob)
learn1a=modelFit1a.Coefficients.Estimate;
learn1aCI=modelFit1a.coefCI;
r21a=uncenteredRsquared(modelFit1a);
r21a=r21a.uncentered;
disp(['Uncentered R^2=' num2str(r21a,3)])

%2 regressors:
modelFit2a=fitlm(tt,'eP_lA~eA+eAT-1','RobustOpts',rob)
learn2a=modelFit2a.Coefficients.Estimate;
learn2aCI=modelFit2a.coefCI;
r22a=uncenteredRsquared(modelFit2a);
r22a=r22a.uncentered;
disp(['Uncentered R^2=' num2str(r22a,3)])

modelFit2a15=fitlm(tt15,'e15P_lA~e15A+e15AT-1','RobustOpts',rob)
learn2a15=modelFit2a15.Coefficients.Estimate;
learn2a15CI=modelFit2a15.coefCI;
r22a15=uncenteredRsquared(modelFit2a15);
r22a15=r22a15.uncentered;
disp(['Uncentered R^2=' num2str(r22a15,3)])

modelFit2c=fitlm(ttb,'eP~lA+eAT-1','RobustOpts',rob)
learn2c=modelFit2c.Coefficients.Estimate;
learn2cCI=modelFit2c.coefCI;
r22c=uncenteredRsquared(modelFit2c);
r22c=r22c.uncentered;
disp(['Uncentered R^2=' num2str(r22c,3)])

%2c new:
modelFit2c=fitlm(tt,'eP_lA~lA+eAT-1','RobustOpts',rob)
learn2c=modelFit2c.Coefficients.Estimate;
learn2cCI=modelFit2c.coefCI;
r22c=uncenteredRsquared(modelFit2c);
r22c=r22c.uncentered;
disp(['Uncentered R^2=' num2str(r22c,3)])

%All 3:
modelFit3=fitlm(ttb,'eP~eA+eAT+lA-1','RobustOpts',rob)
learn3=modelFit3.Coefficients.Estimate;
learn3CI=modelFit3.coefCI;
r23=uncenteredRsquared(modelFit3);
r23=r23.uncentered;
disp(['Uncentered R^2=' num2str(r23,3)])

modelFit3b=fitlm(tt,'eP_lA~eA+eAT+lA-1','RobustOpts',rob)
learn3b=modelFit3b.Coefficients.Estimate;
learn3bCI=modelFit3b.coefCI;
r23b=uncenteredRsquared(modelFit3b);
r23b=r23b.uncentered;
disp(['Uncentered R^2=' num2str(r23b,3)])

%NOTE: considering earlier epochs gives no further insight


%% Individual models::
rob='off'; %These models can't be fit robustly (doesn't converge)
%First: repeat the model(s) above on each subject:
clear modelFitAll* learnAll* 
for i=1:size(eA,2)
    ttAll=table(-eA(muscleIdx,i), eAT(muscleIdx,i), -lA(muscleIdx,i),eP(muscleIdx,i), eP(muscleIdx,i)-lA(muscleIdx,i),'VariableNames',{'eA','eAT','lA','eP','eP_lA'});  
    tt15All=table(-e15A(muscleIdx,i), e15AT(muscleIdx,i), -lA(muscleIdx,i),e15P(muscleIdx,i), e15P(muscleIdx,i)-lA(muscleIdx,i),'VariableNames',{'e15A','e15AT','lA','e15P','e15P_lA'}); 
    ttAllb=table(-eA(muscleIdx,i), eAT(muscleIdx,i), -lA(muscleIdx,i),eP(muscleIdx,i),'VariableNames',{'eA','eAT','lA','eP'}); 
    ttAll1=table(-veA(muscleIdx,i), veAT(muscleIdx,i), -lA(muscleIdx,i),veP(muscleIdx,i),  veP(muscleIdx,i)-lA(muscleIdx,i),'VariableNames',{'eA','eAT','lA','eP','eP_lA'});    

    %Model 1a: eP-lA regressed over eAT
    modelFitAll1a{i}=fitlm(ttAll,'eP_lA~eAT-1','RobustOpts',rob);
    learnAll1a(i,:)=modelFitAll1a{i}.Coefficients.Estimate;
    aux=uncenteredRsquared(modelFitAll1a{i});
    r2All1a(i)=aux.uncentered;
    
    %Model 2a: eP-lA regressed over eA and eAT
    modelFitAll2a{i}=fitlm(ttAll,'eP_lA~eA+eAT-1','RobustOpts',rob);
    learnAll2a(i,:)=modelFitAll2a{i}.Coefficients.Estimate;
    aux=uncenteredRsquared(modelFitAll2a{i});
    r2All2a(i)=aux.uncentered;
    
        %Model 2a: eP-lA regressed over eA and eAT (5 strides)
    modelFitAll2a15{i}=fitlm(tt15All,'e15P_lA~e15A+e15AT-1','RobustOpts',rob);
    learnAll2a15(i,:)=modelFitAll2a15{i}.Coefficients.Estimate;
    aux=uncenteredRsquared(modelFitAll2a15{i});
    r2All2a15(i)=aux.uncentered;
    
    %Model 2c: eP regressed onto lA and eAT
%     modelFitAll2c{i}=fitlm(ttAllb,'eP~lA+eAT-1');
%     learnAll2c(i,:)=modelFitAll2c{i}.Coefficients.Estimate;
%     aux=uncenteredRsquared(modelFitAll2c{i});
%     r2All2c(i)=aux.uncentered;
    
    %Model 2c new: eP-lA regressed onto lA and eAT
    modelFitAll2c{i}=fitlm(ttAll,'eP_lA~lA+eAT-1','RobustOpts',rob);
    learnAll2c(i,:)=modelFitAll2c{i}.Coefficients.Estimate;
    aux=uncenteredRsquared(modelFitAll2c{i});
    r2All2c(i)=aux.uncentered;

    %Model 3: eP regressed onto eA, eAT and lA
    modelFitAll3{i}=fitlm(ttAllb,'eP~eA+eAT+lA-1','RobustOpts',rob);
    learnAll3(i,:)=modelFitAll3{i}.Coefficients.Estimate;
    pAll3(i,:)=modelFitAll3{i}.Coefficients.pValue;
    aux=uncenteredRsquared(modelFitAll3{i});
    r2All3(i)=aux.uncentered;
    
    %Model 3alt:
    modelFitAll3b{i}=fitlm(ttAll,'eP_lA~eA+eAT+lA-1','RobustOpts',rob);
    learnAll3b(i,:)=modelFitAll3b{i}.Coefficients.Estimate;
    pAll3b(i,:)=modelFitAll3b{i}.Coefficients.pValue;
    aux=uncenteredRsquared(modelFitAll3b{i});
    r2All3b(i)=aux.uncentered;
    
    
    %Same models for short exposure:
    ttS=table(-eA(muscleIdx,i), eAT(muscleIdx,i), -lS(muscleIdx,i), ePS(muscleIdx,i)-lS(muscleIdx,i),'VariableNames',{'eA','eAT','lS','ePS_lS'});
    %ttS1=table(-veA(:,i), veAT(:,i), veS(:,i), vePS(:,i)-lS(:,i),'VariableNames',{'eA','eAT','lS','ePS_lS'});
    
    modelFitAllS2a{i}=fitlm(ttS,'ePS_lS~eA+eAT-1','RobustOpts',rob);
    learnAllS2a(i,:)=modelFitAllS2a{i}.Coefficients.Estimate;
    aux=uncenteredRsquared(modelFitAllS2a{i});
    r2AllS2a(i)=aux.uncentered;
    
    modelFitAllS2c{i}=fitlm(ttS,'ePS_lS~lS+eAT-1','RobustOpts',rob);
    learnAllS2c(i,:)=modelFitAllS2c{i}.Coefficients.Estimate;
    aux=uncenteredRsquared(modelFitAllS2c{i});
    r2AllS2c(i)=aux.uncentered;
    
    modelFitAllS3b{i}=fitlm(ttS,'ePS_lS~eA+eAT+lS-1','RobustOpts',rob);
    learnAllS3b(i,:)=modelFitAllS3b{i}.Coefficients.Estimate;
    aux=uncenteredRsquared(modelFitAllS3b{i});
    r2AllS3b(i)=aux.uncentered;
end
%% Display some summary statistics on Short vs. Long exposure:
if write
diary(['../intfig/FBmodeling_' groupName '_' date '_' num2str(round(1e6*(now-today)))])
end
disp(' ')
disp('%%%%%%%%%%%%%%%%%')
modNames={'1a','2a','2a15','S2a','3b','2c'};
modDesc={'LE:\beta_M only','LE','LE5','SE','LE3new','LEwoBetaS'};
for i=1:length(modNames)
    disp(' ')
    eval(['mod=modelFit' modNames{i} ';' ]);
    disp(['Model ' modNames{i} ' (' modDesc{i} '):'])
    disp(['Avg. (uncent.) R^2=' num2str(eval(['r2' modNames{i}]),4)])
    disp(['Indiv. \R^2=' num2str(mean(eval(['r2All' modNames{i}])),3) ' \pm ' num2str(std(eval(['r2All' modNames{i}])),3) ', (mean \pm std)'])
    disp(['Indiv. \R^2=' num2str(median(eval(['r2All' modNames{i}])),3) ' \pm ' num2str(iqr(eval(['r2All' modNames{i}])),3) ', (median \pm iqr)'])
    aux=mod.coefCI;
    for j=1:mod.NumCoefficients
        disp(['Avg. \beta ' mod.CoefficientNames{j} ' CI=' num2str(aux(j,:),3) ', p=' num2str(mod.Coefficients.pValue(j))])
        disp(['Indiv. \beta=' num2str(mean(eval(['learnAll' modNames{i} '(:,j)'])),3) ' \pm ' num2str(std(eval(['learnAll' modNames{i} '(:,j)'])),3) ', (mean \pm std)'])
        disp(['Indiv. \beta=' num2str(median(eval(['learnAll' modNames{i} '(:,j)'])),3) ' \pm ' num2str(iqr(eval(['learnAll' modNames{i} '(:,j)'])),3) ', (median \pm iqr)'])
    end
    disp(['Bayes Factor over 2a model:' num2str(BayesFactor(mod)./BayesFactor(modelFit2a),3)])
    disp(['Bayes Factor over 2c model:' num2str(BayesFactor(mod)./BayesFactor(modelFit2c),3)])
end
%Add explicit comparison between 2-factor models for LE and SE

[~,p1]=ttest(learnAll2a(subjIdx,1),learnAllS2a(subjIdx,1)); %\beta_S
p2=signrank(learnAll2a(subjIdx,1),learnAllS2a(subjIdx,1),'method','exact'); %\beta_S
d=mean(learnAll2a(subjIdx,:)-learnAllS2a(subjIdx,:))./std(learnAll2a-learnAllS2a); %Cohen's d to compute effect size
disp(['\beta_S, paired t-test p=' num2str(p1) ', Cohen''s d=' num2str(d(1)) ', signrank p=' num2str(p2)])
[~,p1]=ttest(learnAll2a(subjIdx,2),learnAllS2a(subjIdx,2)); %\beta_M
p2=signrank(learnAll2a(subjIdx,2),learnAllS2a(subjIdx,2),'method','exact'); %\beta_M
disp(['\beta_M, paired t-test p=' num2str(p1) ', Cohen''s d=' num2str(d(2)) ', signrank p=' num2str(p2)])

disp([num2str(sum((learnAll2a(subjIdx,1)-learnAllS2a(subjIdx,1))<0)) '/' num2str(numel(subjIdx)) ' subjects decreased their \beta_S'])
disp(['Median change: ' num2str(median(learnAll2a(subjIdx,1)-learnAllS2a(subjIdx,1))) ', mean: ' num2str(mean(learnAll2a(subjIdx,1)-learnAllS2a(subjIdx,1)))])
disp([num2str(sum((learnAll2a(subjIdx,2)-learnAllS2a(subjIdx,2))>0)) '/' num2str(numel(subjIdx)) ' subjects increased their \beta_M'])
disp(['Median change: ' num2str(median(learnAll2a(subjIdx,2)-learnAllS2a(subjIdx,2))) ', mean: ' num2str(mean(learnAll2a(subjIdx,2)-learnAllS2a(subjIdx,2)))])

if write
    diary off
end

%% learning vs. age
%Define EMG learning:
betaM=learnAll2a(:,2); 
betaS=learnAll2a(:,1);
r2=r2All2a;
%betaM=learnAll2c(:,1); %This is the regressor for eA* in the 2-regressor model that offers the best fit: same results.
betaFF=learnAll2c(:,2);
%betaM=learnAll1a(:,1); 
%FFamount=1+learnAll2c(:,2);
%betaM=learnAll3(:,2);
%betaS=-learnAll3(:,1);
%betaFF=learnAll3(:,3);

%Some auxiliary measures to confirm our results on age:
BB=reshape(lB,360,16);
BB=1;
norm_S2T=sqrt(sum((eP(muscleIdx,:)-lA(muscleIdx,:)).^2)')./sqrt(sum(BB.^2))'; 
norm_T2S=sqrt(sum((eA(muscleIdx,:)).^2)')./sqrt(sum(BB.^2))';
norm_lA=sqrt(sum(lA(muscleIdx,:).^2,1))'./sqrt(sum(BB.^2))';
norm_eP=sqrt(sum(eP(muscleIdx,:).^2,1))'./sqrt(sum(BB.^2))';
FFasym=sqrt(sum((lA(muscleIdx,:)-lAT(muscleIdx,:)).^2))'./sqrt(sum((lA(muscleIdx,:)).^2))';
ePT=fftshift(eP,1);
AEasym=sqrt(sum((eP(muscleIdx,:)-ePT(muscleIdx,:)).^2))'./sqrt(sum((eP(muscleIdx,:)).^2))';
EAasym=sqrt(sum((eA(muscleIdx,:)-eAT(muscleIdx,:)).^2))'./sqrt(sum((eA(muscleIdx,:)).^2))';

%%%%%%%%%%%%%%%
%Do fits (NOTE: stepLengthDiff is a slightly better predictor than SLA, but p-values change only slightly):
logFile=['../intfig/interSubjectRegressions_' groupName '_' date '_' num2str(round(1e6*(now-today)))];
if write
diary(logFile)
end
rob='on'; %These models CAN be fit robustly
display('----------------------\beta_M VS. AGE and SLA---------------------')
tt2=table(age(subjIdx)', SLA_eP(subjIdx),betaM(subjIdx),betaS(subjIdx),betaFF(subjIdx),norm_eP(subjIdx),norm_S2T(subjIdx),r2(subjIdx)','VariableNames',{'age','SLA_eP','beta_M','beta_S','beta_FF','norm_eP','norm_S2T','r2'}); %Taking SLA in eP minus lA makes SLA coefficients much less predictive (which is even better for making our point!)

learnVsAge=fitlm(tt2,'beta_M~age','RobustOpts',rob)
[r,p]=corr(betaM(subjIdx),age(subjIdx)','Type','Spearman');
disp(['Spearman''s r:' num2str(r) ', p=' num2str(p)])

staticVsAge=fitlm(tt2,'beta_S~age','RobustOpts',rob)
[r,p]=corr(betaS(subjIdx),age(subjIdx)','Type','Spearman');
disp(['Spearman''s r:' num2str(r) ', p=' num2str(p)])

r2VsAge=fitlm(tt2,'r2~age','RobustOpts',rob)
[r,p]=corr(r2(subjIdx)',age(subjIdx)','Type','Spearman');
disp(['Spearman''s r:' num2str(r) ', p=' num2str(p)])

learnVsSLA=fitlm(tt2,'beta_M~SLA_eP','RobustOpts',rob) 
[r,p]=corr(betaM(subjIdx),SLA_eP(subjIdx),'Type','Spearman');
disp(['Spearman''s r:' num2str(r) ', p=' num2str(p)])

learnVsBoth=fitlm(tt2,'beta_M~age+SLA_eP','RobustOpts',rob) 

learnVsBoth1=fitlm(tt2,'beta_M~age+norm_eP','RobustOpts',rob) %After accounting for aftereffect in EMG space, age explains nothing

staticVsBoth2=fitlm(tt2,'beta_S~age+norm_eP','RobustOpts',rob) %Doesn't affect it
ffVsAge=fitlm(tt2,'beta_FF~age','RobustOpts',rob)
%learnVsVel=fitlm(tt2,'beta_M~vel') %Sanity check: not correlated

%Some correlations with AEsize: unsurprisingly, it is very correlated to the regressors of eA* (strength of FB response)
%learnVsAEsize=fitlm(tt2,'beta_M~AEsize','RobustOpts',rob)
%AEsizeVsBoth=fitlm(tt2,'AEsize~SLA','RobustOpts',rob) %SLA and AEsize are VERY VERY HIGHLY CORRELATED -> WHY WOULD THIS BE ?
%learnVsBoth=fitlm(tt2,'beta_M~age+AEsize','RobustOpts',rob)
if write
diary off
txt=fileread(logFile);
txt=removeTags(txt);
fid=fopen(logFile,'w');
fwrite(fid,txt,'char');
fclose(fid);

%%%%%%%%%%%%%%%%
logFile=['../intfig/interSubjectAGE_' groupName '_' date '_' num2str(round(1e6*(now-today)))];
diary(logFile)
end
display('----------------------THE EFFECTS OF AGE ON RESPONSE SIZES--------------------------')
%Making sure that age is not a confound for sth. else: 
ttA=table(age(subjIdx)',norm_S2T(subjIdx),r2All2c(subjIdx)',norm_T2S(subjIdx),norm_lA(subjIdx),betaFF(subjIdx),SLA_eP(subjIdx),norm_eP(subjIdx),'VariableNames',{'age','norm_S2T','res','norm_T2S','norm_lA','beta_FF','SLA_eP','norm_eP'});

S2TvsAge=fitlm(ttA,'norm_S2T~age','RobustOpts',rob)   %Slightly (strongly if we exclude C01) (negatively) correlated: older subjs. show less feedback responses (as expected)
[rs,ps]=corr(norm_S2T(subjIdx),age(subjIdx)','Type','Spearman');
disp(['Spearman correlation: r=' num2str(rs) ', p=' num2str(ps)])

T2SvsAge=fitlm(ttA,'norm_T2S~age','RobustOpts',rob)   %NOT correlated -> Older subjects are not altogether weaker
[rs,ps]=corr(norm_T2S(subjIdx),age(subjIdx)','Type','Spearman');
disp(['Spearman correlation: r=' num2str(rs) ', p=' num2str(ps)])

AEvsAge=fitlm(ttA,'norm_eP~age','RobustOpts',rob)
[rs,ps]=corr(norm_eP(subjIdx),age(subjIdx)','Type','Spearman');
disp(['Spearman correlation: r=' num2str(rs) ', p=' num2str(ps)])

%AEvsAge_SLA=fitlm(ttA,'norm_eP~age+SLA_eP','RobustOpts',rob)
%resVsAge=fitlm(ttA,'res~age')           %Sanity check: residuals not correlated with age! this is proof that reduced regressors are NOT due to older subjects doing something different, but doing just LESS feedback
%FFvsAge=fitlm(ttA,'norm_lA~age','RobustOpts',rob)     %Learned response, also not correlated with age: they don't seem to be reaching a different SS
%Potential confound: they may have responses more aligned with eA, which is
%correlated to lA. Indeed on the regression with eA,eA*, the eA regressor
%is highly correlated with age. Is it more carryover and less feedback or a different feedback
%response? Or both? How to tell?
%FF3vsAge=fitlm(age(idx),FFasym(idx))    %Symmetry of learned response NOT correlated with age either
%FF2vsAge=fitlm(ttA,'beta_FF~age');  %Slight (pos) (strong if C01 excluded) correlation: they may be carrying over more (.01/year of age) 

SLAvsAge=fitlm(ttA,'SLA_eP~age')
[rs,ps]=corr(SLA_eP(subjIdx),age(subjIdx)','Type','Spearman');
disp(['Spearman correlation: r=' num2str(rs) ', p=' num2str(ps)])

if write
diary off
txt=fileread(logFile);
txt=removeTags(txt);
fid=fopen(logFile,'w');
fwrite(fid,txt,'char');
fclose(fid);

%%%%%%%%
logFile=['../intfig/interSubjectSLA_' groupName '_' date '_' num2str(round(1e6*(now-today)))];
diary(logFile)
end
display('-----------------------------WHAT EXPLAINS SLA?-----------------------------')
ttB=table(SLA_eP(subjIdx),age(subjIdx)',norm_S2T(subjIdx),norm_T2S(subjIdx),norm_lA(subjIdx),norm_eP(subjIdx),'VariableNames',{'SLA_eP','age','norm_S2T','norm_T2S','norm_lA','norm_eP'});
disp('age, norm_S2T, norm_T2S, norm_lA, norm_eP')
stepwisefit([age(subjIdx)',norm_S2T(subjIdx),norm_T2S(subjIdx),norm_lA(subjIdx),norm_eP(subjIdx)],SLA_eP(subjIdx))

fitlm(ttB,'SLA_eP~norm_eP','RobustOpts',rob)
[rs,ps]=corr(SLA_eP(subjIdx),norm_eP(subjIdx),'Type','Spearman');
disp(['Spearman correlation: r=' num2str(rs) ', p=' num2str(ps)])

fitlm(ttB,'norm_eP~SLA_eP+age','RobustOpts',rob)
fitlm(ttB,'SLA_eP~norm_eP+norm_lA')
fitlm(ttB,'SLA_eP~norm_S2T+norm_lA')
%FF2vsBoth=fitlm(ttA,'FFamount~age+SLA_eP') 
%FF2vsSLA=fitlm(ttA,'FFamount~SLA_eP') 

% Does walking speed determine feed-forward amounts?
%fitlm(velsC(idx),FFamount(idx))
%fitlm(velsC(idx),FFsize(idx))

%Some exploratory analysis on symmetry of responses:
%FFasymvsSLA=fitlm(SLA_eP(idx),FFasym(idx)) %Learned asym, not correlated with SLA (surprising)
%AEasymvsSLA=fitlm(SLA_eP(idx),AEasym(idx)) %This is VERY correlated with
%SLA (positively) -> ANY asymmetric response will lead to SLA? this doesn't
%even measure sign of asymmetry! -> sign may be implied by the fact that
%they all do roughly the same
%AEasymvsAge=fitlm(age(idx),AEasym(idx)) %Very weakly (p=.049) negatively correlated with age, somwhat stronger (p=.016) if we exclude C01
%EAasymvsSLA=fitlm(SLA_eP(idx),EAasym(idx)) %Not correlated
if write
    diary off
    txt=fileread(logFile);
    txt=removeTags(txt);
    fid=fopen(logFile,'w');
    fwrite(fid,txt,'char');
    fclose(fid);
end

%% Do plots for model comparison
fh=figure('Units','Normalized','OuterPosition',[0 .2 .65 .5*16/10]);
figuresColorMap
modelNames={'2a','3b','2c'};
idxY=age(subjIdx)<58; %Youngest 6, if we exclude C01
idxO=age(subjIdx)>63; %Oldest 6
for i=1:3 %Three models
    for j=1:2 %Exposure length OR age comparison
            eval(['data1=learnAllS' modelNames{i} ';']);
            eval(['data2=learnAll' modelNames{i} ';']);    
            eval(['data1M=learnS' modelNames{i} ';']);
            eval(['data2M=learn' modelNames{i} ';']);
        if j==2
            data=cat(3,data2(idxO,:), data2(idxY,:));
            dataM=nan(1,2);
            nn={['Older (>63y.o., N=6)'],['Younger (<57.3y.o., N=6)']};
            cc=[3,3];
            tt='Regressors vs. age';
        else
            data=cat(3,data1(subjIdx,:), data2(subjIdx,:));
            dataM=cat(2,data1M, data2M);
            nn={'Short Exp.','Long Exp.'};
            cc=[4,3];
            tt='Regressors vs. exposure length';
        end
    
    
    eval(['mod=modelFit' modelNames{i} ';']);

    ph=subplot(3,3,i+(j-1)*3);

    medianFlag=1;
    lineFlag=2; %Set to 1 to see within-subject changes
    [fh,ph]=prettyBarPlot(data,condColors(cc,:),medianFlag,lineFlag,nn,mod.CoefficientNames,ph);

    % %Add group average results:
    pS=scatter([1:size(dataM,1)]'-.19,[dataM(:,1)],120,condColors(4,:),'filled','MarkerFaceAlpha',1);
    p2=scatter([1:size(dataM,1)]'+.09,[dataM(:,2)],120,condColors(3,:),'filled','MarkerFaceAlpha',1);
    pS.Annotation.LegendInformation.IconDisplayStyle = 'off';
    p2.Annotation.LegendInformation.IconDisplayStyle = 'off';
    if j==2
    bb=findobj(ph,'Type','Bar');
    bb(1).FaceAlpha=1;
    bb=findobj(ph,'Type','Scatter');
    set(bb(1:2),'MarkerFaceAlpha',1);
    end
    set(ph,'YLim',[-.5 1.8])
    ylabel('Regressors')
    title(tt)
    end
    ph=subplot(3,3,i+6);
    hold on
    ss=[];
    for k=1:size(data2,2)
    %[rs,ps]=corr(age',data2(:,k),'Type','Pearson');
    [rs,ps]=corr(age',data2(:,k),'Type','Spearman');
    ss(k)=scatter(age,data2(:,k),50,condColors(3,:),'filled','MarkerFaceAlpha',1/k,'DisplayName',[mod.CoefficientNames{k} ' rs=' num2str(rs,3) ', ps= ' num2str(ps,3)]);
    xlabel('Age (y.o.)')
    ylabel('Regressors')
    pp=polyfit1PCA(age,data2(:,k),1);
    plot([min(age) max(age)],[min(age) max(age)]*pp(1)+pp(2),'k')
    end
    legend(ss)
end
%Save fig:
if write
    saveFig(fh,'../intfig/intersubj/',['modelComparison_' groupName],0)
end

%% Do plots alt
fh=figure('Units','Normalized','Position',[0 0 .5 .4])
figuresColorMap
modelNames={'2a','3b','2c'};
idxY=age(subjIdx)<58; %Youngest 6, if we exclude C01
idxO=age(subjIdx)>63; %Oldest 6
for i=1 %Three models
    for j=1
            eval(['data1=learnAllS' modelNames{i} ';']);
            eval(['data2=learnAll' modelNames{i} ';']);    
            eval(['data1M=learnS' modelNames{i} ';']);
            eval(['data2M=learn' modelNames{i} ';']);
            data=cat(3,data1(subjIdx,:), data2(subjIdx,:));
            data=permute(data,[1,3,2]);
            dataM=cat(2,data1M, data2M);
            covM=cat(2,modelFit2a.Coefficients.SE,modelFitS2a.Coefficients.SE);
            nn={'\beta_S','\beta_M'};
            cc=[4,3];
            tt='Regressors vs. exposure length';
    
    
    eval(['mod=modelFit' modelNames{i} ';']);

    ph=subplot(1,2,1);
    medianFlag=1;
    lineFlag=2; %Set to 1 to see within-subject changes
    [fh,ph]=prettyBarPlot(data,colorTransitions,medianFlag,lineFlag,nn,{'Short','Long'},ph);

    % %Add group average results:
    pS=scatter([1:size(dataM,1)]'-.19,[dataM(:,1)],120,colorTransitions(1,:),'filled','MarkerFaceAlpha',1);
    p2=scatter([1:size(dataM,1)]'+.09,[dataM(:,2)],120,colorTransitions(2,:),'filled','MarkerFaceAlpha',1);
    pS.Annotation.LegendInformation.IconDisplayStyle = 'off';
    p2.Annotation.LegendInformation.IconDisplayStyle = 'off';
    set(ph,'YLim',[-.5 1.8])
    ylabel('Regressors')
    title(tt)
    set(gca,'FontSize',14)
    
    subplot(1,2,2)
    bb=bar(reshape(dataM,2,2),'EdgeColor','none');
    bb(1).FaceColor=colorTransitions(1,:);
    bb(2).FaceColor=colorTransitions(2,:);
    hold on
    %errorbar(reshape(.15*[-1; 1]+[1 2],4,1),reshape(dataM',4,1),reshape(covM',4,1),'Color','k','LineWidth',2,'LineStyle','none')
    for k=1:2
        errorbar(.15+[1 2]-(2-k)*.3,dataM(:,k),-2*covM(:,k),2*covM(:,k),'Color',colorTransitions(k,:),'LineWidth',2,'LineStyle','none') %Plotting +- 2ste
    end
    axis([.5 2.5 -.2 1.3])
    set(gca,'XTickLabel',{'Short','Long'})
    legend({'\beta_S','\beta_M'},'Location','Northeast')
    ylabel('Regressors')
    title('Regressors vs. exposure length')
    end
end
set(gca,'FontSize',14)
%Save fig:
if write
   saveFig(fh,'../intfig/intersubj/',['modelComparison_' groupName 'ALT'],0)
end


%% Age and speed effects
mod=modelFit2a;
fh=figure('Units','Normalized','OuterPosition',[0 .2 .8 .5*16/10]);
for i=1:2
    switch i
        case 1 %age
            x=age;
            xl='Age (y.o.)';
        case 2 %speed
            x=velsC;
            xl='Mid walking speed (m/s)';
    end
 
    %Five panels:
    for j=1:5
        switch j
            case 1 %First panel: regressors vs. explanatory variable
                data2=[learnAll2a r2All2a'];
                names=[mod.CoefficientNames, {'R^2'}];
                yl='Regressors';
                tt='Model fit';
                ci=[3,3,2];
                ccc=condColors(ci,:);
                ccc=[colorTransitions;zeros(1,3)];
                ai=[1,1,1];
            case 2 %Second panel: eP and lA sizes
                data2=[norm_lA];
                names={'||LateA||'};
                yl='Response size (a.u.)';
                tt='Late Adaptation';
                ci=[2];
                ccc=condColors(ci,:);
                ai=[1];
                %data2=[r2All2a'];
                %ccc=zeros(1,3);
                %names={'R^2'};
                %yl='Pearson''s R^2';
                %tt='Model goodness-of-fit';
            case 3 %Third panel: feedback response sizes 
                data2=[norm_T2S,norm_S2T]; 
                names={'||FBK_{tied-to-split}||','||FBK_{split-to-tied}||'}; 
                yl='Response size (a.u.)'; 
                tt='Feedback responses'; 
                ci=[2,3]; 
                ccc=condColors(ci,:);
                ccc=colorTransitions;
                ai=[1 1];  
            case 4 %Kin aftereffects 
                data2=[SLA_eP]; 
                names={'SLA_{eP}'}; 
                yl='Step-length asymmetry'; 
                tt='Kinematic Aftereffects'; 
                ci=[3]; 
                ccc=condColors(ci,:);
                ai=1; 
            case 5 %Overlayed on 4, EMG aftereffects
                data2=[norm_eP];
                names={'||EarlyP||'};
                yl='Response size (a.u.)';
                tt='EMG Aftereffects';
                ci=[3];
                ccc=condColors(ci,:);
                ai=[1];
        end
        scf={'flat','flat'};
            sp=subplot(2,5,j+(i-1)*5);
        hold on
        ss=[];
        for k=1:min(2,length(names))
            [rs,ps]=corr(x(subjIdx)',data2(subjIdx,k),'Type','Spearman');
            mdl=fitlm(x(subjIdx)',data2(subjIdx,k),'RobustOpts',rob);
             %[rs,ps]=corr(x(subjIdx)',data2(subjIdx,k),'Type','Pearson');
            ss(k)=scatter(x(subjIdx),data2(subjIdx,k),50,ccc(k,:),'MarkerFaceColor',scf{k},'MarkerEdgeColor','none','MarkerFaceAlpha',ai(k),'DisplayName',[names{k} ' r=' num2str(rs,2) ', p= ' num2str(ps,2)]);% ', robR^2=' num2str(mdl.Rsquared.Ordinary,2) ', robP=' num2str(mdl.Coefficients.pValue(2),2)]);
            pp=polyfit1PCA(x(subjIdx),data2(subjIdx,k),1);
            pp=polyfit(x(subjIdx)',data2(subjIdx,k),1);
            if ps<.05
            plot([min(x) max(x)],[min(x) max(x)]*pp(1)+pp(2),'Color',(ai(k))*ccc(k,:)+(1-ai(k))*ones(1,3),'LineWidth',2)
            end
        end
        xlabel(xl)
        ylabel(yl)
        title(tt)
        lg=legend(ss);
        lg.Color='w';

    end
end
    %Save fig:
    if write
        saveFig(fh,'../intfig/intersubj/',['AgeSpeedEffects_' groupName],0)
    end
%% Alternative figure
fh=figure;
data2=learnAll2a;
c2=(condColors(3,:));
c2=zeros(1,3);
c1=condColors(4,:);
c1=.5*ones(1,3);
normAge=(age-min(age))/(max(age)-min(age));
%scatter(data2(:,1),data2(:,2),60,normAge','filled')
scatter(data2(subjIdx,1),data2(subjIdx,2),60,c2,'filled','MarkerFaceAlpha',.7)
data3=learnAllS2a;
hold on
scatter(data3(subjIdx,1),data3(subjIdx,2),60,c1,'filled','MarkerFaceAlpha',.7)
%cc=colorbar;
xlabel(['\color[rgb]{' num2str(colorTransitions(1,1)) ',' num2str(colorTransitions(1,2)) ',' num2str(colorTransitions(1,3)) '} \beta_S'])
ylabel(['\color[rgb]{' num2str(colorTransitions(2,1)) ',' num2str(colorTransitions(2,2)) ',' num2str(colorTransitions(2,3)) '} \beta_M'])
ax=gca;
ax.XLabel.FontWeight='bold';
ax.XColor=colorTransitions(1,:);
ax.YColor=colorTransitions(2,:);
ax.XAxis.LineWidth=2;
ax.YAxis.LineWidth=2;
ax.YLabel.FontWeight='bold';
%set(cc,'Ticks',[0:.2:1],'TickLabels',num2str((max(age)-min(age))*[0:.2:1]' +min(age),2))
rL=modelFit2a.Coefficients.Estimate;
rS=modelFitS2a.Coefficients.Estimate;
hold on
scatter(rS(1),rS(2),150,c1,'filled')
text(rS(1),rS(2)+.12,{'   Short','exposure'},'Color',c1/2,'FontWeight','bold')
scatter(rL(1),rL(2),150,c2,'filled')
%text(rL(1)+.05,rL(2),{'   Long','exposure'},'Color',c2,'FontWeight','bold')
text(rL(1)+.05,rL(2),{'Long','exposure'},'Color',c2,'FontWeight','bold')
scatter(1,0,100,'k','filled','MarkerFaceColor',colorTransitions(1,:))
scatter(0,1,100,'k','filled','MarkerFaceColor',colorTransitions(2,:))
text(.5,-.02,{'   H2: No','Adaptation'},'FontWeight','bold','Color',colorTransitions(1,:))
text(.05,.99,{' H3: ''New normal'''},'FontWeight','bold','Color',colorTransitions(2,:))
%TO DO: add expected split-to-tied and tied-to-split
axis([-.45 1.55 -.5 1.05])
title('Regression analysis of \Delta EMG_{split-to-tied}')
ax=gca;
ax.YLabel.FontWeight='bold';
ax.XLabel.FontWeight='bold';
ax.YLabel.FontSize=14;
ax.XLabel.FontSize=14;

% Add 15 stride regressors:
%data2=learnAll2a15;
%scatter(data2(:,1),data2(:,2),60,c2,'filled','MarkerFaceAlpha',.3)
%rL=modelFit2a15.Coefficients.Estimate;
%scatter(rL(1),rL(2),150,condColors(3,:),'filled','MarkerFaceAlpha',.3)
%text(rL(1)+.05,rL(2),{'LE15'},'Color',c2,'FontWeight','bold')

    %Save fig:
    if write
        saveFig(fh,'../intfig/intersubj/',['RegressorSpace_' groupName],0)
    end
