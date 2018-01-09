run ../src/loadEMGParams_controls
eAT=fftshift(eA,1);
lAT=fftshift(lA,1);
lST=fftshift(lS,1);
veAT=fftshift(veA,1);
%%
Fig4SC
%% Main fig:
fh=figure('Name','Fig. 5','Units','Normalized','OuterPosition',[0 0 .55 .4]);
figuresColorMap
clear x xlab data
Dsim=auxCosine(eP-lA,eAT)-auxCosine(eP-lA,-eA);
DsimS=auxCosine(ePS-lS,eAT)-auxCosine(ePS-lS,-eA);
for i=1:size(eP,2)
    aux=[-eA(:,i) eAT(:,i)]\(eP(:,i)-lA(:,i));
    Dsim(i)=diff(aux);
    aux=[-eA(:,i) eAT(:,i)]\(ePS(:,i)-lS(:,i));
    DsimS(i)=diff(aux);
end

%Dsim2=auxCosine(eP-lA,eAT)-auxCosine(ePS-lS,-eA);
%Dsim3=Dsim-(DsimS);
%Dsim4=auxCosine(eP-lA,-eA)-auxCosine(ePS-lS,-eA);
%Dsim(1)=1;
%data{2}=[Dsim];
data{1}=[Dsim ];
%data{2}=data{2}(:,1);
x{1}=[ageC']
names{1}={'\Delta Sim','Long sim to ea^T - Short sim to -eA '};
xlab{1}='Age';
ylab{1}='Learning (\Delta \beta)';
titl{1}='Feedback (eP-lA) response vs. age';
titl{1}='';auxCosine(eA,eAT);
%data{3}=[Dsim auxNorm(eA)'./auxNorm(squeeze(aBB))'];
data{2}=[Dsim ];
names{2}={'','||eA||/||B||'};
%data{2}=data{2}(:,1);
EMGsym=auxCosine(eA,eAT);
%EMGsym=auxCosine(lS,lST);
x{2}=EMGsym;

xlab{2}='eA EMG Symmetry';% [cos(eA,eA^T)]';
ylab{2}='';
titl{2}='Feedback (eP-lA) response vs. transposability';
titl{2}='';

% data{1}=[auxCosine(eP-lA,eAT) auxCosine(ePS-lS,eAT)];
% data{1}=data{1}(:,1);
% mData{1}=[auxCosine(mean(eP-lA,2),mean(eAT,2)) auxCosine(mean(ePS-lS,2),mean(eAT,2))];
% names{1}={'eP-lA','ePS-lS'};
% x{1}=[auxCosine(eP-lA,-eA) auxCosine(ePS-lS,-eA)];
% xlab{1}='Sim. to -eA';
% titl{1}='Two competing feedback responses';
% titl{1}='';
% ylab{1}='Sim. to eA^T';
for i=1:2 %
    ax=axes();
    set(ax,'ColorOrder',condColors([1,3],:))
    ax.Position=[.1+.3*i .2 .28 .7];
    cc=get(ax,'ColorOrder');
    cc=cc([2,1],:);
    hold on
    clear ph
    for j=1:size(data{i},2)%:-1:1
            if size(x{i},2)>1
               XX=x{i}(:,j); 
            else
            XX=x{i};
            end
        YY=data{i}(:,j);
       [rr,pp]=corr(XX,YY,'type','pearson');
       [rs,ps]=corr(XX,YY,'type','spearman');
       m=polyfit(XX,YY,1);
       m=polyfit1PCA(XX,YY,1);
       ph(j)=plot(XX,YY,'o','DisplayName',['r=' num2str(rr,2) ', p=' num2str(pp,2)],'LineWidth',3,'Color',cc(j,:));
       plot(XX,m(1)*XX+m(2),'Color',ph(j).Color)
       txt={['r=' num2str(rr,3) ', p=' num2str(pp,3)], ['r_{sp}=' num2str(rs,3) ', p_{sp}=' num2str(ps,3)]};
       %text(max(XX),m(1)*max(XX)+m(2),txt,'Color',ph(j).Color,'FontSize',6)
       %text(XX+.03*range(XX),YY,num2str([1:16]'),'FontSize',10)
    end
    xlabel(xlab{i})
    if i==1
    ylabel(ylab{i})
    set(gca,'YTick',[-1 0 1],'YTickLabel',{'-1','0','1'})
    else
        set(gca,'YTickLabel',{})
    end
    title(titl{i})
    set(gca,'FontSize',16,'FontWeight','bold')
        getNiceAxisLimits; 
    ax.YLim=[ax.YLim(1) 1.5];
    lg=legend(ph);
    legend({},'Location','Best','FontSize',16)
    lg.Position=lg.Position+[0 .05 0 0];
end
%Add Panel A:
f2=openfig('./fig/Fig4SC.fig');
ph=findobj(f2,'Type','axes');
pB=copyobj(ph,fh);
set(pB,'Position',[.05 .2 .28 .7],'XLim',[.5 2.5],'YLim',[-.4 1.8],'YTick',[0 1])
pB.YLabel.FontWeight='bold';
pB.FontWeight='bold';
axes(pB)
legend({'After short exposure','After long exposure'},'Location','Best')
title('')
text(.3,1.85,'A','FontSize',20,'FontWeight','bold','Clipping','off')
text(2.83,1.85,'B','FontSize',20,'FontWeight','bold','Clipping','off')
text(5.03,1.85,'C','FontSize',20,'FontWeight','bold','Clipping','off')
saveFig(fh,'./','Fig5',0)

%% Supp fig:
fh=figure('Name','Suplemental Fig. 5','Units','Normalized','OuterPosition',[0 0 .6 1]);
maxK=4;
for k=1:maxK
    clear data names titl
    switch k
        case 1
            x=[ageC'];
            xlab='Age';
            data{1}=[auxNorm(eP)' auxNorm(lA-eA)' auxNorm(lA)'];
            names{1}={'||eP||','||lA-eA||','||lA||'};
            data{2}=[1-auxCosine(eA,lA), auxCosine(eA,eAT)];
            names{2}={'cos(lA,eA)','eA EMG Sym'};
            ylab{1}='Norm (a.u.)';
            ylab{2}='Similarity (cos)';
        case 2
            x=[velsC'];
            xlab='Speed (m/s)';
            data{1}=[auxNorm(eP)' auxNorm(lA-eA)'];
            names{1}={'||eP||','||lA-eA||'};
            data{2}=[1-auxCosine(eA,lA), auxCosine(eA,eAT)];
            names{2}={'cos(lA,eA)','eA EMG Sym'};
        case 3
            x=EMGsym;
            xlab='eA EMG Symm.';
            data{1}=[auxNorm(eP)' auxNorm(lA-eA)'];
            names{1}={'||eP||','||lA-eA||'};
            data{2}=[1-auxCosine(eA,lA)];
            names{2}={'cos(eA,lA)'};
        case 4
            x=auxCosine(lS,lST);
            xlab='eS EMG Symm.';
            data{1}=[auxNorm(eP)' auxNorm(lA-eA)'];
            names{1}={'||eP||','||lA-eA||'};
            data{2}=[Dsim DsimS];;
            names{2}={'\Delta Sim Long','\Delta Sim Short'};
    end
for i=1:2%:4 % 4 panels
    clear ph
    %subplot(2,maxK,maxK*(i-1)+k)
    ax=axes();
    ax.Position=[.09 .09 .8/maxK .41] + [.9/maxK 0 0 0]*(k-1) + [0 .46 0 0]*(2-i);
    for j=1:size(data{i},2)
        set(gca,'ColorOrderIndex',j)
        XX=x;
        YY=data{i}(:,j);
               [rr,pp]=corr(XX,YY,'type','pearson');
       [rs,ps]=corr(XX,YY,'type','spearman');
       ph(j)=plot(XX,YY,'o','DisplayName',[names{i}{j} ', p=' num2str(pp,2)],'LineWidth',3);
       hold on

       m=polyfit(XX,YY,1);
       plot(XX,m(1)*XX+m(2),'Color',ph(j).Color)
       txt={['r=' num2str(rr,3) ', p=' num2str(pp,3)], ['r_{sp}=' num2str(rs,3) ', p_{sp}=' num2str(ps,3)]};
       %text(max(XX),m(1)*max(XX)+m(2),txt,'Color',ph(j).Color,'FontSize',6)
    end
    set(gca,'FontSize',20)
    lg=legend(ph);
    legend({},'Location','Best','FontSize',14)
    %axis tight
    if i<2
        set(gca,'XTickLabel',{})
    else
                    xlabel(xlab)
    end
    if k>1
        set(gca,'YTickLabel',{})
    else
        %title(titl{i})
        ylabel(ylab{i})
        if i==1
            xOff=40;
            yOff=11.2;
            text(xOff,yOff,'A','FontSize',24,'FontWeight','bold','Clipping','off')
            text(xOff,yOff-8.7,'B','FontSize',24,'FontWeight','bold','Clipping','off')
        end
    end
        getNiceAxisLimits; 
end
end
saveFig(fh,'./','Fig5S',0)

%% addl fig(s): (old)
fh=figure('Name','Suplemental Fig. 5','Units','Normalized','OuterPosition',[0 0 .6 1]);
maxK=3;
for k=1:maxK
    switch k
        case 1
            x=[ageC'];
            xlab='Age';
        case 2
            x=[velsC'];
            xlab='Speed (m/s)';
        case 4
            x=[1-auxCosine(eA,lA)];
            xlab='Learning';
        case 3
            x=EMGsym;
            xlab='Cocontraction';
    end
clear data names titl
data{1}=[auxNorm(eP)' auxNorm(ePS)' auxNorm(eA)' auxNorm(eP-lA)' auxNorm(eA-lA)' auxNorm(lA)'];
names{1}={'||eP||','||ePS||','||eA||','||eP-lA||','||lA-eA||','||lA||'};
titl{1}='Vector sizes';
data{2}=[1-auxCosine(eA,lA), auxCosine(eP-lA,eAT), auxCosine(eP,eAT),auxCosine(eA,lA-eA),auxCosine(eA,eAT),auxCosine(eP-lA,-eA)];
names{2}={'1-<eA,lA>', '<eP-lA,eAT>','<eP,eA^T>','<eA,lA-eA>','<eA,eA^T>','<eP-lA,-eA>','<eP-lA,eA>'};
titl{2}='Geometry';
for i=1:2%:4 % 4 panels
    clear ph
    subplot(2,maxK,maxK*(i-1)+k)
    for j=1:size(data{i},2)
        XX=x;
        YY=data{i}(:,j);
               [rr,pp]=corr(XX,YY,'type','pearson');
       [rs,ps]=corr(XX,YY,'type','spearman');
       ph(j)=plot(XX,YY,'x','DisplayName',[names{i}{j} ', p=' num2str(pp,2)],'LineWidth',3);
       hold on

       m=polyfit(XX,YY,1);
       plot(XX,m(1)*XX+m(2),'Color',ph(j).Color)
       txt={['r=' num2str(rr,3) ', p=' num2str(pp,3)], ['r_{sp}=' num2str(rs,3) ', p_{sp}=' num2str(ps,3)]};
       %text(max(XX),m(1)*max(XX)+m(2),txt,'Color',ph(j).Color,'FontSize',6)
    end
    set(gca,'FontSize',20)
    legend(ph)
    legend({},'Location','Best','FontSize',10)
    %axis tight
    if i<2
        set(gca,'XTickLabel',{})
    else
                    xlabel(xlab)
    end
    if k>1
        set(gca,'YTickLabel',{})
    else
        title(titl{i})
    end
        getNiceAxisLimits; 
end
end
saveFig(fh,'./','Fig5S2',0)