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
    
    correctedBetas=learnAll2a.*(norm_T2S)./norm_S2T;
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
    [rs,ps]=corr(age',y,'Type','Spearman');
    scatter(age',y,'DisplayName',['r=' num2str(rs,3) ',p=' num2str(ps,3)])
    title('\|eP-lA\| / \|eA\|')
    legend
    subplot(2,3,4)
    y=(sum(eA.*eAT,1)')./norm_T2S.^2;
    [rs,ps]=corr(age',y,'Type','Spearman');
    scatter(age',y,'DisplayName',['r=' num2str(rs,3) ',p=' num2str(ps,3)])
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