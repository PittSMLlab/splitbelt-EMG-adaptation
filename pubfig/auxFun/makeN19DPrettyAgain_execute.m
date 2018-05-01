%%
% Script to identify, extract and beautify panels from figs generated through N19D.
% Needed variables:
% name= Nx1 cell array containing figure names (to use in openfig())
% desiredPlotDescription = NxM cell array containing panel titles, used to identify desired panels
% plotTitles = Nx1 cell array with new plot titles
% saveName = string with name of figure to save

% All inputs that are cell arrays can be of the same size, or scalar. Size
% of largest array determines the number of panels in new figure

%% Preface
if isa(name,'char') %Allowing for name to be provided as string
    name={name};
end
%close all
if ~exist('lineFlag','var')
    lineFlag=1;
end
Npanels=length(plotTitles);

%Colormap:
ex1=[.85,0,.1];
ex2=[0,.1,.6];
map=[bsxfun(@plus,ex1,bsxfun(@times,1-ex1,[0:.01:1]'));bsxfun(@plus,ex2,bsxfun(@times,1-ex2,[1:-.01:0]'))];
cLim=[-.6 .6];
bgColor=.9*ones(1,3); %Default background color
map=[bgColor; map; bgColor];
figuresColorMap %This loads an alternative map

%Create new fig:
newFig=figure('Name',saveName,'Units','Normalized','OuterPosition',[.3 .1 .5 .8],'Color',bgColor,'Renderer','opengl');
%% Do the thing:
for i=1:Npanels
    % Open fig
    if length(name)>1 || i==1 %Only doing this step for subsequent panels IFF they belong to a different figure
        if i>1
        close(oldFig)
        end
        oldFig=openfig(['../intfig/all/emg/fig/' name{i}]);
    end
    
    % Select subplots and move to new figure
    plots=findobj(oldFig,'Type','axes');
    titles=get(plots,'Title');
    strTitle=cellfun(@(x) get(x,'String'),titles,'UniformOutput',false);
    aux=cellfun(@(x) ~isa(x,'char'),strTitle);
    strTitle(aux)=cellfun(@(x) x{1},strTitle(aux),'UniformOutput',false);
    descriptionMatch=find(all(cell2mat(cellfun(@(x) contains(strTitle,x,'IgnoreCase',true),desiredPlotDescription(i,:),'UniformOutput',false)),2));
    mLabels=plots(end).YTickLabels;
    newAxes=copyobj(plots(descriptionMatch),newFig);
    %newFig.InvertHardcopy = 'off';
    axes(newAxes);
    hold on
    drawnow
    pause(1)

    % Make pretty
    ll=findobj(newAxes,'Type','Line');
    tt=findobj(newAxes,'Type','text');
    delete(tt)
    try %This fails if no phase/muscle was significant
        ll.MarkerSize=6;
    catch
    end
    newAxes.FontSize=16;
    drawnow
    %pause(.5)
    newAxes.Title.String=plotTitles{i};
    
        %Add colorbar preserving size:
    c=colorbar;
    c.Ticks=[-.3 -.1 0 .1 .3];
    c.TickLabels={'-30%','-10%','No change','+10%','+30%'};
    colormap(flipud(map))
    caxis(cLim)
    c.Limits=[-.5 .5];

    drawnow
    newAxes.Position=[.1+(i-1)*1.1*.66/(Npanels) .2 .66/Npanels .7];

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

    % Adding some first panel stuff:
    if i==1
    xOff=-.6;
    %Slow/fast legs
    p1=plot(xOff/12-1.4*[1 1]/12,[1 15]-.5,'Color',ccc(1,:),'LineWidth',6,'Clipping','off');
    t1=text(xOff/12-2/12,2,'FAST/DOMINANT','FontSize',16,'Rotation',90,'Color',1*ccc(1,:),'FontWeight','bold');
    p2=plot(xOff/12-1.4*[1 1]/12,[16 30]-.5,'Color',ccc(2,:),'LineWidth',6,'Clipping','off');
    t2=text(xOff/12-2/12,17,'SLOW/NON-DOM','FontSize',16,'Rotation',90,'Color',1*ccc(2,:),'FontWeight','bold');
    yOff=0;
    %Flexor/extensor legend
    plot((yOff+5+[5.6 7.5])/12,-3*[1 1],'Color',.7*ones(1,3),'LineWidth',10,'Clipping','off')
    text((yOff+7+[5.6])/12,-3,'FLEXORS','FontSize',12)
    plot((yOff+5+[5.6 7.5])/12,-4*[1 1],'Color',0*ones(1,3),'LineWidth',10,'Clipping','off')
    text((yOff+7+[5.6])/12,-4,'EXTENSORS','FontSize',12)
    axis(aa)
    
    % Add flexor/extensor descriptions
    yOff=[0,15];
    xOff=-.5;
    maxI=2;
    if length(yCoord)<17
        maxI=1;
    end
    for j=1:maxI
        yyOff=yOff(j)-.5;
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
    end


    drawnow
    pause(2)
    % For all panels except last:
    if i~=Npanels
        %Remove ytick labels
        set(gca,'YTickLabel',{});
        %Remove colorbars
        colorbar off
    else
        aux=cellfun(@(x) x(1:end-1),mLabels,'UniformOutput',false);
        newAxes.YTick=.5:1:length(mLabels);
        newAxes.YTickLabel=cellfun(@(x) x([2,max(3,length(x)-1):length(x)]),aux,'UniformOutput',false);
        for j=1:length(newAxes.YTickLabel)
            if j<16
                newAxes.YTickLabel{j}=['\color[rgb]{0,0.447,0.741} ' newAxes.YTickLabel{j}]; %Matches first default color in Matlab R2018a
            else
                newAxes.YTickLabel{j}=['\color[rgb]{0.85,0.325,0.098} ' newAxes.YTickLabel{j}]; %Matches first default color in Matlab R2018a
            end
        end
    end
end

close(oldFig)