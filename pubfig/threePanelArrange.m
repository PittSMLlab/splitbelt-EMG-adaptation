figSize
axB=findobj(fB,'Type','Axes');
set(fB,'Units','Pixels','OuterPosition',figPos,'Renderer','opengl');

%Fix colormap: (not needed)
%figuresColorMap
%colormap(flipud(map))
Clim=.5;

for i=1:length(axB)
    %Change positions slightly:
    set(axB(i),'Position',get(axB(i),'Position').*[1 1 1 .9/.8] + [0 -.1 0 0])
    if i==1
            %Fix colorbar:
        caxis(Clim*[-1 1])
        cc=colorbar();
        cc.Ticks=[-.5 0 .5];
        cc.TickLabels={'-50%','0%','+50%'};
        set(cc,'FontSize',16,'FontWeight','bold')
        cc.Position=cc.Position.*[1 1 1 .98] + [0 .02 0 0];
        text(-2.3,33.5, 'A', 'FontSize',20,'FontWeight','bold','Clipping','off')
        text(-1.2,33.5, 'B', 'FontSize',20,'FontWeight','bold','Clipping','off')
        text(-.08,33.5, 'C', 'FontSize',20,'FontWeight','bold','Clipping','off')
        %Delete contours for post-adap
        ll=findobj(gca,'type','contour');
        delete(ll)
    else
        %Move the EXTENSORS/FLEXORS legend:
        ll2=findobj(axB(i),'Type','line','LineWidth',10);
        if ~isempty(ll2)
        xOff=2.4;
        yOff=2;
        for j=[length(ll2)+[-1:0]]
            ll2(j).XData=ll2(j).XData+xOff;
            ll2(j).YData=ll2(j).YData+yOff;
        end
        tt=findobj(axB(i),'Type','text','String','EXTENSORS');
        tt.Position=tt.Position+[xOff yOff 0];
        tt=findobj(axB(i),'Type','text','String','FLEXORS');
        tt.Position=tt.Position+[xOff yOff 0];
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
            set(ll,'LineWidth',4)
        end
    end
end
axes(axB(2))
pl=plot3([-1.2 2.25],[15 15],[6 6],'k','LineWidth',1,'Clipping','off');

%% Fix some stuff
t1=findobj(axB(3),'Type','Text','String','FAST/DOMINANT');
t1.String=['   ' t1.String];
t1=findobj(axB(3),'Type','Text','String','SLOW/NON-DOM');
t1.String=['   ' t1.String];
t1=findobj(axB(3),'Type','Text','String','ANKLE');
for i=1:length(t1)
t1(i).String=[' ' t1(i).String];
end