%% Open relevant intfigs
f1=openfig('/Datos/Documentos/code/splitbelt-EMG-adaptation/intfig/all/dyn/fig/Adapt[2.1_1]median.fig');
f2=openfig('/Datos/Documentos/code/splitbelt-EMG-adaptation/intfig/all/dyn/fig/Adapt[2.1_1]Bilat.fig');
%% Copy relevant panels:
p1=findobj(f1,'Type','Axes');
p2=findobj(f2,'Type','Axes');
figuresColorMap
fh=figure('Units','Normalized','Position',[0 0 1 1],'Colormap',flipud(map));
np1=copyobj(p1(end-8:end),fh);
np2=copyobj(p2(end-8:end),fh);
for i=1:length(np2)
    np2(i).Position(2)=np1(i).Position(2)-.3;
end

aux=copyobj(p1(end-30),fh);
aux.Position([2,4])=np1(1).Position([2,4]);
aux2=copyobj(p2(end-30),fh);
aux2.Position([2,4])=np2(1).Position([2,4]);
aux2.Title.String='Early Post Data (2:4)';
aux.Title.String='Early Post Data (2:4)';

np1(3).Title.String='End of Adaptation fit';
np2(3).Title.String='End of Adaptation fit';
np1(2).Title.String='Early Post prediction';
np2(2).Title.String='Early Post prediction';
np2(5).YTickLabels=[strcat('s',np2(5).YTickLabels);strcat('f',np2(5).YTickLabels)];
np2(5).YTick=1:30;
np2(5).YAxis.FontSize=6;
axes(np1(end-2))
pp=np1(end-2).Position;
cc=colorbar;
np1(end-2).Position=pp;

np1(1).Position([1,3])=np1(1).Position([1,3])+[.1 -.1];
np2(1).Position([1,3])=np2(1).Position([1,3])+[.1 -.1];

axes(np1(1))
ll=findobj(gca,'Type','Line');
lg=legend(ll,{'Proj. over C_2','Proj. over C_1','State 2','State 1'});
lg.Position(1)=lg.Position(1);
lg.Position(2)=lg.Position(2)+.02;
lg.FontWeight='bold';
axes(np2(1))
np2(1).XTick=np1(1).XTick;
np2(1).YTick=np1(1).YTick;
grid on

%%
saveFig(fh,'./','twoStateCompare')