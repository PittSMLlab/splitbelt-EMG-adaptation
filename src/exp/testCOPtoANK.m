%%
%Get an expData loaded:
%load('/Datos/Documentos/PhD/lab/rawData/synergies/mat/C0002.mat')
%%
close all
clearvars -except expData
trials=[6,7,9,10,10]; %Base, early adapt, POST
timeDuration=12; %In seconds. ~1.2 sec = 1 stride
earlyOrLate=[1,0,1,0,1]; %1=late, 0=early
colorScheme
name={'B','eA','lA','eP','lP'};
plots={'','Unbiased','d/dt','Alt Aligned'};
dataSetNames={'midHIP','COP','COPmix'};
alignLabels={'RHS','LTO','LHS','RTO'};
%%
for dataSets=1:3
for i=1:length(trials)
    trial=trials(i);
    if earlyOrLate(i)==1
        t2=expData.data{trial}.markerData.Time(end)-5; %Throwing away last 5s
        t1=t2-timeDuration;
    else
        t1=expData.data{trial}.markerData.Time(1)+5; %Throwing away first 5s
        t2=t1+timeDuration;
    end
    
%% Get data
allMarkers=expData.data{trial}.markerData.split(t1,t2).substituteNaNs;
dAllMarkers=expData.data{trial}.markerData.lowPassFilter(10).derivate.split(t1,t2).substituteNaNs;
Ts=allMarkers.sampPeriod;
T0=allMarkers.Time(1);

%Events
events=expData.data{trial}.gaitEvents.split(t1,t2).resample(Ts,T0);
eventData=events.getDataAsVector(alignLabels);
Rstance=1-cumsum(eventData(:,4))+cumsum(eventData(:,1));
Lstance=1-cumsum(eventData(:,2))+cumsum(eventData(:,3));
stepIdx=cumsum(eventData(:,1))-cumsum(eventData(:,3));
stepIdx=full(2*stepIdx - sign(mean(stepIdx))); %=1 RHS to LHS, =-1 LHS to RHS
stepIdx=stepIdx(1:size(allMarkers.Data,1));

%Ankle
RANK=allMarkers.getDataAsOTS({'RANK'});
LANK=allMarkers.getDataAsOTS({'LANK'});
stANK=(RANK.* (stepIdx==1)) + (LANK .* (stepIdx==-1));
dRANK=dAllMarkers.getDataAsOTS({'d/dt RANK'});
dLANK=dAllMarkers.getDataAsOTS({'d/dt LANK'});
dstANK=((dRANK) .* (stepIdx==1)) + ((dLANK) .* (stepIdx==-1));

%Datasets:
switch dataSets
    case 1 %midHip
        RHIP=allMarkers.getDataAsOTS({'RHIP'});
        LHIP=allMarkers.getDataAsOTS({'LHIP'});
        Data=(RHIP+LHIP)*.5;
        dData=Data.lowPassFilter(10).derivate;
        clear RHIP LHIP
    case 2 %COP
        [COP,~,~]=expData.data{trial}.computeCOPAlt;
        Data=COP.split(t1,t2).resample(Ts,T0);
        dData=COP.lowPassFilter(10).derivate.split(t1,t2).resample(Ts,T0);
    case 3 %COP mix
        [~,COPL,COPR]=expData.data{trial}.computeCOPAlt;
        COPL=COPL.medianFilter(5).substituteNaNs.lowPassFilter(30).split(t1,t2).resample(Ts,T0);
        COPR=COPR.medianFilter(5).substituteNaNs.lowPassFilter(30).split(t1,t2).resample(Ts,T0);
        Data=(COPR.* (stepIdx==1)) + (COPL .* (stepIdx==-1));
        dCOPL=COPL.medianFilter(5).substituteNaNs.lowPassFilter(10).derivate.split(t1,t2).resample(Ts,T0);
        dCOPR=COPR.medianFilter(5).substituteNaNs.lowPassFilter(10).derivate.split(t1,t2).resample(Ts,T0);
        dData=((dCOPR) .* (stepIdx==1)) + ((dCOPL) .* (stepIdx==-1));
end


%% Test stance ankle:
%  RANK2stANK=RANK+(stANK .* -1);
%  dRANK2stANK=RANK.lowPassFilter(6).derivate+((dstANK) .* -1);
%  RANK2stANK_aligned=RANK2stANK.align(events,{'RHS','LTO','LHS','RTO'},[24,76,24,76]);
%  dRANK2stANK_aligned=dRANK2stANK.align(events,{'RHS','LTO','LHS','RTO'},[24,76,24,76]);
%  LANK2stANK=LANK+(stANK .* -1);
%  dLANK2stANK=LANK.lowPassFilter(6).derivate+(dstANK .* -1);
%  LANK2stANK_aligned=LANK2stANK.align(events,{'RHS','LTO','LHS','RTO'},[24,76,24,76]);
%  dLANK2stANK_aligned=dLANK2stANK.align(events,{'RHS','LTO','LHS','RTO'},[24,76,24,76]);
% % 
%  [fh,ph]=RANK2stANK_aligned.plot;
%  LANK2stANK_aligned.plot(fh,ph,[0,0,1]);
%   [fh,ph]=dRANK2stANK_aligned.plot;
%  dLANK2stANK_aligned.plot(fh,ph,[0,0,1]);

%% Merge data
strideTime=median(diff(find(events.getDataAsVector({'RHS'})))/100);
M=round(200*strideTime);
testEvents=events.align(events,{'RHS'},M).mean;
N=nan(1,5);
for jj=1:4
    N(jj)=find(testEvents.Data(:,jj));
end
N(5)=M;
NN=round([24,76,24,76]*1.2);

Data2stANK=Data+(stANK .* -1);
dData2stANK=dData + (dstANK .* -1);
Data2stANK_aligned=Data2stANK.align(events,alignLabels,NN);
Data2stANK_alignedAlt=Data2stANK.align(events,alignLabels,diff(N));
dData2stANK_aligned=dData2stANK.align(events,alignLabels,NN);

if i==1
   Data_base=Data2stANK_aligned.median;
end
Data2stANK_unbiased=Data2stANK_aligned;
Data2stANK_unbiased.Data=bsxfun(@minus,Data2stANK_unbiased.Data,Data_base.Data);

if dataSets==3
    MM=15;
else
    MM=2;
end
Data2stANK_aligned.Data(1:MM,:,:)=NaN;
Data2stANK_aligned.Data(sum(NN(1:2))+[0:MM]-1,:,:)=NaN;
dData2stANK_aligned.Data(1:MM,:,:)=NaN;
dData2stANK_aligned.Data(sum(NN(1:2))+[0:MM]-1,:,:)=NaN;
Data2stANK_unbiased.Data(1:MM,:,:)=NaN;
Data2stANK_unbiased.Data(sum(NN(1:2))+[0:MM]-1,:,:)=NaN;
%Data2stANK_alignedAlt.Data(1:MM,:,:)=NaN;
%Data2stANK_alignedAlt.Data(N(3)+[0:MM]-1,:,:)=NaN;

%% Do some plotting:
if i==1
    fh=figure();
    b=3;
    a=3;
    ph=tight_subplot(b,a,[.02 .02],[.05 .05], [.05 .05]); %External function
    set(fh,'Name',[dataSetNames{dataSets} ' to stance ANKLE'])
end
bounds=[0,0] ; %This plots ste
Data2stANK_aligned.plot(fh,ph([1:3]),colorConds{i},[],0,[],bounds);
Data2stANK_unbiased.plot(fh,ph(3+[1:3]),colorConds{i},[],0,[],bounds);
dData2stANK_aligned.plot(fh,ph(6+[1:3]),colorConds{i},[],0,[],bounds);
%Data2stANK_alignedAlt.plot(fh,ph(9+[1:3]),colorConds{i},[],0,[],[16,84]);
end
%% Save
for jj=1:length(ph)
    subplot(ph(jj))
    axis tight
end
saveDir='./';
saveFig(fh,saveDir,[dataSetNames{dataSets} '2ANK_C0002'])
end
