%%
%S4C
%% Main fig:
fh=figure('Name','Fig. 5','Units','Normalized','OuterPosition',[0 0 .55 .4]);
figuresColorMap
clear x xlab data
Dsim=auxCosine(eP-lA,eAT)-auxCosine(eP-lA,-eA);
DsimS=auxCosine(ePS-lS,eAT)-auxCosine(ePS-lS,-eA);
Dinit=nan(size(Dsim));
Dff=nan(size(Dsim));
for i=1:size(eP,2)
    aux=[-eA(:,i) eAT(:,i) lA(:,i)]\(eP(:,i));
    %Dsim(i)=diff(aux); %Difference of projection into eA* and -eA
    Dsim(i)=aux(2);
    Dinit(i)=aux(1);
    Dff(i)=aux(3);

    aux=[-eA(:,i) eAT(:,i)]\(ePS(:,i)-lS(:,i));
    DsimS(i)=diff(aux);
end

data{1}=[Dsim Dinit Dff];
x{1}=[ageC'];
names{1}={'\beta_M','\beta_S','\beta_{FF}'};
xlab{1}='Age';
ylab{1}='Mirroring extent';
titl{1}='Feedback (eP-lA) response vs. age';
titl{1}='';auxCosine(eA,eAT);
%data{3}=[Dsim auxNorm(eA)'./auxNorm(squeeze(aBB))'];
data{2}=[auxNorm(eP)' auxNorm(eA)'];
%data{2}=SLA_eP;
names{2}={'||eP||','||eA||'};
%names{2}={'SLA'};
%data{2}=data{2}(:,1);
EMGsym=auxCosine(eA,eAT);
%EMGsym=auxCosine(lS,lST);
x{2}=ageC';
%x{2}=velsC';

xlab{2}='Age';% [cos(eA,eA^T)]';
ylab{2}='EMG Aftereffect size';
titl{2}='';
for i=1:2 %
    ax=axes();
    set(ax,'ColorOrder',condColors([2-(i-2),3,1],:))
    ax.Position=[.1+.3*i .2 .28 .7];
    cc=get(ax,'ColorOrder');
    cc=cc([end:-1:1],:);
    hold on
    clear ph
    for j=1:size(data{i},2)%:-1:1
            if size(x{i},2)>1
               XX=x{i}(:,j); 
            else
            XX=x{i};
            end
        YY=data{i}(:,j);
       %[rr,pp]=corr(XX,YY,'type','pearson');
       [rs,ps]=corr(XX,YY,'type','spearman');
       m=polyfit(XX,YY,1);
       
       %m=polyfit1PCA(XX,YY,1);
ca=cc(j,:);
ls='-';
       if j==2 && i==1
        ca='None';
ls='--';
end
       ph(j)=plot(XX,YY,'o','DisplayName',[names{i}{j} ', r=' num2str(rs,2) ', p=' num2str(ps,2)],'LineWidth',3,'Color',cc(j,:),'MarkerSize',6,'MarkerFaceColor',ca);
       plot(sort(XX),m(1)*sort(XX)+m(2),ls,'Color',ph(j).Color)
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
if i==1
    ax.YLim=[-.2 1.5];
end
    lg=legend(ph);
    legend({},'Location','NorthOutside','FontSize',12)
    lg.Position=lg.Position+[0 .01 0 0];
end
%% Add Panel A:
f2=openfig('./fig/Fig5A.fig');
ph=findobj(f2,'Type','axes');
pB=copyobj(ph,fh);
set(pB,'Position',[.06 .2 .28 .7],'XLim',[.5 2.5],'YLim',[-.4 1.8],'YTick',[0 1])
pB.YLabel.FontWeight='bold';
pB.FontWeight='bold';
axes(pB)
title('')
text(.3,1.6,'A','FontSize',20,'FontWeight','bold','Clipping','off')
text(2.75,1.6,'B','FontSize',20,'FontWeight','bold','Clipping','off')
text(4.9,1.6,'C','FontSize',20,'FontWeight','bold','Clipping','off')
set(gca,'Fontsize',14,'YLim',[-.2 1.5])
legend({'After short exposure','After long exposure'},'Location','NorthOutside','FontSize',12)
%%
%saveFig(fh,'./','Fig5',0)
