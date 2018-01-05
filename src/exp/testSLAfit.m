%% SLA plotting
M=[150 900 600];
for i=1:length(subs.adaptData)
    subs.adaptData{i}.data=subs.adaptData{i}.data.getDataAsPS({'netContributionNorm2'}).substituteNaNs;
end
SLA=subs.getGroupedData({'netContributionNorm2'},conds(2),0,M(2),0,0,pWNf);
SLP=subs.getGroupedData({'netContributionNorm2'},conds(3),0,M(3),0,0,pWNf);
SLB=subs.getGroupedData({'netContributionNorm2'},conds(1),0,M(1),0,0,pWNf);
subjs=[2:16];
%subjs=2:16;
aSLB=squeeze(SLB{1});
aSLB=aSLB(:,subjs);
aSLA=squeeze(SLA{1});
aSLA=aSLA(:,subjs);
aSLP=squeeze(SLP{1});
aSLP=aSLP(:,subjs);

%Median filter for subjects:
MM=5;
aSLB=medfilt2(aSLB,[MM,1]);
aSLB([1:(MM-1)/2],:)=repmat(aSLB((MM+1)/2,:),(MM-1)/2,1); %Clamp
aSLB([end-(MM-3)/2:end],:)=repmat(aSLB(end-(MM-1)/2,:),(MM-1)/2,1);
aSLA=medfilt2(aSLA,[MM,1]);
aSLA([1:(MM-1)/2],:)=repmat(aSLA((MM+1)/2,:),(MM-1)/2,1);%Clamp
aSLA([end-(MM-3)/2:end],:)=repmat(aSLA(end-(MM-1)/2,:),(MM-1)/2,1); 
aSLP=medfilt2(aSLP,[MM,1]);
aSLP([1:(MM-1)/2],:)=repmat(aSLP((MM+1)/2,:),(MM-1)/2,1); %Clamp
aSLP([end-(MM-3)/2:end],:)=repmat(aSLP(end-(MM-1)/2,:),(MM-1)/2,1); 

%Remove baseline:
aBB=nanmean(aSLB(end-55:end-5,:));
aSLP=aSLP-aBB;
aSLA=aSLA-aBB;
aSLB=aSLB-aBB;

avgFlag=2;
switch avgFlag
    case 1 %Mean
        SLB=nanmean(aSLB,2);
        SLA=nanmean(aSLA,2);
        SLP=nanmean(aSLP,2);
    case 2 %Median
        SLB=nanmedian(aSLB,2);
        SLA=nanmedian(aSLA,2);
        SLP=nanmedian(aSLP,2);
end

figure; 
taus=[42.4,526];
U=[zeros(size(SLB)); ones(size(SLA)); zeros(size(SLP))];
p1=plot(sum(M(1:2))+1:sum(M(1:3)),SLP); grid on; hold on; 
plot(M(1)+1:sum(M(1:2)),SLA,'Color',p1.Color);
plot(1:M(1),SLB,'Color',p1.Color);
MM=21;
pp=plot([sum(M(1:2))+1:sum(M(1:3))],medfilt2(aSLP,[MM 1]),'Color',.7*ones(1,3));
uistack(pp,'bottom');
pp=plot(M(1)+1:sum(M(1:2)),medfilt2(aSLA,[MM 1]),'Color',.7*ones(1,3));
uistack(pp,'bottom');
EA=[exp(-[0:899]/taus(1));exp(-[0:899]/taus(2));ones(1,900)]; 
EP=[exp(-[0:599]/taus(1));exp(-[0:599]/taus(2))]; 
xA=(EA'\SLA);
plot(M(1)+1:sum(M(1:2)),EA'*xA,'k')
xP=(EP'\SLP);
plot(sum(M(1:2))+1:sum(M(1:3)),EP'*xP,'r')
plot(sum(M(1:2))+1:sum(M(1:3)),EP'*(xA(1:2).*(EA(1:2,end)-1)),'k')
title('SL asymmetry fitted to EMG time-constants')
legend(p1,['\tau_1 = ' num2str(taus(1),3) ', \tau_2 = ' num2str(taus(2),3)])
%%
[C,J,~,~,D]=sPCAv5(SLA,2,false,false,1)
[C,J,~,~,D]=sPCAv5(SLP,2,false,false,1)