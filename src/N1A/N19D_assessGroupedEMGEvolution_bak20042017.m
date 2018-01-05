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

%patientFastList=strcat('P00',{'01','02','05','08','10','13','15'}); %Patients above .8m/s
patientFastList=strcat('P00',{'01','02','05','08','09','10','13','14','15','16'}); %Patients above .72m/s, which is the group mean. N=10. Mean speed=.88m/s. Mean FM=29.5 (vs 28.8 overall)
controlsSlowList=strcat('C00',{'01','02','04','05','06','07','09','10','12','16'}); %Controls below 1.1m/s (chosen to match pop size), N=10. Mean speed=.9495m/s

patientUphillControlList={'C0001','C0002','C0003','C0004','C0009','C0010','C0011','C0012','C0013','C0014','C0015','C0016'};
patientUphillList_={'P0001','P0002','P0003','P0004','P0009','P0010','P0011','P0012','P0013','P0014','P0015','P0016'}; %patients that did the uphill
patientUphillList=strcat(patientUphillList_,'u'); %patients that did the uphill

%patientFastList=strcat('P00',{'01','02','05','08','09','10','13','14','16'}); %Patients above or at .72m/s,except P15,N=9. Mean speed=.88m/s. Mean FM=29.5 (vs 28.8 overall)
%controlsSlowList=strcat('C00',{'01','02','04','05','06','07','09','10','12'}); %Controls below or at 1.04m/s (chosen to match pop size), N=9. Mean speed=.935m/s


removeP07Flag=1;
if removeP07Flag
    patients=patients.removeSubs({'P0007'});
    controls2=controls.removeSubs({'C0007'});
end
switch matchSpeedFlag
    case 1
        patients2=patients.getSubGroup(patientFastList).removeBadStrides;
        controls2=controls.getSubGroup(controlsSlowList).removeBadStrides;
    case 0
        patients2=patients.removeBadStrides;
        controls2=controls.removeBadStrides;
    case 2
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
%% Colormap:
colorScheme
cc=cell2mat(colorConds');

%% Parameters and conditions to plot
%condList={'TM base', 'Adap', 'Wash'};
%condListExp={'TM base','Adaptation','Washout','TM slow'};
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
end
exemptLast=5;

%% Get EMG data for plots
mOrder={'TA', 'PER', 'SOL', 'MG', 'LG', 'BF', 'SEMB', 'SEMT', 'VM', 'VL', 'RF', 'ADM', 'HIP', 'GLU', 'TFL'};
%mSet='s';
%mSet='t';
%mSet='e';
%mSet='avg';
nMusc=length(mOrder);
labelF={};
labelS={};
for i=1:nMusc
labelF=[labelF controls2.adaptData{1}.data.getLabelsThatMatch(['^f' mOrder{i}  mSet '\d+$'])]; %This needs to be sorted for proper visualization
labelS=[labelS controls2.adaptData{1}.data.getLabelsThatMatch(['^s' mOrder{i}  mSet '\d+$'])]; %This needs to be sorted for proper visualization
%labelF=[labelF controls2.adaptData{1}.data.getLabelsThatMatch(['^f' mOrder{i}  mSet '\d*$'])]; %This needs to be sorted for proper visualization
%labelS=[labelS controls2.adaptData{1}.data.getLabelsThatMatch(['^s' mOrder{i}  mSet '\d*$'])]; %This needs to be sorted for proper visualization
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
if ~shortSplitFlag
    conds={'TM base','Adaptation','Washout','TM slow'};
    if matchSpeedFlag==2 %Uphill group doesn't have slow
        conds{4}='base';
    end
    [dataFullC]=controls2.getGroupedData(label,conds,removeBiasFlag,numberOfStrides,exemptFirst,exemptLast);
    [dataFullP]=patients2.getGroupedData(label,conds(1:3),removeBiasFlag,numberOfStrides,exemptFirst,exemptLast);
    [dataFullP2]=patients2.getGroupedData(label,conds(4),removeBiasFlag,[numberOfStrides(1) -35],exemptFirst,exemptLast);
    dataFullP{2}=cat(1,dataFullP{2},cat(2,nan([1,abs(numberOfStrides(2))-35,size(dataFullP2{2},3),size(dataFullP2{2},4)]),dataFullP2{2}));  %Workaround for the fact that we don't have 40 full strides for all patients in TM slow
    dataFullP{1}=cat(1,dataFullP{1},dataFullP2{1});
    clear dataFullP2
else
    conds={'TM base','Adaptation','Washout','Short'};
    [dataFullC]=controls2.getGroupedData(label,conds(1:3),removeBiasFlag,numberOfStrides,exemptFirst,exemptLast);
    [dataFullP]=patients2.removeSubs({'P0011'}).getGroupedData(label,conds(1:3),removeBiasFlag,numberOfStrides,exemptFirst,exemptLast);
    [dataFullP2]=patients2.removeSubs({'P0011'}).getGroupedData(label,conds(4),removeBiasFlag,[numberOfStrides(1) -1],exemptFirst,exemptLast);
    dataFullP{2}=cat(1,dataFullP{2},cat(2,nan([1,abs(numberOfStrides(2))-1,size(dataFullP2{2},3),size(dataFullP2{2},4)]),dataFullP2{2}));  %Workaround for the fact that we don't have 40 full strides for all patients in TM slow
    dataFullP{1}=cat(1,dataFullP{1},dataFullP2{1});
    clear dataFullP2
    [dataFullC2]=controls2.getGroupedData(label,conds(4),removeBiasFlag,[numberOfStrides(1) -1],exemptFirst,exemptLast);
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
%%
%Colormap:
ex1=[.85,0,.1];
ex2=[0,.1,.6];
map=[bsxfun(@plus,ex1,bsxfun(@times,1-ex1,[0:.01:1]'));bsxfun(@plus,ex2,bsxfun(@times,1-ex2,[1:-.01:0]'))];

%FDR:
fdr1=.05;

%% Get data:
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
for plotSym=0:1%%:1;%2 %bilateral activity, symmetry activity, normalized symmetry activity
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
    baseData=organizedData(:,:,:,2,1);
    baseMin=min(baseData,[],2);
    baseMax=max(baseData,[],2);
    organizedData=bsxfun(@rdivide,bsxfun(@minus,organizedData,baseMin),baseMax-baseMin); 
    
    
    if plotSym>0 %For symmetry plots
        if plotSym>1
            organizedData=bsxfun(@rdivide,organizedData,max(organizedData(:,:,:,2,1),[],2)); %Alternative normalization
        end
        M2=15;
        data=(organizedData(:,:,1:M2,:,:)-organizedData(:,:,M2+[1:M2],:,:)); %FAST - SLOW
        dataMean=.5*(organizedData(:,:,1:M2,:,:)+organizedData(:,:,M2+[1:M2],:,:));
        dataBilat=organizedData(:,:,1:M,:,:);    %This will be used for stat testing only, not displayed
        M3=M2;
        lBB=squeeze(nanmedian(dataMean(:,:,:,baseIdx(1),baseIdx(2)),1))'; %Phases x muscles
        lBBB=squeeze(nanmedian(dataMean(:,:,:,2,1),1))'; %Phases x muscles
    elseif plotSym==0 %For bilateral plots
        data=organizedData(:,:,1:M,:,:);
        dataBilat=data; %Meaningless variable, just to avoid having to change the code further
        M3=M;
        %This defines two 'baselines' that are used in the code: one is a
        %reference signal (to subtract from other signals), the other is a
        %normalization signal to use for muscle equalization.
        lBB=squeeze(nanmedian(data(:,:,:,baseIdx(1),baseIdx(2)),1))'; %GROUP baseline to subtract activity from
        lBBB=squeeze(nanmedian(data(:,:,:,2,1),1))'; %GROUP baseline to normalize coloring to
    end
    %Normalize data for the median of the group:
    if size(lBBB,2)>1
        baseMin=min(lBBB,[],2); %Baseline min: one value for each muscle
        baseMax=max(lBBB,[],2); %Baseline max
    else %No normalization: this works when the parameter is just 'sXXavg'
       baseMin=0;
       baseMax=lBBB; %Baseline max
    end
    activityB=lBB'>repmat(baseMin+.2*(baseMax-baseMin),1,N)'; %Determining 'active' muscle/phases for the MEDIAN of the group

    %This normalization was commented on 20/4/2017. I think it changes
    %nothing, since we are subtracting and dividing by the same quantity
    %for all subjects, which could change colors slightly [values are close
    %to 0 for subtraction and 1 for norm] but stats should remain
    %unchanged.
    %Empirically I do observe very minor changes in stat results. Not sure
    %why.
%     baseMin2=reshape(baseMin,1,1,length(baseMax));
%     baseMax2=reshape(baseMax,1,1,length(baseMax));
%     if plotSym>0
%         baseMin2=0;
%         dataMean=bsxfun(@rdivide,bsxfun(@minus,dataMean,baseMin2),baseMax2-baseMin2);
%         dataBilat=bsxfun(@rdivide,bsxfun(@minus,dataBilat,baseMin2),cat(3,baseMax2,baseMax2)-baseMin2); 
%     else
%         dataBilat=bsxfun(@rdivide,bsxfun(@minus,dataBilat,baseMin2),baseMax2-baseMin2); 
%     end
%     data=bsxfun(@rdivide,bsxfun(@minus,data,baseMin2),baseMax2-baseMin2);    
      
    %Get baseline data & compute activity during base:
    baseData=data(:,:,:,baseIdx(1),baseIdx(2)); %Baseline to subtract activity from

    for j=[1:7] %% Each plot we are going to show
        %% Plot
        subplot(2,7,7*(i-1)+j)
        hold on
        labs=label(1:N:end);
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

        %Compute activity for each phase/muscle
        if plotSym>0 %For symmetry data we do something slightly different, but it is stil median over subjects:
            lRef=squeeze(nanmedian(dataMean(:,:,:,idx(1),idx(2)),1))'; %Phases x muscles
            %lA=squeeze(nanmedian(data(:,:,:,idx(1),idx(2)),1))'; %Phases x muscles
        else
            lRef=squeeze(nanmedian(data(:,:,:,idx(1),idx(2)),1))'; %Phases x muscles
        end
        %activity=lB'>repmat(baseMin+.2*(baseMax-baseMin),1,N)';
        activity=lRef'>.2;

        %Get content to plot:
        if j==1 %For first plot: RAW
            tempP=get(gca,'Position');
            %colorbar
            set(gca,'Position',tempP -[.1 0 0 0])
            baseData2=zeros(size(baseData));
%              if plotSym==0 %Not symmetry plot: subtract min of each muscle, and normalize to [0 1] range.
%                 %eC=bsxfun(@rdivide,bsxfun(@minus,lB,baseMin),baseMax-baseMin);
%                 eC=lB;
%                 ca=1 * [-1,1];
%             else %Symmetry plot: dividing median difference data by median mean data.
%                 %eC=bsxfun(@rdivide,lA,baseMax);
%                 eC=lA;
%                 ca=1 * [-1,1];
%             end
        else  %All other plots, relative to baseline
            %eC=bsxfun(@rdivide,squeeze(nanmedian(data(:,:,:,idx(1),idx(2))-baseData,1))',baseMax); %Alt normalization
            baseData2=baseData;
        end
        %eC=squeeze(nanmedian(data(:,:,:,idx(1),idx(2))-baseData2,1))';
        eCall=permute(data(:,:,:,idx(1),idx(2))-baseData2,[3,2,1]);
        eC=nanmedian(eCall,3);
        ca=1 * [-1,1];
        if j==7 || j==1
            %tempP=get(gca,'Position');
            colorbar
            %set(gca,'Position',tempP)
        end

        %Some aesthetic changes before plotting for bilateral data:
        if plotSym==0
            labs=cellfun(@(x) x(1:end-2),label(1:N:end),'UniformOutput',false);
            eC2=[eC(1:15,:);zeros(1,size(eC,2));eC(16:end,:)]; %Insert a gap between f and s sides
            eC2all=cat(1,cat(1,eCall(1:15,:,:),zeros(1,size(eC,2),size(eCall,3))),eCall(16:end,:,:));
        else
            labs=cellfun(@(x) x(2:end-2),label(1:N:end),'UniformOutput',false);
            eC2=eC;
            eC2all=eCall;
        end

        %Do the plot:
        %imagesc(eC2);
        %To do scaled plotting (to better represent DS vs stance duration)
        x=[0,.5,1:5,5.5,6:10]/10;
        if size(eC,2)==6
            x=x(1:2:end);
        end
        y=[0:size(eC2,1)];
        %x=x*size(eC2,2);
        subCountFlag=true;
        subCountFlag=false;
        if subCountFlag
           eC2=nanmean(2*sign(eC2all)-1,3); %Generating colors just based on signs of effects, not on actual median effect size
           eC2=nanmean((2*sign(eC2all)-1).*abs(eC2all)>.05,3); %Adding a 5% threshold for sign-counting, to reduce noise
        end
        surf(x,y,[[eC2 eC2(:,1)]; [eC2(1,:) eC2(1,1)]],'EdgeColor','none')
        view(2)

    %% Some stats
    p=nan(M3,N);pp=nan(M3,N);pS=nan(M3,N);ppS=nan(M3,N);
    pF=nan(M3,N);ppF=nan(M3,N);tF=nan(M3,N);tS=nan(M3,N);

    if j==7 && ~shortSplitFlag%For late post, I arbitrarily set all muscles to 'active' to test for differences to baseline in ALL of them
        activity=true(size(lRef')); %For late post we test ALL phases
    end

     for k=1:M3
        for k2=1:N
            thisData=squeeze(data(:,k2,k,idx(1),idx(2),:))';
            if plotSym>0
            thisDataS=squeeze(dataBilat(:,k2,k,idx(1),idx(2),:))';
            thisDataF=squeeze(dataBilat(:,k2,k+M3,idx(1),idx(2),:))';
            end
            if j~=1
                bbData=squeeze(data(:,k2,k,baseIdx(1),baseIdx(2),:))';
                if plotSym>0
                    bbDataS=squeeze(dataBilat(:,k2,k,2,2,:))';
                    bbDataF=squeeze(dataBilat(:,k2,k+M3,2,2,:))';
                end
            else
                bbData=zeros(size(thisData)); %Base is compared to 0 only
            end
        [p(k,k2),t,s]=signrank(median(thisData,1)' ,median(bbData,1)','method','exact'); %Paired sign-rank test, median over strides
        %[p(k),t,s]=signrank(median(thisData,1)'-median(baseData,1)','method','exact'); %This should be same as
        %above, but gives an error
        [~,pp(k,k2),t,s]=ttest(median(thisData,1)' - median(bbData,1)'); %Paired t-test
        if j~=1 && plotSym>0
            [pS(k,k2),~,s]=signrank(median(thisDataS,1)' ,median(bbDataS,1)','method','exact');
            tS(k,k2)=median(median(thisDataS,1)' -median(bbDataS,1)');
            [~,ppS(k,k2),t,s]=ttest(median(thisDataS,1)' - median(bbDataS,1)'); %Paired t-test
            [pF(k,k2),~,s]=signrank(median(thisDataF,1)' ,median(bbDataF,1)','method','exact');
            tF(k,k2)=median(median(thisDataF,1)' -median(bbDataF,1)');
            [~,ppF(k,k2),t,s]=ttest(median(thisDataF,1)' - median(bbDataF,1)'); %Paired t-test
        end
        end
    end
    p=p';p=p(:);pp=pp';pp=pp(:);pS=pS';pS=pS(:);
    ppS=ppS';ppS=ppS(:);pF=pF';pF=pF(:);ppF=ppF';ppF=ppF(:);

    %Filtering non-active regions before determining significance (not testing):
    p(~activity(:) & ~activityB(:))=1;pp(~activity(:) & ~activityB(:),:)=1;
    pS(~activity(:) & ~activityB(:))=1;pF(~activity(:) & ~activityB(:),:)=1;
    ppS(~activity(:) & ~activityB(:),:)=1;ppF(~activity(:) & ~activityB(:),:)=1;
    Ntests=sum(activity(:) | activityB(:));

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
        plot3(x(ii)+xx(ii)/2,jj-.5,ones(size(ii)),'o','MarkerFaceColor','k','MarkerEdgeColor','none','MarkerSize',3)
        text(.02,-2,['\alpha=' num2str(pThreshold,3) ', N=' num2str(sum(h)) '/' num2str(Ntests)])

        if j~=1 && plotSym>0
            [hS,pThresholdS,i1S] = BenjaminiHochberg(pS*Ntests/(M3*N),fdr1);
            [hF,pThresholdF,i1F] = BenjaminiHochberg(pF*Ntests/(M3*N),fdr1);
            %[iiS,jjS]=find(reshape(hS ,N,M3) & tS'<0);
            %text(iiS-.1,jjS,' \ ','Color','b','FontWeight','bold')
            %[iiS,jjS]=find(reshape(hS ,N,M3) & tS'>0);
            %text(iiS-.1,jjS,' / ','Color','b','FontWeight','bold')
            %[iiF,jjF]=find(reshape(hF ,N,M3) & tF'<0);
            %text(iiF-.05,jjF,' \ ','Color','r','FontWeight','bold')
            %[iiF,jjF]=find(reshape(hF ,N,M3) & tF'>0);
            %text(iiF-.05,jjF,' / ','Color','r','FontWeight','bold')
        end

    %Additional parsing: activity on S and F sides reported separately
    [~,jj]=find(activity);
    text(.02,-3.5,['fAct=' num2str(sum((jj<=15))) '/' num2str(numel(activity)/2) ', sAct=' num2str(sum((jj>15))) '/' num2str(numel(activity)/2)])
    if j==1 && plotSym==0 %RAW BASELINE data
        %additional testing: activity for individual subjects
        lBAll=squeeze((data(:,:,:,idx(1),idx(2)))); %Subjects x  muscles x phases
        baseMinAll=min(lBAll,[],2); %Baseline min: one value for each muscle
        baseMaxAll=max(lBAll,[],2); %Baseline max
        activityAll =bsxfun(@gt,lBAll,baseMinAll+.2*(baseMaxAll-baseMinAll));
        activityAllCount=squeeze(sum(activityAll,1)); %Muscles x phases
%         for ii=1:size(activityAllCount,1)
%             for jj=1:size(activityAllCount,2)
%                 if activityAllCount(ii,jj)>0
%                     %plot(ii+.3,jj-.4,'o','MarkerFaceColor','k','MarkerEdgeColor','none','MarkerSize',sqrt(activityAllCount(ii,jj)))
% %                     if jj>15
% %                         auxj=jj+1;
% %                     else
% %                         auxj=jj;
% %                     end
%                     %text(ii,auxj-.2,num2str(activityAllCount(ii,jj)),'Color','k','fontsize',5)
%                 end
%             end
%         end

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
    [ii,jj]=find(activityB | activity);
    jj(jj>15)=jj(jj>15)+1;
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
if earlyStridesFlag==1
    saveName=[saveName '_early' num2str(numberOfStrides(1))];
end
if shortSplitFlag
    saveName=[saveName '_shortSplit'];
end
if exist('useLateAdapBase','var') && useLateAdapBase
    if ~shortSplitFlag
        saveName=[saveName '_lateAdapBase'];
    else
        saveName=[saveName '_altBase'];
    end
end
%saveFig(f1,dirStr,[saveName]);

end
