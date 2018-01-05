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


load ../../paramData/bioData_wLearnIdx.mat %speeds, ages and Fugl-Meyer

%Removing P07:
noP07=true;
%noP07=false;



switch matchSpeedFlag
    case 1
        patients2=patients.getSubGroup(patientFastList).removeBadStrides;
        controls2=controls.getSubGroup(controlsSlowList).removeBadStrides;
        controlsUnbiased2=controlsUnbiased.getSubGroup(controlsSlowList).removeBadStrides;
        patientsUnbiased2=patientsUnbiased.getSubGroup(patientFastList).removeBadStrides;
    case 0
        if noP07
            patientsUnbiased2=patientsUnbiased.removeSubs({'P0007'}).removeBadStrides;
            patients2=patients.removeSubs({'P0007'}).removeBadStrides;

            %controlsUnbiased2=controlsUnbiased.removeSubs({'C0007'}).removeBadStrides;
            %controls2=controls.removeSubs({'C0007'}).removeBadStrides;
            controlsUnbiased2=controlsUnbiased.removeBadStrides;
            controls2=controls.removeBadStrides;
        else
            patientsUnbiased2=patientsUnbiased.removeBadStrides;
            patients2=patients.removeBadStrides;
            controls2=controls.removeBadStrides;
            controlsUnbiased2=controlsUnbiased.removeBadStrides;
        end
end
%% Add FM score as parameter
for i=1:length(patients2.ID)
    patients2.adaptData{i}=patients2.adaptData{i}.addNewParameter('FM',@(x) FM(strcmp(patients2.ID{i},strokesNames))*ones(size(x)),{'netContribution'},'lower-limb FM score');
    patients2.adaptData{i}=patients2.adaptData{i}.addNewParameter('age',@(x) ageS(strcmp(patients2.ID{i},strokesNames))*ones(size(x)),{'netContribution'},'lower-limb FM score');
    patients2.adaptData{i}=patients2.adaptData{i}.addNewParameter('learnIdx',@(x) idxS(strcmp(patients2.ID{i},strokesNames))*ones(size(x)),{'netContribution'},'learning Index from EMG aftereffect');
    patients2.adaptData{i}=patients2.adaptData{i}.addNewParameter('altLearnIdx',@(x) idxSalt(strcmp(patients2.ID{i},strokesNames))*ones(size(x)),{'netContribution'},'learning Index from EMG aftereffect');
    patients2.adaptData{i}=patients2.adaptData{i}.addNewParameter('AEproyOntoFlippedEA',@(x) proyS(strcmp(patients2.ID{i},strokesNames))*ones(size(x)),{'netContribution'},'Percentage of variance of early post response along the flipped early adaptation response');
    patients2.adaptData{i}=patients2.adaptData{i}.addNewParameter('diffB',@(x) diffBS(strcmp(patients2.ID{i},strokesNames))*ones(size(x)),{'netContribution'},'EMG activity difference to baseline');
    patients2.adaptData{i}=patients2.adaptData{i}.addNewParameter('proyB',@(x) proyBS(strcmp(patients2.ID{i},strokesNames))*ones(size(x)),{'netContribution'},'EMG projection to baseline');

end
for i=1:length(controls2.ID)
    controls2.adaptData{i}=controls2.adaptData{i}.addNewParameter('FM',@(x) NaN*ones(size(x)),{'netContribution'},'lower-limb FM score');
    controls2.adaptData{i}=controls2.adaptData{i}.addNewParameter('age',@(x) ageC(strcmp(controls2.ID{i},controlsNames))*ones(size(x)),{'netContribution'},'lower-limb FM score');
    controls2.adaptData{i}=controls2.adaptData{i}.addNewParameter('learnIdx',@(x) idxC(strcmp(controls2.ID{i},controlsNames))*ones(size(x)),{'netContribution'},'learning Index from EMG aftereffect');
    controls2.adaptData{i}=controls2.adaptData{i}.addNewParameter('altLearnIdx',@(x) idxCalt(strcmp(controls2.ID{i},controlsNames))*ones(size(x)),{'netContribution'},'learning Index from EMG aftereffect');
    controls2.adaptData{i}=controls2.adaptData{i}.addNewParameter('AEproyOntoFlippedEA',@(x) proyC(strcmp(controls2.ID{i},controlsNames))*ones(size(x)),{'netContribution'},'Percentage of variance of early post response along the flipped early adaptation response');
    controls2.adaptData{i}=controls2.adaptData{i}.addNewParameter('diffB',@(x) diffBC(strcmp(controls2.ID{i},controlsNames))*ones(size(x)),{'netContribution'},'EMG activity difference to baseline');
    controls2.adaptData{i}=controls2.adaptData{i}.addNewParameter('proyB',@(x) proyBC(strcmp(controls2.ID{i},controlsNames))*ones(size(x)),{'netContribution'},'EMG projection to baseline');
end

%%
patients2=patients2.removeAltBias({'TM base'},-40,5,1,0);
controls2=controls2.removeAltBias({'TM base'},-40,5,1,0);
all2=patients2.catGroups(controls2);
medianFlag=1;
regFlag=1;
exemptNo=5;

for k=0%1:8 %different predictions
    switch k
        case 1
            % Using baseline or biographical data as predictors
            predictions={'spatialContribution','stepTimeContribution','velocityContribution','netContribution'};
            predictions=strcat(predictions,suffix);
            predictors=[strcat('biasTM',predictions), {'biasTMequivalentSpeed','biasTMage','biasTMFM'}];
            medianFlag=1;
            diffFlag=0;
            regFlag=1;
            conds={'Wash'};
            strideNo=[20];
            name='_Base';
        case 0
            % Using baseline or biographical data as predictors
            predictions={'spatialContribution','stepTimeContribution','velocityContribution','netContribution'};
            predictions=strcat(predictions,suffix);
            predictors=[{'biasTMequivalentSpeed','biasTMage','biasTMFM','biasTMlearnIdx','biasTMaltLearnIdx','biasTMAEproyOntoFlippedEA'}];
            predictors=[{'biasTMequivalentSpeed','biasTMage','biasTMFM','biasTMlearnIdx','biasTMaltLearnIdx','biasTMdiffB','biasTMproyB'}];
            medianFlag=1;
            diffFlag=0;
            regFlag=1;
            conds={'Wash'};
            strideNo=[20];
            name='_bio';
        case 2
            % Using late adapt as predictors (nothing to see)
            predictions={'spatialContribution','stepTimeContribution','velocityContribution','netContribution'};
            predictions=strcat(predictions,suffix);
            predictors=[predictions];
            diffFlag=0;
            conds={'Adap','Wash'};
            strideNo=[-40 20];
            name='_lateAdapt';
        case 3
            % Using late-early adap as predictors
            predictions={'spatialContribution','stepTimeContribution','velocityContribution','netContribution'};
            predictions=strcat(predictions,suffix);
            predictors=[predictions];
            if strcmp(suffix,'Norm2') || isempty(suffix)
                patients2=patients2.removeSubs({'P0011'}); %This subject needs to be removed because of missing hip in first adap trial (otherwise regressions are NaN)
                all2=all2.removeSubs({'P0011'});
            end
            diffFlag=1;
            conds={'Wash','Adap','Adap'};
            strideNo=[20 -40 20];
            name='_AdaptChange';
        case 4
            % Using early adap to predict early-late change:
            predictions={'spatialContribution','stepTimeContribution','velocityContribution','netContribution'};
            predictions=strcat(predictions,suffix);
            predictors=[ predictions];
            if strcmp(suffix,'Norm2') || isempty(suffix)
                patients2=patients2.removeSubs({'P0011'}); %This subject needs to be removed because of missing hip in first adap trial (otherwise regressions are NaN)
                all2=all2.removeSubs({'P0011'});
            end
            diffFlag=1;
            conds={'Adap','Adap','Adap'};
            strideNo=[20 -40 20];
            name='_AdaptChangeFromEarlyAdapt';
        case 5 %After-effects of all the variables to each other
            predictions={'spatialContribution','stepTimeContribution','velocityContribution','netContribution'};
            predictions=strcat(predictions,suffix);
            predictors=[predictions];
            medianFlag=1;
            diffFlag=0;
            regFlag=1;
            conds={'Wash'};
            strideNo=[20];
            name='_after';
          case 6 %early adap as predictor for late adap
            predictions={'spatialContribution','stepTimeContribution','velocityContribution','netContribution'};
            predictions=strcat(predictions,suffix);
            predictors=[predictions];
            if strcmp(suffix,'Norm2') || isempty(suffix)
                patients2=patients2.removeSubs({'P0011'}); %This subject needs to be removed because of missing hip in first adap trial (otherwise regressions are NaN)
                all2=all2.removeSubs({'P0011'});
            end
            diffFlag=0;
            conds={'Adap','Adap'};
            strideNo=[20 -40];
            name='_earlyAdaptFORlateAdapt';
          case 7 %early adap (alone) as predictor for aftereffects
            predictions={'spatialContribution','stepTimeContribution','velocityContribution','netContribution'};
            predictions=strcat(predictions,suffix);
            predictors=[predictions];
            if strcmp(suffix,'Norm2') || isempty(suffix)
                patients2=patients2.removeSubs({'P0011'}); %This subject needs to be removed because of missing hip in first adap trial (otherwise regressions are NaN)
                all2=all2.removeSubs({'P0011'});
            end
            diffFlag=0;
            conds={'Adap','Wash'};
            strideNo=[20 20];
            name='_earlyAdapt';
          case 9
              %leaving here as interesting case:
              %i mistakenly run predictions after-effects WRT to early adapt, from late
              %adap WRT early adapt: some very significant correlations for spatial &
              %net, which I can't understand and didn't expect to be more predicting that
              %late adaptation for after-effects WRT baseline [in principle, if everyone
              %acted the same, this should exactly have the same predicting power, as we
              %are subtracting a constant from behavior in both cases]
              patients2=patients2.removeAltBias({'Adap'},20,5,1,0); %This alternate baseline is for cases 4 & 5
              controls2=controls2.removeAltBias({'Adap'},20,5,1,0);
              all2=patients2.catGroups(controls2);
              predictions={'spatialContribution','stepTimeContribution','velocityContribution','netContribution'};
              predictions=strcat(predictions,suffix);
              predictors=[ predictions];
              if strcmp(suffix,'Norm2') || isempty(suffix)
                  patients2=patients2.removeSubs({'P0011'}); %This subject needs to be removed because of missing hip in first adap trial (otherwise regressions are NaN)
                  all2=all2.removeSubs({'P0011'});
              end
              diffFlag=0;
              conds={'Wash','Adap'};
              strideNo=[20 -40];
              name='_WRTearlyAdap';
            case 10
                patients2=patients2.removeAltBias({'Adap'},-40,5,1,0); %This alternate baseline is for cases 4 & 5
                controls2=controls2.removeAltBias({'Adap'},-40,5,1,0);
                all2=patients2.catGroups(controls2);
                predictions={'spatialContribution','stepTimeContribution','velocityContribution','netContribution'};
                predictions=strcat(predictions,suffix);
                predictors=[ predictions];
                if strcmp(suffix,'Norm2') || isempty(suffix)
                    patients2=patients2.removeSubs({'P0011'}); %This subject needs to be removed because of missing hip in first adap trial (otherwise regressions are NaN)
                    all2=all2.removeSubs({'P0011'});
                end
                diffFlag=0;
                conds={'Wash','Adap'};
                strideNo=[20 20];
                name='_WRTlateAdap';
              case 8
                all2=patients2.catGroups(controls2);
                predictions={'spatialContribution','stepTimeContribution','velocityContribution','netContribution'};
                predictions=strcat(predictions,suffix);
                predictors=[ predictions];
                if strcmp(suffix,'Norm2') || isempty(suffix)
                    patients2=patients2.removeSubs({'P0011'}); %This subject needs to be removed because of missing hip in first adap trial (otherwise regressions are NaN)
                    all2=all2.removeSubs({'P0011'});
                end
                diffFlag=1;
                conds={'Adap','Adap','Wash'};
                strideNo=[20 -40 20];
                name='_jumps';

    end

    %The actual plots:
    fh=figure;
    M=length(predictors);
    N=length(predictions);
    for i=1:M
        for j=1:N
            ph(i,j)=subplot(N,M,(j-1)*M+i);
        end
    end
    for j=1:N %Predictions
        for i=1:M %Predictors
                ph2=ph(i,j);
                %all2.plotIndividuals([predictors(i) predictions(j)],conds,strideNo,exemptNo,medianFlag,ph2,regFlag,diffFlag);
                patients2.plotIndividuals([predictors(i) predictions(j)],conds,strideNo,exemptNo,medianFlag,ph2,regFlag,diffFlag);
                controls2.plotIndividuals([predictors(i) predictions(j)],conds,strideNo,exemptNo,medianFlag,ph2,regFlag,diffFlag);
            grid on
            set(gca,'FontSize',8)
            if j~=N
               xlabel('')
               set(gca,'XTickLabel',[])
            end
            if i~=1
               ylabel('')
               set(gca,'YTickLabel',[])
               axis tight
               ab=axis;
               %axis([ab(1:2) aa(3:4)])
            else
                axis tight
                aa=axis;
            end
            hl=legend;
            hl.Position=hl.Position+[0 .1 0 0];
            ll=findobj(gca,'Type','Line');
            idx=[1:3:length(ll); 2:3:length(ll)];
            legend(ll(flipud(idx(:))))
        end
    end
    saveFig(fh,dirStr,['kinPrediction' suffix name])
end
%%
clear patients2 controls2
