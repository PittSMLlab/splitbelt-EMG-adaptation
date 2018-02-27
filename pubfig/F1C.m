%% F1C
fh=figure('Units','Normalized');
figuresColorMap;
fh=figure('Units','Normalized','Position',[0 0 .55 .3]);
    
auxF=[0;.35;-.3];
auxS=[-.35;.35;.2];
for k=1:4
    switch k
        case 1 %eA
            aux1=auxF;
            aux2=auxS;
            tt='eA';
        case 2
            tt='H1';
            aux1=zeros(size(auxF));
            aux2=zeros(size(auxS));
        case 3
            tt='H2';
            aux1=-auxF;
            aux2=-auxS;
        case 4
            tt='H3';
            aux1=auxS;
            aux2=auxF;
    end
ax=axes;
ax.Position=[.05+(k-1)*.08 .05 .2 .35];
I=imshow(size(map,1)*(aux1+.5),flipud(map),'Border','tight');
rectangle('Position',[.5 .5 1 3],'EdgeColor','k')
%%Add arrows
hold on
quiver(ones(size(aux1)),[1:numel(aux1)]'+.4*sign(aux1),zeros(size(aux1)),-.7*sign(aux1),0,'Color','k','LineWidth',2)
ax=axes;
ax.Position=[.05+(k-1)*.08 .45 .2 .35];
I=imshow(size(map,1)*(aux2+.5),flipud(map),'Border','tight');
rectangle('Position',[.5 .5 1 3],'EdgeColor','k')
%%Add arrows
hold on
quiver(ones(size(aux1)),[1:numel(aux1)]'+.4*sign(aux2),zeros(size(aux1)),-.7*sign(aux2),0,'Color','k','LineWidth',2)

set(gca,'XTickLabel','','YTickLabel','','XTick','','YTick','')
text(.6,0,tt,'Clipping','off','FontSize',14,'FontWeight','bold')

end

text(-1.8,-.65,'eP-lA','Clipping','off','FontSize',14,'FontWeight','bold')
plot([-3.5 1.5],-.3*[1 1],'k','LineWidth',2,'Clipping','off')
%plot(-4*[1 1],[.5 7],'k','LineWidth',1,'Clipping','off')

%Add lines on fast/slow:
ccc=get(gca,'ColorOrder');
plot(-7*[1 1],[.5 3.5],'LineWidth',4,'Color',ccc(1,:),'Clipping','off')
text(-7.5,3,'FAST','Color',ccc(1,:),'Rotation',90,'FontSize',20,'FontWeight','bold')
plot(-7*[1 1],3.45+[.5 3.5],'LineWidth',4,'Color',ccc(2,:),'Clipping','off')
text(-7.5,6.5,'SLOW','Color',ccc(2,:),'Rotation',90,'FontSize',20,'FontWeight','bold')
%%
    saveFig(fh,'./',['Fig1C'],1)