%% All figures:

%% 1: Methods
F1
%% 2: Early Adapt
F2
%% S2:
%Fig2SB
%Fig2SC
%Fig2S
%% 3: LAte adapt and early post
F3
%% S3:

%% 4:
F4
%% S4:
%Fig4SC
%Fig4SD
%Fig4S

%%
clear all
run ../src/loadEMGParams_controls
eAT=fftshift(eA,1);
lAT=fftshift(lA,1);
lST=fftshift(lS,1);
veAT=fftshift(veA,1);
%%
% aux=eP;
% gamma=2;
% a=.5*(aux(1:180,:)-aux(181:end,:));
% b=.5*(aux(1:180,:)+aux(181:end,:));
% nA=sum(abs(a).^gamma);
% nB=sum(abs(b).^gamma);
% s=nA./(nA+nB)
% sM=(sum(abs(mean(a,2)).^gamma))./((sum(abs(mean(a,2)).^gamma))+(sum(abs(mean(b,2)).^gamma)))
% mean(s)
% figure; subplot(2,1,1); plot(age,s,'x');[r,p]=corr(age',s'); hold on; title(['r=' num2str(r) ', p=' num2str(p)])
% subplot(2,1,2); plot(age,,'x');[r,p]=corr(age',nA'); hold on; title(['r=' num2str(r) ', p=' num2str(p)])
%% 5: (requires loading the above data)
F5 
S5
%Includes supplemental too
