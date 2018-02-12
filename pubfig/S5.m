
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