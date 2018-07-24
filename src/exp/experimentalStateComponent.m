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
%Model: eA=FB + ST (feedback + speed/state dependent factor)
%lA=FF +ST (feedforward + state-dep)
%eP=FF +FB^T
%This implies:
%eP-lA-eA^T = -(ST +ST^T); %Notice this is symmetric
%eP-lA+eA   = FB+FB^T %Notice this is symmetric only
%eP+lA^T-eA^T = FF +FF^T %This is also symmetric only
%Notice that this model:
%1) is 3x3, so given FF, FB and ST we recover eA, eP, lA. Further, because
%it is 3x3 it offers no predictions: we need all three observations to
%decompose into FF,FB, and ST, but we can't use them again to see how good a fit
%the model is to the observations.
%2) is NOT uniquely invertible. In particular the asymmetric part of FB, FF and ST
%is ill-defined (we can add an arbitrary asymmetric offset to FB and FF,
%and subtract it from ST and we get the exact same observations)
%3) If we assume something like asym(ST)=0, then the model becomes
%invertible, and for any eA,lA,eP we can uniquely identify FF, FB, ST.
eAs=.5*(eA+fftshift(eA,1));
eAa=.5*(eA-fftshift(eA,1));

lAs=.5*(lA+fftshift(lA,1));
lAa=.5*(lA-fftshift(lA,1));

ePs=.5*(eP+fftshift(eP,1));
ePa=.5*(eP-fftshift(eP,1));

FBs=.5*(ePs-lAs+eAs);
FFs=.5*(ePs+lAs-eAs);
STs=.5*(eAs+lAs-ePs);

%Computing asym part of FB, FF and ST
off=zeros(size(eAa)); % %This is an arbitrary offset, we can define any asymmetric component we want here, and the model still holds
%Assigning off=lAa means saying there is no asymmetric component to learned FF behavior, just the disappearance of the asymmetric omponent of FB
%Assigning off=0 means saying the state-dep component is purely symmetric
%assigning off=eAa means saying the FB component is symmetric. This seems
%the most parsimonious of the three. However, it has weird results, like
%saying sTA activity immediately after the tied-to-split transition is the
%superposition of two things, and in fTA these two things are present but
%just happen to cancel each other.
%A fourth option is to find offset that minimizes something, like minimum
%norms of FBa +FFa +STa. 
FBa=eAa-off;
FFa=lAa-off;
STa=off;

synthFB=FBs+FBa;
synthFF=FFs+FFa;
synthST=STs+STa;

synthEA=synthFB+synthST;
synthLA=synthFF+synthST;
synthEP=synthFF+fftshift(synthFB,1);

%%
fh=figure('Units','Normalized','OuterPosition',[0 0 1 1],'Name','Symmetric components');
figuresColorMap
colormap(flipud(map))
ct=.6;
M1=3;
M2=6;
subplot(M1,M2,1)
imagesc(reshape(mean(eAs,2),12,30)')
caxis(ct*[-1 1])
title('sym(eA)')

subplot(M1,M2,2)
imagesc(reshape(mean(lAs,2),12,30)')
caxis(ct*[-1 1])
title('sym(lA)')

subplot(M1,M2,3)
imagesc(reshape(mean(ePs,2),12,30)')
caxis(ct*[-1 1])
title('sym(eP)')

%Derivatives
subplot(M1,M2,4)
imagesc(reshape(mean(FBs,2),12,30)')
caxis(ct*[-1 1])
title('sym(FB)=.5(eP-lA+eA)')

subplot(M1,M2,5)
imagesc(reshape(mean(FFs,2),12,30)')
caxis(ct*[-1 1])
title('sym(FF)=.5(eP+lA-eA)')

subplot(M1,M2,6)
imagesc(reshape(mean(STs,2),12,30)')
caxis(ct*[-1 1])
title('sym(ST)=.5(eA+lA-eP)')

subplot(M1,M2,7)
imagesc(reshape(mean(eAa,2),12,30)')
caxis(ct*[-1 1])
title('asym(eA)')

subplot(M1,M2,8)
imagesc(reshape(mean(lAa,2),12,30)')
caxis(ct*[-1 1])
title('asym(lA)')

subplot(M1,M2,9)
imagesc(reshape(mean(ePa,2),12,30)')
caxis(ct*[-1 1])
title('asym(eP)')

%Derivatives
subplot(M1,M2,10)
imagesc(reshape(mean(FBa,2),12,30)')
caxis(ct*[-1 1])
title('asym(FB)=eA')

subplot(M1,M2,11)
imagesc(reshape(mean(FFa,2),12,30)')
caxis(ct*[-1 1])
title('asym(FF)=lA')

subplot(M1,M2,12)
imagesc(reshape(mean(STa,2),12,30)')
caxis(ct*[-1 1])
colorbar
title('asym(ST)=??')

subplot(M1,M2,13)
imagesc(reshape(mean(synthEA,2),12,30)')
caxis(ct*[-1 1])
title('synth(eA)')

subplot(M1,M2,14)
imagesc(reshape(mean(synthLA,2),12,30)')
caxis(ct*[-1 1])
title('synth(lA)')

subplot(M1,M2,15)
imagesc(reshape(mean(synthEP,2),12,30)')
caxis(ct*[-1 1])
title('synth(eP)')

subplot(M1,M2,16)
imagesc(reshape(mean(synthFB,2),12,30)')
caxis(ct*[-1 1])
title('synth(FB)')

subplot(M1,M2,17)
imagesc(reshape(mean(synthFF,2),12,30)')
caxis(ct*[-1 1])
title('synth(FF)')

subplot(M1,M2,18)
imagesc(reshape(mean(synthST,2),12,30)')
caxis(ct*[-1 1])
title('synth(ST)')
