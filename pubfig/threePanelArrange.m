figSize
axB=findobj(fB,'Type','Axes');
set(fB,'Units',figUnits,'InnerPosition',figPosThreeCols,'PaperUnits',paperUnits,'PaperPosition',paperPositionThreeCols,'PaperSize',paperPositionThreeCols(3:4));
%Fix colormap: (not needed)
%figuresColorMap
%colormap(flipud(map))
Clim=.5;

for i=1:length(axB)
    %Change positions slightly:
    set(axB(i),'Position',get(axB(i),'Position').*[1 1 .9 1.05] + [.03+.017*(1-i) -.07 0 0],'FontName','OpenSans')
    if i==1
            %Fix colorbar:
        caxis(Clim*[-1 1])
        cc=colorbar();
        cc.Ticks=[-.5 0 .5];
        cc.TickLabels={'-50%','0%','+50%'};
        set(cc,'FontSize',10,'FontWeight','normal')
        cc.Position=cc.Position.*[1 1 1 .98] + [0 .01 0 0];
        text(-2.7,33.5, 'A', 'FontSize',16,'FontWeight','bold','Clipping','off')
        text(-1.4,33.5, 'B', 'FontSize',16,'FontWeight','bold','Clipping','off')
        text(-.1,33.5, 'C', 'FontSize',16,'FontWeight','bold','Clipping','off')
        %Delete contours for post-adap
        ll=findobj(gca,'type','contour');
        delete(ll)
    else
        axB(i).YTick=[];
    end
    %else
        %Move the EXTENSORS/FLEXORS legend:
        ll2=findobj(axB(i),'Type','line','LineWidth',5);
        if ~isempty(ll2)
            xOff=2.8;
            yOff=1.6;
            for j=[length(ll2)+[-1:0]]
                ll2(j).XData=ll2(j).XData+xOff;
                ll2(j).YData=ll2(j).YData+yOff;
            end
            tt=findobj(axB(i),'Type','text','String','EXTENSORS');
            tt.Position=tt.Position+[xOff yOff 0];
            tt.FontSize=8;
            tt=findobj(axB(i),'Type','text','String','FLEXORS');
            tt.Position=tt.Position+[xOff yOff 0];
            tt.FontSize=8;
        end

        %Change contour colors for late adapt:
        ll=findobj(gca,'type','contour');
        if ~isempty(ll)
            auxZ=ll.ZData;
            auxZ(571:end,:)=0;
            contour(ll.XData,ll.YData,auxZ,.5*[1 1]);
            auxZ=ll.ZData;
            auxZ(1:570,:)=0;
            auxZ(1649:end,:)=0;
            contour(ll.XData,ll.YData,auxZ,.5*[1 1]);
            auxZ=ll.ZData;
            auxZ(1:1649,:)=0;
            auxZ(1649+571:end,:)=0;
            contour(ll.XData,ll.YData,auxZ,.5*[1 1]);
            auxZ=ll.ZData;
            auxZ(1:1649+570,:)=0;
            contour(ll.XData,ll.YData,auxZ,.5*[1 1]);
            delete(ll)
            ll=findobj(gca,'type','contour');
            cc1=get(gca,'ColorOrder');
            ll(2).Color=cc1(2,:);
            ll(1).Color=cc1(1,:);
            ll(3).Color=cc1(2,:);
            ll(4).Color=cc1(1,:);
            set(ll,'LineWidth',2)
        end
    %end
    axB(i).YRuler.Axle.LineStyle = 'none';
    axB(i).XRuler.Axle.LineStyle = 'none';
    axB(i).Title.FontWeight='normal';
    axB(i).Title.FontName='OpenSans';
    ll=findobj(axB(i),'Type','Line','Color',zeros(1,3));
    for j=1:length(ll)
       if ll(j).YData(1)<0
          ll(j).YData=ll(j).YData+.1; 
       end
    end
    uistack(ll,'top')
end
axes(axB(2))
pl=plot3([-1.31 -.25]-.02,[15 15],[6 6],'k','LineWidth',1,'Clipping','off');
pl=plot3([-.03 1.03],[15 15],[6 6],'k','LineWidth',1,'Clipping','off');
pl=plot3([1.25 2.31]+.02,[15 15],[6 6],'k','LineWidth',1,'Clipping','off');
%set(axB,'FontSize',8)
%txt=findobj(fB,'Type','Text');
%set(txt,'FontSize',8)

%% Fix some stuff
try
t1=findobj(axB(3),'Type','Text','String','FAST/DOMINANT');
t1.Position=t1.Position+[-.015 1 0];
t1.FontWeight='normal';
t1=findobj(axB(3),'Type','Text','String','SLOW/NON-DOM');
t1.Position=t1.Position+[-.015 1 0];
t1.FontWeight='normal';
t1=findobj(axB(3),'Type','Text','String','ANKLE');
for i=1:length(t1)
t1(i).String=[' ' t1(i).String];
end
end

