%make everything pretty
saveDir='../../fig/all/emg/';
for i=1:12
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
        case 6
            name='allChangesEMGswSlows_uphill_noP07.fig';
            desiredPlotDescription={'(p)','Early','adap'};
            desiredPlotDescription2={'(c)','Early','adap'};
            plotTitles={'Flat','Uphill' };
            %desiredPlotDescription2=[];
            saveName='prettyEarlyAdap_PvsC_uphill';
        case 7
            name='allChangesEMGswSlows_uphill_noP07.fig';
            desiredPlotDescription={'(p)','Early','post'};
            desiredPlotDescription2={'(c)','Early','post'};
            plotTitles={'Flat','Uphill' };
            %desiredPlotDescription2=[];
            saveName='prettyEarlyPost_PvsC_uphill';
       case 8
            name='allChangesEMGswSlows_noP07_early7_shortSplit_altBase.fig';
            desiredPlotDescription={'(p)','Early','base'};
            desiredPlotDescription2={'(c)','Early','base'};
            plotTitles={'Patients','Controls' };
            %desiredPlotDescription2=[];
            saveName='prettyEarlyBase_PvsC_afterShortSplit';
       case 12
            name='allChangesEMGswSlows_noP07_early7_shortSplit.fig';
            desiredPlotDescription={'(p)','Early','short'};
            desiredPlotDescription2={'(c)','Early','short'};
            plotTitles={'Patients','Controls' };
            %desiredPlotDescription2=[];
            saveName='prettyEarlyShort_PvsC';
        case 9
            name='allChangesEMGswSlows_speedMatched_noP07.fig';
            desiredPlotDescription={'(p)','Late','adap'};
            desiredPlotDescription2={'(c)','Late','adap'};
            plotTitles={'Patients','Controls' };
            %desiredPlotDescription2=[];
            saveName='prettyLateAdap_PvsC_speedMatched';
        case 10
            name='allChangesEMGswSlows_speedMatched_noP07.fig';
            desiredPlotDescription={'(p)','Early','adap'};
            desiredPlotDescription2={'(c)','Early','adap'};
            plotTitles={'Patients','Controls' };
            %desiredPlotDescription2=[];
            saveName='prettyEarlyAdap_PvsC_speedMatched';
        case 11
            name='allChangesEMGswSlows_speedMatched_noP07.fig';
            desiredPlotDescription={'(p)','Early','post'};
            desiredPlotDescription2={'(c)','Early','post'};
            plotTitles={'Patients','Controls' };
            %desiredPlotDescription2=[];
            saveName='prettyEarlyPost_PvsC_speedMatched';
    end
    makeN19DPrettyAgain_execute
    saveFig(newFig,saveDir,saveName,0)
end