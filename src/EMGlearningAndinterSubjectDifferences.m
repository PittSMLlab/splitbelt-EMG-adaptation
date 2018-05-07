%% 
addpath(genpath('./fun/'))
addpath(genpath('../pubfig/auxFun/'))
%% Define data from params if necessary
groupName='patients';
idx=[1:6,8:10,12:16]; %Excluding 7 and 11 which dont have short exp
%groupName='controls';
%idx=1:16;
%loadEMGParams_controls(groupName)

%% Get all needed vars
load(['../data/' groupName 'EMGsummary'])
load ../data/bioData.mat
write=true;
%write=false;
%% Define eAT, lAT, etc
eAT=fftshift(eA,1);
lAT=fftshift(lA,1);
veAT=fftshift(veA,1);
%% Do group analysis:
rob='off';
%%%Short-exposure(to compare):
ttS=table(-mean(eA(:,idx),2), mean(eAT(:,idx),2), -mean(lS(:,idx),2), mean(ePS(:,idx),2)-mean(lS(:,idx),2),'VariableNames',{'eA','eAT','lS','ePS_lS'});
ttSb=table(-mean(eA(:,idx),2), mean(eAT(:,idx),2), -mean(lS(:,idx),2), mean(ePS(:,idx),2),'VariableNames',{'eA','eAT','lS','ePS'});
ttS1=table(-mean(veA(:,idx),2), mean(veAT(:,idx),2), -mean(veS(:,idx),2), mean(vePS(:,idx),2)-mean(lS(:,idx),2),'VariableNames',{'eA','eAT','lS','ePS_lS'});
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
tt=table(-mean(eA(:,idx),2), mean(eAT(:,idx),2), -mean(lA(:,idx),2), mean(eP(:,idx),2)-mean(lA(:,idx),2),'VariableNames',{'eA','eAT','lA','eP_lA'});
ttAlt=table( mean(eP(:,idx),2)-mean(lA(:,idx),2)-mean(eAT(:,idx),2),mean(eP(:,idx),2)-mean(lA(:,idx),2)-mean(eA(:,idx),2),'VariableNames',{'eP_lA_eAT','eP_lA_eA'});
ttb=table(-mean(eA(:,idx),2), mean(eAT(:,idx),2), -mean(lA(:,idx),2),mean(eP(:,idx),2),'VariableNames',{'eA','eAT','lA','eP'});
tt1=table(-mean(veA(:,idx),2), mean(veAT(:,idx),2), -mean(lA(:,idx),2),mean(eP(:,idx),2), mean(eP(:,idx),2)-mean(lA(:,idx),2),'VariableNames',{'eA','eAT','lA','eP','eP_lA'});
ttAlt1=table( mean(eP(:,idx),2)-mean(lA(:,idx),2)-mean(veAT(:,idx),2),mean(eP(:,idx),2)-mean(lA(:,idx),2)-mean(veA(:,idx),2),'VariableNames',{'eP_lA_eAT','eP_lA_eA'});

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
    ttAll=table(-eA(:,i), eAT(:,i), -lA(:,i),eP(:,i), eP(:,i)-lA(:,i),'VariableNames',{'eA','eAT','lA','eP','eP_lA'});  
    ttAllb=table(-eA(:,i), eAT(:,i), -lA(:,i),eP(:,i),'VariableNames',{'eA','eAT','lA','eP'}); 
    ttAll1=table(-veA(:,i), veAT(:,i), -lA(:,i),veP(:,i),  veP(:,i)-lA(:,i),'VariableNames',{'eA','eAT','lA','eP','eP_lA'});    

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
    ttS=table(-eA(:,i), eAT(:,i), -lS(:,i), ePS(:,i)-lS(:,i),'VariableNames',{'eA','eAT','lS','ePS_lS'});
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
modNames={'1a','2a','S2a','3b','2c'};
modDesc={'LE:\beta_M only','LE','SE','LE3new','LEwoBetaS'};
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
if write
diary off
end

%% learning vs. age
%Define EMG learning:
betaM=learnAll2a(:,2); 
betaS=learnAll2a(:,1);
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
norm_S2T=sqrt(sum((eP-lA).^2)')./sqrt(sum(BB.^2))'; 
norm_T2S=sqrt(sum((eA).^2)')./sqrt(sum(BB.^2))';
norm_lA=sqrt(sum(lA.^2,1))'./sqrt(sum(BB.^2))';
norm_eP=sqrt(sum(eP.^2,1))'./sqrt(sum(BB.^2))';
FFasym=sqrt(sum((lA-lAT).^2))'./sqrt(sum((lA).^2))';
ePT=fftshift(eP,1);
AEasym=sqrt(sum((eP-ePT).^2))'./sqrt(sum((eP).^2))';
EAasym=sqrt(sum((eA-eAT).^2))'./sqrt(sum((eA).^2))';

%%%%%%%%%%%%%%%
%Do fits (NOTE: stepLengthDiff is a slightly better predictor than SLA, but p-values change only slightly):
logFile=['../intfig/interSubjectRegressions_' groupName '_' date '_' num2str(round(1e6*(now-today)))];
if write
diary(logFile)
end
rob='on'; %These models CAN be fit robustly
display('----------------------\beta_M VS. AGE and SLA---------------------')
tt2=table(age(idx)', SLA_eP(idx),betaM(idx),betaS(idx),betaFF(idx),norm_eP(idx),norm_S2T(idx),'VariableNames',{'age','SLA_eP','beta_M','beta_S','beta_FF','norm_eP','norm_S2T'}); %Taking SLA in eP minus lA makes SLA coefficients much less predictive (which is even better for making our point!)
learnVsAge=fitlm(tt2,'beta_M~age','RobustOpts',rob)
learnVsBoth1=fitlm(tt2,'beta_M~age+norm_eP','RobustOpts',rob) %After accounting for aftereffect in EMG space, age explains nothing
learnVsSLA=fitlm(tt2,'beta_M~SLA_eP','RobustOpts',rob) 
learnVsBoth=fitlm(tt2,'beta_M~age+SLA_eP','RobustOpts',rob) 
staticVsAge=fitlm(tt2,'beta_S~age','RobustOpts',rob)
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
ttA=table(age(idx)',norm_S2T(idx),r2All2c(idx)',norm_T2S(idx),norm_lA(idx),betaFF(idx),SLA_eP(idx),norm_eP(idx),'VariableNames',{'age','norm_S2T','res','norm_T2S','norm_lA','beta_FF','SLA_eP','norm_eP'});
S2TvsAge=fitlm(ttA,'norm_S2T~age','RobustOpts',rob)   %Slightly (strongly if we exclude C01) (negatively) correlated: older subjs. show less feedback responses (as expected)
[rs,ps]=corr(norm_S2T(idx),age(idx)','Type','Spearman');
disp(['Spearman correlation: r=' num2str(rs) ', p=' num2str(ps)])
AEvsAge=fitlm(ttA,'norm_eP~age','RobustOpts',rob)
[rs,ps]=corr(norm_eP(idx),age(idx)','Type','Spearman');
disp(['Spearman correlation: r=' num2str(rs) ', p=' num2str(ps)])
AEvsAge_SLA=fitlm(ttA,'norm_eP~age+SLA_eP','RobustOpts',rob)
%resVsAge=fitlm(ttA,'res~age')           %Sanity check: residuals not correlated with age! this is proof that reduced regressors are NOT due to older subjects doing something different, but doing just LESS feedback
T2SvsAge=fitlm(ttA,'norm_T2S~age','RobustOpts',rob)   %NOT correlated -> Older subjects are not altogether weaker
FFvsAge=fitlm(ttA,'norm_lA~age','RobustOpts',rob)     %Learned response, also not correlated with age: they don't seem to be reaching a different SS
%Potential confound: they may have responses more aligned with eA, which is
%correlated to lA. Indeed on the regression with eA,eA*, the eA regressor
%is highly correlated with age. Is it more carryover and less feedback or a different feedback
%response? Or both? How to tell?
%FF3vsAge=fitlm(age(idx),FFasym(idx))    %Symmetry of learned response NOT correlated with age either
FF2vsAge=fitlm(ttA,'beta_FF~age');  %Slight (pos) (strong if C01 excluded) correlation: they may be carrying over more (.01/year of age) 
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
ttB=table(SLA_eP(idx),age(idx)',norm_S2T(idx),norm_T2S(idx),norm_lA(idx),norm_eP(idx),'VariableNames',{'SLA_eP','age','norm_S2T','norm_T2S','norm_lA','norm_eP'});
disp('age, norm_S2T, norm_T2S, norm_lA, norm_eP')
stepwisefit([age(idx)',norm_S2T(idx),norm_T2S(idx),norm_lA(idx),norm_eP(idx)],SLA_eP(idx))
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
idxY=age(idx)<57.3; %Youngest 6
idxO=age(idx)>63; %Oldest 6
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
            data=cat(3,data1, data2);
            dataM=cat(2,data1M, data2M);
            nn={'Short Exp.','Long Exp.'};
            cc=[1,3];
            tt='Regressors vs. exposure length';
        end
    
    
    eval(['mod=modelFit' modelNames{i} ';']);

    ph=subplot(3,3,i+(j-1)*3);

    medianFlag=1;
    lineFlag=2; %Set to 1 to see within-subject changes
    [fh,ph]=prettyBarPlot(data,condColors(cc,:),medianFlag,lineFlag,nn,mod.CoefficientNames,ph);

    % %Add group average results:
    pS=scatter([1:size(dataM,1)]'-.19,[dataM(:,1)],120,condColors(1,:),'filled','MarkerFaceAlpha',1);
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
    [rs,ps]=corr(age',data2(:,k),'Type','Pearson');
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

    %Four panels:
    for j=1:4
        switch j
            case 1 %First panel: regressors vs. explanatory variable
                data2=[learnAll2a r2All2a'];
                names=[mod.CoefficientNames, {'R^2'}];
                yl='Regressors';
                tt='Model fit';
                ci=[3,3,2];
                ai=[1,.5,1];
            case 2 %Second panel: eP and lA sizes
                data2=[norm_eP,norm_lA];
                names={'||eP_B||','||lA_B||'};
                yl='Response size (a.u.)';
                tt='Adaptation transfer';
                ci=[3,2];
                ai=[1 1];
            case 3 %Third panel: feedback response sizes
                data2=[norm_T2S,norm_S2T];
                names={'||eA_B||','||eP_B-lA_B||'};
                yl='Response size (a.u.)';
                tt='Feedback responses';
                ci=[2,3];
                ai=[1 1];
            case 4 %Fourth: SLA_eP vs expl. variable
                data2=[SLA_eP];
                names={'SLA_{eP}'};
                yl='Step-length asymmetry';
                tt='Kinematic aftereffects';
                ci=[3];
                ai=1;
        end
        subplot(2,4,j+(i-1)*4)
        hold on
        ss=[];
        for k=1:min(2,length(names))
            [rs,ps]=corr(x(idx)',data2(idx,k),'Type','Spearman');
            ss(k)=scatter(x(idx),data2(idx,k),50,condColors(ci(k),:),'filled','MarkerFaceAlpha',ai(k),'DisplayName',[names{k} ' r=' num2str(rs,2) ', p= ' num2str(ps,2)]);
            pp=polyfit1PCA(x(idx),data2(idx,k),1);
            pp=polyfit(x(idx)',data2(idx,k),1);
            if ps<.05
            plot([min(x) max(x)],[min(x) max(x)]*pp(1)+pp(2),'Color',(ai(k))*condColors(ci(k),:)+(1-ai(k))*ones(1,3),'LineWidth',2)
            end
        end
        legend(ss)
        xlabel(xl)
        ylabel(yl)
        title(tt)
    end
end
    %Save fig:
    if write
        saveFig(fh,'../intfig/intersubj/',['AgeSpeedEffects_' groupName],0)
    end
%% Alternative figure
fh=figure;
data2=learnAll2a;
c1=[1,0,0]*.9;
c2=(condColors(3,:));
c1=condColors(1,:)*1.8;
normAge=(age-min(age))/(max(age)-min(age));
scatter(data2(:,1),data2(:,2),60,normAge','filled')
colormap((c1.*[0:.01:1]'+c2.*[1:-.01:0]').^.5)
cc=colorbar;
xlabel('\beta_S')
ylabel('\beta_M')
set(cc,'Ticks',[0:.2:1],'TickLabels',num2str((max(age)-min(age))*[0:.2:1]' +min(age),2))
rL=modelFit2a.Coefficients.Estimate;
rS=modelFitS2a.Coefficients.Estimate;
hold on
scatter(rS(1),rS(2),150,condColors(1,:),'filled')
text(rS(1)-.15,rS(2)-.1,{'   Short','exposure'})
scatter(rL(1),rL(2),150,condColors(3,:),'filled')
text(rL(1)+.05,rL(2),{'   Long','exposure'})
scatter(1,0,100,'k','filled')
scatter(0,1,100,'k','filled')
text(.8,.1,{'   H2: No','Adaptation'})
text(-.4,.99,{' H3: Ideal'; 'Adaptation'})
%TO DO: add expected split-to-tied and tied-to-split
axis([-.5 1.35 -.2 1.1])
title('Projection of split-to-tied changes in muscle activity')
    %Save fig:
    if write
        saveFig(fh,'../intfig/intersubj/',['RegressorSpace_' groupName],0)
    end
%%
% figuresColorMap
% %First: eAT regressor vs age
% fh1=figure('Units','Normalized','OuterPosition',[0 .2 .5 .5*16/10]);
% subplot(2,2,1)
% model=learnVsAge;
% model.plotPartialDependence('age')
% ylabel('FB learning (\beta_M)')
% xlabel('Age (y.o.)')
% hold on
% p2=plot(age,betaM,'o','MarkerFaceColor',condColors(3,:),'Color','none');
% ax=gca;
% ax.Title.String=['FB learning vs. age, p=' num2str(model.Coefficients.pValue(2)) ', BF=' num2str(BayesFactor(learnVsAge),3)];
% txt = evalc('model.disp');
% warning('off','MATLAB:handle_graphics:exceptions:SceneNode')
% text(40,-.5,removeTags(txt(2:end-1)),'Fontsize',6)
% txt = evalc('learnVsBoth.disp');
% text(40,-1.2,removeTags(txt(2:end-1)),'Fontsize',6)
% %warning('on','MATLAB:handle_graphics:exceptions:SceneNode') %Turning
% %warnings on BEFORE the cell is done makes the warning visible for the
% %whole cell (!)
% text(40,-1.55,['BF both vs. age=' num2str(BayesFactor(learnVsBoth)./BayesFactor(learnVsAge),3)],'FontSize',6)
% text(40,-1.6,['BF both vs. SLA=' num2str(BayesFactor(learnVsBoth)./BayesFactor(learnVsSLA),3)],'FontSize',6)
% set(gca,'YLim',[0 1])
% 
% %Second: lA regressor vs age
% subplot(2,2,2)
% model=FF2vsAge;
% model.plotPartialDependence('age')
% ylabel('Feedforward carryover (\beta_{FF})')
% xlabel('Age (y.o.)')
% hold on
% plot(age,betaFF,'o','MarkerFaceColor',p2.MarkerFaceColor,'Color','none')
% ax=gca;
% ax.Title.String=['FF carryover vs. age, p=' num2str(model.Coefficients.pValue(2)) ', BF=' num2str(BayesFactor(FF2vsAge),3)];
% txt = evalc('model.disp');
% warning('off','MATLAB:handle_graphics:exceptions:SceneNode')
% text(40,-.5,removeTags(txt(2:end-1)),'Fontsize',6)
% %txt = evalc('FF2vsBoth.disp');
% %text(40,-1.2,removeTags(txt(2:end-1)),'Fontsize',6)
% %warning('on','MATLAB:handle_graphics:exceptions:SceneNode')
% %text(40,-1.55,['BF both vs. age=' num2str(BayesFactor(FF2vsBoth)./BayesFactor(FF2vsAge),3)],'FontSize',6)
% %text(40,-1.6,['BF both vs. SLA=' num2str(BayesFactor(FF2vsBoth)./BayesFactor(FF2vsSLA),3)],'FontSize',6)
% set(gca,'YLim',[0 1])
% if write
% saveFig(fh1,'../intfig/',['AgeVsFBmirroring_' groupName],0)
% end
% 
