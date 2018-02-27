%%Traces from example subject to show how data is summarized
%% Load data
subj='C0014';
load(['../data/HPF30/' subj '.mat']);

%% Align it
conds={'TM Base','Adap'};
events={'RHS','LTO','LHS','RTO'};
alignmentLengths=[16,32,16,32];
muscle='MG';
RBase=expData.getAlignedField('procEMGData',conds(1),events,alignmentLengths).getPartialDataAsATS({['R' muscle]});
LBase=expData.getAlignedField('procEMGData',conds(1),events([3,4,1,2]),alignmentLengths).getPartialDataAsATS({['L' muscle]});
RAdap=expData.getAlignedField('procEMGData',conds(2),events,alignmentLengths).getPartialDataAsATS({['R' muscle]});
LAdap=expData.getAlignedField('procEMGData',conds(2),events([3,4,1,2]),alignmentLengths).getPartialDataAsATS({['L' muscle]});

%% Create plots
for l=1:2
    switch l
        case 1
            B=RBase;
            A=RAdap;
            tit=['F' muscle];
        case 2
            B=LBase;
            A=LAdap;
            tit=['S' muscle];
    end
fh=figure('Units','Normalized','Position',[0 0 .45 .2]);
ph=[];
ph1=[];
prc=[16,84];
MM=sum(alignmentLengths);
M=cumsum([0 alignmentLengths]);
xt=sort([M,M(1:end-1)+[diff(M)/2]]);
phaseSize=8;
xt=[0:phaseSize:MM];
%xt=[0:8:MM];
fs=16; %FontSize

    ph(i)=axes();
    set(ph(i),'Position',[.07 .48 .35 .45]);
    hold on

    B.plot(fh,ph(i),condColors(1,:),[],0,[-49:0],prc,true);
    A.plot(fh,ph(i),condColors(2,:),[],0,[-49:0],prc,true);
    axis tight
    ylabel('')
    ylabel(tit)
    

    %Add rectangles quantifying activity
    for j=1:3
        ph1(j)=axes;
        set(ph1(j),'Position',[.07 .25+(j-1)*-.11 .35 .09]);  
        drawnow
        pause(1)
        da=randn(1,12);
        gamma=.5;
        ex1=condColors(j,:);
        map=niceMap(ex1,gamma);
        switch j
            case 1
            aux=nanmedian(B.Data,3)';
            tt='B';
            case 2
            aux=nanmedian(A.Data,3)';
            tt='lA';
            case 3
            aux=1*(nanmedian(A.Data,3)'-nanmedian(B.Data,3)') +.5*max(nanmedian(B.Data,3));
            figuresColorMap;
            tt='\Delta';
        end
        clear aux2
        for k=1:length(xt)-1
            aux2(k)=mean(aux(xt(k)+1:xt(k+1)));
        end
        I=image(size(map,1)*aux2/max(nanmedian(B.Data,3)));
        I.Parent.Colormap=flipud(map);
        rectangle('Position',[.5 .5 12 1],'EdgeColor','k')
        set(ph1(j),'XTickLabel','','YTickLabel','','XTick','','YTick','')
        text(-.4,1,tt,'Clipping','off','FontSize',14,'FontWeight','bold')
    end
    drawnow
    %


    axes(ph(i))
    ll=findobj(ph(i),'Type','Line');
    set(ll,'LineWidth',3)
    set(ph(i),'FontSize',fs,'YTickLabel','','XTickLabel','','XTick',xt,'YTick','')
    a=axis;
    yOff=a(3)-.15*(a(4)-a(3));
    %Add labels:
    text(.25*2*phaseSize,yOff,'DS','Clipping','off','FontSize',fs)
    text(1.35*2*phaseSize,yOff,{'STANCE'},'Clipping','off','FontSize',fs)
    text(3.25*2*phaseSize,yOff,'DS','Clipping','off','FontSize',fs)
    text(4.35*2*phaseSize,yOff,{'SWING'},'Clipping','off','FontSize',fs)
    axis(a)
    hold on
    yOff=a(3)-.05*(a(4)-a(3));
    %Add lines:
    plot([.1 .9]*2*phaseSize,[1 1]*yOff,'Color',0*ones(1,3),'LineWidth',4,'Clipping','off')
    plot([1.1 2.9]*2*phaseSize,[1 1]*yOff,'Color',0*ones(1,3),'LineWidth',4,'Clipping','off')
    plot([3.1 3.9]*2*phaseSize,[1 1]*yOff,'Color',0*ones(1,3),'LineWidth',4,'Clipping','off')
    plot([4.1 5.9]*2*phaseSize,[1 1]*yOff,'Color',0*ones(1,3),'LineWidth',4,'Clipping','off')
    legend(ll(end:-1:end-1),{'Baseline','Adaptation'})
    
    set(fh,'Position',[0 0 .45 .2])

    saveFig(fh,'./',['Fig1B_' num2str(l)],1)
end
%%

