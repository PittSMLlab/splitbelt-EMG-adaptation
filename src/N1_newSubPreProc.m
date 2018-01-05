%New subject
%dbstop if error
%%
clearvars
subs={'1','2'};
subs={'22','41','43','44','119','139','93','124'};
subs={'22'};
subs={'P0001','P0002','P0003','P0004','P0005','P0006','P0007','P0008','P0009','P0010','P0011','P0012','P0013','P0014','P0015','P0016'};
subs={'P0011','P0012','P0013','P0014','P0015','P0016'};
subs={'0002','0003','0004','0005','0006','0007','0008'};
subs={'0003','0008','0004','P0001','P0002','P0003','P0004','P0005','P0006','P0007','P0008','P0009','P0010','P0011','P0012','P0013','P0014','P0015','P0016'};
subs={'P0003u','P0004u','P0007u','P0010u','P0011u','P0013u','P0014u','P0015u','P00016u'};
subs={'C0000','C0001','C0002','C0003','C0004','C0006','C0007','C0008','C0009','C0010','C0011','C0012','C0014','C0015','C0016'};
subs={'P0001','P0002','P0003','P0004','P0005','P0006','P0007','P0008','P0009','P0010','P0011','P0012','P0013','P0014','P0015','P0016'};
strokes={'P0001','P0002','P0003','P0004','P0005','P0006','P0007','P0008','P0009','P0010','P0011','P0012','P0013','P0014','P0015','P0016'};
healthies={'0003','0004','0008'};
strokesUp={'P0001u','P0002u','P0003u','P0004u','P0009u','P0010u','P0011u','P0012u','P0013u','P0014u','P0015u','P0016u'}; %P0007 excluded
controls={'C0001','C0002','C0003','C0004','C0005','C0006','C0007','C0008','C0009','C0010','C0011','C0012','C0013','C0014','C0015','C0016'}; %C0000 is removed because it is not a control for anyone, plus it has

subs=[strokes controls];
subs=strokes(11);
%subs=strokesUp;
%% Pre-process
for i=1:length(subs)
    sub=subs{i};
    disp(['Subject ' num2str(sub)])

    %% Computing supplemecntal data from raw: processed EMG, events, etc.
      disp('Processing from raw data...')
      %run ./N1/N11_calcSuppData.m
      disp('N11 done!')

    %% Review events!
     disp('Reviewing events...')
     %run ./N1/N12_reviewEvents.m
     disp('N12 done!')

    %% Recompute parameters (only run if something changed, otherwise, just keep the ones computed during N11)
     disp('Recomputing parameters...')
     %run ./N1/N13_recomputeParams.m
     disp('N13 done!')

     %% Create adaptData object
     disp('Calculating adaptation data...')
     %run ./N1/N14_calcAdaptData.m
     disp('N14 done!')

     %% Fix condition names in param files
     disp('Changing condition names in adaptation data...')
     %run ./N1/N16_renameCondsInAdaptData.m
     disp('N16 done!')
    %% Visualize data

    %run ./N1A/N13A_assessData.m
    %run ./N1A/N14A_assessIndividualAdaptation.m
    close all
end

%% Group assessments
%clear all
%close all
clc
strokesNames={'P0001','P0002','P0003','P0004','P0005','P0006','P0007','P0008','P0009','P0010','P0011','P0012','P0013','P0014','P0015','P0016'};
%healthies={'0003','0004','0008'};
%strokesUp={'P0003u','P0004u','P0010u','P0011u','P0013u','P0014u','P0015u','P0016u'};
controlsNames={'C0001','C0002','C0003','C0004','C0005','C0006','C0007','C0008','C0009','C0010','C0011','C0012','C0013','C0014','C0015','C0016'}; %C0000 is removed because it is not a control for anyone, plus it has
strokesUpNames={'P0001u','P0002u','P0003u','P0004u','P0009u','P0010u','P0011u','P0012u','P0013u','P0014u','P0015u','P0016u'}; %patients that did the uphill
%strokes1={'P0001','P0013','P0014','P0015'}; %Healthy-behaving strokes
%strokes2={'P0016','P0012','P0009'}; %Almost-healthy, negative step length asym (little spatial)
%strokes3={'P0010','P0006','P0011','P0005','P0008','P0002','P0003'}; % negative time, positive spatial
%strokes4={'P0007'}; %Outliers
%strokes5={'P0004'}; %Outliers

%Some meta-data:
load ../paramData/bioData.mat %speeds, ages and Fugl-Meyer
%run ./N1/N19_loadGroupedData.m %This actually load indiv params files and

%If N19 is not run, need to load:
%load ../paramData/groupedParams_wMissingParameters.mat
%load ../paramData/groupedParams_wMissingParametersUnbiased.mat

matchSpeedFlag=0;
suffix='Norm2';
% run ./N1A/N19A_assessGroupedBaseKin.m
%  run ./N1A/N19B_assessGroupedKinEvolution.m
 run ./N1A/N19B1_assessGroupedKinEvolution.m
% run ./N1A/N19B2_assessGroupedKinEvolution2.m
% run ./N1A/N19B3_assessGroupedKinEvolutionIndividuals.m
 suffix='PNorm';
% run ./N1A/N19A_assessGroupedBaseKin.m
%run ./N1A/N19B_assessGroupedKinEvolution.m
% run ./N1A/N19B2_assessGroupedKinEvolution2.m
% run ./N1A/N19B3_assessGroupedKinEvolutionIndividuals.m
% suffix='P';0% run ./N1A/N19A_assessGroupedBaseKin.m
% run ./N1A/N19B_assessGroupedKinEvolution.m
% run ./N1A/N19B2_assessGroupedKinEvolution2.m
% suffix='';
% run ./N1A/N19A_assessGroupedBaseKin.m


% %
% matchSpeedFlag=1;
 mSet='s';
%  for matchSpeedFlag=0%:1
%      for subCountFlag=1%0:1
%          for earlyStridesFlag=0%:1
%              for shortSplitFlag=0%:1
%                  for useLateAdapBase=0%:1
%                      for plotSym=0%:1
%                         run ./N1A/N19D_assessGroupedEMGEvolution.m
%                      end
%                  end
%              end
%          end
%      end
%  end
% matchSpeedFlag=2;
% run ./N1A/N19D_assessGroupedEMGEvolution.m
% matchSpeedFlag=0;
% run ./N1A/N19D_assessGroupedEMGEvolution.m
% useLateAdapBase=1;
% run ./N1A/N19D_assessGroupedEMGEvolution.m
% 
% useLateAdapBase=0;
% shortSplitFlag=1;
% run ./N1A/N19D_assessGroupedEMGEvolution.m
% useLateAdapBase=1;
% run ./N1A/N19D_assessGroupedEMGEvolution.m
% % %profile off
