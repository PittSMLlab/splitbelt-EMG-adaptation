%% Load some groupAdaptData
 load('/Datos/Documentos/PhD/lab/synergies/paramData/C0009Params.mat')
 load ../paramData/groupedParams_wMissingParameters.mat
%% Get relevant data
ll=(adaptData.data.getLabelsThatMatch('^(f|s).+s\d+$'));
ll=sort(ll);
muscleList=sort(unique(cellfun(@(x) x{1},regexp(ll,'s\d+$','split'),'UniformOutput',false)));
aux=[];
muscleList=fliplr({'TA','PER','MG','LG','SOL','SEMB','SEMT','BF','VM','VL','RF','HIP','ADM','TFL','GLU'});
muscleList=[strcat('f',muscleList) strcat('s',muscleList)];
pp=cellfun(@(x) strcat(x,'s',strtrim(mat2cell(num2str([1:12]'),ones(12,1),2))),muscleList,'UniformOutput',false);
ll=vertcat(pp{:});

AA=adaptData.data.getDataAsVector(ll);
conds={'TM base','Adap','Wash','Short','TM mid'};
%conds={'TM base','Adap','Wash','TM base'};
ii=adaptData.getIndsInCondition(conds);
AA=reshape(AA,size(AA,1),12,30);

%% From all the controls
subs=controls;
M=[150 950 600 8 40];
%M=[150 850 600 8]; %This is needed for patients
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
M(2)=size(AA2a,2);
AA2=squeeze(AA2a);
%AA2=squeeze(AA2{1});
AA3=subs.getGroupedData(ll,conds(3),0,M(3),0,0,pWNf);
AA3=squeeze(AA3{1});
AA4=subs.getGroupedData(ll,conds(4),0,M(4),0,0,pWNf);
AA4=squeeze(AA4{1});
AA5=subs.getGroupedData(ll,conds(5),0,M(5),0,0,pWNf);
AA5=squeeze(AA5{1});

AA=[AA5;AA4;AA1;AA2;AA3];
AA=reshape(AA,size(AA,1),12,30,size(AA1,3));


%% Normalize
B=nanmedian(AA(1:M(1),:,:,:),1); %Baseline estimate
normFactor=max(B,[],2);
minFactor=min(B,[],2);
AAnorm=bsxfun(@rdivide,bsxfun(@minus,AA,minFactor),normFactor-minFactor);

%% Flip interval order for ipsilateral organization
AAnorm(:,:,1:15,:)=AAnorm(:,[7:12,1:6],1:15,:); %Flipping interval order for f muscles, so that both sides are ipsilaterally aligned
AAnorm=reshape(AAnorm,size(AA,1),360,size(AAnorm,4));
symAA=.5*(AAnorm(:,[1:180],:)+AAnorm(:,180+[1:180],:));
%AAnorm=AAnorm - cat(2,symAA,symAA);
%AAnorm=AAnorm(:,:,[1,2,6,8,13,16]); %under 55 subjs
%AAnorm=AAnorm(:,:,[3,7,9,14,15]); %over 64 subjs, except 11 which only did 300 strides of post
allAA=AAnorm;
%AAnorm=AAnorm(:,:,[1:5,7:end]); %Excluding P0006 because he has too little strides in adap/post to study dynamics
%AAnorm=nanmedian(AAnorm,3); %Median sub
AAnorm=nanmean(AAnorm,3); %Median sub

%% Define epochs
M2=[M(5) M(4) M(1:3)];
auxI=cumsum(M2);

BB=nanmedian(AAnorm(auxI(3)-[100:-1:0],:)); %Median of last 100 of base
allBB=nanmedian(AAnorm(auxI(3)-[100:-1:0],:,:));
yPE=nanmedian(AAnorm([auxI(5)-[100:-1:0]],:)); %Median of last 100 of post
allYPE=nanmedian(AAnorm(auxI(5)-[100:-1:0],:,:));
t=[1:sum(M2)]' - (auxI(2)-50);
t=t/t(end-50);
movingBB= t*(yPE-BB);
allMBB=bsxfun(@times, t, allYPE-allBB);
AAnorm=bsxfun(@minus,AAnorm,movingBB); %Removing linearly drifting
allAA=bsxfun(@minus,allAA,allMBB);
%baseline

yM=AAnorm(1:auxI(1),:,:,:);
yS=AAnorm(auxI(1)+1:auxI(2),:,:,:);
yB=AAnorm(auxI(2)+1:auxI(3),:,:,:);
yA=AAnorm(auxI(3)+1:auxI(4),:,:,:);
yP=AAnorm(auxI(4)+1:auxI(5),:,:,:);
allyM=allAA(1:auxI(1),:,:,:);
allyS=allAA(auxI(1)+1:auxI(2),:,:,:);
allyB=allAA(auxI(2)+1:auxI(3),:,:,:);
allyA=allAA(auxI(3)+1:auxI(4),:,:,:);
allyP=allAA(auxI(4)+1:auxI(5),:,:,:);
%Defining some important values:
earlyStrides=5;
lateStrides=100;
exempt=5;
BB=nanmedian(yB(end-exempt-[lateStrides:-1:1],:),1); %Baseline estimate
y0=nanmedian(yA(exempt+[1:earlyStrides],:)) -BB; %First feedback respones
yE=nanmedian(yA(end-exempt-[lateStrides:-1:1],:))-BB; %Steady-state
yPE=nanmedian(yP(end-exempt-[lateStrides:-1:1],:))-BB;
yP0=nanmedian(yP(exempt+[1:earlyStrides],:))-BB;
y0P=y0([181:end,1:180]);
%Break data: (exempting 5 strides)
y3=nanmedian(yA(604:608,:,:));
y4=nanmedian(yA(550:595,:,:));
y1=nanmedian(yA(304:308,:,:));
y2=nanmedian(yA(250:295,:,:));
yBrk=.5*(y1-y2+y3-y4);

allBB=nanmedian(allyB(end-exempt-[lateStrides:-1:1],:,:),1); %Baseline estimate
ally0=nanmedian(allyA(exempt+[1:earlyStrides],:,:)) -allBB; %First feedback respones
allyE=nanmedian(allyA(end-exempt-[lateStrides:-1:1],:,:))-allBB; %Steady-state
allyPE=nanmedian(allyP(end-exempt-[lateStrides:-1:1],:,:))-allBB;
allyP0=nanmedian(allyP(exempt+[1:earlyStrides],:,:))-allBB;
ally0P=ally0(1,[181:end,1:180],:);

%% Fake data:
% noise=1.6*std(bsxfun(@minus,yB,BB));
% yS=bsxfun(@plus,y0,BB).*(1 + bsxfun(@times,noise,randn(size(yS))));
% yB=BB .*(1 + bsxfun(@times,noise,randn(size(yB))));
% T1=50;
% T2=50;
% t=[0:299]';
% yA1=(exp(-t/T1)*(y0) + (1-exp(-t/T2))*(yE));
% yA2=(.3*exp(-t/T1)*(y0) + (1-.2*exp(-(t)/T2))*(yE));
% yA3=(.3*exp(-t/T1)*(y0) + (1-.2*exp(-(t)/T2))*(yE));
% yA=bsxfun(@plus,[yA1;yA2;yA3],BB);
% yA=yA.*(1  + bsxfun(@times,noise,randn(size(yA))));
% t=[0:size(yP,1)-1]';
% yP=(.7*exp(-t/T1)*(y0P) + .5*(exp(-t/T2))*(yE));
% yP=bsxfun(@plus,yP,BB).*(1 + bsxfun(@times,noise,randn(size(yP))));

%% Look at some stuff
%Colormap:
ex1=[.85,0,.1];
ex2=[0,.1,.6];
map=[bsxfun(@plus,ex1,bsxfun(@times,1-ex1,[0:.01:1]'));bsxfun(@plus,ex2,bsxfun(@times,1-ex2,[1:-.01:0]'))];


figure; 
subplot(2,3,2); imagesc(reshape(y0,12,30)'); set(gca,'YTick',1:30,'YTickLabel',muscleList); caxis(.5*[-1 1]); title('Early A'); colormap(flipud(map.^.5))
subplot(2,3,3); imagesc(reshape(yE,12,30)'); set(gca,'YTick',1:30,'YTickLabel',muscleList); caxis(.5*[-1 1]); title('LAte A')
subplot(2,3,4); imagesc(reshape(yP0,12,30)'); set(gca,'YTick',1:30,'YTickLabel',muscleList); caxis(.5*[-1 1]); title('Early post')
subplot(2,3,1); imagesc(reshape(BB,12,30)'); set(gca,'YTick',1:30,'YTickLabel',muscleList); caxis([-1 1]); title('Base')
%subplot(2,3,5); imagesc(reshape(.7*(y0P) +.5*(yE),12,30)'); set(gca,'YTick',1:30,'YTickLabel',muscleList); caxis(.5*[-1 1]); title('.5*lA+.7*eA^T')
subplot(2,3,5); imagesc(reshape(yBrk,12,30)'); set(gca,'YTick',1:30,'YTickLabel',muscleList); caxis(.5*[-1 1]); title('yBrk')
%subplot(2,3,5); imagesc(reshape(.5*(yE-yPE)+.5*(y0P-BB),12,30)'); set(gca,'YTick',1:30,'YTickLabel',muscleList); caxis([-1 1]*.5); title('lA+eA^T')
subplot(2,3,6); imagesc(reshape(yPE,12,30)'); set(gca,'YTick',1:30,'YTickLabel',muscleList); caxis(.5*[-1 1]); title('lP')

%%
figure %PCA exploration of adaptation and aftereffects
[p,c,a]=pca(bsxfun(@minus,yA,yE+BB),'Centered',false);
for i=1:10 %First 10 PCs
    if nanmean(c(1:10,i))<0
        c(:,i)=-c(:,i);
        p(:,i)=-p(:,i);
    end
end
for i=1:3
    subplot(2,4,i)
    imagesc(reshape(p(:,i),12,30)')
    title(['PC' num2str(i) ', EAF = ' num2str(100*a(i)/sum(a),2) '%'])
    caxis([-.2 .2])
    set(gca,'YTick',1:30,'YTickLabel',muscleList)
end
subplot(2,4,4)
plot(c(:,1:5))
set(gca,'ColorOrderIndex',1)
hold on
for i=1:5
plot(monoLS(c(:,i),2,2),'LineWidth',2)
end
hold off
axis([10 100 -2 5])
grid on

subplot(2,4,6)
imagesc(reshape(y0,12,30)'); set(gca,'YTick',1:30,'YTickLabel',muscleList); caxis([-1 1]); title('Early A'); 
subplot(2,4,5); imagesc(reshape(yE,12,30)'); set(gca,'YTick',1:30,'YTickLabel',muscleList); caxis(.5*[-1 1]); title('Late A (y_{\infty})')

colormap(flipud(map))
%% Fit data
oo=optimoptions('lsqnonlin','MaxIter',1000,'MaxFunctionEvaluations',1e4);
%Find time constant assuming that we know the relevant components
clear x
t=[0:size(yA,1)-1]'/100;
et=exp(-t);
xx0=[2 .5 1 1];
yA2=interp1(t(~any(isnan(yA),2)),yA(~any(isnan(yA),2),:),t,'linear','extrap');
xx=lsqnonlin(@(x) (yA2)-( x(3)*(et.^x(1))*(y0) + x(4)*(1-et.^x(2))*(yE) ),xx0,[],[],oo);
xx0=[2 1 .5 .5 1 .5 .5 .5];
%et=et(1:300);
%yA2=yA2(1:300,:);
xxD=lsqnonlin(@(x) (yA2-BB)-( (x(3)*(et.^x(1)) + x(7)*(et.^x(5)))*(y0) + (x(4)*(1-et.^x(2)) + x(8)*(1-et.^x(6)) )*(yE) ),xx0,[],[],oo);

t=[0:size(yP,1)-1]'/100;
et=exp(-t);
xx0=[2 .5 .9 .9];
BB2=0;
yP2=interp1(t(~any(isnan(yP),2)),yP(~any(isnan(yP),2),:),t,'linear','extrap');
xxP=lsqnonlin(@(x) (yP2-BB)-( ( x(3)*et.^x(1))*(y0P) + x(4)*(et.^x(2))*(yE) ) ,xx0,[],[],oo);
xxP2=lsqnonlin(@(x) (yP2-BB)-( -x(3)*( et.^x(1))*(y0) + x(4)*(et.^x(2))*(yE) ),xx0,[],[],oo);
xx0=[2 .5 .5 .5 1 1 .5 .5];
xxPD=lsqnonlin(@(x) (yP2-BB)-( ( x(3)*et.^x(1) +x(7)*et.^x(5))*(y0P) + (x(4)*(et.^x(2))+x(8)*(et.^x(6)))*(yE) ) ,xx0,[],[],oo);
%xxP2D=lsqnonlin(@(x) (yP2-BB)-( -( x(3)*et.^x(1) +x(7)*et.^x(5))*(y0-BB) + (x(4)*(et.^x(2))+x(8)*(et.^x(6)))*(yE-BB) ) ,xx0,[],[],oo);

%% Plot time-courses & regressions onto eA/lA
figure
MMM=5;
for i=1:MMM
    switch i
        case 1
            BB2=BB;
            YY=[y0; yE; yBrk; BB2];
            %YY=[y0; yE; BB2];
            yyA=yA;
            allYY=cat(1,ally0, allyE, allBB);
            allyyA=allyA;
            leg={'Regression onto eA','Reg onto lA','Reg onto yBrk','Reg onto BB'};
            tit={'Adaptation'};
            et=exp(-[1:size(yA2)]'/100);
            fit=[xx(3)*(et.^xx(1))  xx(4)*(1-et.^xx(2))  ones(size(et))];
            fit=[];
            fitD=[xxD(3)*(et.^xxD(1))+xxD(7)*(et.^xxD(5))  xxD(4)*(1-et.^xxD(2))+xxD(8)*(1-et.^xxD(6))  ones(size(et))];
            txt=['x(0)=' num2str(xxD(3)+xxD(7)) ', \tau_1=' num2str(1/xxD(1) * 100) ', \tau_2=' num2str(1/xxD(5) * 100) ];
            txt2=['x(Inf)=' num2str(xxD(4)+xxD(8)) ', \tau_1=' num2str(1/xxD(2) * 100) ', \tau_2=' num2str(1/xxD(6) * 100) ];
        case 2
            BB2=BB;
            YY=[y0; yE; BB2];
            yyA=yS;
            allYY=cat(1,ally0, allyE, allBB);
            allyyA=allyS;
            leg={'Regression onto eA','Reg onto lA','Reg onto BB2'};
            tit={'Short adapt (wrt B)'};
            fit=[];
            fitD=[];
            txt='';
            txt2='';
        case 3
            BB2=BB;
            YY=[y0P; yE; BB2];
            yyA=yP;
            allYY=cat(1,ally0P, allyE, allBB);
            allyyA=allyP;
            leg={'Regression onto eA^T','Reg onto lA','Reg onto lP (BB)'};
            tit={'Post-adap (wrt lP)'};
            et=exp(-[1:size(yP)]'/100);
            fitD=[xxPD(3)*(et.^xxPD(1))+xxPD(7)*(et.^xxPD(5)) xxPD(4)*(et.^xxPD(2))+xxPD(8)*(et.^xxPD(6)) ones(size(et))];
            fit=[xxP(3)*(et.^xxP(1)) xxP(4)*(et.^xxP(2)) ones(size(et))];
            fit=[];
            txt=['x(0)=' num2str(xxPD(3)+xxPD(7)) ', \tau_1=' num2str(1/xxPD(1) * 100) ', \tau_2=' num2str(1/xxPD(5) * 100) ];
            txt2=['x(0)=' num2str(xxPD(4)+xxPD(8)) ', \tau_1=' num2str(1/xxPD(2) * 100) ', \tau_2=' num2str(1/xxPD(6) * 100) ];
        case 4
            BB2=BB;
            YY=[y0; yE; BB2];
            yyA=yP;
            allYY=cat(1,ally0, allyE, allBB);
            allyyA=allyP;
            leg={'Regression onto eA','Reg onto lA','Reg onto lP (BB)'};
            tit={'Post-adap (wrt lP) - Control'};
            et=exp(-[1:size(yP)]'/100);
            fit=[( -xxP2(3)*et.^xxP2(1))'; xxP2(4)*(et.^xxP2(2))';ones(size(et))']';
            fitD=[];
            txt='';
            txt2='';
        case 5
            BB2=BB;
            YY=[y0P; yE; BB2];
            yyA=yB;
            allYY=cat(1,ally0P, allyE, allBB);
            allyyA=allyB;
            leg={'Regression onto eA^T','Reg onto lA','Reg onto BB'};
            tit={'Baseline - Control'};
            fit=[];
            fitD=[];
            txt='';
            txt2='';
        case 6
            yyA=[yS; yB; yA; yP];
            BB2=BB;
            YY=[y0; y0P; yE; BB2;];
            allYY=cat(1,ally0,ally0P, allyE, allBB);
            allyyA=cat(1,allyS,allyB,allyA,allyP);
            leg={'Reg onto eA', 'Reg onto eA^T','Reg onto lA','Reg onto BB'};
            tit='All';
            fit=[];
            fitD=[];
            txt='';
            txt2='';
    end
            
    subplot(MMM,5,[5*i-[4,3]])
    hold on; 
    pY=pinv(YY);
%     for iii=1:size(allyyA,3)
%         pY2=pinv(allYY(:,:,iii));
%         auxAll=allyyA(:,:,iii)*pY;
%         %auxAll=conv2(auxAll,ones(11,1)/11,'same');
%         auxAll= monoLS(auxAll,2,2,3); %Monotonic smoothing
%         set(gca,'ColorOrderIndex',1);
%         plot(auxAll);
%     end
    set(gca,'ColorOrderIndex',1); plot(yyA*pY,'LineWidth',2); set(gca,'ColorOrderIndex',1); plot(fit); set(gca,'ColorOrderIndex',1); plot(fitD)    
    cc=get(gca,'ColorOrder');
    text(200,.6,txt,'Color',cc(1,:),'FontSize',7);
    text(200,.4,txt2,'Color',cc(2,:),'FontSize',7);
    legend(leg)
    title(tit)
    axis tight
    ax=axis;
    axis([ax(1:2) -.5 1.5])
    grid on
    
    subplot(MMM,5,[5*i-[2,1]])
    hold on    
    E1=(nansum((yyA*pY*YY).^2,2)); %All regressed energy
    E2=(nansum((yyA-yyA*pY*YY).^2,2)); %Unregressed energy
    E3=(nansum((yyA*pY(:,1:end-1)*YY(1:end-1,:)).^2,2)); %Energy of regressed signal w/o BB
    E4=(nansum((yyA*pinv(BB2)*BB2).^2,2)); %Regressed energy onto BB
    N=nansum(yyA.^2,2);
    %N=2*sum(nanmean(nanmean(symAA(50:150,:,:),3)).^2); %All energies as % of baseline mean energy
    p1=plot((E1-E4)./N,'LineWidth',2); p2=plot(E2./N,'LineWidth',2); p3=plot(E3./N,'LineWidth',2); 
    legend('Regressed energy (minus BB)','Residual energy ','Reg energy w/o BB')%,'Reg energy onto BB')
%     for iii=1:size(allyyA,3)
%     set(gca,'ColorOrderIndex',1);
%     pY2=pinv(allYY(:,:,iii));
%     YY2=allYY(:,:,iii);
%     yyA2=allyyA(:,:,iii);
%     E1=(nansum((yyA2*pY2*YY2).^2,2)); %All regressed energy
%     E2=(nansum((yyA2-yyA2*pY2*YY2).^2,2)); %Unregressed energy
%     E3=(nansum((yyA2*pY2(:,1:end-1)*YY2(1:end-1,:)).^2,2)); %Energy of regressed signal w/o BB
%     E4=(nansum((yyA2*pinv(BB2)*BB2).^2,2)); %Regressed energy onto BB
%     N=nansum(yyA2.^2,2);
%     p1=plot((E1-E4)./N); p2=plot(E2./N); p3=plot(E3./N); 
%     end
    axis tight
    grid on
    
    subplot(MMM,5,5*i)
    hold on
    bar(1,sum(E3)/sum(N),'FaceColor',p3.Color)
    bar(1,sum(E1-E4)/sum(N),'FaceColor',p1.Color)
    bar(2,sum(E2)/sum(N),'FaceColor',p2.Color)    
    set(gca,'XTick',1:2,'XTickLabel',{'Reg noBB','Residual'},'XTickLabelRotation',0)
    grid on
    title('Energy')
end

%% Look at some individualized data
clear d

figure
hold on
allYY=cat(1,allyE,ally0P,allBB);
for i=1:16; dAux=allyP(:,:,i)*pinv(allYY(:,:,i)); set(gca,'ColorOrderIndex',1); plot(medfilt2(dAux,[11 1],'symmetric')); end %Regressing each subject to its own lA & eA^P

allYY=cat(1,allyE,ally0P);
%allYY=cat(1,allyE,ally0P,ally0);
for i=1:16; d(:,i)=allyP0(:,:,i)*pinv(allYY(:,:,i)); end %Regressing each subject to its own lA & eA^P
residual=squeeze(allyP0 - sum(allYY.*reshape(d,size(d,1),1,size(d,2)),1))'; %(squeeze(allyP0)-squeeze(allyE).*d(1,:)-squeeze(ally0P).*d(2,:))';
resNorm=sqrt(sum(residual.^2,2))./sqrt(sum(squeeze(allyP0+allBB)'.^2,2));
dGroup=yP0*pinv([yE;y0P]); %Group avg. for reference
resGroup=norm(yP0-dGroup*[yE;y0P])/norm(yP0+BB);
load ../paramData/bioData.mat

figure
for k=1:2
    if k==2
    ageC=velsC;
    end
subplot(1,2,k)
hold on
clear p c pp
names={'lA','eA^T','eA','Residual %'};
for j=1:size(d,1)
[r1,p(j)]=corr(ageC',d(j,:)');
c(j)=plot(ageC,d(j,:),'x','DisplayName',['Reg. ' names{j} ', p=' num2str(p(j),3)]);
pp(j,:)=polyfit(ageC,d(j,:),1);
end
[r1,p(end+1)]=corr(ageC',resNorm);
c(end+1)=plot(ageC',resNorm,'x','DisplayName',['Residual energy as %, p=' num2str(p(end),3)]);
pp(end+1,:)=polyfit(ageC',resNorm,1);
plot(ageC,ageC*pp(end,1)+pp(end,2),'Color',c(end).Color,'LineWidth',2)
text(ageC,.85*ones(size(ageC))+.2*rand(size(ageC)),mat2cell(num2str([1:16]'),ones(16,1),2))
for j=1:size(d,1)
plot(ageC,ageC*pp(j,1)+pp(j,2),'Color',c(j).Color,'LineWidth',2)
%plot(ageC,std(d(1,:))*(ageC-mean(ageC))*r1(1)/std(ageC)+mean(d(1,:)),'Color','k') %This is equivalent to polyfit(ageC,d(1,:),1)
%plot(std(ageC)*(d(1,:)-mean(d(1,:)))*r1(1)/std(d(1,:))+mean(ageC),d(1,:),'Color','r') %This is equivalent to polyfit(d(1,:),ageC,1) and inverting it
end

if k==1
xlabel('Age')
else
    xlabel('Speed (m/s)')
end
ylabel('a.u')
legend(c,'Location','SouthWest')
end
%% Visualize projection onto identified time-rates
Y=bsxfun(@minus,yA,BB);
N=size(Y,1);
t=[0:N-1]';
rates=[0 1/35 1/500];
E=[exp(-t*rates) [exp(-t(1:300)/35);exp(-t(1:300)/35);exp(-t(1:300)/35)]]; %rates(end+1)=-1;
%rates(end+1)=-1;
rates(end+1)=NaN;
%Remove NAN
nanidx=any(isnan(Y),2);
Y2=interp1(t(~nanidx),Y(~nanidx,:),t,'linear','extrap');
%LS w/o sparsity term:
M1=pinv(E)*Y2;

NN=size(E,2);
%Visualize:
%Y=bsxfun(@minus,yP,BB);
%M1(2,:)=M1(2,[181:360, 1:180]);
figure; 
for i=1:NN; subplot(3,NN,[0,NN]+i); imagesc(reshape(M1(i,:),12,30)'); set(gca,'YTick',1:30,'YTickLabel',muscleList); title(['\tau= ' num2str(1./rates(i))]); caxis(.5*[-1 1]); colormap(flipud(map)); end
subplot(3,NN,2*NN+[1:NN]); plot(Y*pinv(M1)); grid on; set(gca,'ColorOrderIndex',1); hold on; plot(E)
%% Do some pca & explore the data
% yA1=yA;
% yA1(any(isnan(yA1),2),:)=[];
% yA2=conv2(yA1,ones(21,1)/21,'valid'); %Smoothing
% %yA2=medfilt2(yA2,[20 1],'zeros'); %Alt Smoothing
% yP2=yP;
% yP2(any(isnan(yP2),2),:)=[];
% yP2=conv2(yP2,ones(21,1)/21,'valid'); %Smoothing
% 
% u=mean(yA2,1);
% u=0;
% [p,c,a]=pca(bsxfun(@minus,[yA2; yP2],u),'Centered', false);
% M=size(yA2,1);
% N=size(yP2,1);
% figure; plot3(c(1:M,1), c(1:M,2),c(1:M,3)); hold on;
% plot3(c(M+[1:N],1), c(M+[1:N],2),c(M+[1:N],3));
% for i=1:10:M; text(c(i,1),c(i,2),c(i,3),num2str(i+10),'FontSize',6); end 
% for i=1:10:N; text(c(M+i,1),c(M+i,2),c(M+i,3),num2str(i+10),'FontSize',6); end
% plot3(0,0,0,'o','MarkerSize',20,'MarkerFaceColor','k')
% xlabel(['PC1 ' num2str(100*a(1)/sum(a)) '%']); ylabel(['PC2 ' num2str(100*a(2)/sum(a)) '%']); zlabel(['PC3 ' num2str(100*a(3)/sum(a)) '%']);
% grid on
% 
% %Done subtracting baseline, but not mean of data, the PCs are as follows:
% %PC1~ adap steady-state, PC2~ post steady-state, PC3 ~ main direction of
% %movement in adaptation [lA-eA!] (to be precise: the part of lA - eA that
% %is orthogonal to lA, which is PC1)
% 
% figure;
% subplot(2,3,1); imagesc(reshape(yE/norm(yE),12,30)'); set(gca,'YTick',1:30,'YTickLabel',muscleList); caxis([-1 1]/10); title('Late A')
% subplot(2,3,2); imagesc(reshape(yPE/norm(yPE),12,30)'); set(gca,'YTick',1:30,'YTickLabel',muscleList); caxis([-1 1]/10); title('Late P (fatigue?)')
% subplot(2,3,3); imagesc(reshape(yP0/norm(yP0),12,30)'); set(gca,'YTick',1:30,'YTickLabel',muscleList); caxis([-1 1]/10); title('Early P')
% subplot(2,3,4); imagesc(reshape(p(:,1),12,30)'); set(gca,'YTick',1:30,'YTickLabel',muscleList); caxis([-1 1]/10); title(['PC1 r=' num2str(p(:,1)'*yE'/norm(yE))])
% subplot(2,3,5); imagesc(reshape(-p(:,2),12,30)'); set(gca,'YTick',1:30,'YTickLabel',muscleList); caxis([-1 1]/10); title(['PC2 r=' num2str(-p(:,2)'*yPE'/norm(yPE))])
% subplot(2,3,6); imagesc(reshape(-p(:,3),12,30)'); set(gca,'YTick',1:30,'YTickLabel',muscleList); caxis([-1 1]/10); title(['PC3 r=' num2str(-p(:,3)'*(yP0)'/norm(yP0))])
