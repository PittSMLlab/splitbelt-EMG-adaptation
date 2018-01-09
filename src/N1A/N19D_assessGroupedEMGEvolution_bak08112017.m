%% Assuming that the variables groups() exists (From N19_loadGroupedData)

%% Directory to save figs
figDir='../../fig';
dirStr=[figDir '/all/emg/'];
if ~exist(dirStr,'dir')
    mkdir(dirStr);
end

%%
matDataDir='../../paramData/';
loadName=[matDataDir 'groupedParams'];
loadName=[loadName '_wMissingParameters']; %Never remove missing for this script
if (~exist('patients','var') || ~isa('patients','groupAdaptationData')) || (~exist('controls','var') || ~isa('controls','groupAdaptationData'))
    load(loadName)
    load([loadName 'Unbiased'])
end
patientFastList=strcat('P00',{'01','02','05','08','09','10','13','14','15','16'}); %Patients above .72m/s, which is the group mean. N=10. Mean speed=.88m/s. Mean FM=29.5 (vs 28.8 overall)
controlsSlowList=strcat('C00',{'01','02','04','05','06','07','09','10','12','16'}); %Controls below 1.1m/s (chosen to match pop size), N=10. Mean speed=.9495m/s
patientUphillControlList={'C0001','C0002','C0003','C0004','C0009','C0010','C0011','C0012','C0013','C0014','C0015','C0016'};
patientUphillList_={'P0001','P0002','P0003','P0004','P0009','P0010','P0011','P0012','P0013','P0014','P0015','P0016'}; %patients that did the uphill
patientUphillList=strcat(patientUphillList_,'u'); %patients that did the uphill

removeP07Flag=1;
removeP07Flag=0;
if removeP07Flag
    patients=patients.removeSubs({'P0007'});
    controls2=controls.removeSubs({'C0007'});
end
switch matchSpeedFlag
    case 1 %Speed matched groups
        patients2=patients.getSubGroup(patientFastList).removeBadStrides;
        controls2=controls.getSubGroup(controlsSlowList).removeBadStrides;
    case 0 %Full groups
        patients2=patients.removeBadStrides;
        controls2=controls.removeBadStrides;
    case 2 %Uphill-matched groups (not all P's did uphill)
        if (~exist('patientsUp','var') || ~isa('patientsUp','groupAdaptationData'))
            loadName=[loadName '_wUphill']; 
            load(loadName)
            load([loadName 'Unbiased'])
        end
        patientsUp.ID{6}='P0010';
        patientsUp.ID=strcat(patientsUp.ID,'u');
        oldL=patientsUp.adaptData{5}.data.getLabelsThatMatch('SAR');
        newL=regexprep(oldL,'SAR','HIP');
        patientsUp.adaptData{5}=patientsUp.adaptData{5}.renameParams(oldL,newL);
        patients2=patients.getSubGroup(patientUphillList_).removeBadStrides;
        controls2=patientsUp.getSubGroup(patientUphillList).removeBadStrides;
end
%% 
figuresColorMap
cc=condColors;
%Colormap:
ex1=[.85,0,.1];
ex2=[0,.1,.6];
map=[bsxfun(@plus,ex1,bsxfun(@times,1-ex1,[0:.01:1]'));bsxfun(@plus,ex2,bsxfun(@times,1-ex2,[1:-.01:0]'))];

map2=[.3:.01:1]'*ones(1,3);
%FDR:
fdr1=.05;

%% Parameters and conditions to plot
removeBiasFlag=0;
exemptFirst=5;
if ~exist('shortSplitFlag','var')
    shortSplitFlag=0;
end
if shortSplitFlag
    earlyStridesFlag=1; %Mandated for shortsplit plotting
end
switch earlyStridesFlag
    case 0
        numberOfStrides=[20 -40];
    case 1
        numberOfStrides=[7 -40];
        exemptFirst=1;
    case 2
        exemptFirst=5;
        numberOfStrides=[10 -40];
end
exemptLast=5;

%% Get EMG data for plots
mOrder={'TA', 'PER', 'SOL', 'LG', 'MG', 'BF', 'SEMB', 'SEMT', 'VM', 'VL', 'RF', 'HIP', 'ADM', 'TFL', 'GLU'};
nMusc=length(mOrder);
labelF={};
labelS={};
for i=1:nMusc
    labelF=[labelF controls2.adaptData{1}.data.getLabelsThatMatch(['^RAWf' mOrder{i} 'abs' mSet '\d+$'])]; %This needs to be sorted for proper visualization
    labelS=[labelS controls2.adaptData{1}.data.getLabelsThatMatch(['^RAWs' mOrder{i} 'abs' mSet '\d+$'])]; %This needs to be sorted for proper visualization
end
N=size(labelF,1);
%sort to change phase order:
if mod(N,2)==0
    labelF=labelF([N/2+1:N, 1:N/2],:);
end
labelF=labelF(:);
%sort to change muscle order:
labelS=labelS(:);
label=[labelF; labelS];

%Removing bad strides for visualization and averaging:
controls2=controls2.markBadWhenMissingAny(label).removeBadStrides;
patients2=patients2.markBadWhenMissingAny(label).removeBadStrides;

%conds={'TM base','Adaptation',{'washout','post'}};
padWithNaNFlag=true;
if ~shortSplitFlag
    conds={'TM base','Adaptation','Washout','TM slow'};
    if matchSpeedFlag==2 %Uphill group doesn't have slow
        conds{4}='base';
    end
    [dataFullC]=controls2.getGroupedData(label,conds,removeBiasFlag,numberOfStrides,exemptFirst,exemptLast,padWithNaNFlag);
    [dataFullP]=patients2.getGroupedData(label,conds(1:3),removeBiasFlag,numberOfStrides,exemptFirst,exemptLast,padWithNaNFlag);
    [dataFullP2]=patients2.getGroupedData(label,conds(4),removeBiasFlag,[numberOfStrides(1) -35],exemptFirst,exemptLast,padWithNaNFlag);
    dataFullP{2}=cat(1,dataFullP{2},cat(2,nan([1,abs(numberOfStrides(2))-35,size(dataFullP2{2},3),size(dataFullP2{2},4)]),dataFullP2{2}));  %Workaround for the fact that we don't have 40 full strides for all patients in TM slow
    dataFullP{1}=cat(1,dataFullP{1},dataFullP2{1});
    clear dataFullP2
else
    conds={'TM base','Adaptation','Washout','Short'};
    [dataFullC]=controls2.getGroupedData(label,conds(1:3),removeBiasFlag,numberOfStrides,exemptFirst,exemptLast,padWithNaNFlag);
    [dataFullP]=patients2.removeSubs({'P0011'}).getGroupedData(label,conds(1:3),removeBiasFlag,numberOfStrides,exemptFirst,exemptLast,padWithNaNFlag);
    [dataFullP2]=patients2.removeSubs({'P0011'}).getGroupedData(label,conds(4),removeBiasFlag,[numberOfStrides(1) -1],exemptFirst,exemptLast,padWithNaNFlag);
    dataFullP{2}=cat(1,dataFullP{2},cat(2,nan([1,abs(numberOfStrides(2))-1,size(dataFullP2{2},3),size(dataFullP2{2},4)]),dataFullP2{2}));  %Workaround for the fact that we don't have 40 full strides for all patients in TM slow
    dataFullP{1}=cat(1,dataFullP{1},dataFullP2{1});
    clear dataFullP2
    [dataFullC2]=controls2.getGroupedData(label,conds(4),removeBiasFlag,[numberOfStrides(1) -1],exemptFirst,exemptLast,padWithNaNFlag);
    dataFullC{2}=cat(1,dataFullC{2},cat(2,nan([1,abs(numberOfStrides(2))-1,size(dataFullC2{2},3),size(dataFullC2{2},4)]),dataFullC2{2}));  %Workaround for the fact that we don't have 40 full strides for all patients in TM slow
    dataFullC{1}=cat(1,dataFullC{1},dataFullC2{1});
    clear dataFullC2
end
%For post-adaptation, and post-adaptation only, using data without P15,
%since he was tested at SLOW instead of MID base speed
ii=find(strcmp(patients2.ID,'P0015'));
for i=1:length(numberOfStrides)
    dataFullP{i}(3,:,:,ii)=nan;
end
%[dataFullC]=patients2Uphill_.getGroupedData(label,conds,removeBiasFlag,numberOfStrides,exemptFirst,exemptLast);
%[dataFullP]=groups{3}.getGroupedData(label,conds,removeBiasFlag,numberOfStrides,exemptFirst,exemptLast);

%Data dimension ordering for dataFullC{1} and dataFullP{1}:
%Conditions x strides x (EMGxphases) x subjects
%Cell array indexing corresponds to Early/Late

% Get ordered data:
clear dataFull
dataFull{1}=permute(cat(5,nanmean(dataFullC{1},2),nanmean(dataFullC{2},2)),[4,3,5,1,2]); %Taking the mean over strides so that I can cat Early and Late
dataFull{2}=permute(cat(5,nanmean(dataFullP{1},2),nanmean(dataFullP{2},2)),[4,3,5,1,2]);
dataFull{1}=permute(cat(5,nanmedian(dataFullC{1},2),nanmedian(dataFullC{2},2)),[4,3,5,1,2]); %Taking the median over strides so that I can cat Early and Late
dataFull{2}=permute(cat(5,nanmedian(dataFullP{1},2),nanmedian(dataFullP{2},2)),[4,3,5,1,2]);
%Data dimension ordering for dataFull{i}:
%Subjects x (EMGxphases) x Early/Late x Conditions
%Cell-array indexing represents controls and patients2
g={'controls','patients'};
M=30;

%% Do plots:
%plotSym=0:2 %bilateral activity, symmetry activity, normalized symmetry activity
f1=figure('Name','EMG Activity');
colormap(flipud(map))
if exist('useLateAdapBase','var') && useLateAdapBase
    if ~shortSplitFlag
        baseIdx=[2,2]; %Late adapt base
    else
        baseIdx=[1,4]; %Early short-split base
    end
else
    baseIdx=[2,1]; %True base
end
for i=1:2 %Controls, Patients
    %Sort through the data to get what we care about:
    allData=dataFull{i};
    organizedData=reshape(allData,[size(allData,1),N,M,size(allData,3),size(allData,4)]); %Phases x muscles
    
    %NORMALIZE DATA FOR EACH SUBJECT & MUSCLE TO ITSELF DURING BASELINE:
    scaleDataAll=organizedData(:,:,:,2,1);
    baseMinAll=min(scaleDataAll,[],2);
    baseMaxAll=max(scaleDataAll,[],2);
    organizedData=bsxfun(@rdivide,bsxfun(@minus,organizedData,baseMinAll),baseMaxAll-baseMinAll);   
    
    %Get the data to plot, data to determine if a muscle is active, and bilateral (all) data just in case:
    if plotSym>0 %For symmetry plots
        if plotSym>1
            organizedData=bsxfun(@rdivide,organizedData,max(organizedData(:,:,:,2,1),[],2)); %Alternative normalization
        end
        M2=15;
        M3=M2;
        plotData=(organizedData(:,:,1:M2,:,:)-organizedData(:,:,M2+[1:M2],:,:)); %FAST - SLOW
        activityData=.5*(organizedData(:,:,1:M2,:,:)+organizedData(:,:,M2+[1:M2],:,:)); %Mean of FAST & SLOW
        labs=cellfun(@(x) x(2:end-2),label(1:N:end),'UniformOutput',false); %Remove first and last two chars
    elseif plotSym==0 %For bilateral plots
        plotData=organizedData(:,:,1:M,:,:);
        activityData=plotData;
        M3=M;
        if length(label{1})>8
            labs=cellfun(@(x) x([4:end-5]),label(1:N:end),'UniformOutput',false); %Remove last two chars
        else
        labs=cellfun(@(x) x(1:end-2),label(1:N:end),'UniformOutput',false); %Remove last two chars
        end
    end
    bilatData=organizedData(:,:,1:M,:,:); %This preserves data from both legs, even if we are doing symmetry plots
    
    %This defines two 'baselines' that are used in the code: 
    %1) one is a reference signal (to subtract from other signals)
    %2) the other is a normalization signal to determine activity for the group as a whole
    referencePlotDataAll=plotData(:,:,:,baseIdx(1),baseIdx(2)); %Baseline to subtract activity from
    referenceActivityData=squeeze(nanmedian(activityData(:,:,:,2,1),1))'; %Phases x muscles

    %Compute activity for each phase/muscle on each condition:
    if size(referenceActivityData,2)>1
        baseMinAll=min(referenceActivityData,[],2); %Baseline min: one value for each muscle
        baseMaxAll=max(referenceActivityData,[],2); %Baseline max
    else %No normalization: this works when the parameter is just 'sXXavg'
       baseMinAll=0;
       baseMaxAll=referenceActivityData; %Baseline max
    end
    activityAllConditions=bsxfun(@gt,squeeze(nanmedian(activityData(:,:,:,:,:),1)),(baseMinAll+.2*(baseMaxAll-baseMinAll))');
    referenceActivity=activityAllConditions(:,:,baseIdx(1),baseIdx(2)); %Activity for the 'reference' condition
    clear referenceActivityData activityData

    for j=1:7 %% Each plot we are going to show
        %% Plot
        subplot(2,7,7*(i-1)+j)
        hold on
        switch j %Defines epochs/conditions to be shown per plot
            case 1
                title(['[RAW] Late (' num2str(-numberOfStrides(2)) ') baseline (' g{i}(1) ')'])
                idx=[2,1];
            case 3
                title(['Late (' num2str(-numberOfStrides(2)) ') baseline (' g{i}(1) ')'])
                idx=[2,1];
            case 4
                title(['Early (' num2str(numberOfStrides(1)) ') adap (' g{i}(1) ')'])
                idx=[1,2];
            case 5
                title(['Late (' num2str(-numberOfStrides(2)) ') adap (' g{i}(1) ')'])
                idx=[2,2];
            case 2
                if ~shortSplitFlag
                    title(['Late slow (35) base (' g{i}(1) ')']) %This is forcefully 35 strides!
                    idx=[2,4];
                else
                    title(['Early short exposure (' num2str(numberOfStrides(1)) ') (' g{i}(1) ')']) %This is forcefully 35 strides!
                    idx=[1,4];
                end
            case 6
                title(['Early (' num2str(numberOfStrides(1)) ') post* (' g{i}(1) ')'])
                idx=[1,3];
            case 7
                if ~shortSplitFlag
                    title(['Late (' num2str(-numberOfStrides(2)) ') post* (' g{i}(1) ')'])
                    idx=[2,3];
                else
                    title(['Early (' num2str(numberOfStrides(1)) ') baseline (' g{i}(1) ')'])
                    idx=[1,1];
                end
        end
        activity=activityAllConditions(:,:,idx(1),idx(2));

        %Get content to plot:
        if j==1 %For first plot: RAW
            tempP=get(gca,'Position');
            c=colorbar;
            set(gca,'Position',tempP -[.1 0 0 0])
            baseData=zeros(size(referencePlotDataAll));
        else  %All other plots, relative to baseline
            baseData=referencePlotDataAll;
            if j==7
                tempP=get(gca,'Position');
                c=colorbar;
                set(gca,'Position',tempP)
            end
        end
        eCall=permute(plotData(:,:,:,idx(1),idx(2))-baseData,[3,2,1]);
        ca=1 * [-1,1];

        %Some aesthetic changes before plotting (only affects bilateral data):
        if plotSym==0
            eCall=cat(1,cat(1,eCall(1:15,:,:),zeros(1,size(eCall,2),size(eCall,3))),eCall(16:end,:,:));
        end
        eC=nanmedian(eCall,3);
        if i==1 %Controls
            eCControls{j}=eC;
        end
        
        %To do scaled plotting (to better represent DS vs stance duration)
        x=[0,.5,1:5,5.5,6:10]/10;
        if size(eCall,2)==6
            x=x(1:2:end);
        end
        y=[0:size(eC,1)];
        if subCountFlag==1 %Generating colors just based on signs of effects, not on actual median effect size
            %Counting subjects with effect sign = median sign & at least 10% change
            %Subtracting .5 to make a 50/50 split = white, and scaling to use the full [-1 1] range
           eC=sign(eC).*(nanmean((2*(sign(eCall)==sign(eC))-1).*(abs(eCall)>.1),3)).^2; %This also requires each subj to have at least a 10% change, to reduce noise when being counted
           c.Ticks=[-1 -.8.^2 -.5.^2 0 .5.^2 .8.^2 1];
           c.TickLabels={'Decrease in 100%','90%', '75%','50/50','75%','90%','Increase in 100%'};
           eC=nanmean((sign(eCall)==sign(eCControls{j})).*(abs(eCall)>.05),3); %This also requires each subj to have at least a 10% change, to reduce noise when being counted
           c.Ticks=[0 .25 .5 .75 1];
           c.TickLabels={'0%','25%','50%','75%','100%'};
           %map=map2;
           colormap(flipud(map2))
           ca=[0 1];
        end
        surf(x,y,[[eC eC(:,1)]; [eC(1,:) eC(1,1)]],'EdgeColor','none')
        view(2)

    %% Some stats
    p=nan(M3,N);pp=nan(M3,N);pS=nan(M3,N);ppS=nan(M3,N);
    pF=nan(M3,N);ppF=nan(M3,N);tF=nan(M3,N);tS=nan(M3,N);

    if j==7 && ~shortSplitFlag%For late post, I arbitrarily set all muscles to 'active' to test for differences to baseline in ALL of them
        activity=true(size(activity)); %For late post we test ALL phases
    end
    for k=1:M3
        for k2=1:N
            thisData=squeeze(plotData(:,k2,k,idx(1),idx(2),:))';
%             if plotSym>0
%                 thisDataS=squeeze(bilatData(:,k2,k,idx(1),idx(2),:))';
%                 thisDataF=squeeze(bilatData(:,k2,k+M3,idx(1),idx(2),:))';
%             end
            if j~=1
                bbData=squeeze(plotData(:,k2,k,baseIdx(1),baseIdx(2),:))';
%                 if plotSym>0
%                     bbDataS=squeeze(bilatData(:,k2,k,2,2,:))';
%                     bbDataF=squeeze(bilatData(:,k2,k+M3,2,2,:))';
%                 end
            else
                bbData=zeros(size(thisData)); %Base is compared to 0 only
            end
        [p(k,k2),t,s]=signrank(median(thisData,1)' ,median(bbData,1)','method','exact'); %Paired sign-rank test, median over strides
        %[p(k),t,s]=signrank(median(thisData,1)'-median(baseData,1)','method','exact'); %This should be same as above, but gives an error
        [~,pp(k,k2),t,s]=ttest(median(thisData,1)' - median(bbData,1)'); %Paired t-test
%         if j~=1 && plotSym>0
%             [pS(k,k2),~,s]=signrank(median(thisDataS,1)' ,median(bbDataS,1)','method','exact');
%             tS(k,k2)=median(median(thisDataS,1)' -median(bbDataS,1)');
%             [~,ppS(k,k2),t,s]=ttest(median(thisDataS,1)' - median(bbDataS,1)'); %Paired t-test
%             [pF(k,k2),~,s]=signrank(median(thisDataF,1)' ,median(bbDataF,1)','method','exact');
%             tF(k,k2)=median(median(thisDataF,1)' -median(bbDataF,1)');
%             [~,ppF(k,k2),t,s]=ttest(median(thisDataF,1)' - median(bbDataF,1)'); %Paired t-test
%         end
        end
    end
    p=p';p=p(:);pp=pp';pp=pp(:);pS=pS';pS=pS(:);
    ppS=ppS';ppS=ppS(:);pF=pF';pF=pF(:);ppF=ppF';ppF=ppF(:);

    %Filtering non-active regions before determining significance (not testing):
    p(~activity(:) & ~referenceActivity(:))=1;pp(~activity(:) & ~referenceActivity(:),:)=1;
    pS(~activity(:) & ~referenceActivity(:))=1;pF(~activity(:) & ~referenceActivity(:),:)=1;
    ppS(~activity(:) & ~referenceActivity(:),:)=1;ppF(~activity(:) & ~referenceActivity(:),:)=1;
    Ntests=sum(activity(:) | referenceActivity(:));

    %FDR control through B-H:
        %Function BH:
        [h,pThreshold,i1] = BenjaminiHochberg(p*Ntests/(M3*N),fdr1);
        %Adjusting p-values to account for the fact that I am not testing all 360 variables
        %The elegant way to do it would be to select the values within p
        %that are being tested, and pass only those to BenjaminiHochberg.
        %Then, transform the returned h to be used down-stream.
        [ii,jj]=find(reshape(h ,N,M3));
        jj(jj>15)=jj(jj>15)+1;
        xx=diff(x);
        plot3(x(ii)+xx(ii)/2,jj-.5,2*ones(size(ii)),'o','MarkerFaceColor','k','MarkerEdgeColor','none','MarkerSize',3)
        text(.02,-2,['\alpha=' num2str(pThreshold,3) ', N=' num2str(sum(h)) '/' num2str(Ntests)])

%         if j~=1 && plotSym>0
%             [hS,pThresholdS,i1S] = BenjaminiHochberg(pS*Ntests/(M3*N),fdr1);
%             [hF,pThresholdF,i1F] = BenjaminiHochberg(pF*Ntests/(M3*N),fdr1);
%         end

    %Additional parsing: activity on S and F sides reported separately
    %[~,jj]=find(activity);
    %text(.02,-3.5,['fAct=' num2str(sum((jj<=15))) '/' num2str(numel(activity)/2) ', sAct=' num2str(sum((jj>15))) '/' num2str(numel(activity)/2)])
    if j==1 && plotSym==0 %RAW BASELINE data
        %additional testing: activity for individual subjects
        lBAll=squeeze((plotData(:,:,:,idx(1),idx(2)))); %Subjects x  muscles x phases
        baseMinAll=min(lBAll,[],2); %Baseline min: one value for each muscle
        baseMaxAll=max(lBAll,[],2); %Baseline max
        activityAll =bsxfun(@gt,lBAll,baseMinAll+.2*(baseMaxAll-baseMinAll));
        activityAllCount=squeeze(sum(activityAll,1)); %Muscles x phases

        dd1=sum(sum(activityAll(:,:,1:(M/2)),2),3);
        ft=['fAct=' num2str(round(mean(dd1,1))) '\pm' num2str(round(std(dd1,[],1))) ];%' [' num2str((min(dd1,[],1))) ',' num2str((max(dd1,[],1))) ']'];
        dd2=sum(sum(activityAll(:,:,(M/2+1):M),2),3);
        st=['sAct=' num2str(round(mean(dd2,1))) '\pm' num2str(round(std(dd2,[],1))) ];%' [' num2str((min(dd2,[],1))) ',' num2str((max(dd2,[],1))) ']'];
        if i==1 %Controls
            ddC1=dd1;
            ddC2=dd2;
        else %Patients: do some stats test
            [ppCPf]=ranksum(ddC1 ,dd1,'method','exact');
            [ppCPs]=ranksum(ddC2 ,dd2,'method','exact');
            if ppCPf<.05
                ft=[ft '* p(P vs C)=' num2str(ppCPf,2)];
            end
            if ppCPs<.05
                st=[st '* p(P vs C)=' num2str(ppCPs,2)];
            end
        end
        text(.02,-5,[ft ', ' st])
        [ppPsf]=signrank(dd1 ,dd2,'method','exact');
        if ppPsf<.05
           text(.02,-6.5,['p (s vs f) =' num2str(ppPsf,2)]);
        end
    end

    %Plot activity:
    %[ii,jj]=find(referenceActivity | activity);
    %jj(jj>15)=jj(jj>15)+1;
    %plot(x(ii)+.3,y(jj)+.4,'k.','MarkerSize',1);
    if true%(j==1 || j==4)
        set(gca,'YTick',[1:15 17:(M3+1)]-.5,'YTickLabel',[labs(1:15); labs(16:end)],'XTick',x(1+[0 1 3 4 6]*N/6),'XTickLabel',{'iHS','cTO','cHS','iTO','iHS'})
    else
       set(gca,'YTick',[],'YTickLabel','','XTick',x(1+[0 1 3 4 6]*N/6),'XTickLabel',{'iHS','cTO','cHS','iTO','iHS'})
    end
    axis([0 x(end) 0 y(end)])
    caxis(ca);
    hold off
    end
end

%% Saving
saveName=['allChangesEMG' mSet 'wSlows'];
if plotSym==1
    saveName=[saveName 'Sym'];
elseif plotSym==2
    saveName=[saveName 'Sym_altNorm'];
end
if matchSpeedFlag==1
   saveName=[saveName '_speedMatched']; 
elseif matchSpeedFlag==2
    saveName=[saveName '_uphill'];
end
if removeP07Flag
    saveName=[saveName '_noP07'];
end
%if earlyStridesFlag~=0
    saveName=[saveName '_early' num2str(numberOfStrides(1))];
%end
if shortSplitFlag
    saveName=[saveName '_shortSplit'];
end
if subCountFlag==1
    saveName=[saveName '_subjCount_05pp'];
end
if exist('useLateAdapBase','var') && useLateAdapBase
    if ~shortSplitFlag
        saveName=[saveName '_lateAdapBase'];
    else
        saveName=[saveName '_altBase'];
    end
end
saveFig(f1,dirStr,[saveName]);
