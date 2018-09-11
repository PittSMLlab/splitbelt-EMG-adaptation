%% Get all needed vars
load(['../data/' groupName 'EMGsummary'])
load ../data/bioData.mat
write=true;
write=false;
%% Define eAT, lAT, etc
eAT=fftshift(eA,1);
lAT=fftshift(lA,1);
veAT=fftshift(veA,1);
%% Select sub-sets of muscles to test for robustness
muscleIdx=1:size(eA,1);
%muscleIdx=[[49:180],180+[49:180]]; %Exclude hips
%muscleIdx=[[61:96,109:180],180+[61:96,109:180]]; %Exclude hips, RF, SEMB
%-> Most things remain the same. The most fragile result seems to be the
%correlation of \beta_M to age.

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

%% Some auxiliary measures to confirm our results on age:
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

%% Individual models::
rob='off'; %These models can't be fit robustly (doesn't converge)
%First: repeat the model(s) above on each subject:
clear modelFitAll* learnAll* 
for i=1:size(eA,2)
    ttAll=table(-eA(muscleIdx,i), eAT(muscleIdx,i), -lA(muscleIdx,i),eP(muscleIdx,i), eP(muscleIdx,i)-lA(muscleIdx,i),'VariableNames',{'eA','eAT','lA','eP','eP_lA'});  
    ttAllb=table(-eA(muscleIdx,i), eAT(muscleIdx,i), -lA(muscleIdx,i),eP(muscleIdx,i),'VariableNames',{'eA','eAT','lA','eP'}); 

    %Model 2a: eP-lA regressed over eA and eAT
    modelFitAll2a{i}=fitlm(ttAll,'eP_lA~eA+eAT-1','RobustOpts',rob);
    learnAll2a(i,:)=modelFitAll2a{i}.Coefficients.Estimate;
    aux=uncenteredRsquared(modelFitAll2a{i});
    r2All2a(i)=aux.uncentered;

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
end

%% Sub select subjects
subjIdx=2:16;

%%
c1=diag(cosine(eP-lA,-eA));
c2=diag(cosine(eP-lA,eAT));
c1s=diag(cosine(ePS-lS,-eA));
c2s=diag(cosine(ePS-lS,eAT));
c1g=(cosine(median(eP(:,subjIdx)-lA(:,subjIdx),2),-median(eA(:,subjIdx),2)));
c2g=(cosine(median(eP(:,subjIdx)-lA(:,subjIdx),2),median(eAT(:,subjIdx),2)));
c1gs=(cosine(median(ePS(:,subjIdx)-lS(:,subjIdx),2),-median(eA(:,subjIdx),2)));
c2gs=(cosine(median(ePS(:,subjIdx)-lS(:,subjIdx),2),median(eAT(:,subjIdx),2)));
if write
diary(['../intfig/FBmodelingCosines_' groupName '_' date '_' num2str(round(1e6*(now-today)))])
end
disp(['Subject list=' num2str(subjIdx)])
% Show cosine results
disp('Group')
disp(['cos(eP-lA,-eA) = ' num2str((c1g))])
disp(['cos(eP-lA,eA*) = ' num2str((c2g))])
disp(['cos(ePS-lS,-eA) = ' num2str((c1gs))])
disp(['cos(ePS-lS,eA*) = ' num2str((c2gs))])
disp('Indiv')
disp(['cos(eP-lA,-eA), mean \pm std: ' num2str(mean(c1(subjIdx))) ' \pm ' num2str(std(c1(subjIdx))) '; median \pm iqr: ' num2str(median(c1(subjIdx))) ' \pm ' num2str(iqr(c1(subjIdx)))])
disp(['cos(eP-lA,eA*), mean \pm std: ' num2str(mean(c2(subjIdx))) ' \pm ' num2str(std(c2(subjIdx))) '; median \pm iqr: ' num2str(median(c2(subjIdx))) ' \pm ' num2str(iqr(c2(subjIdx)))])
disp(['cos(ePS-lS,-eA), mean \pm std: ' num2str(mean(c1s(subjIdx))) ' \pm ' num2str(std(c1s(subjIdx))) '; median \pm iqr: ' num2str(median(c1s(subjIdx))) ' \pm ' num2str(iqr(c1s(subjIdx)))])
disp(['cos(ePS-lS,eA*), mean \pm std: ' num2str(mean(c2s(subjIdx))) ' \pm ' num2str(std(c2s(subjIdx))) '; median \pm iqr: ' num2str(median(c2s(subjIdx))) ' \pm ' num2str(iqr(c2s(subjIdx)))])

%Add explicit comparison between 2-factor models for LE and SE
disp('Comparison of individual results in SE vs LE')
[~,p1]=ttest(c1(subjIdx),c1s(subjIdx)); %\beta_S
p2=signrank(c2(subjIdx),c2s(subjIdx),'method','exact'); %\beta_S
d=mean(c1(subjIdx)-c1s(subjIdx))./std(c1(subjIdx)-c1s(subjIdx)); %Cohen's d to compute effect size
disp(['cos(POST,-eA), paired t-test p=' num2str(p1) ', \Delta=' num2str(mean(c1(subjIdx)-c1s(subjIdx))) ', Cohen''s d=' num2str(d) ', signrank p=' num2str(p2)])
[~,p1]=ttest(c2(subjIdx),c2s(subjIdx)); %\beta_M
p2=signrank(c2(subjIdx),c2s(subjIdx),'method','exact'); %\beta_M
d=mean(c2(subjIdx)-c2s(subjIdx))./std(c2(subjIdx)-c2s(subjIdx)); %Cohen's d to compute effect size
disp(['cos(POST,eA*), paired t-test p=' num2str(p1) ', \Delta=' num2str(mean(c2(subjIdx)-c2s(subjIdx))) ', Cohen''s d=' num2str(d) ', signrank p=' num2str(p2)])

disp([num2str(sum((c1(subjIdx)-c1s(subjIdx))<0)) '/' num2str(numel(subjIdx)) ' subjects decreased their cos(POST, -eA)'])
disp(['Median change: ' num2str(median(c1(subjIdx)-c1s(subjIdx))) ', mean: ' num2str(mean(c1(subjIdx)-c1s(subjIdx)))])
disp([num2str(sum((c2(subjIdx)-c2s(subjIdx))>0)) '/' num2str(numel(subjIdx)) ' subjects increased their cos(POST, eA*)'])
disp(['Median change: ' num2str(median(c2(subjIdx)-c2s(subjIdx))) ', mean: ' num2str(mean(c2(subjIdx)-c2s(subjIdx)))])

%Add age correlations:
[rs,ps]=corr(age(subjIdx)',c1(subjIdx),'Type','Pearson');
disp(['Age vs cos(eP-lA,-eA), r=' num2str(rs) ', p=' num2str(ps)])
[rs,ps]=corr(age(subjIdx)',c2(subjIdx),'Type','Pearson');
disp(['Age vs cos(eP-lA,eA*), r=' num2str(rs) ', p=' num2str(ps)])
[rs,ps]=corr(age(subjIdx)',c1(subjIdx)-c1s(subjIdx),'Type','Pearson');
disp(['Age vs \Delta cos(eP-lA,-eA), r=' num2str(rs) ', p=' num2str(ps)])
[rs,ps]=corr(age(subjIdx)',c2(subjIdx)-c2s(subjIdx),'Type','Pearson');
disp(['Age vs \Delta cos(eP-lA,eA*), r=' num2str(rs) ', p=' num2str(ps)])

%-------------------------------------------------- Repeat for 15 strides:
eP=e15P;
eA=e15A;
eAT=fftshift(eA,1);

c1=diag(cosine(eP-lA,-eA));
c2=diag(cosine(eP-lA,eAT));
c1s=diag(cosine(ePS-lS,-eA));
c2s=diag(cosine(ePS-lS,eAT));
c1g=(cosine(median(eP(:,subjIdx)-lA(:,subjIdx),2),-median(eA(:,subjIdx),2)));
c2g=(cosine(median(eP(:,subjIdx)-lA(:,subjIdx),2),median(eAT(:,subjIdx),2)));
c1gs=(cosine(median(ePS(:,subjIdx)-lS(:,subjIdx),2),-median(eA(:,subjIdx),2)));
c2gs=(cosine(median(ePS(:,subjIdx)-lS(:,subjIdx),2),median(eAT(:,subjIdx),2)));
if write
diary(['../intfig/FBmodelingCosines_' groupName '_' date '_' num2str(round(1e6*(now-today)))])
end
% Show cosine results
disp('---------------RESULTS FOR EARLY = 15 strides-----------------')
disp('Group')
disp(['cos(eP-lA,-eA) = ' num2str((c1g))])
disp(['cos(eP-lA,eA*) = ' num2str((c2g))])
disp(['cos(ePS-lS,-eA) = ' num2str((c1gs))])
disp(['cos(ePS-lS,eA*) = ' num2str((c2gs))])
disp('Indiv')
disp(['cos(eP-lA,-eA), mean \pm std: ' num2str(mean(c1(subjIdx))) ' \pm ' num2str(std(c1(subjIdx))) '; median \pm iqr: ' num2str(median(c1(subjIdx))) ' \pm ' num2str(iqr(c1(subjIdx)))])
disp(['cos(eP-lA,eA*), mean \pm std: ' num2str(mean(c2(subjIdx))) ' \pm ' num2str(std(c2(subjIdx))) '; median \pm iqr: ' num2str(median(c2(subjIdx))) ' \pm ' num2str(iqr(c2(subjIdx)))])
disp(['cos(ePS-lS,-eA), mean \pm std: ' num2str(mean(c1s(subjIdx))) ' \pm ' num2str(std(c1s(subjIdx))) '; median \pm iqr: ' num2str(median(c1s(subjIdx))) ' \pm ' num2str(iqr(c1s(subjIdx)))])
disp(['cos(ePS-lS,eA*), mean \pm std: ' num2str(mean(c2s(subjIdx))) ' \pm ' num2str(std(c2s(subjIdx))) '; median \pm iqr: ' num2str(median(c2s(subjIdx))) ' \pm ' num2str(iqr(c2s(subjIdx)))])

%Add explicit comparison between 2-factor models for LE and SE
disp('Comparison of individual results in SE vs LE')
[~,p1]=ttest(c1(subjIdx),c1s(subjIdx)); %\beta_S
p2=signrank(c2(subjIdx),c2s(subjIdx),'method','exact'); %\beta_S
d=mean(c1(subjIdx)-c1s(subjIdx))./std(c1(subjIdx)-c1s(subjIdx)); %Cohen's d to compute effect size
disp(['cos(POST,-eA), paired t-test p=' num2str(p1) ', \Delta=' num2str(mean(c1(subjIdx)-c1s(subjIdx))) ', Cohen''s d=' num2str(d) ', signrank p=' num2str(p2)])
[~,p1]=ttest(c2(subjIdx),c2s(subjIdx)); %\beta_M
p2=signrank(c2(subjIdx),c2s(subjIdx),'method','exact'); %\beta_M
d=mean(c2(subjIdx)-c2s(subjIdx))./std(c2(subjIdx)-c2s(subjIdx)); %Cohen's d to compute effect size
disp(['cos(POST,eA*), paired t-test p=' num2str(p1) ', \Delta=' num2str(mean(c2(subjIdx)-c2s(subjIdx))) ', Cohen''s d=' num2str(d) ', signrank p=' num2str(p2)])

disp([num2str(sum((c1(subjIdx)-c1s(subjIdx))<0)) '/' num2str(numel(subjIdx)) ' subjects decreased their cos(POST, -eA)'])
disp(['Median change: ' num2str(median(c1(subjIdx)-c1s(subjIdx))) ', mean: ' num2str(mean(c1(subjIdx)-c1s(subjIdx)))])
disp([num2str(sum((c2(subjIdx)-c2s(subjIdx))>0)) '/' num2str(numel(subjIdx)) ' subjects increased their cos(POST, eA*)'])
disp(['Median change: ' num2str(median(c2(subjIdx)-c2s(subjIdx))) ', mean: ' num2str(mean(c2(subjIdx)-c2s(subjIdx)))])

%Add age correlations:
[rs,ps]=corr(age(subjIdx)',c1(subjIdx),'Type','Pearson');
disp(['Age vs cos(eP-lA,-eA), r=' num2str(rs) ', p=' num2str(ps)])
[rs,ps]=corr(age(subjIdx)',c2(subjIdx),'Type','Pearson');
disp(['Age vs cos(eP-lA,eA*), r=' num2str(rs) ', p=' num2str(ps)])
[rs,ps]=corr(age(subjIdx)',c1(subjIdx)-c1s(subjIdx),'Type','Pearson');
disp(['Age vs \Delta cos(eP-lA,-eA), r=' num2str(rs) ', p=' num2str(ps)])
[rs,ps]=corr(age(subjIdx)',c2(subjIdx)-c2s(subjIdx),'Type','Pearson');
disp(['Age vs \Delta cos(eP-lA,eA*), r=' num2str(rs) ', p=' num2str(ps)])


%-------------------------------------------------- Repeat for 1 stride:
eP=veP;
eA=veA;
eAT=veAT;

c1=diag(cosine(eP-lA,-eA));
c2=diag(cosine(eP-lA,eAT));
c1s=diag(cosine(ePS-lS,-eA));
c2s=diag(cosine(ePS-lS,eAT));
c1g=(cosine(median(eP(:,subjIdx)-lA(:,subjIdx),2),-median(eA(:,subjIdx),2)));
c2g=(cosine(median(eP(:,subjIdx)-lA(:,subjIdx),2),median(eAT(:,subjIdx),2)));
c1gs=(cosine(median(ePS(:,subjIdx)-lS(:,subjIdx),2),-median(eA(:,subjIdx),2)));
c2gs=(cosine(median(ePS(:,subjIdx)-lS(:,subjIdx),2),median(eAT(:,subjIdx),2)));
if write
diary(['../intfig/FBmodelingCosines_' groupName '_' date '_' num2str(round(1e6*(now-today)))])
end
% Show cosine results
disp('---------------RESULTS FOR EARLY = 1 stride-----------------')
disp('Group')
disp(['cos(eP-lA,-eA) = ' num2str((c1g))])
disp(['cos(eP-lA,eA*) = ' num2str((c2g))])
disp(['cos(ePS-lS,-eA) = ' num2str((c1gs))])
disp(['cos(ePS-lS,eA*) = ' num2str((c2gs))])
disp('Indiv')
disp(['cos(eP-lA,-eA), mean \pm std: ' num2str(mean(c1(subjIdx))) ' \pm ' num2str(std(c1(subjIdx))) '; median \pm iqr: ' num2str(median(c1(subjIdx))) ' \pm ' num2str(iqr(c1(subjIdx)))])
disp(['cos(eP-lA,eA*), mean \pm std: ' num2str(mean(c2(subjIdx))) ' \pm ' num2str(std(c2(subjIdx))) '; median \pm iqr: ' num2str(median(c2(subjIdx))) ' \pm ' num2str(iqr(c2(subjIdx)))])
disp(['cos(ePS-lS,-eA), mean \pm std: ' num2str(mean(c1s(subjIdx))) ' \pm ' num2str(std(c1s(subjIdx))) '; median \pm iqr: ' num2str(median(c1s(subjIdx))) ' \pm ' num2str(iqr(c1s(subjIdx)))])
disp(['cos(ePS-lS,eA*), mean \pm std: ' num2str(mean(c2s(subjIdx))) ' \pm ' num2str(std(c2s(subjIdx))) '; median \pm iqr: ' num2str(median(c2s(subjIdx))) ' \pm ' num2str(iqr(c2s(subjIdx)))])

%Add explicit comparison between 2-factor models for LE and SE
disp('Comparison of individual results in SE vs LE')
[~,p1]=ttest(c1(subjIdx),c1s(subjIdx)); %\beta_S
p2=signrank(c2(subjIdx),c2s(subjIdx),'method','exact'); %\beta_S
d=mean(c1(subjIdx)-c1s(subjIdx))./std(c1(subjIdx)-c1s(subjIdx)); %Cohen's d to compute effect size
disp(['cos(POST,-eA), paired t-test p=' num2str(p1) ', \Delta=' num2str(mean(c1(subjIdx)-c1s(subjIdx))) ', Cohen''s d=' num2str(d) ', signrank p=' num2str(p2)])
[~,p1]=ttest(c2(subjIdx),c2s(subjIdx)); %\beta_M
p2=signrank(c2(subjIdx),c2s(subjIdx),'method','exact'); %\beta_M
d=mean(c2(subjIdx)-c2s(subjIdx))./std(c2(subjIdx)-c2s(subjIdx)); %Cohen's d to compute effect size
disp(['cos(POST,eA*), paired t-test p=' num2str(p1) ', \Delta=' num2str(mean(c2(subjIdx)-c2s(subjIdx))) ', Cohen''s d=' num2str(d) ', signrank p=' num2str(p2)])

disp([num2str(sum((c1(subjIdx)-c1s(subjIdx))<0)) '/' num2str(numel(subjIdx)) ' subjects decreased their cos(POST, -eA)'])
disp(['Median change: ' num2str(median(c1(subjIdx)-c1s(subjIdx))) ', mean: ' num2str(mean(c1(subjIdx)-c1s(subjIdx)))])
disp([num2str(sum((c2(subjIdx)-c2s(subjIdx))>0)) '/' num2str(numel(subjIdx)) ' subjects increased their cos(POST, eA*)'])
disp(['Median change: ' num2str(median(c2(subjIdx)-c2s(subjIdx))) ', mean: ' num2str(mean(c2(subjIdx)-c2s(subjIdx)))])

%Add age correlations:
[rs,ps]=corr(age(subjIdx)',c1(subjIdx),'Type','Pearson');
disp(['Age vs cos(eP-lA,-eA), r=' num2str(rs) ', p=' num2str(ps)])
[rs,ps]=corr(age(subjIdx)',c2(subjIdx),'Type','Pearson');
disp(['Age vs cos(eP-lA,eA*), r=' num2str(rs) ', p=' num2str(ps)])
[rs,ps]=corr(age(subjIdx)',c1(subjIdx)-c1s(subjIdx),'Type','Pearson');
disp(['Age vs \Delta cos(eP-lA,-eA), r=' num2str(rs) ', p=' num2str(ps)])
[rs,ps]=corr(age(subjIdx)',c2(subjIdx)-c2s(subjIdx),'Type','Pearson');
disp(['Age vs \Delta cos(eP-lA,eA*), r=' num2str(rs) ', p=' num2str(ps)])


if write
    diary off
end

    %%
    figure;
    subplot(2,3,1)
    %The 1D model has a straight-forward relation between R^2 and beta^2
    %scatter(r2All1a',learnAll1a(:,1))
%	hold on
%     scatter(r2All1a',sum(learnAll1a.^2,2).*(norm_T2S./norm_S2T).^2)
    scatter(r2All2a(subjIdx)',learnAll2a((subjIdx),2),'DisplayName','\beta_M')
    hold on
    scatter(r2All2a(subjIdx)',learnAll2a((subjIdx),2)-learnAll2a((subjIdx),1),'DisplayName','\Delta \beta')
    scatter(r2All2a(subjIdx)',sum(learnAll2a((subjIdx),:).^2,2),'DisplayName','\sum \beta ^2')
    scatter(r2All2a(subjIdx)',sum(learnAll2a((subjIdx),:).^2,2).*(norm_T2S(subjIdx).^2)./norm_S2T(subjIdx).^2-2*prod(learnAll2a((subjIdx),:),2).*sum(eA(:,(subjIdx)).*eAT(:,(subjIdx)),1)'./norm_S2T(subjIdx).^2)
    scatter(r2All2a(subjIdx)',sum(learnAll2a((subjIdx),:).^2,2).*(norm_T2S(subjIdx).^2)./norm_S2T(subjIdx).^2)
    xlabel('R^2')
    legend('Location','SouthEast')
    subplot(2,3,2)
    for k=1:3
        switch k
            case 1
                y=learnAll2a(:,2);
                nn='\beta_M';
            case 2
                y=(learnAll2a(:,2)-learnAll2a(:,1));
                nn='\Delta \beta ';
            case 3
                y=learnAll2a(:,1);
                nn='\beta_S';
                %y=sum(learnAll2a.^2,2);
                %nn='\sum \beta ^2'
            case 4
                y=sum(learnAll2a.^2,2).*(norm_T2S.^2)./norm_S2T.^2;
                nn='\sum \beta ^2 . \|eA\|/\|eP-lA\|';
            case 5
                y=sum(learnAll2a.^2,2).*(norm_T2S.^2)./norm_S2T.^2-2*prod(learnAll2a,2).*sum(eA.*eAT,1)'./norm_S2T.^2;
                nn='R^2';
        end
    [rs,ps]=corr(age(subjIdx)',y(subjIdx),'Type','Spearman');
    scatter(age(subjIdx)',y(subjIdx),'DisplayName',[nn ', r=' num2str(rs,3) ',p=' num2str(ps,3)])
    hold on
    end
    %scatter(r2All2a',sum(learnAll2a.^2,2).*(norm_T2S.^2)./norm_S2T.^2-2*prod(learnAll2a,2).*sum(eA.*eAT,1)'./norm_S2T.^2)
    %scatter(r2All2a',sum(learnAll2a.^2,2).*(norm_T2S.^2)./norm_S2T.^2)
    xlabel('age')
    legend('Location','SouthEast')
    
    correctedBetas=learnAll2a.*(norm_T2S)./norm_S2T; %Betas corrected by the effect of regressor factor size onto 'regresee'
    subplot(2,3,3)
    for k=1:4
        switch k
            case 1
                y=correctedBetas(:,2);
                nn='Corrected \beta_M';
            case 2
                y=correctedBetas(:,2)-correctedBetas(:,1);
                nn='Corrected \Delta \beta';
            case 3
                y=correctedBetas(:,1);
                nn='Corrected \beta_S';
                %y=sum(learnAll2a.^2,2);
                %nn='\sum \beta ^2'
            case 4
                y=sum(correctedBetas.^2,2);
                nn='\sum \beta ^2';
        end
    [rs,ps]=corr(age(subjIdx)',y(subjIdx),'Type','Spearman');
    scatter(age(subjIdx)',y(subjIdx),'DisplayName',[nn ', r=' num2str(rs,3) ',p=' num2str(ps,3)])
    hold on
        end
    xlabel('age')
    legend('Location','SouthEast')
    
    subplot(2,3,5)
    y=(norm_S2T)./norm_T2S;
    [rs,ps]=corr(age(subjIdx)',y(subjIdx),'Type','Spearman');
    scatter(age(subjIdx)',y(subjIdx),'DisplayName',['r=' num2str(rs,3) ',p=' num2str(ps,3)])
    title('\|eP-lA\| / \|eA\|')
    legend
    subplot(2,3,4)
    y=(sum(eA.*eAT,1)')./norm_T2S.^2;
    [rs,ps]=corr(age(subjIdx)',y(subjIdx),'Type','Spearman');
    scatter(age(subjIdx)',y(subjIdx),'DisplayName',['r=' num2str(rs,3) ',p=' num2str(ps,3)])
    title('(<eA,eA*> / \|eA\|)^2 = cos(eA,eA*)')
    legend
    subplot(2,3,6)
    norm_S2Tse=sqrt(sum((ePS-lS).^2,1))';
    for k=1:4%6
        switch k
            case 1
                y=(sum(eA.*(eP-lA),1)')./(norm_T2S.*norm_S2T);
                nn='cos(eA,eP-lA)';
            case 2
                y=(sum(eAT.*(eP-lA),1)')./(norm_T2S.*norm_S2T);
                nn='cos(eA*,eP-lA)';
            case 5
                y1=(sum(eA.*(eP-lA),1)')./(norm_T2S.*norm_S2T);
                y=y1-(sum(eA.*(ePS-lS),1)')./(norm_T2S.*norm_S2Tse);
                nn='\Delta cos(eA,S2T)';
                %y=sum(learnAll2a.^2,2);
                %nn='\sum \beta ^2'
            case 6
                y1=(sum(eAT.*(eP-lA),1)')./(norm_T2S.*norm_S2T);
                y=y1-(sum(eAT.*(ePS-lS),1)')./(norm_T2S.*norm_S2Tse);
                nn='\Delta cos(eA*,S2T)';
           case 3
                y=(sum(eA.*(ePS-lS),1)')./(norm_T2S.*norm_S2Tse);
                nn='cos(eA,ePS-lS)';
                %y=sum(learnAll2a.^2,2);
                %nn='\sum \beta ^2'
            case 4
                y=(sum(eAT.*(ePS-lS),1)')./(norm_T2S.*norm_S2Tse);
                nn='cos(eA*,ePS-lS)';
        end
    
    [rs,ps]=corr(age(subjIdx)', y(subjIdx),'Type','Pearson');
    scatter(age(subjIdx)',y(subjIdx),'filled','DisplayName',[nn ', r=' num2str(rs,3) ',p=' num2str(ps,3)])
    hold on
    end
    title('Angles')
    legend
    