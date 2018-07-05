%% Open relevant intfigs
f(1)=openfig('/Datos/Documentos/code/splitbelt-EMG-adaptation/intfig/all/dyn/fig/Adapt[2.1_1]medianALT.fig');
f(2)=openfig('/Datos/Documentos/code/splitbelt-EMG-adaptation/intfig/all/dyn/fig/Adapt[2.1_1]ALT.fig');
p=findobj(f(2),'Type','Axes');
set(p,{'Position'},cellfun(@(x) x+[.35 0 0 0],get(p,'Position'),'UniformOutput',false));
load ../data/dynamicsData.mat
addpath(genpath('./auxFun/'))
%% Copy relevant panels:
figuresColorMap
figSize
fh=figure('Units','Pixels','Position',figPos,'Colormap',flipud(map));
for j=1:2
  
p1=findobj(f(j),'Type','Axes');
np1=copyobj(p1(end-5:end),fh); %Copying states and associated checkerboards
np1(2).Title.String='D';
np1(4).Title.String='C_2';
np1(6).Title.String='C_1';
np1(1).Title.String='v';
np1(3).Title.String='x_2';
np1(5).Title.String='x_1';
set(np1(2:2:6),{'Position'},cellfun(@(x) x+[0 -.01 0 0],get(np1(2:2:6),'Position'),'UniformOutput',false));
%Change text:
tt=findobj(np1(5),'Type','Text');
tt.Position=tt.Position-[100 0 0];
tt=findobj(np1(1),'Type','Text');
tt.String=tt.String(3:end);
%Add panel letters
if j==1
    axes(np1(1))
    text(-750,1,'A','FontSize',20,'FontWeight','bold','Clipping','off');
    text(-750,-4,'B','FontSize',20,'FontWeight','bold','Clipping','off');
    text(-750,-13,'C','FontSize',20,'FontWeight','bold','Clipping','off');
    text(5100,1,'D','FontSize',20,'FontWeight','bold','Clipping','off');
    text(5100,-4,'E','FontSize',20,'FontWeight','bold','Clipping','off');
    text(5100,-13,'F','FontSize',20,'FontWeight','bold','Clipping','off');
end

off=[0;6;15;21];%Early post,lA,eA,B
titleList={'Early Post','Late Adap','Early Adap'};
for i=1:length(off)
    aux=copyobj(p1([11,12]+off(i)),fh); 
    if i~=4
        for k=1:2
            aux(k).Position(1)=np1(2*(mod(i,3)+1)).Position(1);
            if k==2 %Changing title
                aux(k).Title.String=titleList{i};
            end
        end
    end
    if i==3
        aux3=aux;
    end
end

aux2=copyobj(p1(34),fh); 
aux2.Position(1)=aux(2).Position(1)+aux(2).Position(3)+.006;
aux2.Position(3)=aux2.Position(3)-aux(2).Position(3)-.006;
aux2.Position(2)=1.5*aux(1).Position(2)-.5*aux(2).Position(2);
aux2.Position(4)=.5*aux2.Position(4);
aux2.Box='off';
%aa=axis;
%axis([1 1350 aa(3:4)])
ll=findobj(aux2,'Type','Line');
if j==1
lg=legend(ll,{'Proj. over C_2','Proj. over C_1','x_2','x_1'});
lg.Position(1)=lg.Position(1)+.09;
lg.Position(2)=lg.Position(2)-.03;
lg.FontWeight='bold';
end
grid on

% Add SLA evolution below
states=[ll(3).YData;ll(4).YData; [zeros(1,50), ones(1,900), zeros(1,600)]];
SLA=cat(1,nanmedian(dataContribs{1},3),nanmedian(dataContribs{2},3),nanmedian(dataContribs{3},3))-nanmean(nanmedian(dataContribs{1},3)); %Catting and removing base
SLA(isnan(SLA))=0;
ff=states'\SLA;
ax=axes();
ax.Position=aux2.Position+[0 -.1 0 0];
hold on
plot(SLA,'k.','DisplayName','SLA data')
sim=states'*ff;
sim(50)=NaN;
sim(950)=NaN;
SLA(50)=NaN;
SLA(950)=NaN;
plot(sim,'Color',[.8,0,.1],'LineWidth',2,'DisplayName','SLA fitted')
ax.XTick=aux2.XTick;
ax.YTick=[-.15:.15:.15];
grid on
ax.YTickLabel={};
ax.XLim=aux2.XLim;
if j==1
lg=legend('Location','SouthEast');
lg.FontWeight='bold';
lg.Position(1)=lg.Position(1)+.09;
end

%aux=copyobj(p1([11,12]+6),fh); %late adapt
%aux=copyobj(p1([11,12]+15),fh); %early adapt

%aux=copyobj(p1([11,12]+21),fh); %base
%aux.Position([2,4])=np1(1).Position([2,4]);
%aux.Title.String='Early Post Data (2:4)';

%np1(3).Title.String='End of Adaptation fit';
%np1(2).Title.String='Early Post prediction';

%set(np1,'Position',get(np1,'Position')+[]);

axes(np1(end-2))
pp=np1(end-2).Position;
cc=colorbar;
np1(end-2).Position=pp;

if j==2
    np1(2).YTickLabels=[strcat('s',np1(2).YTickLabels);strcat('f',np1(2).YTickLabels)];
    np1(2).YTick=1:30;
    np1(2).YAxis.FontSize=6;
end

%Delete baseline checkerboards
p1=findobj(gcf,'Type','Axes');
delete(p1([4,5]))

%Add yticks to other checkerboards
for kk=6:7
p1(kk).YTick=np1(2).YTick;
p1(kk).YAxis.FontSize=np1(2).YAxis.FontSize;
p1(kk).YTickLabels=np1(2).YTickLabels;
end

%Add ylabels, change side
lab={'DATA','MODEL SIM.'};
for kk=10:11
   p1(kk).YAxis.Label.String=lab{12-kk}; 
   p1(kk).YAxis.Label.Position(1)=15;
   p1(kk).YAxis.Label.FontWeight='bold';
   p1(kk).YAxis.Label.FontSize=14;
end

% Add muscle legends to panels
ax=[np1(2); aux3];
ccc=get(gca,'ColorOrder');
for i=1:length(ax)
    axes(ax(i))
    grid off
    hold on
    
    % Add flexor/extensor descriptions
    yOff=[0,15];
    maxI=2;
    yCoord=ax(i).YTick;
    if length(yCoord)<17
        maxI=1;
    else
        xOff=-28;
        %Slow/fast legs
        pp1=plot(xOff/12-1.4*[1 1]/12,[16 30],'Color',ccc(1,:),'LineWidth',4,'Clipping','off');
        t1=text(xOff/12-1.5,27,'FAST','FontSize',12,'Rotation',90,'Color',1*ccc(1,:),'FontWeight','bold');
        pp2=plot(xOff/12-1.4*[1 1]/12,[1 15],'Color',ccc(2,:),'LineWidth',4,'Clipping','off');
        t2=text(xOff/12-1.5,12,'SLOW','FontSize',12,'Rotation',90,'Color',1*ccc(2,:),'FontWeight','bold');
    end
    xOff=-35;
    fSize=12;
    txt={'ANKLE','KNEE','HIP'};
    if j==2
        xOff=-6;
        set(gca,'YTick',[]);
        fSize=10;
        txt={'A','K','H'};
    end
    for jj=1:maxI
        yyOff=yOff(jj)+1;
        plot(xOff*[1 1]/12,15-[.6 1.5]+yyOff,'Color',.7*ones(1,3),'LineWidth',6,'Clipping','off')
        plot(xOff*[1 1]/12,15-[1.5 5.4]+yyOff,'Color',0*ones(1,3),'LineWidth',6,'Clipping','off')
        text((xOff-12)/12,yyOff+12.5+numel(txt{1})/3-.33,txt{1},'FontSize',fSize,'Rotation',90)
        plot(xOff*[1 1]/12,15-[5.6 8.5]+yyOff,'Color',.7*ones(1,3),'LineWidth',6,'Clipping','off')
        plot(xOff*[1 1]/12,15-[8.5 11.4]+yyOff,'Color',0*ones(1,3),'LineWidth',6,'Clipping','off')
        text((xOff-12)/12,7+yyOff+numel(txt{2})/3-.33,txt{2},'FontSize',fSize,'Rotation',90)
        plot(xOff*[1 1]/12,15-[11.6 14.5]+yyOff,'Color',.7*ones(1,3),'LineWidth',6,'Clipping','off')
        plot(xOff*[1 1]/12,15-[14.5 15.4]+yyOff,'Color',0*ones(1,3),'LineWidth',6,'Clipping','off')
        text((xOff-12)/12,2+yyOff+numel(txt{3})/3-.33,txt{3},'FontSize',fSize,'Rotation',90)
    end
    grid off
end
set(ax,'GridLineStyle','none')
end
%%
saveFig(fh,'./','F6',0)