%%
fh=openfig('../intfig/intersubj/fig/AgeSpeedEffects_controls.fig');
addpath(genpath('./auxFun/'))
figSize
%%
myFiguresColorMap
f1=figure('Units',figUnits,'InnerPosition',figPosThreeCols,'PaperUnits',paperUnits,'PaperPosition',paperPositionThreeCols,'PaperSize',paperPositionThreeCols(3:4));
f1.InnerPosition(4)=f1.InnerPosition(4)*1.4;
f1.PaperPosition(4)=f1.PaperPosition(4)*1.4;
f1.PaperSize(2)=f1.PaperSize(2)*1.4;
ph=findobj(fh,'Type','Axes');
pa=copyobj(ph([7:10,6]),f1);
mapI=[1,2,3,1,2]; %Alignment along x-axis
mapJ=[2,1,1,1,2]; %y-axis
%fname='Helvetica';
fname='Open Sans';
annotSize=8;
for k=1:5
%for i=1:2
%    for j=1:2
i=mapI(k);
j=mapJ(k);
        p=pa(k);
        axes(p)
        ss=findobj(p,'Type','scatter');
        %ll=legend(ss);
        %drawnow
        %pause(1)
        %ll.FontSize=10;
        p.Position=[.07+.33*(i-1)+.12*(j>1)+.1*(j>1 & i>1) .12+.47*((2-j)) .24 .31];
        p.FontSize=8;
        drawnow
        ll2=findobj(gca,'Type','Scatter');
        try %Manu scatter plots
             nn=get(ll2,'DisplayName');
                cc=colorTransitions([2,1],:);
                aa=cell2mat(get(ll2,'MarkerFaceAlpha'));
                cc=(cc.*aa +(1-aa));
                if k==4
                    nn{1}=['\beta_{adapt}: ' nn{1}(5:end)];
                    nn{2}=['\beta_{no-adapt}: ' nn{2}(4:end)];
                elseif k==2
                    %nn{1}=['||{\Delta}EMG_{{\uparrow}on}||:' nn{1}(24:end)];
                    %nn{2}=['||{\Delta} EMG_{{\uparrow}off}^{long}||:' nn{2}(24:end)];
                    nn{2}=['on (+):' nn{2}(24:end)];
                    nn{1}=['off (+) long:' nn{1}(24:end)];
                    %cc(2,:)=cc(1,:);
                    cc(1,:)=[0 0 0];
                end
                for ii=1:size(cc,1)
                    nn{ii} = sprintf('\\color[rgb]{%f, %f, %f}%s', cc(ii,:), nn{ii});
                    ll2(ii).MarkerFaceColor=cc(ii,:);
                end
        catch %Single scatter plot
             nn=get(ll2,'DisplayName');
                cc=(get(ll2,'CData'));
                aa=(get(ll2,'MarkerFaceAlpha')); 
                cc=(cc.*aa +(1-aa)); 
                %nn = sprintf('\\color[rgb]{%f, %f, %f}%s', cc, nn);
        end
        nn=regexprep(nn,'\\rho =','{\\rho}= ');
        switch k
            case 1 %SLA aftereffects
                axis([45 80 0 .35])
                %text(60,.27,nn([1:41,50:end]),'FontSize',annotSize,'FontWeight','bold','FontName',fname)
                nn=[nn(9:end)];
                text(55,.27,nn,'FontSize',annotSize,'FontWeight','bold','FontName',fname)
                set(gca,'YTick',[0:.1:.3])
                p.YLabel.String={'Step-length asymmetry';'(early Wash. - Base.)'};
                ll2=findobj(gca,'Type','Scatter');
                ll2.CData=[0 0 0];
                 set(ll2,'MarkerEdgeColor','w');
                set(ll2,'MarkerFaceColor','k')
            case 2 %Feedback
                axis([45 80 2 14.8])
                p.Title.String='Corrective responses';
                p.YLabel.String='||{\Delta}EMG|| (a.u.)';
                ll2=findobj(gca,'Type','Scatter');
                set(ll2,'MarkerEdgeColor','w');
                %ll2(1).MarkerFaceColor=ll2(2).MarkerFaceColor;
                %ll2(2).MarkerFaceColor=[0 0 0];
                l2=findobj(gca,'Type','Line');
                l2(2).Color=ll2(2).MarkerFaceColor;
                l2(1).Color=ll2(1).MarkerFaceColor;
                uistack(l2,'bottom')
                text(54,13,nn{2},'FontSize',annotSize,'FontWeight','bold','FontName',fname)
                text(47,3,nn{1},'FontSize',annotSize,'FontWeight','bold','FontName',fname)
            case 3 %Late adapt
                axis([45 80 2 9])
                %text(50,7,nn([1:41,52:end]),'FontSize',annotSize,'FontWeight','bold','FontName',fname)
                nn=[nn(10:end)];
                text(50,7,nn,'FontSize',annotSize,'FontWeight','bold','FontName',fname)
                p.Title.String={'Late Long Exp.';'modulation'};
                set(gca,'YTick',3:4:15)
                p.YLabel.String={'||{\Delta}EMG|| (a.u.)';'(late Long - Base.)'};
                ll2=findobj(gca,'Type','Scatter');
                 set(ll2,'MarkerEdgeColor','w');
                ll2.CData=[0 0 0];
            case 4 %Regressors
                axis([45 80 -.4 .8])
                ll2=findobj(gca,'Type','Scatter');
                set(ll2,'MarkerEdgeColor','w');
                ll2=findobj(gca,'Type','Line');
                uistack(ll2,'bottom')
                set(gca,'YTick',[-.4:.4:.8])
                text(54,.68,nn{1},'FontSize',annotSize,'FontWeight','bold','FontName',fname)
                text(54,-.3,nn{2},'FontSize',annotSize,'FontWeight','bold','FontName',fname)
                 %Add panel letters:
                text(38,.98,'A','FontWeight','Bold','FontSize',16)
                text(88,.98,'B','FontWeight','Bold','FontSize',16)
                text(136,.98,'C','FontWeight','Bold','FontSize',16)
                text(117,-.9,'E','FontWeight','Bold','FontSize',16)
                text(51,-.9,'D','FontWeight','Bold','FontSize',16)
                ax=gca; ax.YLabel.String='Coefficients';
                ax.YLabel.Position=ax.YLabel.Position+[2 0 0];
               
                p.Title.String='Regression model';
            case 5 %EMG aftereffects
                axis([45 80 2 14])
                nn=[nn(11:end)];
                %text(59,12,nn([1:41,52:end]),'FontSize',annotSize,'FontWeight','bold','FontName',fname)
                text(55,12,nn,'FontSize',annotSize,'FontWeight','bold','FontName',fname)
                set(gca,'YTick',[0:5:15])
                p.YLabel.String={'||{\Delta}EMG|| (a.u.)';'(early Wash. - Base.)'};
                ll2=findobj(gca,'Type','Scatter');
                ll2.CData=[0 0 0];
                set(ll2,'MarkerEdgeColor','w');
                ll2=findobj(gca,'Type','Line');
                uistack(ll2,'bottom')
                set(ll2,'Color','k')
        end
        ax=gca;
        ax.YLabel.Position(1)=ax.YLabel.Position(1)-1;
        ax.FontName=fname;
        ax.Title.String=upper(ax.Title.String);
        ax.Title.FontWeight='normal';
         %p.YLabel.FontWeight='bold';
         %p.XLabel.FontWeight='bold';
end
%%
set(findobj(f1,'Type','Axes'),'FontName',fname)
saveFig2(f1,'./','Fig5',0)