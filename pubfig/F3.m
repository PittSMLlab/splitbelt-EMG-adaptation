%% 
%This script generates the checkerboards with late Adaptation (steady-state) and early Post-adaptation (aftereffects)
addpath(genpath('./auxFun/'))
figSize
%% Get panels from existing figure and make pretty:
saveDir='./';
name='allChangesEMG.fig';
desiredPlotDescription={'Slow';'late A'; 'early P[5]'};
%plotTitles={'Slow Tied','Late Adaptation (LateA)','       Early Post-Adaptation (EarlyP)'};
plotTitles={{'SLOW (TIED)'},{'LATE LONG EXPOSURE'},{' EARLY WASHOUT'}};
saveName='Fig3B';
lineFlag=0;
makeN19DPrettyAgain_execute
fB=gcf;

%% Add some details:
figPos=figPosThreeCols;
threePanelArrange
%% Add contours 
s1=findobj(axB(1),'Type','surface'); 
s2=findobj(axB(2),'Type','surface'); 
c1=s1.CData; 
c2=s2.CData; 
matchedC=sign(c1)==sign(c2) & abs(c1)>.1 & abs(c2)>.1; 
matchedC(:,end)=0; 
matchedC(end,:)=0; 
matchedC=[zeros(1,size(matchedC,2)+1); zeros(size(matchedC,1),1) matchedC; ]; 
mC=3*interp2([-1:30],[-1:12]',matchedC',[-1:.1:30],[-1:.1:12]','nearest')'; 
axes(axB(1)) 
contour3([-.5:.1:12.5]/12+.05/12,[-1:.1:30]'+.55,mC,2.9*[1 1],'k','LineWidth',3,'Clipping','off') 
axes(axB(2)) 
contour3([-.5:.1:12.5]/12+.05/12,[-1:.1:30]'+.55,mC,2.9*[1 1],'k','LineWidth',3,'Clipping','off') 

%%
set(findobj(fB,'Type','Axes'),'FontName','Helvetica')
saveFig(fB,'./','Fig3',1)
