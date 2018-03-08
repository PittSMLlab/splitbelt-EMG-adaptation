%% Load data
loadEMGParams_controls
%Define eAT, lAT, etc
eAT=fftshift(eA,1);
lAT=fftshift(lA,1);
veAT=fftshift(veA,1);
%% Do group analysis:
idx=1:16;
%idx=ageC<mean(ageC); %To look at younger subjects only
%idx=age<57.3; %Youngest 6
%idx=age>63; %Oldest 6

%%%Short-exposure(to compare):
ttS=table(-mean(eA(:,idx),2), mean(eAT(:,idx),2), mean(lS(:,idx),2), mean(ePS(:,idx),2)-mean(lS(:,idx),2),'VariableNames',{'eA','eAT','lS','ePS_lS'});
ttSb=table(-mean(eA(:,idx),2), mean(eAT(:,idx),2), mean(lS(:,idx),2), mean(ePS(:,idx),2),'VariableNames',{'eA','eAT','lS','ePS'});
ttS1=table(-mean(veA(:,idx),2), mean(veAT(:,idx),2), mean(veS(:,idx),2), mean(vePS(:,idx),2)-mean(lS(:,idx),2),'VariableNames',{'eA','eAT','lS','ePS_lS'});
%Model:
modelFitS2=fitlm(ttS,'ePS_lS~eA+eAT-1')
learnS2=modelFitS2.Coefficients.Estimate;
learnS2CI=modelFitS2.coefCI;
r2S2=uncenteredRsquared(modelFitS2);
r2S2=r2S2.uncentered;
disp(['Uncentered R^2=' num2str(r2S2,3)])

modelFitS3=fitlm(ttSb,'ePS~lS+eA+eAT-1')
learnS3=modelFitS3.Coefficients.Estimate;
learnS3CI=modelFitS3.coefCI;
r2S3=uncenteredRsquared(modelFitS3);
r2S3=r2S3.uncentered;
disp(['Uncentered R^2=' num2str(r2S3,3)])

%%% LONG EXPOSURE
tt=table(-mean(eA(:,idx),2), mean(eAT(:,idx),2), mean(lA(:,idx),2), mean(eP(:,idx),2)-mean(lA(:,idx),2),'VariableNames',{'eA','eAT','lA','eP_lA'});
ttAlt=table( mean(eP(:,idx),2)-mean(lA(:,idx),2)-mean(eAT(:,idx),2),mean(eP(:,idx),2)-mean(lA(:,idx),2)-mean(eA(:,idx),2),'VariableNames',{'eP_lA_eAT','eP_lA_eA'});
ttb=table(-mean(eA(:,idx),2), mean(eAT(:,idx),2), mean(lA(:,idx),2),mean(eP(:,idx),2),'VariableNames',{'eA','eAT','lA','eP'});
tt1=table(-mean(veA(:,idx),2), mean(veAT(:,idx),2), mean(lA(:,idx),2),mean(eP(:,idx),2), mean(eP(:,idx),2)-mean(lA(:,idx),2),'VariableNames',{'eA','eAT','lA','eP','eP_lA'});
ttAlt1=table( mean(eP(:,idx),2)-mean(lA(:,idx),2)-mean(veAT(:,idx),2),mean(eP(:,idx),2)-mean(lA(:,idx),2)-mean(veA(:,idx),2),'VariableNames',{'eP_lA_eAT','eP_lA_eA'});

%2 regressors:
modelFit2a=fitlm(tt,'eP_lA~eA+eAT-1')
learn2a=modelFit2a.Coefficients.Estimate;
learn2aCI=modelFit2a.coefCI;
r22a=uncenteredRsquared(modelFit2a);
r22a=r22a.uncentered;
disp(['Uncentered R^2=' num2str(r22a,3)])

modelFit2c=fitlm(ttb,'eP~lA+eAT-1')
learn2c=modelFit2c.Coefficients.Estimate;
learn2cCI=modelFit2c.coefCI;
r22c=uncenteredRsquared(modelFit2c);
r22c=r22c.uncentered;
disp(['Uncentered R^2=' num2str(r22c,3)])

%All 3:
modelFit3=fitlm(ttb,'eP~eA+eAT+lA-1')
learn3=modelFit3.Coefficients.Estimate;
learn3CI=modelFit3.coefCI;
r23=uncenteredRsquared(modelFit3);
r23=r23.uncentered;
disp(['Uncentered R^2=' num2str(r23,3)])

%NOTE: considering earlier epochs gives no further insight


%% Individual models::

%First: repeat the model(s) above on each subject:
clear modelFitAll* learnAll* 
for i=1:size(eA,2)
    ttAll=table(-eA(:,i), eAT(:,i), lA(:,i),eP(:,i), eP(:,i)-lA(:,i),'VariableNames',{'eA','eAT','lA','eP','eP_lA'});  
    ttAllb=table(-eA(:,i), eAT(:,i), lA(:,i),eP(:,i),'VariableNames',{'eA','eAT','lA','eP'}); 
    ttAll1=table(-veA(:,i), veAT(:,i), lA(:,i),veP(:,i),  veP(:,i)-lA(:,i),'VariableNames',{'eA','eAT','lA','eP','eP_lA'});    

    %Model 2a: eP-lA regressed over eA and eAT
    modelFitAll2a{i}=fitlm(ttAll,'eP_lA~eA+eAT-1');
    learnAll2a(i,:)=modelFitAll2a{i}.Coefficients.Estimate;
    aux=uncenteredRsquared(modelFitAll2a{i});
    r2All2a(i)=aux.uncentered;
    
    %Model 2c: eP regressed onto lA and eAT
    modelFitAll2c{i}=fitlm(ttAllb,'eP~lA+eAT-1');
    learnAll2c(i,:)=modelFitAll2c{i}.Coefficients.Estimate;
    aux=uncenteredRsquared(modelFitAll2c{i});
    r2All2c(i)=aux.uncentered;

    %Model 3: eP regressed onto eA, eAT and lA
    modelFitAll3{i}=fitlm(ttAllb,'eP~eA+eAT+lA-1');
    learnAll3(i,:)=modelFitAll3{i}.Coefficients.Estimate;
    pAll3(i,:)=modelFitAll3{i}.Coefficients.pValue;
    aux=uncenteredRsquared(modelFitAll3{i});
    r2All3(i)=aux.uncentered;
    
    %Same models for short exposure:
    ttS=table(-eA(:,i), eAT(:,i), lS(:,i), ePS(:,i)-lS(:,i),'VariableNames',{'eA','eAT','lS','ePS_lS'});
    ttS1=table(-veA(:,i), veAT(:,i), veS(:,i), vePS(:,i)-lS(:,i),'VariableNames',{'eA','eAT','lS','ePS_lS'});
    
    modelFitAllS2{i}=fitlm(ttS,'ePS_lS~eA+eAT-1');
    learnAllS2(i,:)=modelFitAllS2{i}.Coefficients.Estimate;
    aux=uncenteredRsquared(modelFitAllS2{i});
    r2AllS2(i)=aux.uncentered;
end
%% Display some summary statistics on Short vs. Long exposure:
diary(['../intfig/FBmodeling_' date '_' num2str(round(1e6*(now-today)))])
disp(' ')
disp('%%%%%%%%%%%%%%%%%')
modNames={'2a','S2','3'};
modDesc={'LE','SE','LE3'};
for i=1:length(modNames)
    disp(' ')
    eval(['mod=modelFit' modNames{i} ';' ]);
    disp(['Model ' modNames{i} ' (' modDesc{i} '):'])
    disp(['Avg. (uncent.) R^2=' num2str(eval(['r2' modNames{i}]),3)])
    disp(['Indiv. \R^2=' num2str(mean(eval(['r2All' modNames{i}])),3) ' \pm ' num2str(std(eval(['r2All' modNames{i}])),3) ', (mean \pm std)'])
    disp(['Indiv. \R^2=' num2str(median(eval(['r2All' modNames{i}])),3) ' \pm ' num2str(iqr(eval(['r2All' modNames{i}])),3) ', (median \pm iqr)'])
    aux=mod.coefCI;
    for j=1:mod.NumCoefficients
        disp(['Avg. \beta CI=' num2str(aux(j,:),3) ', p=' num2str(mod.Coefficients.pValue(j))])
        disp(['Indiv. \beta=' num2str(mean(eval(['learnAll' modNames{i} '(:,j)'])),3) ' \pm ' num2str(std(eval(['learnAll' modNames{i} '(:,j)'])),3) ', (mean \pm std)'])
        disp(['Indiv. \beta=' num2str(median(eval(['learnAll' modNames{i} '(:,j)'])),3) ' \pm ' num2str(iqr(eval(['learnAll' modNames{i} '(:,j)'])),3) ', (median \pm iqr)'])
    end
end
diary off
%% Do plots for short vs. long exposure comparison
figuresColorMap
data=[learnAllS2 learnAll2a];
dataM=[learnS2' learn2a'];
fh=figure('Units','Normalized','OuterPosition',[0 .5 .3 .5]);
%First: group average results:
pS=plot([1 ; 2]-.15,([dataM(:,[1,3])]),'o','LineWidth',4,'MarkerSize',6,'Color',condColors(1,:),'MarkerFaceColor',condColors(1,:));
hold on
p2=plot([1 ; 2]+.15,([dataM(:,[2,4])]),'o','LineWidth',4,'MarkerSize',6,'Color',condColors(3,:),'MarkerFaceColor',condColors(3,:));

%Add mean and std of pop:
bb=bar(reshape(mean(data),2,2),'FaceAlpha',.6,'EdgeColor','none');
bb(1).FaceColor=pS.Color;
bb(2).FaceColor=p2.Color;
%errorbar(reshape(.15*[-1 1]+[1; 2],4,1),mean(data),std(data),'Color','k','LineWidth',2,'LineStyle','none')
errorbar(.15*[-1]+[1; 2],mean(data(:,1:2)),[],std(data(:,1:2)),'Color',pS.Color,'LineWidth',2,'LineStyle','none')
errorbar(.15*[1]+[1; 2],mean(data(:,3:4)),[],std(data(:,3:4)),'Color',p2.Color,'LineWidth',2,'LineStyle','none')
set(gca,'XTick',[1,2],'XTickLabel',{'\beta_S','\beta_M'},'YLim',[-.5 1.8])
pp1=plot(1+.1*[-1 1],data(:,[1,3]),'k');
pp2=plot(2+.1*[-1 1],data(:,[1,3]+1),'k');
ylabel('R^2')
%text(1.15*ones(16,1),data(:,3),mat2cell(num2str([1:16]'),ones(16,1),2))
%text(1.5*ones(16,1),data(:,2),mat2cell(num2str([1:16]'),ones(16,1),2))
text(.75,data(1,1),'C01')
text(2.13,data(1,4),'C01')
legend('Short Exp.','Long Exp.')
title('Regressors vs. exposure length for two-factor model')
saveFig(fh,'../intfig/','ShortVsLongExpMirroring',0)

%% learning vs. age
idx=1:16;
%idx=2:16; %Exclude C01: step length asymmetry increases during adaptation!
%idx
%Define EMG learning:
betaM=learnAll2a(:,2); 
betaS=learnAll2a(:,1);
betaM=learnAll2c(:,1); %This is the regressor for eA* in the 2-regressor model that offers the best fit: same results.
betaFF=learnAll2c(:,2);
%FFamount=1+learnAll2c(:,2);
betaM=learnAll3(:,2);
betaS=-learnAll3(:,1);
betaFF=learnAll3(:,3);


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
logFile=['../intfig/interSubjectRegressions_' date '_' num2str(round(1e6*(now-today)))];
diary(logFile)
rob='off';
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
diary off
txt=fileread(logFile);
txt=removeTags(txt);
fid=fopen(logFile,'w');
fwrite(fid,txt,'char');
fclose(fid);

%%%%%%%%%%%%%%%%
logFile=['../intfig/interSubjectAGE_' date '_' num2str(round(1e6*(now-today)))];
diary(logFile)
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

diary off
txt=fileread(logFile);
txt=removeTags(txt);
fid=fopen(logFile,'w');
fwrite(fid,txt,'char');
fclose(fid);

%%%%%%%%
logFile=['../intfig/interSubjectSLA_' date '_' num2str(round(1e6*(now-today)))];
diary(logFile)
display('-----------------------------WHAT EXPLAINS SLA?-----------------------------')
ttB=table(SLA_eP(idx),age(idx)',norm_S2T(idx),norm_T2S(idx),norm_lA(idx),norm_eP(idx),'VariableNames',{'SLA_eP','age','norm_S2T','norm_T2S','norm_lA','norm_eP'});
disp('age, norm_S2T, norm_T2S, norm_lA, norm_eP')
stepwisefit([age(idx)',norm_S2T(idx),norm_T2S(idx),norm_lA(idx),norm_eP(idx)],SLA_eP(idx))
fitlm(ttB,'SLA_eP~norm_eP+norm_lA')
fitlm(ttB,'SLA_eP~norm_S2T+norm_lA')
%FF2vsAge=fitlm(ttA,'FFamount~age')  %Slight (pos) (strong if C01 excluded) correlation: they may be carrying over more (.01/year of age) 
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

diary off
txt=fileread(logFile);
txt=removeTags(txt);
fid=fopen(logFile,'w');
fwrite(fid,txt,'char');
fclose(fid);



%%
figuresColorMap
%First: eAT regressor vs age
fh1=figure('Units','Normalized','OuterPosition',[0 .2 .5 .5*16/10]);
subplot(2,2,1)
model=learnVsAge;
model.plotPartialDependence('age')
ylabel('FB learning (\beta_M)')
xlabel('Age (y.o.)')
hold on
p2=plot(age,betaM,'o','MarkerFaceColor',condColors(3,:),'Color','none');
ax=gca;
ax.Title.String=['FB learning vs. age, p=' num2str(model.Coefficients.pValue(2)) ', BF=' num2str(BayesFactor(learnVsAge),3)];
txt = evalc('model.disp');
warning('off','MATLAB:handle_graphics:exceptions:SceneNode')
text(40,-.5,removeTags(txt(2:end-1)),'Fontsize',6)
txt = evalc('learnVsBoth.disp');
text(40,-1.2,removeTags(txt(2:end-1)),'Fontsize',6)
%warning('on','MATLAB:handle_graphics:exceptions:SceneNode') %Turning
%warnings on BEFORE the cell is done makes the warning visible for the
%whole cell (!)
text(40,-1.55,['BF both vs. age=' num2str(BayesFactor(learnVsBoth)./BayesFactor(learnVsAge),3)],'FontSize',6)
text(40,-1.6,['BF both vs. SLA=' num2str(BayesFactor(learnVsBoth)./BayesFactor(learnVsSLA),3)],'FontSize',6)
set(gca,'YLim',[0 1])

%Second: lA regressor vs age
subplot(2,2,2)
model=FF2vsAge;
model.plotPartialDependence('age')
ylabel('Feedforward carryover (\beta_{FF})')
xlabel('Age (y.o.)')
hold on
plot(age,FFamount,'o','MarkerFaceColor',p2.MarkerFaceColor,'Color','none')
ax=gca;
ax.Title.String=['FF carryover vs. age, p=' num2str(model.Coefficients.pValue(2)) ', BF=' num2str(BayesFactor(FF2vsAge),3)];
txt = evalc('model.disp');
warning('off','MATLAB:handle_graphics:exceptions:SceneNode')
text(40,-.5,removeTags(txt(2:end-1)),'Fontsize',6)
txt = evalc('FF2vsBoth.disp');
text(40,-1.2,removeTags(txt(2:end-1)),'Fontsize',6)
%warning('on','MATLAB:handle_graphics:exceptions:SceneNode')
text(40,-1.55,['BF both vs. age=' num2str(BayesFactor(FF2vsBoth)./BayesFactor(FF2vsAge),3)],'FontSize',6)
text(40,-1.6,['BF both vs. SLA=' num2str(BayesFactor(FF2vsBoth)./BayesFactor(FF2vsSLA),3)],'FontSize',6)
set(gca,'YLim',[0 1])
%saveFig(fh1,'../intfig/','AgeVsFBmirroring',0)

