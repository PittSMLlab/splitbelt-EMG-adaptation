% %%
% close all
% clearvars
% timeDuration=30; %In seconds. ~1.2 sec = 1 stride
% earlyOrLate=[0,0,1,0,1,0,1]; %1=late, 0=early
% name={'Sh','eB','lB','eA','lA','eP','lP'};
% plots={'','Unbiased','d/dt','Alt Aligned'};
% condName={'Short','TM Base','TM Base','Adap','Adap','Wash','Wash'};
% subNames=num2str(10000+[1:16]');
% subNames(:,1)='C';
% dataSetNames={'midHIP','COP','COPmix'};
% 
% %% Load relevant data & store in appropriate structure
% for sIdx=1:length(subNames)
%     % Load
%     load(['/Datos/Documentos/PhD/lab/rawData/synergies/mat/' subNames(sIdx,:) '.mat'])  
%     % Define trials:
%     trials=nan(size(condName));
%     for jj=1:length(condName) %Conditions
%         allTrials=expData.metaData.getTrialsInCondition(condName{jj});
%         ii=earlyOrLate(jj);
%             if ii==0
%                 trials(jj)= allTrials(1);
%             else
%                 trials(jj)=allTrials(end);
%             end
% 
%     end
%     
%     %Get fast leg:
%     S=expData.getRefLeg;
%     F=expData.getNonRefLeg;
%     alignLabels={[F 'HS'],[S 'TO'],[S 'HS'],[F 'TO']};
%     
% for i=1:length(trials)
%     trial=trials(i);
%     if earlyOrLate(i)==1 %LAte data
%         t2=expData.data{trial}.markerData.Time(end); 
%         t1=t2-timeDuration-10; %Extra 5 seconds to discard at beginning and end
%     else %Early data
%         t1=expData.data{trial}.markerData.Time(1); 
%         if expData.data{trial}.markerData.timeRange>timeDuration
%             t2=t1+timeDuration+10;
%         else
%             t2=t1+expData.data{trial}.markerData.timeRange-.02; %Try to get 'timeDuration' secs, but if not, take what is available [needed for short-split condition]
%         end
%     end
%     t2=t2+1e-4;
%     
%     %------ Get data
%     allMarkers=expData.data{trial}.markerData.split(t1,t2).substituteNaNs;
%     Ts=allMarkers.sampPeriod;
%     T0=allMarkers.Time(1);
% 
%     %Events
%     events=expData.data{trial}.gaitEvents.getDataAsTS(alignLabels).split(t1,t2).resample(Ts,T0);
% 
%     %Ankle
%     ANK=allMarkers.getDataAsOTS({[F 'ANK'],[S 'ANK']}).renameLabels({[F 'ANK'],[S 'ANK']},{['FANK'],['SANK']});
% 
%     %HIP
%     FHIP=allMarkers.getDataAsOTS({[F 'HIP']}).renameLabels([F 'HIP'],['FHIP']);
%     SHIP=allMarkers.getDataAsOTS({[S 'HIP']}).renameLabels([S 'HIP'],['SHIP']);
%     midHip=((FHIP+SHIP)*.5);
%     midHip=midHip.renameLabels(midHip.getLabelPrefix,{'mHIP'});
%     
%     %COP
%     [COP]=expData.data{trial}.computeCOPAlt;
%     COP=COP.split(t1,t2).resample(Ts,T0).renameLabels([F 'COP'],['FCOP']).renameLabels([S 'COP'],['SCOP']);
%     
%     %Some EMG
%     muscList={[F 'MG'],[S 'MG'],[F 'LG'],[S 'LG'],[F 'TA'],[S 'TA']};
%     muscList1={['FMG'],['SMG'],['FLG'],['SLG'],['FTA'],['STA']};
%     [EMG]=expData.data{trial}.procEMGData.getDataAsTS(muscList).split(t1,t2).resample(Ts,T0).renameLabels(muscList,muscList1);
%     
%     %Merge data
%     allTS{sIdx,i}=ANK.cat(midHip).cat(COP);%.cat(dRANK).cat(dLANK).cat(dMidHip).cat(dCOP)
%     if F=='L'
%         %Flipping x-axis for consistency
%         allTS{sIdx,i}=allTS{sIdx,i}.flipAxis('x');
%     end
%     allEvents{sIdx,i}=labTimeSeries(events.Data,events.Time(1),events.sampPeriod,{['FHS'],['STO'],['SHS'],['FTO']});
%     allEMG{sIdx,i}=EMG;
% end
% end
% save allTS2.mat allTS allEvents allEMG

%% Load previously computed data, if necessary
if ~exist('allTS','var')
    load allTS.mat
end
%% Find derivatives, get events, compute stance ankle position
clearvars -except all*
alignLabels={['FHS'],['STO'],['SHS'],['FTO']};
emgList={'TA','MG','LG'};
discardStrides=1;
Nstr=5;

for i=1:size(allTS,2)
    for sIdx=1:size(allTS,1)
        thisTS=allTS{sIdx,i};
        thisE=allEvents{sIdx,i};
        thisEMG=allEMG{sIdx,i};

        % Find stance leg:
        eventData=thisE.getDataAsVector(alignLabels);
        Fstance=1-cumsum(eventData(:,4)) +cumsum(eventData(:,1));
        HSevents=eventData(:,1)-eventData(:,3); %1 for FHS, -1 for SHS
        idx=find(HSevents);
        lastHS=zeros(size(HSevents)) ; %This stores the cumulative last non-zero entry in the vector
        for j=1:length(idx)-1 %Can I do this w/o a for loop?
            lastHS(idx(j):idx(j+1)-1)=HSevents(idx(j));
        end
        %stepIdx=full(2*stepIdx - sign(mean(stepIdx))); %=1 FHS to SHS, =-1 SHS to FHS
        stepIdx=lastHS;
        if any(stepIdx>1) || any(stepIdx)<-1 %Two consecutive FHS or SHS
            error('')
            %Should we do stance computation after aligning? It's easier!
        end
        stepIdx=stepIdx(1:size(thisTS.Data,1));
        
        %Normalize EMG
        if i==1
        NN=round([24,76,24,76]*1.2);
        alignEMGmed=thisEMG.align(thisE,alignLabels,NN).median;
        baseMax{sIdx}=max(alignEMGmed.Data,[],1);
        baseMin{sIdx}=min(alignEMGmed.Data,[],1);
        end
        thisEMG.Data=bsxfun(@rdivide,bsxfun(@minus,thisEMG.Data,baseMin{sIdx}),baseMax{sIdx}-baseMin{sIdx});

        % Get derivatives
        thisTS=thisTS.cat(thisTS.lowPassFilter(10).derivate);
        thisEMG=thisEMG.cat(thisEMG.substituteNaNs.lowPassFilter(10).derivate).split(thisEMG.Time(1),thisTS.Time(end)+1e-5);

        % Compute stance ankle, stance COP, stance EMG
        stANK=renameLabels((thisTS.getDataAsOTS({'FANK'}).* (stepIdx==1)) + (thisTS.getDataAsOTS({'SANK'}) .* (stepIdx==-1)),[],{'stANK'});
        stCOP=renameLabels((thisTS.getDataAsOTS({'FCOP'}).* (stepIdx==1)) + (thisTS.getDataAsOTS({'SCOP'}) .* (stepIdx==-1)),[],{'stCOP'});
        dstANK=renameLabels((thisTS.getDataAsOTS({'d/dt FANK'}).* (stepIdx==1)) + (thisTS.getDataAsOTS({'d/dt SANK'}) .* (stepIdx==-1)),[],{'d/dt stANK'});
        dstCOP=renameLabels((thisTS.getDataAsOTS({'d/dt FCOP'}).* (stepIdx==1)) + (thisTS.getDataAsOTS({'d/dt SCOP'}) .* (stepIdx==-1)),[],{'d/dt stCOP'});
        thisTS=thisTS.cat(stANK).cat(stCOP).cat(dstANK).cat(dstCOP);
        for ii=1:length(emgList)
            stEMG=renameLabels((thisEMG.getDataAsTS({['F' emgList{ii}]}).* (stepIdx==1)) + (thisEMG.getDataAsTS({['S' emgList{ii}]}) .* (stepIdx==-1)),[],{['st' emgList{ii}]});
            dstEMG=renameLabels((thisEMG.getDataAsTS({['d/dt F' emgList{ii}]}).* (stepIdx==1)) + (thisEMG.getDataAsTS({['d/dt S' emgList{ii}]}) .* (stepIdx==-1)),[],{['d/dt st' emgList{ii}]});
            thisEMG=thisEMG.cat(stEMG).cat(dstEMG);
        end
        
        %Align data
        NN=round([24,76,24,76]*1.2);
        N=cumsum(NN);
        alignTS=thisTS.align(thisE,alignLabels,NN);
        alignEMG=thisEMG.align(thisE,alignLabels,NN);
        alignTS=alignTS.cat(alignEMG,2);
        %alignTS=alignTS.getPartialStridesAsATS([discardStrides:size(alignTS.Data,3)-discardStrides]); %Throwing away first and last stride
        alignTS=alignTS.getPartialStridesAsATS([discardStrides:Nstr+discardStrides]); %Keeping 5 strides only
        %Eliminate datapoints corresponding to transitions:
        alignTS.Data(1:2,:,:)=NaN;
        alignTS.Data(sum(NN(1:2))+[0:2]-1,:,:)=NaN;
        
        %Save subject
        if sIdx==1 %First sub
            medianTS{i}=alignTS.median;
            labelOrder=alignTS.labels;
        else
            medianTS{i}=medianTS{i}.cat(alignTS.getPartialDataAsATS(labelOrder).median);
        end
    end
end


%% Do some plotting:
close all
bounds=[0 0];
colorScheme
name={'Sh','eB','B','eA','lA','eP','lP'};
name=name(end-length(medianTS)+1:end); %This makes it work with both allTS and allTS2
plots={'','Unbiased','Change','Sym'};
condName={'TM Base','Adap','Wash'};
dataSetNames={'mHIP','COP','stCOP','EMG'};
ratePrefix={'','rate'};
ratePrefix1={'','d/dt'};
dP=[];
for rate=1:2 %Variables themselves & derivatives
for dataSets=1:4
    if dataSets<4
        labels=strcat(dataSetNames{dataSets},{'x','y','z'});
        labels2=strcat('stANK',{'x','y','z'});
    else
        labels={'stTA','stMG','stLG'};
        labels2={};
    end
    if rate==2
        labels=strcat('d/dt',{' '},labels);
        if ~isempty(labels2)
            labels2=strcat('d/dt',{' '},labels2);
        end
    end
    dB=medianTS{end-4}.getPartialDataAsATS(labels); %Late baseline
    if ~isempty(labels2) %EMG data
        dB=dB- (medianTS{end-4}.getPartialDataAsATS(labels2));
    end
    for i=1:length(medianTS)
        d1=medianTS{i}.getPartialDataAsATS(labels);
        if ~isempty(labels2) %EMG data
            d1=d1- (medianTS{i}.getPartialDataAsATS(labels2));
        end
        
        mf=0; %PLot mean and ste
        %mf=1; %PLot median and iqr-based ste        
        if i==1
            fh=figure();
            a=4;
            b=length(labels);
            ph=tight_subplot(b,a,[.02 .02],[.05 .05], [.05 .05]); %External function
            ph=reshape(ph,a,b);
            set(fh,'Name',dataSetNames{dataSets})
        end
        d1.plot(fh,ph(1,:),colorConds{i},[],0,[],bounds,mf);
        
        d2=d1-dB; %Unbiased
        d2.plot(fh,ph(2,:),colorConds{i},[],0,[],bounds,mf);
        
        if i==1
            dP=dB; %Need to define dP for baseline, even if it makes no sense.
        end
        d3=d1-dP;
        dP=d1; %Storing dP for next condition
        d3.plot(fh,ph(3,:),colorConds{i},[],0,[],bounds,mf);
        
        if dataSets<4
            d1FlippedX=d1;
            d1FlippedX.Data(:,1,:)=-d1FlippedX.Data(:,1,:);
            d4=d1-d1FlippedX.fftshift;
        else
            d4=d1-d1.fftshift;
        end
        d4.Data=d4.Data(1:size(d4.Data,1)/2,:,:);
        d4.plot(fh,ph(4,:),colorConds{i},[],0,[],bounds,mf);
        
        
        for jj=1:length(ph(:))
            ll=findobj(ph(jj),'Type','line');
            ll(1).DisplayName=name{i};
            subplot(ph(jj))
            ls=legend(ll);
            set(ls,'Location','Best')
            axis tight
            set(gca,'YTickMode','auto','YTickLabelMode','auto')
            if jj<=a
                title([plots{jj} ' ' ratePrefix{rate}])
            end
            ylabel('')
            if mod(jj-1,a)==0
                ylabel(labels{1+(jj-1)/a})
            end
            if jj<=(b-1)*a
                set(gca,'XTickLabel',{})
            elseif i==5
                aa=axis;
                text(N(1),aa(3),'FAST ST.','FontWeight','bold','Clipping','off','FontSize',16)
                text(N(3),aa(3),'SLOW ST.','FontWeight','bold','Clipping','off','FontSize',16)
            end
        end
    end
    saveDir='./';
    saveFig(fh,saveDir,[ratePrefix{rate} dataSetNames{dataSets} '2ANK_all_' num2str(Nstr) 'strides'])
end
end