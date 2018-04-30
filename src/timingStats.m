%% Get some basic parameter stats in table form
write=true;
groupName='controls';
%% Load data
a=load('/Datos/Documentos/code/splitbelt-EMG-adaptation/data/HPF30/groupedParams_wMissingParameters.mat');

%% Define epochs
ep=getEpochs();

%%
data=a.(groupName).getEpochData(ep,{'doubleSupportSlow','swingTimeSlow','doubleSupportFast','swingTimeFast'}); %The phases are ordered as they appear in the gait cycle, and as would be plotted for fast leg muscles

%% Create table:
D=round(1000*median(data,3)); %Parameters x epochs, in ms
S=round(1000*iqr(data,3)); %Parameters x epochs, in ms
idx=[5,7,8,10,11]; %Relevant epochs;
t=table(ep.shortName(idx),D(1,idx)',S(1,idx)',D(2,idx)',S(2,idx)',D(3,idx)',S(3,idx)',D(4,idx)',S(4,idx)','VariableNames',{'Epoch','FHS_STO','iqr1','swingSlow','iqr2','SHS_FTO','iqr3','swingFast','iqr4'});

%% Write
logFile=['../intfig/timing_' groupName '_' date '_' num2str(round(1e6*(now-today)))];
if write
diary(logFile)
end
    disp(t)
if write
    diary off
    txt=fileread(logFile);
txt=removeTags(txt);
fid=fopen(logFile,'w');
fwrite(fid,txt,'char');
fclose(fid);
end


