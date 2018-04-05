%%
fh=openfig('../intfig/intersubj/fig/AgeSpeedEffects_controls.fig');

%%
f1=figure('Units','Normalized','OuterPosition',[0 0 .5 .8]);
ph=findobj(fh,'Type','Axes');
pa=copyobj(ph(5:8),f1);
for i=1:2
    for j=1:2
        p=pa((j-1)*2+i);
        axes(p)
        ss=findobj(p,'Type','scatter');
        ll=legend(ss);
        drawnow
        pause(1)
        ll.FontSize=10;
        p.Position=[.1+.5*(2-j) .1+.5*((2-i)*(2-j)+(j-1)*(i-1)) .3 .3];
        p.FontSize=14;
        drawnow
        switch (j-1)*2+i
            case 1
                axis([40 80 0 .4])
                
            case 2
                axis([40 80 2 25])
                
            case 3
                axis([40 80 2 25])
            case 4
                axis([40 80 -.4 1.4])
        end
    end
end

%%
saveFig(f1,'./','Fig5',0)