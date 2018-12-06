%% 
addpath(genpath('./fun/'))
addpath(genpath('../pubfig/auxFun/'))
%% Define data from params if necessary
groupName='patients';
subjIdx=[1:6,8:10,12:16]; %Excluding 7 and 11 which dont have short exp
groupName='controls';
subjIdx=2:16; %Excluding C01

%% Get all needed vars
load(['../data/' groupName 'EMGsummary'])
load ../data/bioData.mat
write=true;
write=false;
%% Add group average as an additional subject:
avgFun=@median;
eA(:,end+1)=avgFun(eA,2);
eP(:,end+1)=avgFun(eP,2);
ePS(:,end+1)=avgFun(ePS,2);
veP(:,end+1)=avgFun(veP,2);
veS(:,end+1)=avgFun(veS,2);
vePS(:,end+1)=avgFun(vePS,2);
lA(:,end+1)=avgFun(lA,2);
lS(:,end+1)=avgFun(lS,2);
e15A(:,end+1)=avgFun(e15A,2);
e15P(:,end+1)=avgFun(e15P,2);
veA(:,end+1)=avgFun(veA,2);

%% Define eAT, lAT, etc
eAT=fftshift(eA,1);
lAT=fftshift(lA,1);
veAT=fftshift(veA,1);
e15AT=fftshift(e15A,1);
e15PT=fftshift(e15P,1);
ePT=fftshift(eP,1);
vePT=fftshift(veP,1);
%% Do analysis 
rob='off'; %These models can't be fit robustly (doesn't converge)
muscleIdxList{1}=1:size(eA,1); % Select sub-sets of muscles to test for robustness
muscleIdxList{2}=1:180;% one leg
muscleIdxList{3}=181:360; %other leg

for l=1:3
    muscleIdx=muscleIdxList{l};
    for i=1:size(eA,2)
        %Long exposure tables:
        tt{1}=table(-eA(muscleIdx,i), eAT(muscleIdx,i), -lA(muscleIdx,i),eP(muscleIdx,i), eP(muscleIdx,i)-lA(muscleIdx,i),'VariableNames',{'eA','eAT','lA','eP','eP_lA'});  
        tt{2}=table(-e15A(muscleIdx,i), e15AT(muscleIdx,i), -lA(muscleIdx,i),e15P(muscleIdx,i), e15P(muscleIdx,i)-lA(muscleIdx,i),'VariableNames',{'eA','eAT','lA','eP','eP_lA'}); 
        tt{3}=table(-veA(muscleIdx,i), veAT(muscleIdx,i), -lA(muscleIdx,i),veP(muscleIdx,i),  veP(muscleIdx,i)-lA(muscleIdx,i),'VariableNames',{'eA','eAT','lA','eP','eP_lA'});    
        
        %Backward regression tables:
        ttB{1}=table(lA(muscleIdx,i)-eP(muscleIdx,i), -lAT(muscleIdx,i)+ePT(muscleIdx,i), eA(muscleIdx,i),'VariableNames',{'lA_eP','lAT_ePT','eA'});  
        ttB{2}=ttB{1}; %Doxy
        ttB{3}=ttB{1}; %Doxy
        
        %Short exposure tables:
        ttS{1}=table(-eA(muscleIdx,i), eAT(muscleIdx,i), -lS(muscleIdx,i), ePS(muscleIdx,i)-lS(muscleIdx,i),'VariableNames',{'eA','eAT','lS','ePS_lS'});
        ttS{2}=table(-e15A(muscleIdx,i), e15AT(muscleIdx,i), -lS(muscleIdx,i), ePS(muscleIdx,i)-lS(muscleIdx,i),'VariableNames',{'eA','eAT','lS','ePS_lS'});
        ttS{3}=table(-veA(:,i), veAT(:,i), veS(:,i), vePS(:,i)-lS(:,i),'VariableNames',{'eA','eAT','lS','ePS_lS'});
        for k=1:3
            %two regressor models:
            modelFitSHORT{i,k,l}=fitlm(ttS{k},'ePS_lS~eA+eAT-1','RobustOpts',rob);
            modelFitLONG{i,k,l}=fitlm(tt{k},'eP_lA~eA+eAT-1','RobustOpts',rob);
            modelFitLONGopp{i,k,l}=fitlm(ttB{k},'eA~lA_eP+lAT_ePT-1','RobustOpts',rob);
        end
    end
end

%% Compare results as a function of leg:
expNames={'Both legs','Fast leg','Slow leg'};
figure
clear sc
for k=1:3
    dataLong(:,1)=cellfun(@(x) x.Coefficients.Estimate(1),modelFitLONG(:,1,k));
    dataLong(:,2)=cellfun(@(x) x.Coefficients.Estimate(2),modelFitLONG(:,1,k));
    dataSh(:,1)=cellfun(@(x) x.Coefficients.Estimate(1),modelFitSHORT(:,1,k));
    dataSh(:,2)=cellfun(@(x) x.Coefficients.Estimate(2),modelFitSHORT(:,1,k));
    
    %Plot beta_S vs. beta_M
    subplot(1,2,1)
    hold on
    set(gca,'ColorOrderIndex',k)
    sc(k)=scatter(dataLong(:,1),dataLong(:,2),'filled','DisplayName',[expNames{k} ' LONG'],'MarkerFaceAlpha',.5);
    set(gca,'ColorOrderIndex',k)
    scatter(dataLong(end,1),dataLong(end,2),100,'filled','DisplayName',[expNames{k} ' LONG'],'MarkerFaceColor',sc(k).MarkerFaceColor);

    set(gca,'ColorOrderIndex',k)
    scatter(dataSh(:,1),dataSh(:,2),'DisplayName',[expNames{k} ' SHORT'],'MarkerEdgeColor',sc(k).MarkerFaceColor);
    set(gca,'ColorOrderIndex',k)
    scatter(dataSh(end,1),dataSh(end,2),100);
    
    %Plot change in betas:
    subplot(1,2,2)
    hold on
    scatter(dataLong(:,1)-dataSh(:,1),dataLong(:,2)-dataSh(:,2),'filled','MarkerEdgeColor',sc(k).MarkerFaceColor,'MarkerFaceAlpha',.5);
    set(gca,'ColorOrderIndex',k)
    scatter(dataLong(end,1)-dataSh(end,1),dataLong(end,2)-dataSh(end,2),100,'filled');
end
subplot(1,2,1)
xlabel('\beta_S')
ylabel('\beta_M')
legend(sc)
axis equal
subplot(1,2,2)
xlabel('\Delta \beta_S')
ylabel('\Delta \beta_M')
title('Long vs. short change')
axis equal
%% Compare results as a function of stride No:
expNames={'5 strides','15 strides','1 stride'};
figure
clear sc
for k=1:3
    %Plot beta_S vs. beta_M
    subplot(2,2,1)
    hold on
    dataLong(:,1)=cellfun(@(x) x.Coefficients.Estimate(1),modelFitLONG(:,k,1));
    dataLong(:,2)=cellfun(@(x) x.Coefficients.Estimate(2),modelFitLONG(:,k,1));
    set(gca,'ColorOrderIndex',k)
    sc(k)=scatter(dataLong(:,1),dataLong(:,2),'filled','DisplayName',[expNames{k} ' LONG'],'MarkerFaceAlpha',.5);
    set(gca,'ColorOrderIndex',k)
    scatter(dataLong(end,1),dataLong(end,2),100,'filled','DisplayName',[expNames{k} ' LONG'],'MarkerFaceColor',sc(k).MarkerFaceColor);
    dataSh(:,1)=cellfun(@(x) x.Coefficients.Estimate(1),modelFitSHORT(:,k,1));
    dataSh(:,2)=cellfun(@(x) x.Coefficients.Estimate(2),modelFitSHORT(:,k,1));
    set(gca,'ColorOrderIndex',k)
    scatter(dataSh(:,1),dataSh(:,2),'DisplayName',[expNames{k} ' SHORT'],'MarkerEdgeColor',sc(k).MarkerFaceColor);
    set(gca,'ColorOrderIndex',k)
    scatter(dataSh(end,1),dataSh(end,2),100);
    
    %Plot change in betas:
    subplot(2,2,2)
    hold on
    scatter(dataLong(:,1)-dataSh(:,1),dataLong(:,2)-dataSh(:,2),'filled','MarkerEdgeColor',sc(k).MarkerFaceColor,'MarkerFaceAlpha',.5);
    set(gca,'ColorOrderIndex',k)
    scatter(dataLong(end,1)-dataSh(end,1),dataLong(end,2)-dataSh(end,2),100,'filled');
    
    %Plot vs. age:
    subplot(2,2,3)
    hold on
    if k==1 %Plotting only 5 stride analysis
        set(gca,'ColorOrderIndex',k)
        scatter(age,dataLong(1:end-1,1),'DisplayName',['\beta_S, 5, LONG'],'MarkerFaceAlpha',.5);
        set(gca,'ColorOrderIndex',k)
        scatter(age,dataLong(1:end-1,2),'filled','DisplayName',['\beta_M, 5, LONG']);
    end
    subplot(2,2,4)
    hold on
    if k==1
        set(gca,'ColorOrderIndex',k)
        scatter(age,dataLong(1:end-1,1)-dataSh(1:end-1,1),'DisplayName',['\Delta \beta_S, 5, LONG'],'MarkerFaceAlpha',.5);
        set(gca,'ColorOrderIndex',k)
        scatter(age,dataLong(1:end-1,2)-dataSh(1:end-1,2),'filled','DisplayName',['\Delta \beta_M, 5, LONG'],'MarkerFaceAlpha',.5);
        scatter(age,diff(dataLong(1:end-1,:),[],2)-diff(dataSh(1:end-1,:),[],2),'filled','DisplayName',['\Delta \beta_M-\beta_S, 5, LONG'],'MarkerFaceAlpha',.5,'MarkerFaceColor','k');
    end
end
subplot(2,2,1)
xlabel('\beta_S')
ylabel('\beta_M')
legend(sc)
axis equal
subplot(2,2,2)
xlabel('\Delta \beta_S')
ylabel('\Delta \beta_M')
title('Long vs. short change')
axis equal
subplot(2,2,3)
xlabel('Age')
ylabel('\beta')
legend
subplot(2,2,4)
xlabel('Age')
ylabel('\Delta \beta')
legend
