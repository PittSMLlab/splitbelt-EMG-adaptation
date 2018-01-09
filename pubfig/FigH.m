fh=figure('Units','Normalized','OuterPosition',[0 .5 .53 .4],'Color',ones(1,3));
figuresColorMap

%Define basics:
    B=[0;0];
    eA=[.5;.7];
    eAT=eA.*[1;-1];
    lA=eA+[-eA(1);-.2];
    eP2=lA-eA;
    eP3=lA+eAT;
    eP1=lA+.05*(eAT-eA);
    for i=1:3
        aa=strcat(num2str(condColors(i,:)',2),',');
        aa=cell2mat(strtrim(mat2cell(aa,ones(size(aa,1),1),size(aa,2)))');
        aux{i}=['\color[rgb]{' aa(1:end-1) '} '];
    end
    eqs={[aux{3} 'eP_2 \color[rgb]{0,0,0} = ' aux{2} 'lA \color[rgb]{0,0,0} - ' aux{2} 'eA'];
        [aux{3} 'eP_3 \color[rgb]{0,0,0} = ' aux{2} 'lA \color[rgb]{0,0,0} + ' aux{2} 'eA*'];
        [aux{3} 'eP_1 \color[rgb]{0,0,0} \approx ' aux{2} 'lA']};
    eqs=eqs([2,3,1]);
    
for i=1:3
    ph=axes();
    ph.Position=[.05+(i-1)*.33 .1 .28 .7];
    eval(['eP=eP' num2str(i) ';']);
        
    %set(ph,'Position',[.07 .4 .4 .28],'FontSize',16)
    axis([-.6+(i<3)*.3 .7 -.5 1])
    ph.XTick=[];
    ph.YTick=[];
    ph.GridAlpha=.7;
    text(-.7+(i<3)*.3, 1.2,char('A'+(i-1)),'FontSize',24,'FontWeight','bold','Clipping','off')

    dd=[B eA lA];
    hold on
    pp=plot(dd(1,:),dd(2,:),'o','MarkerSize',14,'Color',condColors(2,:));
    set(pp,'MarkerFaceColor',pp.Color);
    text(B(1)-.05,B(2)-.15,'B','FontSize',20,'Color',condColors(1,:),'FontWeight','bold')
    text(eA(1)-.1,eA(2)+.15,{'eA'},'FontSize',20,'Color',pp.Color,'FontWeight','bold')
    text(lA(1)-.2,lA(2)+.1,{'lA'},'FontSize',20,'Color',pp.Color,'FontWeight','bold')
    dd1=[eP B];
    plot(dd(1,1:2),dd(2,1:2),'--','LineWidth',4,'Color','k');
    %plot(dd(1,2:3),dd(2,2:3),'-','LineWidth',4,'Color',pp.Color);
    quiver(dd(2,3),dd(2,2),-(dd(2,3)-dd(1,3)),-(dd(2,2)-dd(1,2)),0,'LineWidth',4,'Color',pp.Color,'MaxHeadSize',.8);
    plot([lA(1) eP(1)],[lA(2) eP(2)],'--','LineWidth',4,'Color','k');
    pp1=plot(dd1(1,1),dd1(2,1),'o','MarkerSize',14,'Color',condColors(3,:));
    %plot(dd1(1,1:2),dd1(2,1:2),'-','LineWidth',4,'Color',pp1.Color);
    quiver(dd1(1,1),dd1(2,1),(dd1(1,2)-dd1(1,1)),(dd1(2,2)-dd1(2,1)),0,'LineWidth',4,'Color',pp1.Color,'MaxHeadSize',.8);
    set(pp1,'MarkerFaceColor',pp1.Color);
    text(eP(1)+(i==1)*-.2,eP(2)-.15,['eP'],'FontSize',20,'Color',pp1.Color,'FontWeight','bold','Interpreter','tex')


    pp=plot(dd(1,2:end),dd(2,2:end),'o','MarkerSize',14,'Color',condColors(2,:));
    set(pp,'MarkerFaceColor',pp.Color);
    pp=plot(dd(1,1),dd(2,1),'o','MarkerSize',14,'Color',condColors(1,:));
    set(pp,'MarkerFaceColor',pp.Color);
    xlabel('PC 2 (a.u.)')
    ylabel('PC 1 (a.u.)')
    ax=gca;
    ax.YTickLabel={};
    ax.XTickLabel={};
    ax.YLabel.FontWeight='bold';
    ax.XLabel.FontWeight='bold';
    ax.XLabel.FontSize=20;
    ax.YLabel.FontSize=20;
    
    text(-.4+(i<3)*.2+(i==1)*.15, 1.05, eqs{i},'FontSize',16,'FontWeight','bold','interpreter','tex','Clipping','off')
end

saveFig(fh,'./','FigH',0)