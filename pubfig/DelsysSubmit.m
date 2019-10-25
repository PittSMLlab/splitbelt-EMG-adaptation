f1=openfig('./fig/Fig4.fig');
ph=findobj(f1,'Type','Axes');
delete(ph(1))
f2=openfig('./fig/Fig5.fig');
ph=findobj(f2,'Type','Axes');
p1=copyobj(ph(2),f1);
p1.Position=[.6 .085 .25 .25];
p1.Title.String='';
t1=findobj(p1,'Type','Text');
tt=findobj(t1,'String','A');
delete(tt)
tt=findobj(t1,'String','B');
delete(tt)
close(f2)

%%
export_fig ./png/FigDelsys.png -png -c[0 5 0 5] -transparent -r600