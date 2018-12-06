function resizeFigure(figHandle, factor)

%Some pre-amble:
set(figHandle,'Units','pixels','PaperPosition',get(figHandle,'PaperPosition')*factor)
tt=findobj(figHandle,'Type','Axes');
for i=1:length(tt)
    tt(i).Units='Normalized'; %This ensures axes get re-scaled with fig
end
lg=findobj(figHandle,'Type','Legend');
set(lg,'Units','normalized');
%This PREVENTS legends from being auto-rescaled
%because Matlab's rescaling of legends is weird. Doing by hand.


%Rounding fun:
if factor<1
    roundFun=@ceil;
else
    roundFun=@round;
end
roundfun=@(x) x; %No rounding
%Re-size figure:
ip=get(figHandle,'InnerPosition');
set(figHandle,'InnerPosition',[ip(1:2) ip(3:4)*factor]);

%Re-size axes fonts:
tt=findobj(figHandle,'Type','Axes');
for i=1:length(tt)
    tt(i).FontSize=roundFun(tt(i).FontSize*factor);
end

%Re-size other text elements:
tt=findobj(figHandle,'Type','Text');
for i=1:length(tt)
    set(tt(i),'FontSize',roundFun(get(tt(i),'FontSize')*factor))
end

%Re-size line widths:
tt=findobj(figHandle,'Type','Line');
for i=1:length(tt)
    set(tt(i),'LineWidth',roundFun(get(tt(i),'LineWidth')*factor),'MarkerSize',roundFun(get(tt(i),'MarkerSize')*factor))
end

%Re-size legend boxes and fonts:
for i=1:length(lg)
    lg(i).FontSize=roundFun(lg(i).FontSize*factor);
   % lg(i).Position=lg(i).Position*factor;
end

%Re-size color fonts:
tt=findobj(figHandle,'Type','Colorbar');
for i=1:length(tt)
    tt(i).FontSize=roundFun(tt(i).FontSize*factor);
end
    
end

