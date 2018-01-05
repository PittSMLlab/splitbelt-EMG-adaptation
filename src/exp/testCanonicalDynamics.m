%% Load params
%auxI=[];
loadEMGParams_controls

%Needed to bypass matlab error:
auxII=auxI;
auxI=auxII;
clear auxII

%% Get subject(s) of interest
%Mean subject:
AAnorm1=nanmean(AAnorm,3); %Mean sub: the median sub is much worse in its reconstruction

%% Define epochs
yM=AAnorm1(auxI(1)+1:auxI(2),:,:,:);
yS=AAnorm1(auxI(2)+1:auxI(3),:,:,:);
yB=AAnorm1(auxI(3)+1:auxI(4),:,:,:);
yA=AAnorm1(auxI(4)+1:auxI(5),:,:,:);
yP=AAnorm1(auxI(5)+1:auxI(6),:,:,:);

ayM=AAnorm(auxI(1)+1:auxI(2),:,:,:);
ayS=AAnorm(auxI(2)+1:auxI(3),:,:,:);
ayB=AAnorm(auxI(3)+1:auxI(4),:,:,:);
ayA=AAnorm(auxI(4)+1:auxI(5),:,:,:);
ayP=AAnorm(auxI(5)+1:auxI(6),:,:,:);

%% Defining some important values:
earlyStrides=5;
lateStrides=100;
exempt=5; %Only for purposes of estimating baseline
BB=nanmean(yB(end-exempt-[lateStrides:-1:1],:),1); %Baseline estimate
aBB=nanmean(ayB(end-exempt-[lateStrides:-1:1],:,:),1); %Baseline estimate

Yall=[yM; yS; yB; yA; yP]-BB;
aYall=[ayM; ayS; ayB; ayA; ayP]-aBB;
Yall=Yall(:,1:Nn*(Nm/2))-Yall(:,Nn*(Nm/2)+[1:Nn*(Nm/2)]);
aYall=aYall(:,1:Nn*(Nm/2),:)-aYall(:,Nn*(Nm/2)+[1:Nn*(Nm/2)],:);
Uall=[zeros(size(yM,1),1);ones(size(yS,1),1);zeros(size(yB,1),1);ones(size(yA,1),1);zeros(size(yP,1),1)];

%% Generate models
%Get adapt and post data:
Ya=[yA(1:end-3,:)]-BB;
Ya=Ya(:,1:Nn*(Nm/2))-Ya(:,Nn*(Nm/2)+[1:Nn*(Nm/2)]);
ta=1:size(Ya,1);
nanidx=any(isnan(Ya),2);
Ya=interp1(ta(~nanidx),Ya(~nanidx,:),ta,'linear','extrap')'; %Substitute nans

Yp=[yP(1:end-10,:)]-BB;
Yp=Yp(:,[1:Nn*(Nm/2)])-Yp(:,Nn*(Nm/2)+[1:Nn*(Nm/2)]);
tp=1:size(Yp,1);
nanidx=any(isnan(Yp),2);
Yp=interp1(tp(~nanidx),Yp(~nanidx,:),tp,'linear','extrap')';

Ys=yS-BB;
Ys=Ys(:,1:Nn*(Nm/2))'-Ys(:,Nn*(Nm/2)+[1:Nn*(Nm/2)])';

%Models Based on adapt data:
forcePCS=false;
nullBD=false;
model={};
for order=1:3
    model{end+1} = sPCAv6(Ya',order,forcePCS,nullBD);
    model{end}.name=['Adapt [' num2str(order) ']'];
end
model{end+1} = sPCAv6(Ya',2,forcePCS,nullBD);
model{end}.name='Short [2]';
model{end+1} = sPCAv6(Ya',2,forcePCS,nullBD,1);
model{end}.name='Adapt [2+1]';
Nfolds=2;
outputUnderRank=[];
model(end+[1:2]) = CVsPCA(Ya',2,forcePCS,nullBD,outputUnderRank,Nfolds);
model{end-1}.name='Adapt [2.1]';
model{end}.name='Adapt [2.2]';
model(end+[1:2]) = CVsPCA(Ya',3,forcePCS,nullBD,outputUnderRank,Nfolds);
model{end-1}.name='Adapt [3.1]';
model{end}.name='Adapt [3.2]';

%Also, based on post-data
for order=1:4
    model{end+1} = sPCAv6(Yp',order,forcePCS,false);
    model{end}.name=['Post* [' num2str(order) ']'];
    I=eye(size(model{end}.J));
    model{end}.B= (model{end}.J^900-I)\(model{end}.J-I)*model{end}.X(:,1);%Re-writing B value to have x=x(0) at end of adapt
end
%Same, asuming final state =0
for order=1:4
    model{end+1} = sPCAv6(Yp',order,forcePCS,true);
    model{end}.name=['Post [' num2str(order) ']'];
    I=eye(size(model{end}.J));
    model{end}.B= (model{end}.J^900-I)\(model{end}.J-I)*model{end}.X(:,1);
end
%Taking every other stride for cross-validation:
model(end+[1:2]) = CVsPCA(Yp',2,forcePCS,true,outputUnderRank,Nfolds);
model{end-1}.name='Post [2.1]';
model{end}.name='Post [2.2]';
I=eye(size(model{end}.J));
model{end}.B= (model{end}.J^900-I)\(model{end}.J-I)*model{end}.X(:,1);
model{end-1}.B= (model{end-1}.J^900-I)\(model{end-1}.J-I)*model{end-1}.X(:,1);
model(end+[1:2]) = CVsPCA(Yp',3,forcePCS,true,outputUnderRank,Nfolds);
model{end-1}.name='Post [3.1]';
model{end}.name='Post [3.2]';
I=eye(size(model{end}.J));
model{end}.B= (model{end}.J^900-I)\(model{end}.J-I)*model{end}.X(:,1);
model{end-1}.B= (model{end-1}.J^900-I)\(model{end-1}.J-I)*model{end-1}.X(:,1);

%Add PCA models (CV):
for i=1:2
[pp,cc]=pca(Ya(:,i:2:end)','Centered',false);
model{end+1}.C=pp(:,1:3);
model{end}.X=model{end}.C*(model{end}.C\Ya(:,(3-i):2:end));
model{end}.D=0;
model{end}.name=['Adapt [PCA.' num2str(i) ']'];
model{end}.J=[];
[pp,cc]=pca(Yp(:,i:2:end)','Centered',false);
model{end+1}.C=pp(:,1:3);
model{end}.X=model{end}.C*(model{end}.C\Ya(:,(3-i):2:end));
model{end}.D=0;
model{end}.name=['Post [PCA.' num2str(i) ']'];
model{end}.J=[];
end

%Add the baseline model:
model{end+1}.J=[];
model{end}.C=zeros(size(Ya,1),1);
model{end}.D=0;
model{end}.X=zeros(1,size(Yall,2));
model{end}.name='Baseline [0]';

%
for k=1:length(model)
    try %For PCA models this makes no sense
        model{k}.Xinf=((eye(size(model{k}.J))-model{k}.J)\model{k}.B);
        model{k}.Yinf=model{k}.C*model{k}.Xinf+model{k}.D;
    end
end

%% Simulate model forward, assess fit to ALL conditions

% Simulate models forward & get residuals
for k=1:length(model)
    if ~isfield(model{k},'D')
        model{k}.D=0;
    end
    model{k}.Xproj=model{k}.C\(Yall'-model{k}.D*Uall'); %Projecting data onto C's span
    try
        model{k}.Xsim=zeros(size(model{k}.C,2),size(Yall,2));
        for i=2:size(Yall,1)
            model{k}.Xsim(:,i)=model{k}.J*model{k}.Xsim(:,i-1) + model{k}.B * Uall(i-1);
        end
    catch
        model{k}.Xsim=model{k}.Xproj;
    end
    model{k}.Ysim=model{k}.C * model{k}.Xsim + model{k}.D * Uall';  
    model{k}.res=Yall'-model{k}.Ysim;
    model{k}.r2sim=(sum((model{k}.res).^2))./(sum((BB').^2));
    %MM=3;
    %model{k}.r2sim=medfilt1(model{k}.r2sim,MM);
end

figure; 
subplot(2,1,1) %Plot states
hold on
%Simulated states:
models=[1:length(model)];
models=[1:2,5:7,3,8:9,14:15,18:19,16,20:21,17,26]; %With CV models
models=[1:3,14:17,26]; %No CV
pX=nan(size(model));
models=[2,26]; %G's request
for k=models
    aux=plot(model{k}.Xsim','LineWidth',2,'DisplayName',[model{k}.name ' \tau=' num2str(-1./log(eig(model{k}.J))',3)]);
    set(aux,'Color',get(aux(1),'Color'));
    pX(k)=aux(1);
end
mrk={'.','x','o','d'};
pX1=nan(size(model));
for k=2;%1:3%models
    for j=1:size(model{k}.C,2)
        pX1(k)=plot(model{k}.Xproj(j,:),mrk{j},'Color',get(pX(k),'Color'),'DisplayName',[model{k}.name ', state ' num2str(j)]);
    end
end
grid on; axis tight; aa=axis; axis([aa(1:2) -.8 3.5]); 
pp=patch([40.5 48.5 48.5 40.5],3*[-2 -2 2 2],.3*ones(1,3),'EdgeColor','None','FaceAlpha',.3);uistack(pp,'bottom')
pp=patch(198+[.5 900.5 900.5 .5],3*[-2 -2 2 2],.3*ones(1,3),'EdgeColor','None','FaceAlpha',.3);uistack(pp,'bottom')
legend([pX(models)],'Location','Best');xlabel('Strides');ylabel('a.u.');set(gca,'FontSize',20)
title(['States'])

subplot(2,1,2) %Plot residuals
hold on
models1=[1:3,14:17,22,23,26]; %No CV
models1=[2,15,26]; %G's request
pXr=nan(size(model));
cca=get(gca,'ColorOrder');
for k=models1
    ii=1:length(model{k}.r2sim);
    try
        cc=get(pX(k),'Color');
    catch
        cc=cca(randi(size(cca,1)),:);
    end
    pXr(k)=plot(ii,sqrt(model{k}.r2sim(ii)),'LineWidth',1,'DisplayName',[model{k}.name],'Color',cc);
end
grid on; axis tight; aa=axis; axis([aa(1:2) 0 .65]); 
pp=patch([40.5 48.5 48.5 40.5],[-2 -2 2 2],.3*ones(1,3),'EdgeColor','None','FaceAlpha',.3);
uistack(pp,'bottom')
pp=patch(198+[.5 900.5 900.5 .5],[-2 -2 2 2],.3*ones(1,3),'EdgeColor','None','FaceAlpha',.3);
uistack(pp,'bottom')
lg=legend([pXr(models1)],'Location','Best');
lg.FontSize=14;
Nstrides=[100,290, 590]; %First 100,290, first 590 strides
title(['Residuals: ||Y-Y*||'])
set(gca,'FontSize',20)
xlabel('Strides')
ylabel('% Base')

%% Subspace projection view
%Subspace where most of the short-split variance resides
YY=[yM(end-20:end,:); yS; yB(1:30,:)];
%[M,~]=pca(YY(:,1:180)-YY(:,181:360));
%M=M(:,1:3);

%Subspace where most of the adapt variance resides
firstStride=99;
idx=firstStride:1698;
[M,~,aa]=pca(Yall(idx,:),'Centered',false);
M=M(:,[1:3]);
%M=M(:,4:6);

%Find projection of data onto subspace:
auxII=auxI(3:6)-firstStride+1;
cconds=conds([1:3]);
auxII(1)=0;
XX=M'*Yall(idx,:)';
%For each subject, find projections
clear aXX
for i=1:size(aYall,3)
    aXX(:,:,i)=M'*aYall(idx,:,i)'; 
end

for i=1:2:21 %Smoothing with increasing windows, exempting very last 5 strides
    for k=1:length(auxII)-1
        aux=conv2(XX(:,auxII(k)+1:auxII(k+1)-1),ones(1,i)/i,'valid');
        XX2(:,[auxII(k)+1+(i-1)/2:auxII(k+1)-(i-1)/2-1])=aux;
        for j=1:size(aYall,3)
            aux=conv2(aXX(:,auxII(k)+1:auxII(k+1)-1,j),ones(1,i)/i,'valid');
            aXX2(:,[auxII(k)+1+(i-1)/2:auxII(k+1)-(i-1)/2-1],j)=aux;
        end
        if i==11
            XX2(:,auxII(k+1)+[-(i-1)/2+1:0])=NaN;
            aXX2(:,auxII(k+1)+[-(i-1)/2+1:0],:)=NaN;
        end
    end
end

%Plot data:
figure; 
cca=get(gca,'ColorOrder');
hold on
clear pp
pp=[];
mrk={'.','o','x','d','s'};
for i=2:length(auxII)
    in=6; %This is the average of the first 11
    in2=11; %So that the last sample we use is an average (of 11 samples) that does not include any of the very last 5
    aux1=[auxII(i-1)+1:auxII(i)-in2];
    auxEarly=[auxII(i-1)+[6:25]]; %First 20, exclude 5
    auxLate=[auxII(i)-[24:-1:5]]; %Last 20, exclude 5
    pp(i-1)=plot3(XX2(1,aux1),XX2(2,aux1),XX2(3,aux1),'-','DisplayName',cconds{i-1},'Color',cca(i-1,:),'LineWidth',2);   
    early=mean(XX(:,auxEarly),2);
    late=mean(XX(:,auxLate),2);
    plot3(early(1),early(2),early(3),mrk{i-1},'DisplayName',cconds{i-1},'Color',cca(i-1,:),'LineWidth',2);
    if i>2
        early=squeeze(mean(aXX(:,auxEarly,:),2));
        late=squeeze(mean(aXX(:,auxLate,:),2));
        plot3(early(1,:),early(2,:),early(3,:),mrk{i-1},'DisplayName',cconds{i-1},'Color',.7*ones(1,3),'LineWidth',1);
        plot3([early(1,:); late(1,:)],[early(2,:); late(2,:)],[early(3,:); late(3,:)],'-','DisplayName',cconds{i-1},'Color',.7*ones(1,3),'LineWidth',1);
        text(early(1,:),early(2,:),early(3,:),[num2str([1:16]')],'Color',.7*ones(1,3),'FontSize',14);
    end
end

%For each model, find projections & plot:
models=[1,2,14,15];
for k=models
    M1=[model{k}.C];
    l={};
    t=-1./log(diag(model{k}.J));
    for j=1:size(model{k}.C,2)       
        l=[l,{['C' num2str(j) ', \tau=' num2str(t(j),3)]}];%' ' model{k}.name([1,end-2:end])]}];
    end
    if all(model{k}.D==0)
        model{k}.D=nanmean(Ya,2)-nanmean(model{k}.Ysim(:,Uall==1),2);
        model{k}.Ysim=model{k}.Ysim+model{k}.D*Uall';
    end
    if numel(model{k}.D)>1
        M1=[M1 model{k}.D];
        l=[l,{['D ']}];% model{k}.name([1,end-2:end])]}];
    end

    %Find projection of vectors of interest onto the subspace:
    C=M'*M1;

    %Find projection of SSM models onto subspace:
    if any(any(model{k}.Ysim~=0))
        XXA1=M'*model{k}.Ysim(:,idx);
        XXRes=XX-XXA1;
        XXRes2=XX2-XXA1;
        XXRes2(:,2:3:end)=NaN;
        XXRes2(:,3:3:end)=NaN;
    end

    %Plots:
    pp(end+1)=plot3(XXA1(1,:),XXA1(2,:),XXA1(3,:),'-','DisplayName',model{k}.name,'Color',cca(length(auxII)+find(k==models)-1,:));
    %plot3(XXA1(1,:)+[zeros(1,size(XXA1,2)); XXRes2(1,:)],XXA1(2,:)+[zeros(1,size(XXA1,2)); XXRes2(2,:)],XXA1(3,:)+[zeros(1,size(XXA1,2)); XXRes2(3,:)],'DisplayName',model{k}.name,'Color',get(pp(end),'Color'));
    for i=1:length(l)
        plot3(2+[0 C(1,i)],2+[0 C(2,i)],2+[0 C(3,i)],'Color',get(pp(end),'Color'))
        text(2+C(1,i),2+C(2,i),2+C(3,i),l{i},'Color',get(pp(end),'Color'))
    end
end

legend(pp)
axis equal
grid on
%% Visualize results:

%Colormap:
ex1=[.85,0,.1];
ex2=[0,.1,.6];
map=[bsxfun(@plus,ex1,bsxfun(@times,1-ex1,[0:.01:1]'));bsxfun(@plus,ex2,bsxfun(@times,1-ex2,[1:-.01:0]'))];

for kk=1:2 %adaptation + post
    switch kk
        case 1
            C=Ca;
            X=Ca\(Ya-Da);
            J=Ja;
            %V=Va;
            X_hat=Xa_hat;
            Yinf=Yainf;
            D=Da;
            Y=Ya-Yainf;
            YY=Ya;
        case 2
            C=-Cpa;
            Yinf=Ypinf;
            Y=Yp-Yinf;
            YY=Yp;
            X=C\(Y);
            J=Jp;
            %V=Vp;
            X_hat=1-Xp_hat; %Re-defining initial states
            D=Dp-C*ones(size(X,1),1); %Re-defining D accordingly to new init states
            
    end
M=size(Y,2); %Number of samples to be considered for fits

eaf=1-norm(YY-C*X-D,'fro')^2 / norm(Y,'fro')^2;
figure('Name',['cPCA, EAF=' num2str(100*eaf,3) '%'])
%Plot Yinf:
subplot(3,4,1)
imagesc(reshape(Yinf,Nn,Nm/2)')
set(gca,'YTick',1:30,'YTickLabel',muscleList)
caxis([-1 1])
title('Y_\infty')
%lot late fit:
subplot(3,4,5)
imagesc(reshape(mean(D+C*X(:,end+[-20:0]),2),Nn,Nm/2)')
set(gca,'YTick',1:30,'YTickLabel',muscleList)
caxis([-1 1])
title('Late (fit) response')

%Add PCs:
for i=1:size(C,2)
subplot(3,4,i+1)
imagesc(reshape((C(:,i)),Nn,Nm/2)')
set(gca,'YTick',1:30,'YTickLabel',muscleList)
caxis([-1 1])
projectedEAF=1-norm(Y-C(:,i)*X(i,:)-D+Yinf,'fro')^2/norm(Y,'fro')^2;
remainderEAF=1-norm(Y-C(:,[1:i-1,i+1:end])*X([1:i-1,i+1:end],:)-D+Yinf,'fro')^2/norm(Y,'fro')^2;
title(['PC' num2str(i) ', EAF \in ['  num2str(100*(eaf-remainderEAF),3) ', ' num2str(100*projectedEAF,3) ']'])
end

%Compare reconstruction and actual
subplot(3,4,4+2)
imagesc(reshape(mean(YY(:,end+[-20:0]),2),Nn,Nm/2)')
set(gca,'YTick',1:30,'YTickLabel',muscleList)
caxis([-1 1])
title('Late (actual) response')
subplot(3,4,(4)+4)
imagesc(reshape(mean(YY(:,4:13),2),Nn,Nm/2)')
set(gca,'YTick',1:30,'YTickLabel',muscleList)
caxis([-1 1])
title('Early (actual) response')
subplot(3,4,(2+5))
imagesc(reshape(D+C*mean(X(:,4:13),2),Nn,Nm/2)')
set(gca,'YTick',1:30,'YTickLabel',muscleList)
caxis([-1 1])
title('Early (fit) response')
if kk==2
    subplot(3,4,4)
    imagesc(reshape(Ca*Xa_hat(:,end),Nn,Nm/2)')
    set(gca,'YTick',1:30,'YTickLabel',muscleList)
    caxis([-1 1])
    title('Early (predicted*) response')
else
    subplot(3,4,4)
    imagesc(reshape(D,Nn,Nm/2)')
    set(gca,'YTick',1:30,'YTickLabel',muscleList)
    caxis([-1 1])
    title('D')
    

end

subplot(3,size(C,2)+2,2*(size(C,2)+2)+[1:size(C,2)+2])
%scale=abs(nanmedian(X(:,1:10),2));
%XX=bsxfun(@rdivide,X,scale)';
JJ=jordan(J);
XX=X';
plot(XX)
hold on
set(gca,'ColorOrderIndex',1)
clear pp fits
for i=1:size(C,2)
    if any(abs(J(i,[1:i-1,i+1:end]))>(1e-5 * abs(J(i,i))))
        if imag(JJ(i,i))~=0 %Diagonal in Complex field
            t=['\tau=' num2str(-1/log(abs(JJ(i,i))),3) '+ j* ' num2str((2*pi)/phase(JJ(i,i)),3) ' strides' ];
        else %No diagonal form even in Complex field
            t=['\tau=' num2str(-1/log(J(i,i)),3) '*'];
        end
    else 
        t=['\tau=' num2str(-1/log(J(i,i)),3)]; %Diagonal matrix
    end
    fit=X_hat(i,:);
    %A=XX(:,i)'/fit(1:size(XX,1));
    %fit=A*fit;
    pp(i)=plot(fit,'DisplayName',['PC' num2str(i) ', ' t ', r^2=' num2str(1-norm(fit(1:size(XX,1))'-XX(:,i))^2/norm(XX(:,i))^2,2)]);
    fits(:,i)=fit(:);
end
colormap(flipud(map))
axis tight
aa=axis;
axis([0 500 -1.5 1.5]) 
grid on
r2=1-norm(YY(:,1:M)-C*fits(1:M,:)'-D,'fro')^2/norm(Y(:,1:M),'fro')^2;
title(['Time evolution & two single-rate fit, r^2=' num2str(r2,3)])
xlabel('Strides')
ylabel('Activation (a.u.)')
legend(pp)

% %Do PCA to extract the two most meaningful PCs:
% [p,c,a]=pca(bsxfun(@minus,Y,0),'Centered',false);
% figure('Name',['PCA, EAF=' num2str(100*sum(a(1:order))/sum(a),3) '%'])
% subplot(2,size(C,2)+1,1)
% imagesc(reshape(Yinf,Nn,Nm)')
% set(gca,'YTick',1:30,'YTickLabel',muscleList)
% caxis([-1 1])
% title('Y_\infty')
% subplot(2,size(C,2)+1,size(C,2)+[2:size(C,2)+2])
% scale=nanmean(p(1:20,1:order));
% p=bsxfun(@rdivide,p(:,1:order),scale);
% c=bsxfun(@times,c(:,1:order),scale);
% plot(p)
% hold on
% set(gca,'ColorOrderIndex',1)
% clear pp
% [C,A,X2,~,~,r2,~] = sPCAv2(Y',order,1,true);
% %[C,A,X2,r2] = sPCA_knownYinf(Y',order,1);
% X2=bsxfun(@rdivide,X2,scale');
% C=bsxfun(@times,C,scale);
% %[C1,A1,X1,r1] = sPCA_knownYinf(Y',1,1);
% [C1,A1,X1,~,~,r1,~] = sPCAv2(Y',1,1,true);
%    t2=-1./log(eig(A));
%    t1=-1./log(eig(A1));
%    fit=X2;
%    fit1=X1;
% for i=1:order
%     subplot(2,size(C,2)+1,size(C,2)+[2:size(C,2)+2])
%     pp(i)=plot(fit(i,:),'DisplayName',['PC' num2str(i) ', \tau= ' num2str(t2',3) ', r^2=' num2str(1-norm(X2(i,:)-p(:,i)')^2/norm(p(:,i))^2,2) ]);
%     subplot(2,size(C,2)+1,i+1)
%     imagesc(reshape(c(:,i),Nn,Nm)')
%     caxis([-1 1])
%     title(['PC' num2str(i) ', EAF=' num2str(100*a(i)/sum(a))])
%     set(gca,'YTick',1:30,'YTickLabel',muscleList)
% end
% 
% subplot(2,size(C,2)+1,size(C,2)+[2:size(C,2)+2])
% colormap(flipud(map))
% axis tight
% aa=axis;
% axis([0 500 -1 2]) 
% grid on
% r2=1-norm(Y(:,1:M)-C*fit(1:order,1:M),'fro')^2/norm(Y(:,1:M),'fro')^2;
% r12=1-norm(Y(:,1:M)-C1*fit1(:,1:M),'fro')^2/norm(Y(:,1:M),'fro')^2;
% title(['Time evolution & dual rate fit, r^2=' num2str(r2,3) ', r_1^2=' num2str(r12,3)])
% xlabel('Strides')
% ylabel('Activation (a.u.)')
% legend(pp)

end