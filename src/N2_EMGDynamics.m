%% Load params
%error('Need to review loadEMGParams_controls to figure out what the proper way of aligning subjects is. Perhaps there is no good workaround') %I mean to align the trial ends every 300 strides during Adaptation
groupName='controls';
%allDataEMG=loadEMGParams_ForDynamics(groupName); %If ../data/dynamicsData.mat doesn't exist, this needs to be run. Alternatively, just load the file
%load ../data/dynamicsData.mat

%% Some pre-proc
B=nanmean(allDataEMG{1}(end-45:end-5,:,:)); %Baseline: last 40, exempting 5
clear data dataSym
for i=1:3 %B,A,P
    %Remove baseline
    data{i}=allDataEMG{i}-B;

    %Interpolate over NaNs
    for j=1:size(data{i},3) %each subj
    t=1:size(data{i},1); nanidx=any(isnan(data{i}(:,:,j)),2); %Any muscle missing
    data{i}(:,:,j)=interp1(t(~nanidx),data{i}(~nanidx,:,j),t,'linear','extrap'); %Substitute nans
    end
    
    %Compute asymmetry component
    aux=data{i}-fftshift(data{i},2);
    dataSym{i}=aux(:,1:size(aux,2)/2,:);
end

% dataSym=data; %Bilateral models
%% Generate models

forcePCS=false;
model={};
outputUnderRank=[];
for dataSet=1%:2%3
    switch dataSet
        case 1 %Using adaptation data to fit model
            data=median(dataSym{2},3); %Median across subjs
            nn='Adapt';
            nullBD=false;
        case 2 %Using post-adaptation data to fit model
            data=median(dataSym{3},3); %Median across subjs
            nn='Post';
            nullBD=true; %This means B & D are not fitted, because the input is null. Instead, we fit the initial state to a non-zero value. 
            %Notice that not fitting B implies no loss of generality, as B and x(0)
            %can be, in general, interchanged for one another (if all
            %states are reachable). Not fitting D does imply loss of
            %generality: means that the steady-state HAS TO BE 0. [in
            %practice if the steady-state is non-zero, a very slow changing
            %state will be found, such that after any finite number of steps
            %the state will be non-zero]
        case 3 %Using post-adaption, but fitting B,D. See above.
            data=median(dataSym{3},3); %Median across subjs
            nn='Post*';
            nullBD=false;
    end
    for Nfolds=1:2 %Doing 1,2-fold cross-validation 
        for order=1:5
            model(end+[1:Nfolds]) = CVsPCA(data,order,forcePCS,nullBD,outputUnderRank,Nfolds);
            for j=1:Nfolds %Setting names
                model{end-Nfolds+j}.name=[nn '[' num2str(order) '.' num2str(j) '/' num2str(Nfolds) ']'];
                if dataSet==2
                    m=model{end-Nfolds+j};
                    I=eye(size(m.J));
                    m.B= (m.J^900-I)\(m.J-I)*m.X(:,1); %Setting B such that the computed initState is reached within 900 strides starting from 0.
                    if isempty(m.D); m.D=0; end %No D fitting
                    model{end-Nfolds+j}=m;
                end
            end
        end
    end
end

%Add the baseline model:
model{end+1}.J=0; model{end}.C=zeros(size(data,2),1); model{end}.D=0;
model{end}.X=zeros(1,size(dataSym{1},1)); model{end}.name='Baseline [0]'; model{end}.B=0;

% Simulate models forward & get residuals
Uall=[zeros(size(dataSym{1},1),1); ones(size(dataSym{2},1),1); zeros(size(dataSym{3},1),1)];
Yall=median(cell2mat(dataSym'),3);
for k=1:length(model)
    model{k}.Xproj=model{k}.C\(Yall'-model{k}.D*Uall'); %Projecting data onto C's span
    model{k}.Xsim=zeros(size(model{k}.C,2),size(Yall,2));
    for i=2:size(Yall,1)
        model{k}.Xsim(:,i)=model{k}.J*model{k}.Xsim(:,i-1) + model{k}.B * Uall(i-1);
    end
    model{k}.Ysim=model{k}.C * model{k}.Xsim + model{k}.D * Uall';  
    model{k}.res=Yall'-model{k}.Ysim;
    model{k}.r2sim=(sum((model{k}.res).^2));   
    model{k}.r2Adapt=(sum((model{k}.res(:,51:950)).^2)); 
    model{k}.r2Post=(sum((model{k}.res(:,951:end)).^2));  
    model{k}.r2AdaptOdd=(sum((model{k}.res(:,51:2:950)).^2));   
    model{k}.r2AdaptEven=(sum((model{k}.res(:,52:2:950)).^2)); 
end

%save ../data/dynamicsModelingResultsALL.mat model Yall Uall model dataSym
%% Plot basic model performance
for i=1:5 %Model orders tried
    rAllAll(i)=mean(model{i}.r2Adapt);
    rAllOdd(i)=mean(model{i}.r2AdaptOdd);
    rAllEven(i)=mean(model{i}.r2AdaptEven);
    r1Odd(i)=mean(model{4+2*i}.r2AdaptOdd); %Trained on odd data
    r1Even(i)=mean(model{4+2*i}.r2AdaptEven);
    r2Odd(i)=mean(model{5+2*i}.r2AdaptOdd); %Trained on even data
    r2Even(i)=mean(model{5+2*i}.r2AdaptEven);
    rAllPost(i)=mean(model{i}.r2Post);
end
fh=figure('Units','Normalized','OuterPosition',[0 0 .5 .7]);
subplot(2,2,1) %Cross-validation of adaptation-fitted models to Post-data
hold on
p0=plot(rAllAll,'DisplayName','Train: adapt, Test: adapt');
p1=plot(rAllPost,'DisplayName','Train: adapt, Test: post');
xlabel('Model order')
legend([p0 p1])
ylabel('Squared residuals (a.u.)')
grid on

subplot(2,2,2) %Cross-validation of adapt-fitted models to unused(2-fold) adapt data
hold on
p0=plot(rAllOdd,'k','DisplayName','Train: all data, Test: odd strides');
p1=plot(rAllEven,'k--','DisplayName','Test: even strides');
p2=plot(r1Odd,'DisplayName','Train: odd data, Test: odd data');
plot(r1Even,'--','Color',p2.Color);
p3=plot(r2Odd,'DisplayName','Train: even data, Test: odd data');
plot(r2Even,'--','Color',p3.Color)
xlabel('Model order')
ylabel('Squared residuals (a.u.)')
legend([p0 p1 p2 p3])
grid on

subplot(2,2,4) %Plotting decay rates
hold on
for i=1:5
    plot(i+.1*randn(i,1),-1./log(diag(model{i}.J)),'ko','MarkerFaceColor','k') 
   plot(i+.1*randn(i,1),-1./log(diag(model{4+2*i}.J)),'o','Color',p2.Color,'MarkerFaceColor',p2.Color) 
   plot(i+.1*randn(i,1),-1./log(diag(model{5+2*i}.J)),'o','Color',p3.Color,'MarkerFaceColor',p3.Color) 
end
xlabel('Model order')
set(gca,'YScale','log')
grid on
title('Decay rates (fitted)')
ylabel('Time-constants (strides)')
saveFig(fh,'../intfig/all/dyn/','modelOrderAssessment',0)

%%
figure; 
subplot(2,1,1) %Plot states
hold on
%Simulated states:
models=[1:length(model)];
models=[1:2,5:7,3,8:9,14:15,18:19,16,20:21,17,26]; %With CV models
models=[1:3,14:17,26]; %No CV
pX=nan(size(model));
models=[3,16]; %G's request
for k=models
    aux=plot(model{k}.Xsim','LineWidth',2,'DisplayName',[model{k}.name ' \tau=' num2str(-1./log(eig(model{k}.J))',3)]);
    set(aux,'Color',get(aux(1),'Color'));
    pX(k)=aux(1);
end
mrk={'.','x','o','d'};
pX1=nan(size(model));
for k=models(1) %Only for first model
    for j=1:size(model{k}.C,2)
        pX1(k)=scatter([1:size(model{k}.Xproj,2)]',model{k}.Xproj(j,:),20,get(pX(k),'Color'),'filled','MarkerEdgeColor','none','MarkerFaceAlpha',1-(j-1)/(size(model{k}.C,2)),'DisplayName',[model{k}.name ', state ' num2str(j)]);
        %pX1(k)=plot(model{k}.Xproj(j,:),mrk{j},'Color',get(pX(k),'Color'),'DisplayName',[model{k}.name ', state ' num2str(j)]);
    end
end
grid on; axis tight; aa=axis; axis([aa(1:2) -.8 3.5]); 
%pp=patch([40.5 48.5 48.5 40.5],3*[-2 -2 2 2],.3*ones(1,3),'EdgeColor','None','FaceAlpha',.3);uistack(pp,'bottom')
pp=patch(50+[.5 900.5 900.5 .5],3*[-2 -2 2 2],.3*ones(1,3),'EdgeColor','None','FaceAlpha',.3);uistack(pp,'bottom')
legend([pX(models)],'Location','Best');xlabel('Strides');ylabel('a.u.');set(gca,'FontSize',20)
title(['States'])

subplot(2,1,2) %Plot residuals
hold on

pXr=nan(size(model));
cca=get(gca,'ColorOrder');
for k=models
    ii=1:length(model{k}.r2sim);
    try
        cc=get(pX(k),'Color');
    catch
        cc=cca(randi(size(cca,1)),:);
    end
    pXr(k)=plot(ii,sqrt(model{k}.r2sim(ii)),'LineWidth',1,'DisplayName',[model{k}.name],'Color',cc);
end
grid on; axis tight; %aa=axis; axis([aa(1:2) 0 .65]); 
pp=patch(50+[.5 900.5 900.5 .5],[-2 -2 2 2],.3*ones(1,3),'EdgeColor','None','FaceAlpha',.3);
uistack(pp,'bottom')
lg=legend([pXr(models)],'Location','Best');
lg.FontSize=14;
Nstrides=[100,290, 590]; %First 100,290, first 590 strides
title(['Residuals: ||Y-Y*||'])
set(gca,'FontSize',20)
xlabel('Strides')
ylabel('% Base')

%% Visualize and save each model
switchFactor=0; %LTI model prediction as is
postOffset=951;
for i=[1,2,3,4,5]%15,16]
    m=model{i};
    if i<=8 %Fitted to adapt data
        [~,idx]=max(diag(model{i}.J)); %Find slowest state
        m.Ysim(:,postOffset:end)=m.Ysim(:,postOffset:end) - switchFactor* m.C(:,idx) * m.Xsim(idx,postOffset:end); %Removing some percentage of the slowest state only
        m.Xsim(idx,postOffset:end)=(1-switchFactor)*m.Xsim(idx,postOffset:end);
    end
    fh=assessModel(m,Yall',Uall');
    %saveFig(fh,'../intfig/all/dyn/',[regexprep(model{i}.name,'/','_')]);
end
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