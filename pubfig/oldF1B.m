ph=subplot(5,2,5);

set(ph,'Position',[.07 .4 .4 .28],'FontSize',16)
axis([-.7 1.2 -.5 1])
grid on
ph.XTick=0;
ph.YTick=0;
ph.GridAlpha=.7;
text(-.9, 1.2,'B','FontSize',24,'FontWeight','bold','Clipping','off')
B=[0;0];
eA=[.7;.6];
eAT=eA.*[1;-.7];
lA=[.15;.5];
eP1=lA-eA;
eP2=lA+eAT;
eP3=lA-.1*(eAT-eA);
dd=[B eA lA];
hold on
pp=plot(dd(1,:),dd(2,:),'o','MarkerSize',14,'Color',condColors(2,:));
set(pp,'MarkerFaceColor',pp.Color);
text(B(1)+.05,B(2)-.1,'Baseline','FontSize',20,'Color',condColors(1,:),'FontWeight','bold')
text(eA(1)+.05,eA(2)+.1,{'early';'Adapt.'},'FontSize',20,'Color',pp.Color,'FontWeight','bold')
text(lA(1)-.5,lA(2)+.15,{'late';'Adapt.'},'FontSize',20,'Color',pp.Color,'FontWeight','bold')
dd1=[eP1 eP2 eP3];
plot(dd(1,1:2),dd(2,1:2),'--','LineWidth',4,'Color','k');
plot(dd(1,2:3),dd(2,2:3),'-','LineWidth',4,'Color',pp.Color);
plot([lA(1) eP1(1)],[lA(2) eP1(2)],'--','LineWidth',4,'Color','k');
plot([lA(1) eP2(1)],[lA(2) eP2(2)],'--','LineWidth',4,'Color','k');
plot([lA(1) eP3(1)],[lA(2) eP3(2)],'--','LineWidth',4,'Color','k');
pp1=plot(dd1(1,:),dd1(2,:),'o','MarkerSize',14,'Color',condColors(3,:));
set(pp1,'MarkerFaceColor',pp1.Color);
text(eP1(1)+.05,eP1(2)-.1,'eP_{2}','FontSize',20,'Color',pp1.Color,'FontWeight','bold','Interpreter','tex')
text(eP2(1)+.05,eP2(2)-.1,'eP_{3}','FontSize',20,'Color',pp1.Color,'FontWeight','bold','Interpreter','tex')
text(eP3(1)+.05,eP3(2)+.1,'eP_{1}','FontSize',20,'Color',pp1.Color,'FontWeight','bold','Interpreter','tex')


pp=plot(dd(1,2:end),dd(2,2:end),'o','MarkerSize',14,'Color',condColors(2,:));
set(pp,'MarkerFaceColor',pp.Color);
pp=plot(dd(1,1),dd(2,1),'o','MarkerSize',14,'Color',condColors(1,:));
set(pp,'MarkerFaceColor',pp.Color);
xlabel('PC 1')
ylabel('PC 2')
ax=gca;
ax.YTickLabel={};
ax.XTickLabel={};
ax.YLabel.FontWeight='bold';
ax.XLabel.FontWeight='bold';
title('ADAPTATION IN MUSCLE SPACE')