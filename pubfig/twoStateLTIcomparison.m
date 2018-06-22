%% Open relevant intfigs
f(1)=openfig('/Datos/Documentos/code/splitbelt-EMG-adaptation/intfig/all/dyn/fig/Adapt[2.1_1]medianALT.fig');
f(2)=openfig('/Datos/Documentos/code/splitbelt-EMG-adaptation/intfig/all/dyn/fig/Adapt[2.1_1]ALT.fig');
p=findobj(f(2),'Type','Axes');
set(p,{'Position'},cellfun(@(x) x+[.35 0 0 0],get(p,'Position'),'UniformOutput',false));
load ../data/dynamicsData.mat
%% Copy relevant panels:
figuresColorMap
fh=figure('Units','Normalized','Position',[0 0 1 1],'Colormap',flipud(map));
for j=1:2
  
p1=findobj(f(j),'Type','Axes');
np1=copyobj(p1(end-5:end),fh); %Copying states and associated checkerboards
np1(2).Title.String='D';
np1(4).Title.String='C_1';
np1(6).Title.String='C_2';
set(np1(2:2:6),{'Position'},cellfun(@(x) x+[0 -.01 0 0],get(np1(2:2:6),'Position'),'UniformOutput',false));
%Change text:
tt=findobj(np1(5),'Type','Text');
tt.Position=tt.Position-[100 0 0];
tt=findobj(np1(1),'Type','Text');
tt.String=tt.String(3:end);

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
end
aux2=copyobj(p1(34),fh); 
aux2.Position(1)=aux(2).Position(1)+aux(2).Position(3)+.006;
aux2.Position(3)=aux2.Position(3)-aux(2).Position(3)-.006;
aux2.Position(2)=1.5*aux(1).Position(2)-.5*aux(2).Position(2);
aux2.Position(4)=.5*aux2.Position(4);
ll=findobj(aux2,'Type','Line');
if j==1
lg=legend(ll,{'Proj. over C_2','Proj. over C_1','State 2','State 1'});
lg.Position(1)=lg.Position(1)+.08;
lg.Position(2)=lg.Position(2)+.02;
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
lg.Position(1)=lg.Position(1)+.08;
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
end
%%
saveFig(fh,'./','twoStateCompare')