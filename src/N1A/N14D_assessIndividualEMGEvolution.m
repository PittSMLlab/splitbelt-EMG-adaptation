%% Assuming that the variables groups() exists (From N19_loadGroupedData)

%% Directory to save figs
figDir='../../intfig';
if ~exist(figDir,'dir')
    mkdir(figDir);
end
dirStr=[figDir '/indiv/'];
if ~exist(dirStr,'dir')
    mkdir(dirStr);
end
dirStr=[figDir '/indiv/emg/'];
if ~exist(dirStr,'dir')
    mkdir(dirStr);
end


%% Define epochs:
baseEp=getBaseEpoch; %defines baseEp
ep=getEpochs(); %Defines other epochs

refEp=baseEp;
refEp2=ep(strcmp(ep.Properties.ObsNames,'late A'),:); 
earlyPost=ep(strcmp(ep.Properties.ObsNames,'early P'),:); 
refEp.Properties.ObsNames{1}=['Ref: ' refEp.Properties.ObsNames{1}];

%% Get normalized parameters:
%Define parameters we care about:
mOrder={'TA', 'PER', 'SOL', 'LG', 'MG', 'BF', 'SEMB', 'SEMT', 'VM', 'VL', 'RF', 'HIP', 'ADM', 'TFL', 'GLU'};
nMusc=length(mOrder);
type='s';
labelPrefix=([strcat('f',mOrder) strcat('s',mOrder)]); %To display
labelPrefixLong= strcat(labelPrefix,['_' type]); %Actual names
normString='^Norm';
baseEp=getBaseEpoch;

%Renaming normalized parameters, for convenience:
ll=adaptData.data.getLabelsThatMatch(normString);
l2=regexprep(regexprep(ll,normString,''),'_s','s');
adaptData=adaptData.renameParams(ll,l2);
newLabelPrefix=strcat(labelPrefix,'s');

%% Sym/asym 
flip=1;
if plotSym==1
    flip=2;
end

%% Plot (and get data)
fh=figure('Units','Normalized','OuterPosition',[0 0 1 1]);
ph=tight_subplot(2,length(ep)+1,[.03 .005],.04,.04);
summFlag='median';
clear dataE dataRef
adaptData.plotCheckerboards(newLabelPrefix,ep,fh,ph(1,2:end),[],flip); %First, plot raw
[~,~,labels,dataE,dataRef]=adaptData.plotCheckerboards(newLabelPrefix,ep,fh,ph(2,2:end),refEp,flip);%Second, differences to baseline
adaptData.plotCheckerboards(newLabelPrefix,earlyPost,fh,ph(2,1),refEp2,flip); %Third: early post WRT la 
%adaptData.plotCheckerboards(newLabelPrefix,refEp2,fh,ph(2,1),[],flip); %First, plot reference epoch:   
%[~,~,labels,dataE,dataRef2]=adaptData.plotCheckerboards(newLabelPrefix,ep,fh,ph(2,2:end),refEp2,flip);%Second, the rest:
set(ph(:,1),'CLim',[-1 1]);
set(ph(:,2:end),'YTickLabels',{},'CLim',[-1 1]);
set(ph(1,:),'XTickLabels','');
set(ph(2,:),'Title',[]);
set(ph,'FontSize',8)
pos=get(ph(1,end),'Position');
axes(ph(1,end))
colorbar
set(ph(1,end),'Position',pos);
ph(2,1).Title.String='eP - lA';
%% Save
saveName=['allChangesEMG' sub];
if useLateAdapBase
    saveName=[saveName '_lateAdapBase'];
end
if plotSym
    saveName=[saveName '_sym'];
end
saveFig(fh,dirStr,[saveName],0);
