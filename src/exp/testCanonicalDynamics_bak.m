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
aBB=nanmean(yB(end-exempt-[lateStrides:-1:1],:),1); %Baseline estimate

%% 
Yall=[yM; yS; yB; yA; yP]-BB;
aYall=[ayM; ayS; ayB; ayA; ayP]-aBB;
Yall=Yall(:,1:Nn*(Nm/2))-Yall(:,Nn*(Nm/2)+[1:Nn*(Nm/2)]);
aYall=aYall(:,1:Nn*(Nm/2),:)-aYall(:,Nn*(Nm/2)+[1:Nn*(Nm/2)],:);
Uall=[zeros(size(yM,1),1);ones(size(yS,1),1);zeros(size(yB,1),1);ones(size(yA,1),1);zeros(size(yP,1),1)];

%Now, do canonical PCA on adapt data:
Ya=[yA(1:end-3,:)]-BB;
Ya=Ya(:,1:Nn*(Nm/2))-Ya(:,Nn*(Nm/2)+[1:Nn*(Nm/2)]);
ta=1:size(Ya,1);
nanidx=any(isnan(Ya),2);
Ya=interp1(ta(~nanidx),Ya(~nanidx,:),ta,'linear','extrap')'; %Substitute nans
YYainf=mean(Ya(:,end-100:end),2)';

Ys=yS-BB;
Ys=Ys(:,1:Nn*(Nm/2))'-Ys(:,Nn*(Nm/2)+[1:Nn*(Nm/2)])';

order=2;
forcePCS=false;
nullBD=false;
[Ca,Ja,Xa_hat,Ba,Da,r2a] = sPCAv5(Ya',order,forcePCS,nullBD);
[Cs,Js,Xs_hat,Bs,Ds,r2s] = sPCAv5(Ys',order,forcePCS,nullBD);
[Cab,Jab,Xa_hatb,Bab,Dab,r2ab] = sPCAv5(Ya',order,forcePCS,nullBD,1);
% Xa=Ca\(Ya-Da);
Xainf=((eye(size(Ja))-Ja)\Ba);
Yainf=Ca*Xainf+Da;
%Order 1 model:
[C1a,J1a,X1a_hat,B1a,D1a,r12a] = sPCAv5(Ya',1,forcePCS,nullBD);
%Order 3 model:
[C3a,J3a,X3a_hat,B3a,D3a,r32a] = sPCAv5(Ya',3,forcePCS,nullBD);
%Taking every other stride for cross-validation:
Nfolds=2;
outputUnderRank=[];
[Cf,Af,Xf,Bf,Df,rf] = CVsPCA(Ya',order,forcePCS,nullBD,outputUnderRank,Nfolds);
Ca1=Cf(:,:,1); Ja1=Af(:,:,1); Xa_hat1=Xf(:,:,1); Ba1=Bf(:,:,1); Da1=Df(:,:,1); r2a1=rf(:,1);
Ca2=Cf(:,:,2); Ja2=Af(:,:,2); Xa_hat2=Xf(:,:,2); Ba2=Bf(:,:,2); Da2=Df(:,:,2); r2a2=rf(:,2);
[Cf,Af,Xf,Bf,Df,rf] = CVsPCA(Ya',3,forcePCS,nullBD,outputUnderRank,Nfolds);
C3a1=Cf(:,:,1); J3a1=Af(:,:,1); X3a_hat1=Xf(:,:,1); B3a1=Bf(:,:,1); D3a1=Df(:,:,1); r23a1=rf(:,1);
C3a2=Cf(:,:,2); J3a2=Af(:,:,2); X3a_hat2=Xf(:,:,2); B3a2=Bf(:,:,2); D3a2=Df(:,:,2); r23a2=rf(:,2);


%Just as a control, is using the first 300 strides only better?

%Also, do canonical PCA for post-adapt data
Yp=[yP(1:end-10,:)]-BB;
Yp=Yp(:,[1:Nn*(Nm/2)])-Yp(:,Nn*(Nm/2)+[1:Nn*(Nm/2)]);
tp=1:size(Yp,1);
nanidx=any(isnan(Yp),2);
Yp=interp1(tp(~nanidx),Yp(~nanidx,:),tp,'linear','extrap')';
YYpinf=mean(Yp(:,end-100:end),2)';

% [Cp,Jp,Xp_hat,Bp,Dp,r2p] = sPCAv5(Yp',order,forcePCS,nullBD);
% Ypinf=Cp*((eye(size(Jp))-Jp)\Bp)+Dp;
% Xp=Cp\(Yp-Ypinf);
% %Order 1:
% [C1p,J1p,X1p_hat,B1p,D1p,r12p] = sPCAv5(Yp',1,forcePCS,nullBD);
% %Order 3:
% [C3p,J3p,X3p_hat,B3p,D3p,r32p] = sPCAv5(Yp',3,forcePCS,nullBD);
% %Taking every other stride for cross-validation:
% [Cp1,Jp1,Xp_hat1,Bp1,Dp1,r2p1] = sPCAv5(Yp(:,1:2:end)',order,forcePCS,nullBD);
% [Cp2,Jp2,Xp_hat2,Bp2,Dp2,r2p2] = sPCAv5(Yp(:,2:2:end)',order,forcePCS,nullBD);

%Same, asuming final state =0
[Cpa,Jpa,Xp_hata,Bpa,Dpa,r2pa] = sPCAv5(Yp',order,forcePCS,true);
Xpa=Cpa\Yp;
%Order 1:
[C1pa,J1pa,X1p_hata,B1pa,D1pa,r12pa] = sPCAv5(Yp',1,forcePCS,true);
%Order 3:
[C3pa,J3pa,X3p_hata,B3pa,D3pa,r32pa] = sPCAv5(Yp',3,forcePCS,true);
%Order 4:
[C4pa,J4pa,X4p_hata,B4pa,D4pa,r42pa] = sPCAv5(Yp',4,forcePCS,true);
%Taking every other stride for cross-validation:
[Cpa1,Jpa1,Xp_hata1,Bpa1,Dpa1,r2pa1] = sPCAv5(Yp(:,1:2:end)',order,forcePCS,true);
[Cpa2,Jpa2,Xp_hata2,Bpa2,Dpa2,r2pa2] = sPCAv5(Yp(:,2:2:end)',order,forcePCS,true);

%% Simulate model forward, assess fit to ALL conditions

Uall=[zeros(size(yM,1),1);ones(size(yS,1),1);zeros(size(yB,1),1);ones(size(yA,1),1);zeros(size(yP,1),1)];
%Uall1=[zeros(size(yM,1),1);1.23*ones(size(yS,1),1);zeros(size(yB,1),1);ones(size(yA,1),1);zeros(size(yP,1),1)];
Uall1=Uall;
CC=Ca;JJ=Ja;B=Ba;D=Da;E=0;      Xall=CC\(Yall'-D*Uall'); %Adaptation 2-state model
CC1=C1a;JJ1=J1a;BB1=B1a;DD1=D1a;      X1all=CC1\(Yall'-DD1*Uall'); %adaptation 1 state
CC2=Cab;JJ2=Jab;BB2=Bab; DD2=Dab; %2-state dyn with rank-1 C matrix
%CC2=C3a;JJ2=J3a;BB2=B3a; DD2=D3a; 
%CC3=Cp;JJ3=Jp;BB3=Bp;DD3=Dp; %Post-adapt 2-state
CC3=Cpa;JJ3=Jpa;BB3=Bpa;DD3=Dpa; %Dpa=0; Bpa=0;
%CC4=C1p;JJ4=J1p;BB4=B1p;DD4=D1p; %Post-adapt 1-state
CC4=C1pa;JJ4=J1pa;BB4=B1pa;DD4=D1pa; %D1pa=0, B1pa=0;
%CC5=C3p;JJ5=J3p;BB5=B3p;DD5=D3p; %Post-adapt 3-state
CC5=C3pa;JJ5=J3pa;BB5=B3pa;DD5=D3pa; %D1pa=0, B1pa=0;
CC6=C3a;JJ6=J3a;BB6=B3a;DD6=D3a; X6all=CC6\(Yall'-DD6*Uall');
CC61=C3a1;JJ61=J3a1;BB61=B3a1;DD61=D3a1; X6all1=CC61\(Yall'-DD61*Uall');
CC62=C3a2;JJ62=J3a2;BB62=B3a2;DD62=D3a2; X6all2=CC62\(Yall'-DD62*Uall');

Xall_hat=nan(size(CC,2),size(Xall,2));       Xall_hat(:,1)=0;
X1all_hat=nan(size(CC1,2),size(Xall,2));  X1all_hat(:,1)=0;
X2all_hat=nan(size(CC2,2),size(Xall,2));      X2all_hat(:,1)=0;
X3all_hat=nan(size(Xall));      X3all_hat(:,1)=0;
X4all_hat=nan(1,size(Xall,2));  X4all_hat(:,1)=0;
X5all_hat=nan(3,size(Xall,2));  X5all_hat(:,1)=0;
X6all_hat=nan(size(CC6,2),size(Xall,2));  X6all_hat(:,1)=0;
X6all1_hat=nan(size(CC6,2),size(Xall,2));  X6all1_hat(:,1)=0;
X6all2_hat=nan(size(CC6,2),size(Xall,2));  X6all2_hat(:,1)=0;
idx=find(diff(Uall)~=0);         
Y1hat=nan(size(Yall'));         Y2hat=nan(size(Yall'));
Y3hat=nan(size(Yall'));         Y4hat=nan(size(Yall'));
Y5hat=nan(size(Yall'));         Yhat=nan(size(Yall'));
Y6hat=nan(size(Yall'));         Y6hat1=nan(size(Yall'));
Y6hat2=nan(size(Yall'));

Ya=[yA(1:end,:)]-BB;
Ya=Ya(:,1:Nn*(Nm/2))-Ya(:,Nn*(Nm/2)+[1:Nn*(Nm/2)]);
[pa,ca]=pca(Ya,'Centered',false);
YPCAhat=nan(size(Yall'));
YPCAhat3=nan(size(Yall'));
for i=1:2
[pp,cp]=pca(Ya(i:2:end,:),'Centered',false);
%YPCAhat(:,auxI(end-2)+(3-i):2:auxI(end-1)) = pp(:,1:2)*(pp(:,1:2)\Ya((3-i):2:end,:)');
YPCAhat3(:,auxI(end-2)+(3-i):2:auxI(end-1)) = pp(:,1:3)*(pp(:,1:3)\Ya((3-i):2:end,:)');
end
Yp=[yP(1:end,:)]-BB;
Yp=Yp(:,[1:Nn*(Nm/2)])-Yp(:,Nn*(Nm/2)+[1:Nn*(Nm/2)]);
for i=1:2
[pp,cp]=pca(Yp(i:2:end,:),'Centered',false);
YPCAhat3(:,auxI(end-1)+(3-i):2:auxI(end)) = pp(:,1:2)*(pp(:,1:2)\Yp((3-i):2:end,:)');
%YPCAhat3(:,auxI(end-1)+(3-i):2:auxI(end)) = pp(:,1:3)*(pp(:,1:3)\Yp((3-i):2:end,:)');
end

for i=2:size(Yall,1)
    Xall_hat(:,i)=JJ*Xall_hat(:,i-1)+B*Uall(i-1);Yhat(:,i)=CC*Xall_hat(:,i)+D*Uall1(i)+E;
    X1all_hat(:,i)=JJ1*X1all_hat(:,i-1)+BB1*Uall(i-1);Y1hat(:,i-1)=CC1*X1all_hat(:,i-1)+DD1*Uall1(i-1);
    X2all_hat(:,i)=JJ2*X2all_hat(:,i-1)+BB2*Uall(i-1);Y2hat(:,i-1)=CC2*X2all_hat(:,i-1)+DD2*Uall1(i-1);
    X6all_hat(:,i)=JJ6*X6all_hat(:,i-1)+BB6*Uall(i-1);Y6hat(:,i-1)=CC6*X6all_hat(:,i-1)+DD6*Uall1(i-1);
    X6all1_hat(:,i)=JJ61*X6all1_hat(:,i-1)+BB61*Uall(i-1);Y6hat1(:,i-1)=CC61*X6all1_hat(:,i-1)+DD61*Uall1(i-1);
    X6all2_hat(:,i)=JJ62*X6all2_hat(:,i-1)+BB62*Uall(i-1);Y6hat2(:,i-1)=CC62*X6all2_hat(:,i-1)+DD62*Uall1(i-1);
    if i<idx(end)  
        %nop
    else %For post-adaptation
        if i==idx(end)+1
            X3all_hat(:,i)=Xp_hata(:,1);
            X4all_hat(:,i)=X1p_hata(:,1);
            X5all_hat(:,i)=X3p_hata(:,1);
            %CC1=CC4;
        else
           X3all_hat(:,i)=JJ3*X3all_hat(:,i-1)+BB3;     Y3hat(:,i-1)=CC3*X3all_hat(:,i-1)+DD3; 
           X4all_hat(:,i)=JJ4*X4all_hat(:,i-1)+BB4;     Y4hat(:,i-1)=CC4*X4all_hat(:,i-1)+DD4;
           X5all_hat(:,i)=JJ5*X5all_hat(:,i-1)+BB5;     Y5hat(:,i-1)=CC5*X5all_hat(:,i-1)+DD5;
        end
    end
end
Xall(:,idx+1)=nan;
r=(sum((Yall'-CC*Xall -D*Uall').^2))./(sum((BB').^2)); %Residual from regressed states directly
MM=3; r(idx+1)=nan; r=medfilt1(r,MM); %r=conv(r,ones(1,MM)/MM);
r2=(sum((Yall'-Yhat).^2))./(sum((BB').^2)); %Residual from projected states
r2(idx+1)=nan; r2=medfilt1(r2,MM); %r2=conv(r2,ones(1,MM)/MM);
r3=(sum((Yall'-Y2hat).^2))./(sum((BB').^2)); %Residual from projected states, with dynamics & C correction
r3(idx+1)=nan; r3=medfilt1(r3,MM); %r3=conv(r3,ones(1,MM)/MM);
r4=(sum((Yall'-Y3hat).^2))./(sum((BB').^2)); %Residual from projected states, with dynamics & C correction, forcing 0 end-state
r4(idx+1)=nan; r4=medfilt1(r4,MM); %r4=conv(r4,ones(1,MM)/MM);
r5=(sum((Yall'-Y4hat).^2))./(sum((BB').^2)); %Residual from projected states, with dynamics & C correction, forcing 0 end-state
r5(idx+1)=nan; r5=medfilt1(r5,MM);%r5=conv(r5,ones(1,MM)/MM);
r6=(sum((Yall'-Y5hat).^2))./(sum((BB').^2)); %Residual from projected states, with dynamics & C correction, forcing 0 end-state
r6(idx+1)=nan; r6=medfilt1(r6,MM);%r6=conv(r6,ones(1,MM)/MM);
r0=(sum((Yall').^2))./(sum((BB').^2)); %Residual from baseline model
r0(idx+1)=nan; r0=medfilt1(r0,MM);%r0=conv(r0,ones(1,MM)/MM);
r1=(sum((Yall'-Y1hat).^2))./(sum((BB').^2));
r1(idx+1)=nan; r1=medfilt1(r1,MM);%r1=conv(r1,ones(1,MM)/MM);
r7=(sum((Yall'-Y6hat).^2))./(sum((BB').^2)); %Residual from projected states, with dynamics & C correction, forcing 0 end-state
r7(idx+1)=nan; r7=medfilt1(r7,MM);%r6=conv(r6,ones(1,MM)/MM);
rPCA=(sum((Yall'-YPCAhat).^2))./(sum((BB').^2)); 
rPCA(idx+1)=nan; rPCA=medfilt1(rPCA,MM);
rPCA3=(sum((Yall'-YPCAhat3).^2))./(sum((BB').^2)); 
rPCA3(idx+1)=nan; rPCA3=medfilt1(rPCA3,MM);


figure; 
subplot(2,1,1)
pX0=plot([1,size(Xall,2)],[0,0],'k','LineWidth',2,'DisplayName','x=0 (Baseline)');
hold on
cc=get(gca,'ColorOrder');
set(gca,'ColorOrderIndex',1); 
pXh=plot(Xall_hat','LineWidth',2,'DisplayName',['x_A [2], \tau=' num2str(-1./log(eig(JJ))',3)],'Color',cc(1,:)); %p1=plot(r,'DisplayName','Rec. from C_a,x=C_a\Y'); 
pXh1=plot(X1all_hat','LineWidth',2,'DisplayName',['x_A [1], \tau=' num2str(-1./log(eig(JJ1))',3)],'Color',cc(2,:)); %p1=plot(r,'DisplayName','Rec. from C_a,x=C_a\Y'); 
pXh3=plot(X3all_hat','LineWidth',1,'Color',cc(3,:)); %p1=plot(r,'DisplayName','Rec. from C_a,x=C_a\Y'); 
pXh4=plot(X4all_hat','LineWidth',1,'Color',cc(4,:)); %p1=plot(r,'DisplayName','Rec. from C_a,x=C_a\Y'); 
pXh5=plot(X5all_hat','LineWidth',1,'Color',cc(5,:)); %p1=plot(r,'DisplayName','Rec. from C_a,x=C_a\Y'); 
pXh6=plot(X6all_hat','LineWidth',2,'DisplayName',['x_A [3], \tau=' num2str(-1./log(eig(JJ6))',3)],'Color',cc(6,:)); %p1=plot(r,'DisplayName','Rec. from C_a,x=C_a\Y'); 


set(gca,'ColorOrderIndex',1); 
mrk={'.','x','o'};
for iii=1:2
pX(iii)=plot(Xall(iii,:)',mrk{iii},'DisplayName','x=C_A \\ (Y-D_A) [2]','Color',cc(1,:)); hold on; 
end
pX1=plot(X1all','.','DisplayName','x=C_A \\ (Y-D_A) [1]','Color',cc(2,:)); 
for iii=1:3
%pX6(iii)=plot(X6all(iii,:)',mrk{iii},'DisplayName','x=C_A \\ (Y-D_A) [3]','Color',pXh6(1).Color); 
end
grid on; axis tight; aa=axis; axis([aa(1:2) -.8 3.5]); 
pp=patch([40.5 48.5 48.5 40.5],3*[-2 -2 2 2],.3*ones(1,3),'EdgeColor','None','FaceAlpha',.3);
uistack(pp,'bottom')
pp=patch(198+[.5 900.5 900.5 .5],3*[-2 -2 2 2],.3*ones(1,3),'EdgeColor','None','FaceAlpha',.3);
uistack(pp,'bottom')
legend([pX0 pXh(1) pXh1(1)],'Location','Best')
xlabel('Strides')
ylabel('States (a.u.)')
set(gca,'FontSize',20)

subplot(2,1,2)
hold on
ii=1:MM:length(r2);
p2=plot(ii,sqrt(r2(ii)),'LineWidth',1,'DisplayName','Y=C_A.x_A+D_A.u [2]','Color',pX(1).Color,'MarkerFaceColor',pX(1).Color); 
p3=plot(ii,sqrt(r3(ii)),'LineWidth',1,'DisplayName',['Y=C_A.x_A+D_A.u [2+1], \tau=' num2str(-1./log(eig(JJ2))',4)],'Color','g');
p4=plot(ii,sqrt(r4(ii)),'LineWidth',1,'DisplayName',['Y=X_p.C_p [2], \tau=' num2str(-1./log(eig(JJ3))',4)],'Color',pXh3(1).Color,'MarkerFaceColor',pX(2).Color); 
p5=plot(ii,sqrt(r5(ii)),'LineWidth',1,'DisplayName',['Y=X_p.C_p [1], \tau= ' num2str(-1./log(eig(JJ4))',4)],'Color',pXh4(1).Color .^2,'MarkerFaceColor','r'); %This is essentially the same as with D=0
p6=plot(ii,sqrt(r6(ii)),'LineWidth',1,'DisplayName',['Y=X_p.C_p [3], \tau= ' num2str(-1./log(eig(JJ5))',4)],'Color',pXh5(1).Color .^.5,'MarkerFaceColor','g'); %This is essentially the same as with D=0
p0=plot(ii,sqrt(r0(ii)),'LineWidth',1,'DisplayName','Y=Baseline [0]','Color','k','MarkerFaceColor','k'); 
p1=plot(ii,sqrt(r1(ii)),'LineWidth',1,'DisplayName','Y=C_A.x_A+D_A.u [1]','Color',pXh1.Color,'MarkerFaceColor',pXh1.Color); 
%p7=plot(ii,sqrt(r7(ii)),'LineWidth',1,'DisplayName',['Y=X_a.C_a [3], \tau= ' num2str(-1./log(eig(JJ6))',4)],'Color',pXh6(1).Color .^.5,'MarkerFaceColor','g'); %This is essentially the same as with D=0
%pPCA=plot(ii,sqrt(rPCA(ii)),'LineWidth',1,'DisplayName','PCA (non-CV) 2-state','Color','m'); 
pPCA3=plot(ii,sqrt(rPCA3(ii)),'LineWidth',1,'DisplayName','PCA (CV) [2]','Color','m'); 
grid on; axis tight; aa=axis; axis([aa(1:2) 0 .65]); 
pp=patch([40.5 48.5 48.5 40.5],[-2 -2 2 2],.3*ones(1,3),'EdgeColor','None','FaceAlpha',.3);
uistack(pp,'bottom')
pp=patch(198+[.5 900.5 900.5 .5],[-2 -2 2 2],.3*ones(1,3),'EdgeColor','None','FaceAlpha',.3);
uistack(pp,'bottom')
lg=legend([p2,p1,p3,p0,p5,p4,p6,pPCA3],'Location','Best');
lg.FontSize=14;
Nstrides=[100,290, 590]; %First 100,290, first 590 strides
title(['Residuals ||Y-Y*||'])
set(gca,'FontSize',20)
for k=1:2
    %Normalized to mean baseline energy
    Nfactor=(Nstrides(k)*(sum((BB').^2)));
    idxP=auxI(end-1)+[1:Nstrides(k)];
    idxA=auxI(end-2)+[1:Nstrides(k)];
    idxB=auxI(end-3)+45+[1:Nstrides(k)];
    dataP=Yall(idxP,:)';
    dataA=Yall(idxA,:)';
    rP=1-norm(dataP-Yhat(:,idxP),'fro').^2/Nfactor; %1-Residual from predicted states, post-only
    rP0=1-norm(dataP,'fro').^2/Nfactor; %1-Residual from 0-th model (BB)
    rP1=1-norm(dataP-Y1hat(:,idxP),'fro').^2/Nfactor; %1-Residual from 1st order model
    rP2=1-norm(dataP-Y2hat(:,idxP),'fro').^2/Nfactor; %1-Residual from predicted+adjusted states, post-only
    rP3=1-norm(dataP-Y3hat(:,idxP),'fro').^2/Nfactor; %1-Residual from projected states, post-only, forcing 0 end-state
    rP4=1-norm(dataP-Y4hat(:,idxP),'fro').^2/Nfactor; %1-Residual from projected states, post-only, not forcing 0 end-state
    rA=1-norm(dataA-Yhat(:,idxA),'fro').^2/Nfactor; %1-Residual from projected states, adapt-only
    rA0=1-norm(dataA,'fro').^2/Nfactor; %1-Residual from 0-th model (BB)
    rA00=1-norm(dataA-mean(dataA,2),'fro').^2/Nfactor; %1-Residual from 0-th order model (constant)
    rA1=1-norm(dataA-Y1hat(:,idxA),'fro').^2/Nfactor; %1-Residual from 1st order model
    rB=1-norm(Yall(idxB,:)','fro').^2/Nfactor; %1-Residual from projected states, adapt-only
end
xlabel('Strides')
ylabel('Res. amplitude [% Base]')

%% Subspace projection view
M1=[C1a C1pa D1a Ca Da C3a D3a D3a2 D3a1];
l={'Ca [1]','Cp [1]','Da [1]', 'Ca [2,1]', 'Ca [2,2]', 'Da [2]', 'Ca [3,1]', 'Ca [3,2]', 'Ca [3,3]', 'Da [3]','Da [3.2]','Da [3.1]'};
%Subspace spanned by M1 in orthogonal coordinates:
[M,~]=pca(M1(:,1:3)','Centered',false);
%Subspace where most of the short-split variance resides
YY=[yM(end-20:end,:); yS; yB(1:30,:)];
%[M,~]=pca(YY(:,1:180)-YY(:,181:360));
%M=M(:,1:3);
%Subspace where most of the adapt variance resides
YY=[yB(31:end,:); yA; yP];
[M,~,aa]=pca(YY(:,1:180)-YY(:,181:360),'Centered',false);
M=M(:,1:3);

%Find projection of vectors of interest onto the subspace:
C=M'*M1;
%Find projection of data onto subspace:
XX=M'*Yall';
for i=1:size(aYall,3)
   aXX(:,:,i)=M'*aYall(:,:,i)'; 
   MM=11;
   aXX(:,:,i)=medfilt2(aXX(:,:,i),[1,MM]);
   aXX(:,[1:(MM-1)/2,end-(MM-1)/2+1:end],i)=NaN;
end
XX2=medfilt2(XX,[1,5]);
XX2(:,[1:2,end-1:end])=NaN;
%Find projection of SSM models onto subspace:
XXA2=M'*Yhat;
XXA1=M'*Y1hat;
XXA2p1=M'*Y2hat;
XXA3=M'*Y6hat;
XXA31=M'*Y6hat1;
XXA32=M'*Y6hat2;
XXP1=M'*Y4hat;
XXP3=M'*Y5hat;
XXP2=M'*Y3hat;

figure; 
cca=get(gca,'ColorOrder');
hold on
cconds=conds([5 4 1:3]);
clear pp
for i=2:length(auxI)
    pp(i-1)=plot3(XX(1,auxI(i-1)+1:auxI(i)),XX(2,auxI(i-1)+1:auxI(i)),XX(3,auxI(i-1)+1:auxI(i)),'.','DisplayName',cconds{i-1},'Color',cca(i-1,:));
    plot3(XX(1,auxI(i)),XX(2,auxI(i)),XX(3,auxI(i)),'o','DisplayName',cconds{i-1},'Color',pp(i-1).Color);
    plot3(XX2(1,auxI(i-1)+1:auxI(i)),XX2(2,auxI(i-1)+1:auxI(i)),XX2(3,auxI(i-1)+1:auxI(i)),'DisplayName',cconds{i-1},'Color',cca(i-1,:),'LineWidth',2);   
    
    %plot3(squeeze(aXX(1,auxI(i-1)+1:auxI(i),:)),squeeze(aXX(2,auxI(i-1)+1:auxI(i),:)),squeeze(aXX(3,auxI(i-1)+1:auxI(i),:)),'DisplayName',cconds{i-1},'Color',.7*ones(1,3));
end
%Plot models:
% aux=C*[X1all_hat(1,:);zeros(size(X1all_hat(1,:)));Uall'];
% plot3(aux(1,:),aux(2,:),aux(3,:))
set(gca,'ColorOrderIndex',1)
pp(end+1)=plot3(XXA1(1,:),XXA1(2,:),XXA1(3,:),'.-','DisplayName','Adapt [1]');
%plot3([XXA1(1,:); XX(1,:)],[XXA1(2,:); XX(2,:)],[XXA1(3,:); XX(3,:)],'-','DisplayName','Adapt [1]','Color','k');
pp(end+1)=plot3(XXA2(1,:),XXA2(2,:),XXA2(3,:),'.-','DisplayName','Adapt [2]');
%pp(end+1)=plot3(XXA2p1(1,:),XXA2p1(2,:),XXA2p1(3,:),'.-','DisplayName','Adapt [2+1]');
pp(end+1)=plot3(XXA3(1,:),XXA3(2,:),XXA3(3,:),'.-','DisplayName','Adapt [3]');
%plot3([XXA3(1,:); XX(1,:)],[XXA3(2,:); XX(2,:)],[XXA3(3,:); XX(3,:)],'-','DisplayName','Adapt [1]','Color','k');
%pp(end+1)=plot3(XXA31(1,:),XXA31(2,:),XXA31(3,:),'.-','DisplayName','Adapt [3.1]');
%pp(end+1)=plot3(XXA32(1,:),XXA32(2,:),XXA32(3,:),'.-','DisplayName','Adapt [3.2]');
%plot3([XXA32(1,:); XX(1,:)],[XXA32(2,:); XX(2,:)],[XXA32(3,:); XX(3,:)],'-','DisplayName','Adapt [1]','Color','k');
%pp(end+1)=plot3(XXP1(1,:),XXP1(2,:),XXP1(3,:),'.-','DisplayName','Post [1]');
%pp(end+1)=plot3(XXP2(1,:),XXP2(2,:),XXP2(3,:),'.-','DisplayName','Post [2]');
pp(end+1)=plot3(XXP3(1,:),XXP3(2,:),XXP3(3,:),'.-','DisplayName','Post [3]');
for i=1:10%length(l)
    plot3(2+[0 C(1,i)],2+[0 C(2,i)],2+[0 C(3,i)],'k')
    text(2+C(1,i),2+C(2,i),2+C(3,i),l{i})
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