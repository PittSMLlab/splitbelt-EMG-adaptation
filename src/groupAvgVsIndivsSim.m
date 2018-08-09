%% Generate the normative vectors
v1=randn(360,1);
v1T=fftshift(v1);
v2=.8*v1T+.2*v1;

%% Generate individuals:
n=.8; %Noise levels
for i=1:16
    t2s(:,i)=v1+n*randn(size(v1));
    s2t(:,i)=v2+n*randn(size(v2));
end

%% Do regressions:
rob='off';
for i=1:16
    tt=table(s2t(:,i),t2s(:,i),fftshift(t2s(:,i)),'VariableNames',{'s2t','t2s','t2sT'});
    modelFit=fitlm(tt,'s2t~t2s+t2sT-1','RobustOpts',rob);
    learnIndiv(i,:)=modelFit.Coefficients.Estimate;
end
    tt=table(mean(s2t,2),mean(t2s,2),mean(fftshift(t2s),2),'VariableNames',{'s2t','t2s','t2sT'});
    modelFit=fitlm(tt,'s2t~t2s+t2sT-1','RobustOpts',rob);
    learnAll=modelFit.Coefficients.Estimate;
%% Plot
figure; hold on;
scatter(learnAll(1),learnAll(2),150,'m','filled','DisplayName','GroupAveragedReg')
scatter(learnIndiv(:,1),learnIndiv(:,2),'m','filled','DisplayName','Indiv Reg')
grid on
axis([0 1 0 1])
plot(.2,.8,'k.','DisplayName','True params')
plot(.2/(1+n.^2),.8/(1+n.^2),'kx','DisplayName','Indiv expected')
plot(.2/(1+(n/4).^2),.8/(1+(n/4).^2),'ko','DisplayName','Group avg. expected')
legend