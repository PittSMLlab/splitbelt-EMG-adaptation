%%Traces from example subject to show how data is summarized
clearvars
try
   % Load if existing:
    load C014sampleEMG.mat 
catch
    % Load data
    subj='C0014FIXED';
    load(['../data/HPF30/' subj '.mat']);
    % Align it
    conds={'TM Base','Adap'};
    events={'RHS','LTO','LHS','RTO'};
    alignmentLengths=[16,32,16,32];
    muscle='MG';
    RBase=expData.getAlignedField('procEMGData',conds(1),events,alignmentLengths).getPartialDataAsATS({['R' muscle]});
    LBase=expData.getAlignedField('procEMGData',conds(1),events([3,4,1,2]),alignmentLengths).getPartialDataAsATS({['L' muscle]});
    RAdap=expData.getAlignedField('procEMGData',conds(2),events,alignmentLengths).getPartialDataAsATS({['R' muscle]});
    LAdap=expData.getAlignedField('procEMGData',conds(2),events([3,4,1,2]),alignmentLengths).getPartialDataAsATS({['L' muscle]});
    % Normalize:
    normM=max(median(RBase.Data(:,:,end-40:end),3));
    normm=min(median(RBase.Data(:,:,end-40:end),3));
    RBase.Data=(RBase.Data-normm)/(normM-normm);
    RAdap.Data=(RAdap.Data-normm)/(normM-normm);
    normM=max(median(LBase.Data(:,:,end-40:end),3));
    normm=min(median(LBase.Data(:,:,end-40:end),3));
    LBase.Data=(LBase.Data-normm)/(normM-normm);
    LAdap.Data=(LAdap.Data-normm)/(normM-normm);

    % Save, to avoid dealing with the whole file again
    clear expData
    save C014sampleEMG.mat
end

%% Create plots
myFiguresColorMap
for l=1:2
    switch l
        case 1
            B=RBase.getPartialStridesAsATS(110:150);
            A=RAdap.getPartialStridesAsATS(2:16);
            tit=['F' muscle];
        case 2
            B=LBase.getPartialStridesAsATS(110:150);
            A=LAdap.getPartialStridesAsATS(2:16);
            tit=['S' muscle];
    end
fh=figure('Units','Normalized','Position',[0 .5*(l-1) .45 .2]);
ph=[];
ph1=[];
prc=[16,84];
MM=sum(alignmentLengths);
M=cumsum([0 alignmentLengths]);
xt=sort([M,M(1:end-1)+[diff(M)/2]]);
phaseSize=8;
xt=[0:phaseSize:MM];
%xt=[0:8:MM];
fs=12; %FontSize

    ph=axes();
    set(ph,'Position',[.1 .48 .35 .45]);
    hold on

    B.plot(fh,ph,condColors(1,:),[],0,[-49:0],prc,true);
    A.plot(fh,ph,condColors(2,:),[],0,[-49:0],prc,true);
    axis([0 95 -.05 1.9])
    ylabel('')
    ylabel(tit)
    set(ph,'YTick',[0,1],'YTickLabel',{'0%','100%'})
    grid on

    %Add rectangles quantifying activity
    for j=1:3
        ph1(j)=axes;
        set(ph1(j),'Position',[.1 .35+(j-1)*-.11 .35 .09]);  
        drawnow
        pause(1)
        da=randn(1,12);

        switch j
            case 1
            aux=nanmedian(B.Data,3)';
            tt='Baseline';
            ca=[0 1.4];
                    gamma=.5;
                ex1=condColors(1,:);
                map1=niceMap(ex1,gamma);
            case 2
                aux=nanmedian(A.Data,3)';
                tt='early Adapt.';
                ca=[0 1.4];
                    gamma=.5;
                ex1=condColors(1,:);
                map1=niceMap(ex1,gamma);
            case 3
                aux=(nanmedian(A.Data,3)'-nanmedian(B.Data,3)');
                ca=[-.9 .9];
                tt='difference';
                map1=map;
        end
        clear aux2
        for k=1:length(xt)-1
            aux2(k)=mean(aux(xt(k)+1:xt(k+1)));
        end
        I=image(aux2);
        I.CDataMapping='scaled';
        I.Parent.Colormap=flipud(map1);
        drawnow
        rectangle('Position',[.5 .5 12 1],'EdgeColor','k')
        set(ph1(j),'XTickLabel','','YTickLabel','','XTick','','YTick','','CLim',ca)
        text(-1.3-.11*length(tt),1,tt,'Clipping','off','FontSize',10)
    end
    drawnow
    %


    axes(ph)
    ll=findobj(ph,'Type','Line');
    set(ll,'LineWidth',3)
    set(ph,'FontSize',fs,'XTickLabel','','XTick',xt)
    a=axis;
    yOff=a(3)-.97*(a(4)-a(3));
    %Add labels:
    text(.25*2*phaseSize,yOff,'DS','Clipping','off','FontSize',fs)
    text(1.4*2*phaseSize,yOff,{'STANCE'},'Clipping','off','FontSize',fs)
    text(3.25*2*phaseSize,yOff,'DS','Clipping','off','FontSize',fs)
    text(4.4*2*phaseSize,yOff,{'SWING'},'Clipping','off','FontSize',fs)
    axis(a)
    hold on
    yOff=a(3)-.84*(a(4)-a(3));
    %Add lines:
    plot([.1 .9]*2*phaseSize,[1 1]*yOff,'Color',0*ones(1,3),'LineWidth',4,'Clipping','off')
    plot([1.1 2.9]*2*phaseSize,[1 1]*yOff,'Color',0*ones(1,3),'LineWidth',4,'Clipping','off')
    plot([3.1 3.9]*2*phaseSize,[1 1]*yOff,'Color',0*ones(1,3),'LineWidth',4,'Clipping','off')
    plot([4.1 5.9]*2*phaseSize,[1 1]*yOff,'Color',0*ones(1,3),'LineWidth',4,'Clipping','off')
    lg=legend(ll(end:-1:end-1),{'Baseline','early Adapt.'});
    lg.Position(1:2)=lg.Position(1:2)+[-.03 -.1];
    set(fh,'Position',[0 .5*(l-1) .45 .2])

    saveFig2(fh,'./',['Fig1B_' num2str(l)],1)
end
%%

