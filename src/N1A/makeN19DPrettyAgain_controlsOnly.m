%make everything pretty
saveDir='../../fig/all/emg/';
for i=1:6
    switch i
        case 1
            name='allChangesEMGswSlows_noP07_lateAdapBase.fig';
            desiredPlotDescription={'(c)','Early','post'};
            desiredPlotDescription2=[];
            plotTitles={'Controls' };
            saveName='prettyEarlyPost_C_WRTLateAdapt';
        case 2
            name='allChangesEMGswSlows_noP07.fig';
            desiredPlotDescription={'(c)','Early','post'};
            desiredPlotDescription2=[];
            plotTitles={'Controls' };
            saveName='prettyEarlyPost_C';
        case 3
            name='allChangesEMGswSlows_noP07.fig';
            desiredPlotDescription={'(c)','Early','adap'};
            desiredPlotDescription2=[];
            plotTitles={'Controls' };
            saveName='prettyEarlyAdap_C';
        case 4
            name='allChangesEMGswSlows_noP07.fig';
            desiredPlotDescription={'(c)','Late','adap'};
            desiredPlotDescription2=[];
            plotTitles={'Controls' };
            saveName='prettyLateAdap_C';
       case 5
            name='allChangesEMGswSlows_noP07_early7_shortSplit_altBase.fig';
            desiredPlotDescription={'(c)','Early','base'};
            desiredPlotDescription2=[];
            plotTitles={'Controls' };
            saveName='prettyEarlyBase_C_afterShortSplit';
       case 6
            name='allChangesEMGswSlows_noP07_early7_shortSplit.fig';
            desiredPlotDescription={'(c)','Early','short'};
            desiredPlotDescription2=[];
            plotTitles={'Controls' };
            saveName='prettyEarlyShort_C';
        case 7
            name='allChangesEMGswSlowsSym_noP07_lateAdapBase.fig';
            desiredPlotDescription={'(c)','Early','post'};
            desiredPlotDescription2=[];
            plotTitles={'Controls' };
            saveName='prettyEarlyPost_C_WRTLateAdapt_sym';
        case 8
            name='allChangesEMGswSlowsSym_noP07.fig';
            desiredPlotDescription={'(c)','Early','post'};
            desiredPlotDescription2=[];
            plotTitles={'Controls' };
            saveName='prettyEarlyPost_C_sym';
        case 9
            name='allChangesEMGswSlowsSym_noP07.fig';
            desiredPlotDescription={'(c)','Early','adap'};
            desiredPlotDescription2=[];
            plotTitles={'Controls' };
            saveName='prettyEarlyAdap_C_sym';
        case 10
            name='allChangesEMGswSlowsSym_noP07.fig';
            desiredPlotDescription={'(c)','Late','adap'};
            desiredPlotDescription2=[];
            plotTitles={'Controls' };
            saveName='prettyLateAdap_C_sym';
       case 11
            name='allChangesEMGswSlowsSym_noP07_early7_shortSplit_altBase.fig';
            desiredPlotDescription={'(c)','Early','base'};
            desiredPlotDescription2=[];
            plotTitles={'Controls' };
            saveName='prettyEarlyBase_C_afterShortSplit_sym';
       case 12
            name='allChangesEMGswSlowsSym_noP07_early7_shortSplit.fig';
            desiredPlotDescription={'(c)','Early','short'};
            desiredPlotDescription2=[];
            plotTitles={'Controls' };
            saveName='prettyEarlyShort_C_sym';

    end
    makeN19DPrettyAgain_execute
    %saveFig(newFig,saveDir,saveName,0)
    drawnow
    pause
end