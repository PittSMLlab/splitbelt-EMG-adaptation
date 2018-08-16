%% Generate the normative vectors
s=.23;
m=.1; %Having a non-zero mean changes the theoretical predictions, need to work on that
m=0;
v1=s*randn(360,1)+m; %Represents avg data from eA, preserving mean, std
betaM=.8; %Partial mirroring (90%)
betaS=1-betaM;

%% Do regressions:
n=.6; %Noise levels as percent of baseline variability
rob='off';
Nreps=1e2;
Nsub=16;
learnIndiv=nan(Nsub,2,Nreps);
learnAll=nan(2,Nreps);
f=.5; %Fraction of 'noise' variance that represents intersubject variability (with the rest being true noise/stochasticity within each subject/measurement)
for j=1:Nreps
    j
    %Generate noisy data:
    noise1=sqrt(f)*n*sqrt(s^2+m^2)*randn(size(v1,1),Nsub);
    subjSpecificV1=v1+noise1;
    noise2=sqrt(1-f)*n*sqrt(s^2+m^2)*randn(size(v1,1),Nsub);
    t2s=subjSpecificV1+noise2;
    subjSpecificV2=(betaM*fftshift(subjSpecificV1)-betaS*subjSpecificV1);
    noise2=sqrt(1-f)*n*sqrt(s^2+m^2)*randn(size(v1,1),Nsub);
    s2t=subjSpecificV2 +noise2;
    %Do indiv regressions:
    for i=1:Nsub
        tt=table(s2t(:,i),-t2s(:,i),fftshift(t2s(:,i)),'VariableNames',{'s2t','t2s','t2sT'});
        modelFit=fitlm(tt,'s2t~t2s+t2sT-1','RobustOpts',rob);
        learnIndiv(i,:,j)=modelFit.Coefficients.Estimate;
    end
    %Do group regressions:
    tt=table(mean(s2t,2),-mean(t2s,2),mean(fftshift(t2s),2),'VariableNames',{'s2t','t2s','t2sT'});
    modelFit=fitlm(tt,'s2t~t2s+t2sT-1','RobustOpts',rob);
    learnAll(:,j)=modelFit.Coefficients.Estimate;
end
%% Plot
figure; hold on;
scatter(learnAll(1,1),learnAll(2,1),150,'m','filled','DisplayName','Sample GroupAveragedReg')
scatter(learnIndiv(:,1,1),learnIndiv(:,2,1),'m','filled','DisplayName','Sample Indiv Reg')
scatter(mean(learnAll(1,:),2),mean(learnAll(2,:),2),150,'g','filled','DisplayName','Sample GroupAveragedReg')
scatter(mean(learnIndiv(:,1,:),3),mean(learnIndiv(:,2,:),3),'g','filled','DisplayName','Sample Indiv Reg')
grid on
axis([-.3 1 0 1])
plot(betaS,betaM,'k.','DisplayName','True params')
plot(betaS/(1+(1-f)*n.^2),betaM/(1+n.^2),'kx','DisplayName','Indiv expected')
plot(betaS/(1+(1-f)*(n/4).^2),betaM/(1+(n/4).^2),'ko','DisplayName','Group avg. expected')
legend
axis equal