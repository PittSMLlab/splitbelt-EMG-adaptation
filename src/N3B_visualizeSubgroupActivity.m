%% Get all needed vars
load(['../data/' groupName 'EMGsummary'])
load ../data/bioData.mat
write=true;
write=false;
%% Define eAT, lAT, etc
eAT=fftshift(eA,1);
lAT=fftshift(lA,1);
veAT=fftshift(veA,1);

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

%% Visualizing model goodness-of-fit differences
figure;  
aa=eA(:,r2All2a<.3); 
bb=eP(:,r2All2a<.3)-lA(:,r2All2a<.3); 
cc=eA(:,r2All2a>.3); 
dd=eP(:,r2All2a>.3)-lA(:,r2All2a>.3); 
subplot(2,3,1);imagesc(reshape(mean(aa,2),12,30)'); figuresColorMap; caxis(.5*[-1 1]); colormap(flipud(map)); title('eA bad') 
subplot(2,3,2);imagesc(reshape(mean(eA,2),12,30)'); figuresColorMap; caxis(.5*[-1 1]); colormap(flipud(map)); title('eA all') 
subplot(2,3,3);imagesc(reshape(mean(eA,2)-median(aa,2),12,30)'); figuresColorMap; caxis(.5*[-1 1]); colormap(flipud(map)); title('eA diff') 
subplot(2,3,2);imagesc(reshape(mean(cc,2),12,30)'); figuresColorMap; caxis(.5*[-1 1]); colormap(flipud(map)); title('eA good') 
subplot(2,3,3);imagesc(reshape(mean(cc,2)-mean(aa,2),12,30)'); figuresColorMap; caxis(.5*[-1 1]); colormap(flipud(map)); title('eA diff') 
subplot(2,3,4);imagesc(reshape(mean(bb,2),12,30)'); figuresColorMap; caxis(.5*[-1 1]); colormap(flipud(map)); title('eP-lA bad') 
subplot(2,3,5);imagesc(reshape(mean(eP-lA,2),12,30)'); figuresColorMap; caxis(.5*[-1 1]); colormap(flipud(map)); title('eP-lA all') 
subplot(2,3,6);imagesc(reshape(mean(eP-lA,2)-median(bb,2),12,30)'); figuresColorMap; caxis(.5*[-1 1]); colormap(flipud(map)); title('eP-lA diff') 
subplot(2,3,5);imagesc(reshape(mean(dd,2),12,30)'); figuresColorMap; caxis(.5*[-1 1]); colormap(flipud(map)); title('eP-lA good') 
subplot(2,3,6);imagesc(reshape(mean(dd,2)-mean(bb,2),12,30)'); figuresColorMap; caxis(.5*[-1 1]); colormap(flipud(map)); title('eP-lA diff') 

%% Visualizing age differences
figure;  
aa=eA(:,ageC<50);  %The two youngest subjects have the lowest R^2 of all, and I do not understand why. It is true that C01 was an outlier behaviorally (kinematics) so that may be part of it.
bb=eP(:,ageC<50)-lA(:,ageC<50); 
cc=eA(:,ageC>50); 
dd=eP(:,ageC>50)-lA(:,ageC>50); 
subplot(2,3,1);imagesc(reshape(mean(aa,2),12,30)'); figuresColorMap; caxis(.5*[-1 1]); colormap(flipud(map)); title('eA bad') 
subplot(2,3,2);imagesc(reshape(mean(eA,2),12,30)'); figuresColorMap; caxis(.5*[-1 1]); colormap(flipud(map)); title('eA all') 
subplot(2,3,3);imagesc(reshape(mean(eA,2)-median(aa,2),12,30)'); figuresColorMap; caxis(.5*[-1 1]); colormap(flipud(map)); title('eA diff') 
subplot(2,3,2);imagesc(reshape(mean(cc,2),12,30)'); figuresColorMap; caxis(.5*[-1 1]); colormap(flipud(map)); title('eA good') 
subplot(2,3,3);imagesc(reshape(mean(cc,2)-mean(aa,2),12,30)'); figuresColorMap; caxis(.5*[-1 1]); colormap(flipud(map)); title('eA diff') 
subplot(2,3,4);imagesc(reshape(mean(bb,2),12,30)'); figuresColorMap; caxis(.5*[-1 1]); colormap(flipud(map)); title('eP-lA bad') 
subplot(2,3,5);imagesc(reshape(mean(eP-lA,2),12,30)'); figuresColorMap; caxis(.5*[-1 1]); colormap(flipud(map)); title('eP-lA all') 
subplot(2,3,6);imagesc(reshape(mean(eP-lA,2)-median(bb,2),12,30)'); figuresColorMap; caxis(.5*[-1 1]); colormap(flipud(map)); title('eP-lA diff') 
subplot(2,3,5);imagesc(reshape(mean(dd,2),12,30)'); figuresColorMap; caxis(.5*[-1 1]); colormap(flipud(map)); title('eP-lA good') 
subplot(2,3,6);imagesc(reshape(mean(dd,2)-mean(bb,2),12,30)'); figuresColorMap; caxis(.5*[-1 1]); colormap(flipud(map)); title('eP-lA diff') 