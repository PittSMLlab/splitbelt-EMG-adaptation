%% Group assessments
clc
strokesNames={'P0001','P0002','P0003','P0004','P0005','P0006','P0007','P0008','P0009','P0010','P0011','P0012','P0013','P0014','P0015','P0016'};
controlsNames={'C0001','C0002','C0003','C0004','C0005','C0006','C0007','C0008','C0009','C0010','C0011','C0012','C0013','C0014','C0015','C0016'}; %C0000 is removed because it is not a control for anyone, plus it has

% aux=num2str([1:2,4:10]'/100+.001);
% GYAA=mat2cell(strcat('GYAA',aux(:,3:4)),ones(size(aux,1),1),6)';
% aux=num2str([1:4,6:11]'/100+.001);
% GYRC=mat2cell(strcat('GYRC',aux(:,3:4)),ones(size(aux,1),1),6)';

%Some meta-data:
load ../data/bioData.mat %speeds, ages and Fugl-Meyer
%run ./N1/N19_loadGroupedData.m %This actually load indiv params files and

%If N19 is not run, need to load:
load ../data/HPF30/groupedParams_wMissingParameters.mat

matchSpeedFlag=0;
suffix='Norm2';
% run ./N1A/N19A_assessGroupedBaseKin.m
% run ./N1A/N19B_assessGroupedKinEvolution.m
% run ./N1A/N19B1_assessGroupedKinEvolution.m
% run ./N1A/N19B2_assessGroupedKinEvolution2.m
% run ./N1A/N19B3_assessGroupedKinEvolutionIndividuals.m

% %
  for matchSpeedFlag=0%:1 %Unimplemented
     for subCountFlag=0%0:1 %Unimplemented
         for useLateAdapBase=0:1
             for plotSym=0%:1 %Unimplemented
                run ./N1A/N19D_assessGroupedEMGEvolution.m
             end
         end
     end
  end
