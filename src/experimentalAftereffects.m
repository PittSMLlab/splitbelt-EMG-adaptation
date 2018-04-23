%% Experimental stuff: test if we can distinguish the existence of a 'state' dependent component of EMG above and beyond the FF and FB components
%Notice that this is only identifiable in the symmetric part of EMG, as in
%the anti-sym part it can be folded into the FB and FF components BOTH, and according to our
%hypothesis of transposition without any visible consequences in eP
%This initially suggests that we should do our analysis on anti-sym
%components only, to avoid dealing with state-dep component, but then H2
%and H3 are indistinguishable from each other

%%
addpath(genpath('./fun/'))
addpath(genpath('../pubfig/auxFun/'))
groupName='patients';
idx=[1:6,8:10,12:16]; %Excluding 7 and 11 which dont have short exp
groupName='controls';
idx=1:16;
load(['../data/' groupName 'EMGsummary'])
load ../data/bioData.mat


%%
fh=figure('Units','Normalized','OuterPosition',[0 0 1 1],'Name','Symmetric components');
figuresColorMap
colormap(flipud(map))
ct=.6;
M1=1;
M2=4;
subplot(M1,M2,1)
imagesc(reshape(median(lA,2),12,30)')
caxis(ct*[-1 1])
title('lA')

subplot(M1,M2,2)
imagesc(reshape(median(eP,2),12,30)')
caxis(ct*[-1 1])
title('eP')

subplot(M1,M2,4)
imagesc(reshape(median(lA,2)-median(eA,2),12,30)')
caxis(ct*[-1 1])
title('lA-eA')

subplot(M1,M2,3)
imagesc(reshape(median(lA,2)+median(fftshift(eA,1),2),12,30)')
caxis(ct*[-1 1])
title('lA+eA^T')

%%
fh=figure('Units','Normalized','OuterPosition',[0 0 1 1],'Name','residuals');
figuresColorMap
colormap(flipud(map))
ct=.6;
M1=1;
M2=4;
subplot(M1,M2,1)
imagesc(reshape(median(lP-lA,2),12,30)')
caxis(ct*[-1 1])
title('lP-lA')

subplot(M1,M2,2)
imagesc(reshape(median(-lA,2),12,30)')
caxis(ct*[-1 1])
title('-lA')

subplot(M1,M2,3)
imagesc(reshape(median(fftshift(lA,1),2),12,30)')
caxis(ct*[-1 1])
title('lA^T')

