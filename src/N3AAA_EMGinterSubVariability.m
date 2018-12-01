%% 
addpath(genpath('./fun/'))
addpath(genpath('../pubfig/auxFun/'))
%% Define data from params if necessary
groupName='patients';
subjIdx=[1:6,8:10,12:16]; %Excluding 7 and 11 which dont have short exp
groupName='controls';
subjIdx=2:16; %Excluding C01

%% Get all needed vars
load(['../data/' groupName 'EMGsummary'])
load ../data/bioData.mat
write=true;
write=false;

%% Define eAT, lAT, etc
eAT=fftshift(eA,1);
lAT=fftshift(lA,1);
veAT=fftshift(veA,1);
e15AT=fftshift(e15A,1);
e15PT=fftshift(e15P,1);
ePT=fftshift(eP,1);
vePT=fftshift(veP,1);

%%
c5=crossValCosine(eA);
c15=crossValCosine(e15A);
c1=crossValCosine(veA);

%%
c=[c1;c5;c15];
figure; subplot(2,1,1)
hold on;
plot([1,5,15],c)
xlabel('Strides')
ylabel('Cos of eA, indiv to median ')
plot(1,c1,'kx')
plot(5,c5,'kx')
plot(15,c15,'kx')
plot([1,5,15],median(c'),'LineWidth',2,'Color','k')
subplot(2,1,2)
hold on;
