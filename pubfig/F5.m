%%
%S4C
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

data{1}=[Dsim ];
x{1}=[ageC'];
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
    end
    xlabel(xlab{i})
    if i==1
    ylabel(ylab{i})
    set(gca,'YTick',[-1 0 1],'YTickLabel',{'-1','0','1'})
    else
        set(gca,'YTickLabel',{})
    end
    title(titl{i})
    set(gca,'FontSize',14,'FontWeight','bold')
        getNiceAxisLimits; 
    ax.YLim=[ax.YLim(1) 1.5];
    lg=legend(ph);
    legend({},'Location','Best','FontSize',14)
    lg.Position=lg.Position+[0 .01 0 0];
end
%Add Panel A:
f2=openfig('./fig/Fig4SC.fig');
ph=findobj(f2,'Type','axes');
pB=copyobj(ph,fh);
set(pB,'Position',[.06 .2 .28 .7],'XLim',[.5 2.5],'YLim',[-.4 1.8],'YTick',[0 1])
pB.YLabel.FontWeight='bold';
pB.FontWeight='bold';
axes(pB)
legend({'After short exposure','After long exposure'},'Location','Best')
title('')
text(.3,1.88,'A','FontSize',20,'FontWeight','bold','Clipping','off')
text(2.75,1.88,'B','FontSize',20,'FontWeight','bold','Clipping','off')
text(4.9,1.88,'C','FontSize',20,'FontWeight','bold','Clipping','off')
set(gca,'Fontsize',14)

saveFig(fh,'./','Fig5',0)
