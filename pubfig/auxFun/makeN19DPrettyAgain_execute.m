
%close all
if ~exist('lineFlag','var')
    lineFlag=1;
end
%% Make output of N19D pretty
dualPlot=~isempty(desiredPlotDescription2);

%% Define params
%Colormap:
ex1=[.85,0,.1];
ex2=[0,.1,.6];
map=[bsxfun(@plus,ex1,bsxfun(@times,1-ex1,[0:.01:1]'));bsxfun(@plus,ex2,bsxfun(@times,1-ex2,[1:-.01:0]'))];
cLim=[-.6 .6];
bgColor=.9*ones(1,3); %Default background color
map=[bgColor; map; bgColor];

%% Open fig
oldFig=openfig(['../intfig/all/emg/fig/' name]);
if exist('name2','var')
    oldFig2=openfig(['../intfig/all/emg/fig/' name2]);
else
    oldFig2=oldFig;
end
%% Select subplots and move to new figure

plots=findobj(oldFig,'Type','axes');
titles=get(plots,'Title');
strTitle=cellfun(@(x) get(x,'String'),titles,'UniformOutput',false);
strTitle=cellfun(@(x) x{1},strTitle,'UniformOutput',false);
descriptionMatch=find(all(cell2mat(cellfun(@(x) contains(strTitle,x,'IgnoreCase',true),desiredPlotDescription,'UniformOutput',false)),2));
mLabels=plots(end).YTickLabels;
newFig=figure('Name',saveName,'Units','Normalized','OuterPosition',[.3 .1 .5 .8],'Color',bgColor);
newAxes=copyobj(plots(descriptionMatch),newFig);
newFig.InvertHardcopy = 'off';


%% Make pretty
ll=findobj(newAxes,'Type','Line');
tt=findobj(newAxes,'Type','text');
delete(tt)
try %This fails if no phase/muscle was significant
ll.MarkerSize=6;
catch
    
end
newAxes.FontSize=16;
title(plotTitles{1})

%Colorbar stuff:
c=colorbar;
c.Ticks=[-.3 -.1 0 .1 .3];
c.TickLabels={'-30%','-10%','No change','+10%','+30%'};
colormap(flipud(map))
caxis(cLim)
c.Limits=[-.5 .5];

drawnow
newAxes.Position=[.1 .2 .3 .7];

aa=axis;
newAxes.YAxisLocation='right';
hold on
newAxes.XTick=[1 4 7 10]/12;
ccc=get(gca,'ColorOrder');

% Find significant points & mark anti-symmetric changes
ss=findobj(newAxes,'Type','Surface');
ll=findobj(newAxes,'Type','Line');
xCoord=ss.XData(1:end-1)+diff(ss.XData)/2;
yCoord=ss.YData(1:end-1)+diff(ss.YData)/2;

try
Y1=ll(end).YData(ll(end).YData>yCoord(15))-mean(yCoord(16:17));
X1=ll(end).XData(ll(end).YData>yCoord(15));
Y2=ll(end).YData(ll(end).YData<=yCoord(15));
X2=ll(end).XData(ll(end).YData<=yCoord(15));
[jj1,~]=find(bsxfun(@minus,Y1,yCoord')==0);
[ii1,~]=find(bsxfun(@minus,X1,xCoord')==0);
sig1=zeros(length(xCoord),length(yCoord));
sig1(sub2ind([length(xCoord),length(yCoord)],ii1,jj1))=1;
[jj2,~]=find(bsxfun(@minus,Y2,yCoord')==0);
[ii2,~]=find(bsxfun(@minus,X2,xCoord')==0);
sig2=zeros(length(xCoord),length(yCoord));
sig2(sub2ind([length(xCoord),length(yCoord)],ii2,jj2))=1;
cc=ss.CData;
%cc(cc>c.Limits(2))=c.Limits(2); %To avoid saturation of map
%cc(cc<c.Limits(1))=c.Limits(1);
%cc(16,:)=-1;
sig= sig1 & sig2 & sign(cc(1:31,1:12)')~=sign([cc(17:31,1:12); cc(1:16,1:12)]');
sig(:,17:31)=sig(:,1:15);
[ii,jj]=find(sig);
%plot3(xCoord(ii),yCoord(jj),1.5*ones(size(ii)),'o','MarkerFaceColor','r','MarkerEdgeColor','None','MarkerSize',6)
ss.ZData=-1*ones(size(ss.ZData));
ss.CData=cc;
if lineFlag==1
[lineHandles] = addBinaryBoundary(newAxes, sig',xCoord,yCoord);
end
catch
    
end

drawnow
%Add swing/stance/DS lines & text
newAxes.XTickLabel={'DS','STANCE','DS','SWING'};
plot([.1 1.9]/12,-.3*[1 1],'Color',0*ones(1,3),'LineWidth',4,'Clipping','off')
plot([2.1 5.9]/12,-.3*[1 1],'Color',0*ones(1,3),'LineWidth',4,'Clipping','off')
plot([6.1 7.9]/12,-.3*[1 1],'Color',0*ones(1,3),'LineWidth',4,'Clipping','off')
plot([8.1 11.9]/12,-.3*[1 1],'Color',0*ones(1,3),'LineWidth',4,'Clipping','off')

xOff=-.5;
%Slow/fast legs
p1=plot(xOff/12-1.4*[1 1]/12,[1 15]-.5,'Color',ccc(1,:),'LineWidth',6,'Clipping','off');
t1=text(xOff/12-2/12,2.1,'FAST/NON-PARETIC','FontSize',16,'Rotation',90,'Color',1*ccc(1,:));
p2=plot(xOff/12-1.4*[1 1]/12,[16 30]-.5,'Color',ccc(2,:),'LineWidth',6,'Clipping','off');
t2=text(xOff/12-2/12,18,'SLOW/PARETIC','FontSize',16,'Rotation',90,'Color',1*ccc(2,:));
yOff=0;
%Flexor/extensor legend
plot((yOff+5+[5.6 7.5])/12,-3*[1 1],'Color',.7*ones(1,3),'LineWidth',10,'Clipping','off')
text((yOff+7+[5.6])/12,-3,'FLEXORS','FontSize',12)
plot((yOff+5+[5.6 7.5])/12,-4*[1 1],'Color',0*ones(1,3),'LineWidth',10,'Clipping','off')
text((yOff+7+[5.6])/12,-4,'EXTENSORS','FontSize',12)
axis(aa)

%Fix some stuff for symmetry plots:
if length(yCoord)<17
   newAxes.Position=[.1 .15 .3 .4];
   t1.String='FAST - SLOW DIFFERENCE';
   t1.Position=[t1.Position(1) 1.2];
   t1.Color=ccc(5,:);
   p1.Color=ccc(5,:);
   delete(p2)
   delete(t2)
   
    cLim=[-.9 .9];
    bgColor=.9*ones(1,3); %Default background color
    map=[bgColor; map; bgColor];
    c.Ticks=[-.6 -.3 0 .3 .6];
    c.TickLabels={'-60%','-30%','No change','+30%','+60%'};
    colormap(flipud(map))
    caxis(cLim)
    c.Limits=[-.8 .8];
    
    maxI=1;

else %Change muscle names
    %mLabels=newAxes.YTickLabel;
    aux=cellfun(@(x) x(1:end-1),mLabels,'UniformOutput',false);
    newAxes.YTickLabel=cellfun(@(x) x([2,max(3,length(x)-1):length(x)]),aux,'UniformOutput',false);
    maxI=2;
end
drawnow
pause(2)
% Add flexor/extensor descriptions
yOff=[0,15];
xOff=-.5;
for i=1:maxI
    yyOff=yOff(i)-.5;
    plot(xOff*[1 1]/12,0+[.6 1.5]+yyOff,'Color',.7*ones(1,3),'LineWidth',10,'Clipping','off')
    plot(xOff*[1 1]/12,0*[1 1]+[1.5 5.4]+yyOff,'Color',0*ones(1,3),'LineWidth',10,'Clipping','off')
    text((xOff-.8)/12,1+yyOff,'ANKLE','FontSize',16,'Rotation',90)
    plot(xOff*[1 1]/12,0*[1 1]+[5.6 8.5]+yyOff,'Color',.7*ones(1,3),'LineWidth',10,'Clipping','off')
    plot(xOff*[1 1]/12,0*[1 1]+[8.5 11.4]+yyOff,'Color',0*ones(1,3),'LineWidth',10,'Clipping','off')
    text((xOff-.8)/12,7+yyOff,'KNEE','FontSize',16,'Rotation',90)
    plot(xOff*[1 1]/12,0*[1 1]+[11.6 13.5]+yyOff,'Color',.7*ones(1,3),'LineWidth',10,'Clipping','off')
    plot(xOff*[1 1]/12,0*[1 1]+[13.5 15.4]+yyOff,'Color',0*ones(1,3),'LineWidth',10,'Clipping','off')
    text((xOff-.8)/12,12.5+yyOff,'HIP','FontSize',16,'Rotation',90)
end
%% Second plot
if dualPlot
    c.Visible='off';
    newAxes.YTick=[];
    plots=findobj(oldFig2,'Type','axes');
    titles=get(plots,'Title');
    strTitle=cellfun(@(x) get(x,'String'),titles,'UniformOutput',false);
    strTitle=cellfun(@(x) x{1},strTitle,'UniformOutput',false);
    descriptionMatch2=find(all(cell2mat(cellfun(@(x) contains(strTitle,x,'IgnoreCase',false),desiredPlotDescription2,'UniformOutput',false)),2));
    newAxes2=copyobj(plots(descriptionMatch2),newFig);
    axes(newAxes2)
    title(plotTitles{2})
    ll=findobj(newAxes2,'Type','Line');
    tt=findobj(newAxes2,'Type','text');
    delete(tt)
    try
    ll.MarkerSize=6;
    catch
        
    end
    drawnow
    newAxes2.FontSize=16;
    aa=axis;
    c2=colorbar;
    c2.Location='eastoutside';
    c2.Ticks=c.Ticks;
    c2.TickLabels=c.TickLabels;
    c2.Limits=c.Limits;
    drawnow
    newAxes2.Position=[.45 .2 .3 .7];
    drawnow
    colormap(flipud(map))
    caxis(cLim)
    
    newAxes2.YAxisLocation='right';
    hold on
    newAxes2.YTickLabel=cellfun(@(x) x([2,max(3,length(x)-1):length(x)]),newAxes2.YTickLabel,'UniformOutput',false);
    newAxes2.XTick=[1 4 7 10]/12;
    newAxes2.XTickLabel={'DS','STANCE','DS','SWING'};

    plot([.1 1.9]/12,-.3*[1 1],'Color',0*ones(1,3),'LineWidth',4,'Clipping','off')
    plot([2.1 5.9]/12,-.3*[1 1],'Color',0*ones(1,3),'LineWidth',4,'Clipping','off')
    plot([6.1 7.9]/12,-.3*[1 1],'Color',0*ones(1,3),'LineWidth',4,'Clipping','off')
    plot([8.1 11.9]/12,-.3*[1 1],'Color',0*ones(1,3),'LineWidth',4,'Clipping','off')
    axis(aa)

% Find significant points & mark anti-symmetric changes
drawnow
ss=findobj(newAxes2,'Type','Surface');
ll=findobj(newAxes2,'Type','Line');
xCoord=ss.XData(1:end-1)+diff(ss.XData)/2;
%xCoord=[0:ss.XData(2)-1] +.5;
yCoord=ss.YData(1:end-1)+diff(ss.YData)/2;
%yCoord=[0:ss.YData(2)-1] +.5;
%try
    Y1=ll(end).YData(ll(end).YData>yCoord(15))-mean(yCoord(16:17));
    X1=ll(end).XData(ll(end).YData>yCoord(15));
    Y2=ll(end).YData(ll(end).YData<=yCoord(15));
    X2=ll(end).XData(ll(end).YData<=yCoord(15));
%catch
    
%end
[jj1,~]=find(bsxfun(@minus,Y1,yCoord')==0);
[ii1,~]=find(bsxfun(@minus,X1,xCoord')==0);
sig1=zeros(length(xCoord),length(yCoord));
sig1(sub2ind([length(xCoord),length(yCoord)],ii1,jj1))=1;
[jj2,~]=find(bsxfun(@minus,Y2,yCoord')==0);
[ii2,~]=find(bsxfun(@minus,X2,xCoord')==0);
sig2=zeros(length(xCoord),length(yCoord));
sig2(sub2ind([length(xCoord),length(yCoord)],ii2,jj2))=1;
cc=ss.CData;
%cc(cc>c.Limits(2))=c.Limits(2); %To avoid saturation of map
%cc(cc<c.Limits(1))=c.Limits(1);
%cc(16,:)=-1;
sig= sig1 & sig2 & sign(cc(1:30,1:12)')~=sign([cc(16:30,1:12); cc(1:15,1:12)]');
sig(:,16:30)=sig(:,1:15);
[ii,jj]=find(sig);
%plot3(xCoord(ii),yCoord(jj),1.5*ones(size(ii)),'o','MarkerFaceColor','r','MarkerEdgeColor','None','MarkerSize',6)
%ss.ZData=-1*ones(size(ss.ZData));
ss.CData=cc;
if lineFlag==1
[lineHandles] = addBinaryBoundary(newAxes2, sig',xCoord,yCoord);
end
end

%%
try
close(oldFig)
close(oldFig2)
catch
    
end