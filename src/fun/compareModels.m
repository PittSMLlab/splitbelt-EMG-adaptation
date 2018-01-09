function [fh] = compareModels(models,trainingData,trainingU)

fh=figure;
hold on
for i=1:length(models)
    if ~all(models{i}.D(:)==0)
    tit='D';
else %Models fitted to post-adapt data
    tit='D*';
    models{i}.D=nanmean((trainingData(:,trainingU~=0)-models{i}.Ysim(:,trainingU~=0))./trainingU(trainingU~=0),2);
    models{i}.Ysim=models{i}.C*models{i}.Xsim+models{i}.D*trainingU;
    end
name=[models{i}.name ', \tau=' num2str(sort(-1./log(diag(models{i}.J))'),4)];
    plot(sum((models{i}.Ysim-trainingData).^2,1) ./nanmean(sum(trainingData.^2,1)),'DisplayName',name)
end
plot(sum((trainingData).^2,1) ./nanmean(sum(trainingData.^2,1)),'k','DisplayName','Signal Energy')

axis tight
legend()
end

