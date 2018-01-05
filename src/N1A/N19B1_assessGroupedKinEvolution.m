% %% Assuming that the variables groups() exists (From N19_loadGroupedData)

%% Directory to save figs
figDir='../../fig';
dirStr=[figDir '/all/kin/'];
if ~exist(dirStr,'dir')
    mkdir(dirStr);
end
%% Colormap:
colorScheme
cc=cell2mat(colorConds');
cc(2:3,:)=cc([3,2],:);
color_palette(2:3,:)=color_palette([3,2],:);

%%
removeMissing=false;
matDataDir='../../paramData/';
loadName=[matDataDir 'groupedParams'];
loadName=[loadName '_wMissingParameters']; %Never remove missing for this script
if (~exist('patients','var') || ~isa('patients','groupAdaptationData')) || (~exist('controls','var') || ~isa('controls','groupAdaptationData'))
    load(loadName)
    load([loadName 'Unbiased'])
end
patientFastList=strcat('P00',{'01','02','05','08','10','13','15'}); %Patients above .8m/s
%patients=patients.getSubGroup(patientFastList);
patientFastList=strcat('P00',{'01','02','05','08','09','10','13','14','15','16'}); %Patients above .72m/s, which is the group mean. N=10. Mean speed=.88m/s. Mean FM=29.5 (vs 28.8 overall)
controlsSlowList=strcat('C00',{'01','02','04','05','06','07','09','10','12','16'}); %Controls below 1.1m/s (chosen to match pop size), N=10. Mean speed=.9495m/s

patientUphillControlList={'C0001','C0002','C0003','C0004','C0009','C0010','C0011','C0012','C0013','C0014','C0015','C0016'};
patientUphillList_={'P0001','P0002','P0003','P0004','P0009','P0010','P0011','P0012','P0013','P0014','P0015','P0016'}; %patients that did the uphill
patientUphillList=strcat(patientUphillList_,'u'); %patients that did the uphill

load ../../paramData/bioData.mat %speeds, ages and Fugl-Meyer

%Removing P07:
noP07=true;
%noP07=false;
noC01=true;
noC01=false;

switch matchSpeedFlag
    case 1
        patients2=patients.getSubGroup(patientFastList).removeBadStrides;
        controls2=controls.getSubGroup(controlsSlowList).removeBadStrides;
        controlsUnbiased2=controlsUnbiased.getSubGroup(controlsSlowList).removeBadStrides;
        patientsUnbiased2=patientsUnbiased.getSubGroup(patientFastList).removeBadStrides;
    case 2
        if (~exist('patientsUp','var') || ~isa('patientsUp','groupAdaptationData'))
            loadName=[loadName '_wUphill']; 
            load(loadName)
            load([loadName 'Unbiased'])
        end
        patientsUp.ID{6}='P0010';
        patientsUp.ID=strcat(patientsUp.ID,'u');
        patientsUpUnbiased.ID{6}='P0010';
        patientsUpUnbiased.ID=strcat(patientsUpUnbiased.ID,'u');
        patients2=patients.getSubGroup(patientUphillList_).removeBadStrides;
        controls2=patientsUp.getSubGroup(patientUphillList).removeBadStrides;
        controlsUnbiased2=patientsUpUnbiased.getSubGroup(patientUphillList).removeBadStrides;
        patientsUnbiased2=patientsUnbiased.getSubGroup(patientUphillList_).removeBadStrides;
    case 0
        if noC01
            patientsUnbiased2=patientsUnbiased.removeSubs({'P0007','P0001'}).removeBadStrides;
            patients2=patients.removeSubs({'P0007','P0001'}).removeBadStrides;

            controlsUnbiased2=controlsUnbiased.removeSubs({'C0007','C0001'}).removeBadStrides;
            controls2=controls.removeSubs({'C0007','C0001'}).removeBadStrides;
        elseif noP07
            patientsUnbiased2=patientsUnbiased.removeSubs({'P0007'}).removeBadStrides;
            patients2=patients.removeSubs({'P0007'}).removeBadStrides;

            controlsUnbiased2=controlsUnbiased.removeSubs({'C0007'}).removeBadStrides;
            controls2=controls.removeSubs({'C0007'}).removeBadStrides;
        else
            patientsUnbiased2=patientsUnbiased.removeBadStrides;
            patients2=patients.removeBadStrides;
            controls2=controls.removeBadStrides;
            controlsUnbiased2=controlsUnbiased.removeBadStrides;
        end
end

%% Parameters and conditions to plot
paramList={'spatialContribution','stepTimeContribution','velocityContribution','netContribution','velocityAltContribution'};
paramList={'spatialContribution','stepTimeContribution','velocityContribution','netContribution'};
paramList={'cadenceSlow','swingTimeDiff','stanceTimeDiff','stepTimeDiff','doubleSupportDiff'};
condList={'TM base', 'Adap', 'Wash'};
condListExp={'TM base','Adaptation','Washout','TM slow'};
removeBiasFlag=0;
numberOfStrides=[20 -40];
exemptFirst=5;
exemptLast=5;

binwidth=3;
trialMarkerFlag=0;
indivSubs=[]; %List of subjects to be plotted. Default is ALL
colorOrder=color_palette;
biofeedback=[];
groupNames={'Patients','Controls'};
plotIndividualsFlag=0;
legendNames=[];
significanceThreshold=.05;
colors=color_palette;
removeBiasFlag=0;
significancePlotMatrix=[];
alignEnd=abs(numberOfStrides(2));
signifPlotMatrixConds=zeros(6);
signifPlotMatrixConds(2,[4:6])=1;
signifPlotMatrixConds(sub2ind([6,6],[2:5],[3:6]))=1;

%% Kin changes
for plotBiased=0%:1 %Whether to remove baseline in plots
    for indivFlag=0%:1 %Whether to plot individual subjects
        for mm=0:1 %Whether to take mean or median across subjects
            labels=paramList; %This needs to be sorted for proper visualization
            %labels={'spatialContribution','stepTimeDiff','velocityContributionAlt','stepLengthDiff'};
            %labels=groups{2}.adaptData{1}.data.getLabelsThatMatch('Contribution$')';
            %labels=groups{2}.adaptData{1}.data.getLabelsThatMatch('PNorm$')';
            conds=condList;
            fh=figure;
            %color_palette=color_palette([1,3,2,4:size(color_palette,1)],:);
            M=length(labels);
            clear ph
            for i=1:M
                ph(i,1)=subplot(M,3,[1:2]+3*(i-1));
                ph(i,1).Position(1)=ph(i,1).Position(1)-.05;
                ph(i,2)=subplot(M,3,[3]+3*(i-1));
                ph(i,2).Position(1)=ph(i,2).Position(1)-.08;
            end
            medianFlag=[1,mm];
            %medianFlag=[1,2,1];

            %Time courses:
            if plotBiased==1
                fh=adaptationData.plotAvgTimeCourse({patients2.adaptData,controls2.adaptData},labels,conds,binwidth,trialMarkerFlag,indivFlag,indivSubs,colorOrder,biofeedback,removeBiasFlag,groupNames,medianFlag,ph(:,1),alignEnd);
                %Add bars:
                medianFlag2=medianFlag(2);
                [fh,allData]=groupAdaptationData.plotMultipleGroupsBars({patients2,controls2},labels,removeBiasFlag,plotIndividualsFlag,conds,numberOfStrides,exemptFirst,exemptLast,legendNames,significanceThreshold,ph(:,2),colors,significancePlotMatrix,medianFlag2,signifPlotMatrixConds);
            else
                fh=adaptationData.plotAvgTimeCourse({patientsUnbiased2.adaptData,controlsUnbiased2.adaptData},labels,conds,binwidth,trialMarkerFlag,indivFlag,indivSubs,colorOrder,biofeedback,removeBiasFlag,groupNames,medianFlag,ph(:,1),alignEnd);
                medianFlag2=medianFlag(2);
                [fh,allData]=groupAdaptationData.plotMultipleGroupsBars({patientsUnbiased2,controlsUnbiased2},labels,removeBiasFlag,plotIndividualsFlag,conds,numberOfStrides,exemptFirst,exemptLast,legendNames,significanceThreshold,ph(:,2),colors,significancePlotMatrix,medianFlag2,signifPlotMatrixConds);
            end

            %Make pretty:
            for i=1:M
                subplot(ph(i,2));
                grid on
                axis tight
                aa=axis;
                axis([aa(1:2) [mean(aa(3:4))+(aa(3:4)-mean(aa(3:4)))*1.05]])
                aa=axis;
                if i==M
                   ll=findobj(gca,'Type','Legend'); 
                else
                    set(gca,'XTickLabel',{})
                end
                set(gca,'XLim',[3 18])
                set(gca,'XTick',[4.5 9 15])
                set(ph(i,2),'FontSize',20)
                ph(i,2).Title.String='';

                subplot(ph(i,1));
                grid on
                ab=axis;
                axis([ab(1:2) aa(3:4)])
                ll=findobj(ph(i,1),'Type','Line');
                set(ll,'MarkerEdgeColor','none','MarkerSize',5)
                pp=findobj(ph(i,1),'Type','Patch');
                set(pp,'EdgeColor','None')
                ph(i,1).Title.String=ph(i,1).YLabel.String;
                ph(i,1).YLabel.String='';
                if i==M

                else
                    set(gca,'XTickLabel',{})
                end
            end
            ph(end,1).Legend.Location='SouthWest';
            uistack(ph(end,2),'top')
            for i=1:min([length(ph(end,2).Legend.String),4])
                ph(end,2).Legend.String{i}=[groupNames{ceil(i/2)} ' ' ph(end,2).Legend.String{i}(8:end)];
            end
            set(fh,'Units','Normalized','OuterPosition',[0 0 1 1])
            ph(end,2).Legend.Position(1:2)=[.4,.11];
            ph(end,2).Legend.FontSize=14;
            %ph(end,2).Legend.FontWeight='bold';
            %% saving
            saveName=['allChangesTime'];
            if noC01
                saveName=[saveName '_noP07_noC01'];
            elseif noP07
                saveName=[saveName '_noP07'];
            end
            if matchSpeedFlag==1
               saveName=[saveName '_speedMatched']; 
            elseif matchSpeedFlag==2
                saveName=[saveName '_uphill'];
            end
            if medianFlag2==1
                saveName=[saveName '_median'];
            end
            if plotBiased==0
                saveName=[saveName '_unbiased'];
            end
            if indivFlag==1
                saveName=[saveName '_wIndiv'];
            end
            saveFig(fh,dirStr,saveName);
        end
    end
end

