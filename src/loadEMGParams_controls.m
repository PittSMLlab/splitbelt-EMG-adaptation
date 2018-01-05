clearvars
close all 
load('/Datos/Documentos/PhD/lab/synergies/paramData/C0009Params.mat')
load ../paramData/groupedParams_wMissingParameters.mat
load ../paramData/bioData.mat
%% Get relevant data
type='s';
ll=(adaptData.data.getLabelsThatMatch(['^(f|s).+' type '\d+$']));
ll=sort(ll);
muscleList=sort(unique(cellfun(@(x) x{1},regexp(ll,[type '\d+$'],'split'),'UniformOutput',false)));
%aux=[];
Nm=length(muscleList);
Nn=length(ll)/Nm;

muscleList=fliplr({'TA','PER','MG','LG','SOL','SEMB','SEMT','BF','VM','VL','RF','HIP','ADM','TFL','GLU'});
%muscleList=fliplr({'TA','MG','LG','SOL','SEMB','SEMT','BF','VM','VL','RF','HIP','ADM','TFL','GLU'});
muscleList=[strcat('f',muscleList) strcat('s',muscleList)];
aux=num2str([1:Nn]');
pp=cellfun(@(x) strcat(x,type,strtrim(mat2cell(aux,ones(Nn,1),size(aux,2)))),muscleList,'UniformOutput',false);
ll=vertcat(pp{:});

AA=adaptData.data.getDataAsVector(ll);
conds={'TM base','Adaptation','Washout','Short exposure','TM mid'};
ii=adaptData.getIndsInCondition(conds);
Nm=length(muscleList);
Nn=length(ll)/Nm;
AA=reshape(AA,size(AA,1),Nn,Nm);

%% From all the controls
subs=controls;
%subs=patients.removeSubs({'P0011','P0007'});
M=[150 950 600 8 40];
%M=[150 850 600 8 40]; %This is needed for patients
pWNf=true;
AA1=subs.getGroupedData(ll,conds(1),0,M(1),0,0,pWNf);
AA1=squeeze(AA1{1});
AA2=subs.getGroupedData(ll,conds(2),0,M(2),0,0,pWNf);

%Aligning adaptation trials (not just conds):
tt2=subs.getGroupedData({'trial','trial'},conds(2),0,M(2),0,0,pWNf);
tt2=squeeze(tt2{1}(:,:,1,:));
tt2=bsxfun(@minus,tt2,tt2(1,:));
AA2a=nan(1,300*3,size(AA1,2),size(AA1,3));
for i=1:size(tt2,2) %Each sub
    for k=1:3 %Each trial
        idx=find(tt2(:,i)==(k-1),299,'first');
        if length(idx)<200
            error('')
        end
        AA2a(1,(k-1)*300 +[1:length(idx)],:,i)=AA2{1}(1,idx,:,i);
    end
end
M(2)=size(AA2a,2); %Controls
AA2=squeeze(AA2a); %Controls
%AA2=squeeze(AA2{1}); %Patients
AA3=subs.getGroupedData(ll,conds(3),0,M(3),0,0,pWNf);
AA3=squeeze(AA3{1});
AA4=subs.getGroupedData(ll,conds(4),0,M(4),0,0,pWNf);
AA4=squeeze(AA4{1});
%try %This fails for patients
AA5=subs.getGroupedData(ll,conds(5),0,M(5),0,0,pWNf);
AA5=squeeze(AA5{1});
%warning(['Could not load condition ' conds(5)])
%catch
%    AA5=zeros(M(5),length(ll),size(AA4,3));
%end
AA=[AA5;AA4;AA1;AA2;AA3];
AA=reshape(AA,size(AA,1),Nn,Nm,size(AA1,3));
M2=[M(5) M(4) M(1:3)];
auxI=[0 cumsum(M2)];
%% Normalize
B=nanmean(AA(auxI(end-2)+[-100:-1],:,:,:),1); %Baseline estimate
normFactor=max(B,[],2);
minFactor=min(B,[],2);
AAnorm=bsxfun(@rdivide,bsxfun(@minus,AA,minFactor),normFactor-minFactor);

%% Flip interval order for ipsilateral organization
AAnorm(:,:,1:Nm/2,:)=AAnorm(:,[Nn/2+1:Nn,1:Nn/2],1:Nm/2,:); %Flipping interval order for f muscles, so that both sides are ipsilaterally aligned
AAnorm=reshape(AAnorm,size(AA,1),Nn*Nm,size(AAnorm,4));

%% Subtract moving/linear baseline
BB=nanmedian(AAnorm(auxI(end-2)-[100:-1:0],:,:,:)); %Median of last 100 of base
yPE=nanmedian(AAnorm([auxI(end)-[100:-1:0]],:,:,:)); %Median of last 100 of post
t=[1:sum(M2)]' - (auxI(end-2)-50);
t=t/t(end-50);
movingBB= bsxfun(@times,t,(yPE-BB));
%AAnorm=bsxfun(@minus,AAnorm,movingBB); %Removing linearly drifting

