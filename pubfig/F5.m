%%
fh=openfig('../intfig/intersubj/fig/AgeSpeedEffects_controls.fig');
addpath(genpath('./auxFun/'))
figSize
%%
f1=figure('Units',figUnits,'OuterPosition',figPos);
ph=findobj(fh,'Type','Axes');
pa=copyobj(ph([7:10,6]),f1);
mapI=[1,2,3,1,2]; %Alignment along x-axis
mapJ=[2,1,1,1,2]; %y-axis
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
        p.Position=[.05+.28*(i-1)+.15*(j>1) .1+.5*((2-j)) .22 .35];
        p.FontSize=14;
        drawnow
        ll2=findobj(gca,'Type','Scatter');
        try
             nn=get(ll2,'DisplayName');
                cc=cell2mat(get(ll2,'CData'));
                aa=cell2mat(get(ll2,'MarkerFaceAlpha'));
                cc=(cc.*aa +(1-aa));
                if k==4
                    nn{1}=['\beta_M ' nn{1}(5:end)];
                nn{2}=['\beta_S ' nn{2}(4:end)];
                end
                for ii=1:size(cc,1)
                    nn{ii} = sprintf('\\color[rgb]{%f, %f, %f}%s', cc(ii,:), nn{ii});
                end
        catch
             nn=get(ll2,'DisplayName');
                cc=(get(ll2,'CData'));
                aa=(get(ll2,'MarkerFaceAlpha')); 
                cc=(cc.*aa +(1-aa)); 
                nn = sprintf('\\color[rgb]{%f, %f, %f}%s', cc, nn);
        end
        switch k
            case 1 %aftereffects
                axis([45 80 0 .35])
                text(55,.33,nn,'FontSize',10,'FontWeight','bold')
                set(gca,'YTick',[0:.1:.3])
            case 2 %Feedback
                axis([45 80 2 18])
                text(54,16,nn,'FontSize',10,'FontWeight','bold')
                
            case 3 %Late adapt
                axis([45 80 2 9])
                text(50,8.5,nn,'FontSize',10,'FontWeight','bold')
                p.Title.String='Late Adaptation';
                set(gca,'YTick',3:4:15)
            case 4 %Regressors
                axis([45 80 -.4 1])
                ll2=findobj(gca,'Type','Scatter');
                set(gca,'YTick',[-.4:.4:.8])
                text(61,.8,nn,'FontSize',10,'FontWeight','bold')
                 %Add panel letters:
                text(40,1.1,'A','FontWeight','Bold','FontSize',20)
                text(85,1.1,'B','FontWeight','Bold','FontSize',20)
                text(130,1.1,'C','FontWeight','Bold','FontSize',20)
                text(110,-.85,'E','FontWeight','Bold','FontSize',20)
                text(65,-.85,'D','FontWeight','Bold','FontSize',20)
            case 5 %EMG aftereffects
                axis([45 80 2 16])
                text(55,15,nn,'FontSize',10,'FontWeight','bold')
                set(gca,'YTick',[0:5:15])
                
               
        end
end
%%
saveFig(f1,'./','Fig5',0)