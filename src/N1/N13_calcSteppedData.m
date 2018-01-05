
% 4) With the events, select steps in which events are in the correct
% (expected) order. Report % of thrown samples. Get good steps into a new structure
% -------------Save this new structure as stepped data----------

%Calculate secundary results for assessment

%% Basics
clearvars -except sub

%Load subject raw data & supplemental
%eval(['load ../matData/sub' num2str(sub) 'RAW.mat;']);
matDataDir='../../rawData/Synergies/mat/';
%matDataDir='S:\Shared\Exp0001\raw\matData'; %This works in main lab PC 2
%matDataDir='Z:\Shared\Exp0001\raw\matData'; %This works in lab laptop
eval(['load ' matDataDir '/sub' num2str(sub) 'Processed.mat;']);
eval(['expData=sub' num2str(sub) 'Processed;']);

%% Split into strides:
stridedExp=splitIntoStrides(expData);
%% Normalize strides (not necessary)
%stridedNormalizedExp=stridedExp.timeNormalize(256);

        
%% Save
    eval(['sub' num2str(sub) 'Strided = stridedExp;']);
    %eval(['sub' num2str(sub) 'NormStrided = stridedNormalizedExp;']);
    eval(['save ' matDataDir '/sub' num2str(sub) 'Strided.mat sub' num2str(sub) 'Strided -v7.3']);
    %eval(['save ' matDataDir '/sub' num2str(sub) 'NormStrided.mat sub' num2str(sub) 'NormStrided']);
    loadedSub=sub;