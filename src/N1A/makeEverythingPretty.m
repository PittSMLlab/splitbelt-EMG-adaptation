%make everything pretty
saveDir='../../fig/all/emg/';
for i=5%1:4
    switch i
        case 1
            name='allChangesEMGswSlows_noP07_lateAdapBase.fig';
            desiredPlotDescription={'(p)','Early','post'};
            desiredPlotDescription2={'(c)','Early','post'};
            %desiredPlotDescription2=[];
            plotTitles={'Patients','Controls' };
            saveName='prettyEarlyPost_PvsC_noP07_WRTLateAdapt';
        case 2
            name='allChangesEMGswSlows_noP07.fig';
            desiredPlotDescription={'(p)','Early','post'};
            desiredPlotDescription2={'(c)','Early','post'};
            %desiredPlotDescription2=[];
             plotTitles={'Patients','Controls' };
            saveName='prettyEarlyPost_PvsC_noP07';
        case 3
            name='allChangesEMGswSlows_noP07.fig';
            desiredPlotDescription={'(p)','Early','adap'};
            desiredPlotDescription2={'(c)','Early','adap'};
            %desiredPlotDescription2=[];
             plotTitles={'Patients','Controls' };
            saveName='prettyEarlyAdap_PvsC_noP07';
        case 4
            name='allChangesEMGswSlows_noP07.fig';
            desiredPlotDescription={'(p)','Late','adap'};
            desiredPlotDescription2={'(c)','Late','adap'};
            %desiredPlotDescription2=[];
             plotTitles={'Patients','Controls' };
            saveName='prettyLateAdap_PvsC_noP07';
        case 5
            name='allChangesEMGswSlows_uphill_noP07.fig';
            desiredPlotDescription={'(p)','Late','adap'};
            desiredPlotDescription2={'(c)','Late','adap'};
            plotTitles={'Flat','Uphill' };
            %desiredPlotDescription2=[];
            saveName='prettyLateAdap_PvsC_uphill';
    end
    makeN19DPrettyAgain
    saveFig(newFig,saveDir,saveName,0)
end