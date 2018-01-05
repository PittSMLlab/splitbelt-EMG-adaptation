%% Load some groupAdaptData
load('/Datos/Documentos/PhD/lab/synergies/paramData/C0004Params.mat')
load('/Datos/Documentos/PhD/lab/synergies/paramData/groupedParams_wMissingParameters.mat')

%% Get relevant data
ll=(controls.getLabelsThatMatch('^(f|s).+s\d+$'));
ll=sort(ll);
muscleList=sort(unique(cellfun(@(x) x{1},regexp(ll,'s\d+$','split'),'UniformOutput',false)));
AA=adaptData.data.getDataAsVector(ll);
ii=adaptData.getIndsInCondition({'TM base','Adap','Wash'});


%% Normalize
B=nanmedian(AA(ii{1},:)); %Baseline estimate
AAnorm=nan(size(AA));
normFactor=nan(size(muscleList));
for i=1:length(muscleList)
    idx=cellfun(@(x) ~isempty(x),regexp(ll,muscleList{i}));
    normFactor(i)=max(B(idx));
    AAnorm(:,idx)=AA(:,idx)/normFactor(i);
end
%%
BB=nanmedian(AAnorm(ii{1},:)); %Baseline estimate
yA=bsxfun(@minus,AAnorm(ii{2},:),BB); %Adapt data, minus baseline
yP=bsxfun(@minus,AAnorm(ii{3},:),BB); %Adapt data, minus baseline

%% Fit data
yA2=yA;
yA2(any(isnan(yA2),2),:)=[];
yA2=conv2(yA2,ones(10,1)/10,'valid');
[p,c,a]=pca(yA2);
yA2=c(:,1:5);%*c(:,1:10)'; %PCA reduction for complexity's sake
N=size(yA2,2);
M=size(yA2,1);
t=[0:M-1]'/100;
x0=nan(1,2*N+2);
x0([1:N])=nanmedian(yA2(1:10,:));
x0([N+1:2*N])=nanmedian(yA2(end-10:end,:));
x0(2*N+1)=1/10;
x0(2*N+2)=1/50;
oo=optimoptions('lsqnonlin','MaxIter',100);
et=exp(-t);
x=lsqnonlin(@(x) yA2-( ( et.^x(2*N+1))*x([1:N]) + (1-et.^x(2*N+2))*x([N+1:2*N]) ),x0,[],[],oo);

%% PLot
C1=c(:,1:N)*x([1:N])';
C2=c(:,1:N)*x(N+[1:N])';
%%
%figure; imagesc(reshape(p(:,2),12,30)'); set(gca,'YTick',1:30,'YTickLabel',muscleList) 
figure; 
subplot(1,4,1); imagesc(reshape(nanmedian(yA(1:20,:)),12,30)'); set(gca,'YTick',1:30,'YTickLabel',muscleList); caxis([-1 1])
subplot(1,4,2); imagesc(reshape(nanmedian(yA(end-20:end,:)),12,30)'); set(gca,'YTick',1:30,'YTickLabel',muscleList); caxis([-1 1])
subplot(1,4,3); imagesc(reshape(nanmedian(yP(1:20,:)),12,30)'); set(gca,'YTick',1:30,'YTickLabel',muscleList); caxis([-1 1])
subplot(1,4,4); imagesc(reshape(BB,12,30)'); set(gca,'YTick',1:30,'YTickLabel',muscleList); caxis([0 1])
%figure; plot(c(:,1:5))
%figure; imagesc(reshape(C1,30,12))
%figure; imagesc(reshape(C2,30,12))
