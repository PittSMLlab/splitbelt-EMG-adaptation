%% Load params
%auxI=[];
run ./../../src/loadEMGParams_controls.m

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

%% Get all the eA, lA, eP vectors
idx=[4:15];
eA=squeeze(mean(ayA(idx,:,:))-aBB);
eP=squeeze(nanmean(ayP(idx,:,:))-aBB);
lA=squeeze(mean(ayA(end-5-idx,:,:))-aBB);
eAT=[eA(181:360,:);eA(1:180,:)];
lAT=[lA(181:360,:);lA(1:180,:)];
symEA=sqrt(sum((eA(1:180,:)-eA(181:360,:)).^2))./(sqrt(sum((eA(1:180,:).^2)))+sqrt(sum((eA(181:360,:)).^2)));
symLA=sqrt(sum((lA(1:180,:)-lA(181:360,:)).^2))./(sqrt(sum((lA(1:180,:).^2)))+sqrt(sum((lA(181:360,:)).^2)));
lS=squeeze(nanmean(ayS(2:end-1,:,:))-aBB);
ePS=squeeze(mean(ayB(idx,:,:))-aBB);
lST=[lS(181:360,:);lS(1:180,:)];

figure
x=ageC;
for i=1:8
subplot(2,4,i)
switch i
    case 1
v=sqrt(sum(eA.^2));
tit='Early A';
    case 2
       v=sqrt(sum(eP.^2)); 
       tit='Early P';
    case 3
       v=sqrt(sum((lA-eA).^2)); 
       tit='Late A minus Early A';
    case 4
        v=sqrt(sum((lA).^2)); 
       tit='Late A';
    case 5
        v=symEA;
        tit='asymmetry eA';
    case 6
        v=symLA;
        tit='asymmetry lA';     
    case 7
        v=sqrt(sum((lA+eAT).^2)); 
        tit='Late A plus eA^T';
    case 8
        v=sqrt(sum(eP.^2)) ./sqrt(sum((lA+eAT).^2)); 
        tit='eP/(lA+eA^T)';
end
plot(x,v,'x')
title(tit)
text(x,v,num2str([1:16]'),'FontSize',8)
[r,p]=corr(x',v','type','pearson');
[rs,ps]=corr(x',v','type','spearman');
text(min(x),min(v),['r=' num2str(r,3) ', p=' num2str(p,3) '; r_{sp}=' num2str(rs,3) ', p_{sp}=' num2str(ps,3)],'FontSize',8);
end

%% PLot
for k=1
    switch k
        case 1
            x=ageC;
        case 2
            x=velsC;
    end
for j=7:10%[1:6]
    switch j
%         case 1
%             %1) Compare eP vs lA+eA^T
%             figure('Name','eP vs eA^T+lA')
%             v1=eP;
%             v2=lA+eAT;
%             modv2=(v2.*(.7-.7*(ageC-45)/45));
%         case 3
%             %3) Control: eP vs lA-eA
%             figure('Name','eP vs lA- eA')
%             v1=eP;
%             v2=lA-eA;
%             modv2=v2;
%         case 4
%             figure('Name','eP vs eA^T')
%             v1=eP;
%             v2=eAT;
%             modv2=v2;
%         case 2
%             %1) Compare ePS vs lS+eA^T
%             figure('Name','ePS vs eS^T+lS')
%             v1=ePS;
%             v2=lS+lST;
%             modv2=v2;
%         case 5
%             figure('Name','eP vs lA')
%             v1=eP;
%             v2=lA;
%             modv2=v2;
        case 7
            figure('Name','eP-lA vs eA^T')
            v1=eP-lA;
            v2=eAT;
            modv2=(v2.*(1-(ageC-40)/60));
        case 8
            figure('Name','eP-lA vs -eA')
            v1=eP-lA;
            v2=-eA;
            modv2=v2;
        case 9
            figure('Name','ePS-lS vs eA^T')
            v1=ePS-lS;
            v2=eAT;
            modv2=v2;
        case 10
            figure('Name','ePS-lS vs -eA')
            v1=ePS-lS;
            v2=-eA;
            modv2=v2;
    end
    normEP=sqrt(sum(v1.^2));
    normExpEP=sqrt(sum(v2.^2));
    cosEP=diag((v1'*v2)./(normEP' .* normExpEP))';
    projEP=diag((v1'*v2)./( normExpEP))';
    distEP=sqrt(sum((v1-v2).^2)) ./ normEP;
    distEPcorrected=sqrt(sum((v1-modv2).^2)) ./ normEP;
    m1=mean(v1,2);
    m2=mean(v2,2);
    modm=mean(modv2,2);
    normM=sqrt(sum(m1.^2));
    normExpM=sqrt(sum(m2.^2));
    cosM=diag((m1'*m2)./(normM' .* normExpM))';
    projM=diag((m1'*m2)./( normExpM))';
    distM=sqrt(sum((m1-m2).^2)) ./ normM;
    distMcorr=sqrt(sum((m1-modm).^2)) ./ normM;
    for i=1:4
        switch i
            case 1
                v=cosEP;
                m=cosM;
                v2=[];
                mm=[];
                tt='Cosine to expected';
            case 2
                v=normEP ./ normExpEP;
                m=normM ./ normExpM;
                v2=[];
                mm=[];
                tt='Actual norm over expected norm';
            case 3
                v=distEP;
                m=distM;
                tt='Distance to expected over actual norm';
                v2=distEPcorrected;
                mm=distMcorr;
            case 4
                v=projEP ./ normExpEP;
                m=projM ./ normExpM;
                v2=[];
                mm=[];
                tt='Projection onto expected over expected norm';
        end
        subplot(2,2,i)
        p1=plot(x,v,'x');
        hold on
        try
            p2=plot(x,v2,'x');
            p2=plot(mean(x),mm,'o','MarkerSize',8,'Color',p2.Color,'MarkerFaceColor',p2.Color);
        catch
        
        end
        p1=plot(mean(x),m,'o','MarkerSize',8,'Color',p1.Color,'MarkerFaceColor',p1.Color);
        text(x,v,num2str([1:16]'),'FontSize',8)
        title(tt)
        [r,p]=corr(x',v','type','pearson');
        [rs,ps]=corr(x',v','type','spearman');
        text(min(x),min(v),['r=' num2str(r,3) ', p=' num2str(p,3) '; r_{sp}=' num2str(rs,3) ', p_{sp}=' num2str(ps,3)],'FontSize',8);
    end
end
end