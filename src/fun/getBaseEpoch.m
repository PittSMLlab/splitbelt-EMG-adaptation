function baseEp=getBaseEpoch()
ep=getEpochs();
baseEp=ep(strcmp(ep.Properties.ObsNames,'Base'),:);
end