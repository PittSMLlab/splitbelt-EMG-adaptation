%% Load params
%loadEMGParams_controls

%Needed to bypass matlab error:
auxII=auxI;
auxI=auxII;
clear auxII

%% Get subject(s) of interest
AAnormM=nanmean(AAnorm,3); %Mean sub: use for auxiliar projection into low-dim space

%Specific subject:
subj=1;
clear tausA tausP tausP2 rsA rsP rsP2 rsA0 tausA0 tausA1 tausA2 rsA1 rsA2 rsPA xPA Xpa taus1A rs1A
for subj=1:16

%subj=16;
disp(['Subj: ' num2str(subj) ', age= ' num2str(ageC(subj))])
AAnorm1=AAnorm(:,:,subj);

%Substitute NaNs prev to medfilt:
nanidx=any(isnan(AAnorm1),2);
auxT=1:size(AAnorm1,1);
AAaux=interp1(auxT(~nanidx),AAnorm1(~nanidx,:),auxT,'linear');

%Medfilt:
AAaux=medfilt2(AAaux,[9,1]);

%Replace with NaNs:
AAnorm1(~nanidx,:)=AAaux(~nanidx,:);

%% Define epochs
yM=AAnorm1(auxI(1)+1:auxI(end-4),:,:,:);
yS=AAnorm1(auxI(end-4)+1:auxI(end-3),:,:,:);
yB=AAnorm1(auxI(end-3)+1:auxI(end-2),:,:,:);
yA=AAnorm1(auxI(end-2)+1:auxI(end-1),:,:,:);
yP=AAnorm1(auxI(end-1)+1:auxI(end),:,:,:);
yBM=AAnormM(auxI(end-3)+1:auxI(end-2),:,:,:);
yAM=AAnormM(auxI(end-2)+1:auxI(end-1),:,:,:);
yPM=AAnormM(auxI(end-1)+1:auxI(end),:,:,:);

%% Defining some important values:
earlyStrides=5;
lateStrides=100;
exempt=5; %Only for purposes of estimating baseline
BB=nanmean(yB(end-exempt-[lateStrides:-1:1],:),1); %Baseline estimate
BBM=nanmean(yBM(end-exempt-[lateStrides:-1:1],:),1); %Baseline estimate

%% 
Yall=[yM; yS; yB; yA; yP]-BB;

%Project onto subspace given by group mean
YallM=[yBM; yAM; yPM]-BBM;
%[p,c,a]=pca(YallM,'Centered',false);
%P=p(:,1:3);
%Yall=Yall/P' * P';
%yM=(yM-BB)/P' * P' +BB;
%yS=(yS-BB)/P' * P'+BB;
%yB=(yB-BB)/P' * P'+BB;
%yA=(yA-BB)/P' * P'+BB;
%yP=(yP-BB)/P' * P'+BB;

Yall=Yall(:,1:Nn*(Nm/2))-Yall(:,Nn*(Nm/2)+[1:Nn*(Nm/2)]);
Uall=[zeros(size(yM,1),1);ones(size(yS,1),1);zeros(size(yB,1),1);ones(size(yA,1),1);zeros(size(yP,1),1)];

%Now, do canonical PCA on adapt data:
Ya=[yA(1:end-5,:)]-BB;
Ya=Ya(:,1:Nn*(Nm/2))-Ya(:,Nn*(Nm/2)+[1:Nn*(Nm/2)]);
ta=1:size(Ya,1);
nanidx=any(isnan(Ya),2);
Ya=interp1(ta(~nanidx),Ya(~nanidx,:),ta,'linear','extrap')';
YYainf=mean(Ya(:,end-50:end),2)';

order=2;
forcePCS=false;
nullBD=false;
[Ca,Ja,Xa_hat,Ba,Da,r2a] = sPCAv4(Ya',order,forcePCS,nullBD);
tausA(:,subj)=-1./log(eig(Ja));
rsA(subj)=r2a(1);
% Xa=Ca\(Ya-Da);
Xainf=((eye(size(Ja))-Ja)\Ba);
Yainf=Ca*Xainf+Da;
%Order 1 model:
[C1a,J1a,X1a_hat,B1a,D1a,r12a] = sPCAv4(Ya',1,forcePCS,nullBD);
taus1A(:,subj)=-1./log(eig(J1a));
rs1A(subj)=r12a(1);
%Control 0: use only first 300 strides, estimating YYainf first [ugly]
[Ca0,Ja0,Xa_hat0,Ba0,Da0,r2a0] = sPCAv4(Ya(:,1:290)'-YYainf,order,forcePCS,true);
tausA0(:,subj)=-1./log(eig(Ja0));
rsA0(subj)=r2a0(1);
%Control 1: Taking every other stride for cross-validation:
[Ca1,Ja1,Xa_hat1,Ba1,Da1,r2a1] = sPCAv4(Ya(:,1:2:end)',order,forcePCS,nullBD);
tausA1(:,subj)=-1./log(eig(Ja1).^.5);
rsA1(subj)=r2a1(1);
[Ca2,Ja2,Xa_hat2,Ba2,Da2,r2a2] = sPCAv4(Ya(:,2:2:end)',order,forcePCS,nullBD);
tausA2(:,subj)=-1./log(eig(Ja2).^.5);
rsA2(subj)=r2a2(1);

%Just as a control, is using the first 300 strides only better?

%Also, do canonical PCA for post-adapt data
Yp=[yP(1:end-10,:)]-BB;
Yp=Yp(:,[1:Nn*(Nm/2)])-Yp(:,Nn*(Nm/2)+[1:Nn*(Nm/2)]);
tp=1:size(Yp,1);
nanidx=any(isnan(Yp),2);
Yp=interp1(tp(~nanidx),Yp(~nanidx,:),tp,'linear','extrap')';
YYpinf=mean(Yp(:,end-100:end),2)';

[Cp,Jp,Xp_hat,Bp,Dp,r2p] = sPCAv4(Yp',order,forcePCS,nullBD);
Ypinf=Cp*((eye(size(Jp))-Jp)\Bp)+Dp;
Xp=Cp\(Yp-Ypinf);
tausP(:,subj)=-1./log(eig(Jp));
rsP(subj)=r2p(1);
rsPA(subj)=1-norm(nanmean(Yp(:,1:20),2)-Ca*Xa_hat(:,end))^2/norm(nanmean(Yp(:,1:20),2))^2; %Prediction r^2
Xpa=Ca\Yp;
xPA(:,subj)=nanmean(Xpa(:,1:20),2);

%Same, asuming final state =0
[Cp2,Jp2,Xp_hat2,Bp2,Dp2,r2p2] = sPCAv4(Yp',order,forcePCS,true);
Xp2=Cp2\Yp;
tausP2(:,subj)=-1./log(eig(Jp2));
rsP2(subj)=r2p(1);

end
%% Simulate model forward, assess fit to ALL conditions
CC=Ca;JJ=Ja;B=Ba;D=Da;      Xall=CC\(Yall'-D*Uall');
Xall_hat=nan(size(Xall));   Xall_hat(:,1)=0;
X2all_hat=nan(size(Xall));  X2all_hat(:,1)=0;
X3all_hat=nan(size(Xall));  X3all_hat(:,1)=0;
X4all_hat=nan(size(Xall));  X4all_hat(:,1)=0;
idx=find(diff(Uall)~=0);
Yhat=nan(size(Yall'));      Y2hat=nan(size(Yall'));
Y3hat=nan(size(Yall'));     Y4hat=nan(size(Yall'));
JJ2=JJ;CC2=CC;
for i=2:size(Yall,1)
    Xall_hat(:,i)=JJ*Xall_hat(:,i-1)+B*Uall(i);Yhat(:,i)=CC*Xall_hat(:,i)+D*Uall(i);
    if i<=idx(end)  
        %nop
    else %For post-adaptation, an attempt at predicting using the same
    %states inferred from adaptation
        if i==idx(end)+1
            sc=nanmedian(Xall(:,idx(end)+[1:10]),2)./Xall_hat(:,i-1);
            X2all_hat(:,i-1)=sc.*Xall_hat(:,i-1);  JJ2(end,end)=JJ(end,end)^2;
            %Xall_hat(:,i)=sc.*Xall_hat(:,i);
            X3all_hat(:,i-1)=ones(size(Cp2,2),1);%Xall_hat(:,i-1);
            X4all_hat(:,i-1)=zeros(size(Cp,2),1);
            %JJ2=Jp2;
            %CC2=[Cp2(:,1) Cp2(:,2)/sc(2)];
            %CC2=Cp2;
            %CC2=[Cp2(:,2) Cp2(:,1)];
        end
       X2all_hat(:,i)=JJ2*X2all_hat(:,i-1);  Y2hat(:,i)=CC2*X2all_hat(:,i);
       X3all_hat(:,i)=Jp2*X3all_hat(:,i-1);  Y3hat(:,i)=Cp2*X3all_hat(:,i);
       X4all_hat(:,i)=Jp*X4all_hat(:,i-1)+Bp;Y4hat(:,i)=Cp*X4all_hat(:,i)+Dp;
    end
end
Xall(:,idx+1)=nan;
r=(sum((Yall'-CC*Xall -D*Uall').^2))./(sum((BB').^2)); %Residual from regressed states directly
r(idx+1)=nan;
r2=(sum((Yall'-Yhat).^2))./(sum((BB').^2)); %Residual from projected states
r2(idx+1)=nan;
r3=(sum((Yall'-Y2hat).^2))./(sum((BB').^2)); %Residual from projected states, with dynamics & C correction
r3(idx+1)=nan;
r4=(sum((Yall'-Y3hat).^2))./(sum((BB').^2)); %Residual from projected states, with dynamics & C correction, forcing 0 end-state
r4(idx+1)=nan;
r5=(sum((Yall'-Y4hat).^2))./(sum((BB').^2)); %Residual from projected states, with dynamics & C correction, forcing 0 end-state
r5(idx+1)=nan;

figure; pX=plot(Xall','DisplayName','x=C_a\Y'); hold on; set(gca,'ColorOrderIndex',1); pXh=plot(Xall_hat','LineWidth',2,'DisplayName',['x_A, \tau=' num2str(-1./log(eig(JJ))',3)]); %p1=plot(r,'DisplayName','Rec. from C_a,x=C_a\Y'); 
p2=plot(r2,'LineWidth',2,'DisplayName','Rec. from C_a,x_A'); p3=plot(r3,'LineWidth',2,'DisplayName','Rec. from C_a,x_A scaled');p4=plot(r4,'LineWidth',2,'DisplayName','Rec. from X_p,C_p (Y_\infty =0)'); p5=plot(r5,'LineWidth',2,'DisplayName','Rec. from X_p,C_p (Y_\infty \neq 0)'); 
grid on; axis tight; aa=axis; axis([aa(1:2) -.8 1.2]); 
pp=patch([41 48 48 41],[-2 -2 2 2],.6*ones(1,3),'EdgeColor','None');
uistack(pp,'bottom')
pp=patch(198+[1 900 900 1],[-2 -2 2 2],.6*ones(1,3),'EdgeColor','None');
uistack(pp,'bottom')
legend([pX(1),pXh(1),p2,p3,p4,p5],'Location','Best')
Nstrides=[100,290, 590]; %First 100,290, first 590 strides
for k=1:2

%Normalized to signal minus baseline contribution: [not a truly fair comparison for adapt vs post]
%rP=1-norm(Yall(auxI(end-1)+[1:Nstrides(k)],:)'-Yhat(:,auxI(end-1)+[1:Nstrides(k)]),'fro').^2/norm(Yall(auxI(end-1)+[1:Nstrides(k)],:)','fro').^2; %1-Residual from projected states, post-only
%rP2=1-norm(Yall(auxI(end-1)+[1:Nstrides(k)],:)'-Y2hat(:,auxI(end-1)+[1:Nstrides(k)]),'fro').^2/norm(Yall(auxI(end-1)+[1:Nstrides(k)],:)','fro').^2; %1-Residual from projected states, post-only
%rP3=1-norm(Yall(auxI(end-1)+[1:Nstrides(k)],:)'-Y3hat(:,auxI(end-1)+[1:Nstrides(k)]),'fro').^2/norm(Yall(auxI(end-1)+[1:Nstrides(k)],:)','fro').^2; %1-Residual from projected states, post-only, forcing 0 end-state
%rP4=1-norm(Yall(auxI(end-1)+[1:Nstrides(k)],:)'-Y4hat(:,auxI(end-1)+[1:Nstrides(k)]),'fro').^2/norm(Yall(auxI(end-1)+[1:Nstrides(k)],:)','fro').^2; %1-Residual from projected states, post-only, forcing 0 end-state
%rA=1-norm(Yall(auxI(end-2)+[1:Nstrides(k)],:)'-Yhat(:,auxI(end-2)+[1:Nstrides(k)]),'fro').^2/norm(Yall(auxI(end-2)+[1:Nstrides(k)],:)'-Yainf,'fro').^2; %1-Residual from projected states, adapt-only

%Normalized to mean baseline energy
Nfactor=(Nstrides(k)*(sum((BB').^2)));
idxP=auxI(end-1)+[1:Nstrides(k)];
idxA=auxI(end-2)+[1:Nstrides(k)];
idxB=auxI(end-3)+45+[1:Nstrides(k)];
dataP=Yall(idxP,:)';
dataA=Yall(idxA,:)';
rP=1-norm(dataP-Yhat(:,idxP),'fro').^2/Nfactor; %1-Residual from predicted states, post-only
rP0=1-norm(dataP,'fro').^2/Nfactor; %1-Residual from 0-th model (BB)
rP2=1-norm(dataP-Y2hat(:,idxP),'fro').^2/Nfactor; %1-Residual from predicted+adjusted states, post-only
rP3=1-norm(dataP-Y3hat(:,idxP),'fro').^2/Nfactor; %1-Residual from projected states, post-only, forcing 0 end-state
rP4=1-norm(dataP-Y4hat(:,idxP),'fro').^2/Nfactor; %1-Residual from projected states, post-only, not forcing 0 end-state
rA=1-norm(dataA-Yhat(:,idxA),'fro').^2/Nfactor; %1-Residual from projected states, adapt-only
rA0=1-norm(dataA,'fro').^2/Nfactor; %1-Residual from 0-th model (BB)
rA1=1-norm(dataA-mean(dataA,2),'fro').^2/Nfactor; %1-Residual from 1st order model (constant)
rB=1-norm(Yall(idxB,:)','fro').^2/Nfactor; %1-Residual from projected states, adapt-only

text(auxI(end-1)+200*k-100,1.1,[num2str(Nstrides(k),3) ' str.'],'Fontsize',16,'Color','k');
text(auxI(end-1)+200*k-100,1,[num2str(rP,3)],'Fontsize',16,'Color',p2.Color);
text(auxI(end-1)+200*k-100,.9,num2str(rP2,3),'Fontsize',16,'Color',p3.Color);
text(auxI(end-1)+200*k-100,.8,num2str(rP3,3),'Fontsize',16,'Color',p4.Color);
text(auxI(end-1)+200*k-100,.7,num2str(rP4,3),'Fontsize',16,'Color',p5.Color);
text(auxI(end-1)+200*k-100,.6,num2str(rP0,3),'Fontsize',16,'Color','k');
text(auxI(end-2)+200*k-100,1,num2str(rA,3),'Fontsize',16,'Color',p2.Color);
text(auxI(end-2)+200*k-100,.6,num2str(rA0,3),'Fontsize',16,'Color','k');
text(auxI(end-2)+200*k-100,.7,num2str(rA1,3),'Fontsize',16,'Color','k');
if k==1
    text(auxI(end-3),.6,num2str(rB,3),'Fontsize',16,'Color','k');
end
end
xlabel('Strides')
ylabel('a.u.')

%% Visualize results:

%Colormap:
alp=2;
ex1=[.85,0,.1].^alp;
ex2=[0,.1,.6].^alp;
map=[bsxfun(@plus,ex1,bsxfun(@times,1-ex1,[0:.01:1]'));bsxfun(@plus,ex2,bsxfun(@times,1-ex2,[1:-.01:0]'))].^(1/alp);

for kk=1:2 %adaptation + post
    switch kk
        case 1
            C=Ca;
            X=Ca\(Ya-Da);
            J=Ja;
            V=Va;
            X_hat=Xa_hat;
            Yinf=Yainf;
            D=Da;
            Y=Ya-Yainf;
            YY=Ya;
        case 2
            C=-Cp;
            Yinf=Ypinf;
            Y=Yp-Yinf;
            YY=Yp;
            X=C\(Y);
            J=Jp;
            V=Vp;
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