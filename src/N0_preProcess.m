%%
strokeNames={'P0001','P0002','P0003','P0004','P0005','P0006','P0007','P0008','P0009','P0010','P0011','P0012','P0013','P0014','P0015','P0016'};
controlNames={'C0001','C0002','C0003','C0004','C0005','C0006','C0007','C0008','C0009','C0010','C0011','C0012','C0013','C0014','C0015','C0016'}; %C0000 is removed because it is not a control for anyone, plus it has

subs=[controlNames strokeNames];
%%
for i=1:length(subs)
    sub=subs{i};
    disp(['Subject ' num2str(sub)])

    %% Computing supplemental data from raw: processed EMG, events, etc.
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

    %% Visualize data
    %load(['../data/' sub 'Params.mat']) %Load if not created in N13
    %Alternative:
    if strcmp(sub(1),'C')
        adaptData=controls.getSubGroup({sub}).adaptData{1};
    else
        adaptData=patients.getSubGroup({sub}).adaptData{1};
    end
    %run ./N1A/N13A_assessData.m
    %run ./N1A/N14A_assessIndividualAdaptation.m
    plotSym=1;
    useLateAdapBase=false;
    run ./N1A/N14D_assessIndividualEMGEvolution.m
    close all
end
