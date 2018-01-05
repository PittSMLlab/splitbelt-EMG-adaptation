%load ../paramData/groupedParams_wMissingParameters.mat
%%
%load ../paramData/bioData.mat
%%
mOrder={'TA', 'PER', 'SOL', 'MG', 'LG', 'BF', 'SEMB', 'SEMT', 'VM', 'VL', 'RF', 'GLU', 'TFL', 'ADM', 'HIP'};
mSet='s';
nMusc=length(mOrder);
labelF={};
labelS={};
for i=1:nMusc
labelF=[labelF controls.adaptData{1}.data.getLabelsThatMatch(['^f' mOrder{i}  mSet '\d+$'])]; %This needs to be sorted for proper visualization
labelS=[labelS controls.adaptData{1}.data.getLabelsThatMatch(['^s' mOrder{i}  mSet '\d+$'])]; %This needs to be sorted for proper visualization
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
%%
clear normProy index
fh=figure;
earlyStrides=20;
earlyStrides2=7;
lateStrides=-40;
for i=1%:2
    switch i
        case 1
            group=controls;
            g='C';
        case 2
            group=patients;
            g='P';
    end

    dd=group.getGroupedData(label,{'TM base'},0,lateStrides,5,5);
    dd1=group.getGroupedData(label,{'Wash'},0,earlyStrides,1,1);
    b=squeeze(nanmean(dd{1}));
    normalizationFactors=reshape(repmat(max(reshape(b,12,30,size(b,2)),[],1),12,1,1),360,size(b,2));
    subtractFactors=reshape(repmat(min(reshape(b,12,30,size(b,2)),[],1),12,1,1),360,size(b,2));
    %subtractFactors=0; %check: this changes nothing
    normalizationFactors=normalizationFactors-subtractFactors;
    b2=(b-subtractFactors)./normalizationFactors;
    p=(squeeze(nanmean(dd1{1}))-subtractFactors)./normalizationFactors;
    dd1=group.getGroupedData(label,{'Adap'},0,earlyStrides,1,1);
    ea=(squeeze(nanmean(dd1{1}))-subtractFactors)./normalizationFactors;
    dd1=group.getGroupedData(label,{'Adap'},0,lateStrides,5,5);
    la=(squeeze(nanmean(dd1{1}))-subtractFactors)./normalizationFactors;
    dd1=group.getGroupedData(label,{'TM base'},0,earlyStrides,1,1);
    eB=(squeeze(nanmean(dd1{1}))-subtractFactors)./normalizationFactors;
try
    dd1=group.getGroupedData(label,{'Short'},0,earlyStrides2,1,1);
    ss=(squeeze(nanmean(dd1{1}))-subtractFactors)./normalizationFactors;
catch
    dd1=group.removeSubs({'P0007','P0011'}).getGroupedData(label,{'Short'},0,earlyStrides2,1,1);
    ss=squeeze(nanmean(dd1{1}));
    ss=([ss(:,1:6) nan(size(ss,1),1) ss(:,7:9) nan(size(ss,1),1) ss(:,10:end)]-subtractFactors)./normalizationFactors;
end

%Compute some vectors of interest:
T2=p-la; %After effects, WRT late adapt: transition 2
T0=eB-ss; %After effects following short-split: transition 0
IR=ea-b2; %Initial response: transition 1
AR=-IR; %Alternative response: means no learning or rapid switching to baseline
IR=IR([181:360,1:180],:); %Flipped initial response
AE=p-b2; %After-effects, WRT baseline
L=la-ea; %Learning
SS=la-b2; %Steady-state, WRT baseline
%IR=AR; %Check

%Normalize vectors:
T1norm=bsxfun(@rdivide,IR,sqrt(sum(IR.^2,1)));
ARnorm=bsxfun(@rdivide,AR,sqrt(sum(AR.^2,1)));
T2norm=bsxfun(@rdivide,T2,sqrt(sum(T2.^2,1)));
T0norm=bsxfun(@rdivide,T0,sqrt(sum(T0.^2,1)));
AEnorm=bsxfun(@rdivide,AE,sqrt(sum(AE.^2,1)));
Lnorm=bsxfun(@rdivide,L,sqrt(sum(L.^2,1)));
SSnorm=bsxfun(@rdivide,SS,sqrt(sum(SS.^2,1)));

normProy{i}=sum(T2norm.*T1norm,1); %Percentage of response aligned with 'learning' vector [actually the cosine of the angle that it forms with that vector]
%Notice we expect this to be lower for patients than controls: because of asymmetry, they can't really react equally with the opposite leg.
%Similarly, for controls this will be <1 just because we have unequal gains on EMG sensors [e.g. we never record RTA with exactly the same fidelity as LTA, even if we equalize channels]
normAltProy{i}=sum(T2norm.*ARnorm,1);
controlProy{i}=sum(T1norm.*ARnorm,1); %Similarity between alt responses

AE1proyNorm{i}=sum(T0norm.*T1norm,1); %Projection onto IR
AE1proyAltNorm{i}=sum(T0norm.*ARnorm,1); %Projection onto IR
controlProy2{i}=sum(T2norm.*T0norm,1); %Similarity between actual responses

proyAE2B{i}=sum(p.*b2,1); %Not strictly a cosine, since neither is norm-alized 
diffAE2B{i}=sum(p-b2,1);

proyAEonSS{i}=sum(AEnorm.*SSnorm,1); %How similar are the after-effects to the steady-state activity

subplot(4,4,1+(i-1)*8)
hold on
 ppp(1)=plot(normProy{i}','DisplayName',[g ' Cosine to flipped IR'],'LineWidth',2);
 ppp(2)=plot(normAltProy{i}','DisplayName',[g ' Cosine to AR']);
 ppp(3)=plot(AE1proyNorm{i},'DisplayName',[g ' Cosine of SE (ae) to IR']);
 ppp(4)=plot(AE1proyAltNorm{i},'DisplayName',[g ' Cosine of SE (ae) to AR']);
 ppp(5)=plot(controlProy{i},'DisplayName',[g ' Cosine of IR to AR']);
 ppp(6)=plot(controlProy2{i},'DisplayName',[g ' Cosine of SE to AE']);
  %ppp(7)=plot(proyAEonSS{i},'DisplayName',[g ' proy AE on LA']);
 set(gca,'XTick',1:length(normProy{1}),'XTickLabel',cellfun(@(x) x(end-1:end),group.ID,'UniformOutput',false),'XTickLabelRotation',90)
 barY=[nanmean(normProy{i}) nanmean(normAltProy{i}) nanmean(AE1proyNorm{i}) nanmean(AE1proyAltNorm{i}) nanmean(controlProy{i}) nanmean(controlProy2{i})];
 for jj=1:6
 bar(16+jj, barY(jj),'FaceColor',ppp(jj).Color,'DisplayName','')
 end
  legend(ppp,'Location','best')
 
 subplot(4,4,2+(i-1)*8) %Correlate after-effects to walk speed
   hold on
  switch i
      case 1
          v=velsC;
      case 2
          v=velsS;
  end
 plot(v,normProy{i},'o','DisplayName',[g ' Cosine to flipped IR'],'LineWidth',2)
 plot(v,normAltProy{i}','o','DisplayName',[g ' Cosine to AR'])
   plot(v,AE1proyNorm{i},'o','DisplayName',[g ' Cosine of SE (ae) to flipped IR'])
  plot(v,AE1proyAltNorm{i},'o','DisplayName',[g ' Cosine of SE (ae) to AR'])
   plot(v,controlProy{i},'o','DisplayName',[g ' Cosine of IR to AR']);
   plot(v,controlProy2{i},'o','DisplayName',[g ' ']);
   xlabel('TM speed (m/s)')

 subplot(4,4,3+(i-1)*8) %Correlate to age
  hold on
  switch i
      case 1
          age=ageC;
      case 2
          age=ageS;
  end
 plot(age,normProy{i},'o','DisplayName',[g ' Cosine to flipped IR'],'LineWidth',2)
 plot(age,normAltProy{i}','o','DisplayName',[g ' Cosine to AR'])
    plot(age,AE1proyNorm{i},'o','DisplayName',[g ' Cosine of SE (ae) to flipped IR'])
  plot(age,AE1proyAltNorm{i},'o','DisplayName',[g ' Cosine of SE (ae) to AR'])
   plot(age,controlProy{i},'o','DisplayName',[g ' Cosine of IR to AR']);
   xlabel('Age')

 subplot(4,4,4+(i-1)*8) % Correlate to FM
 hold on
 if i==2
 plot(FM,normProy{i},'o','DisplayName',[g ' Cosine to flipped IR'],'LineWidth',2)
 plot(FM,normAltProy{i}','o','DisplayName',[g ' Cosine to AR'])
    plot(FM,AE1proyNorm{i},'o','DisplayName',[g ' Cosine of SE (ae) to flipped IR'])
  plot(FM,AE1proyAltNorm{i},'o','DisplayName',[g ' Cosine of SE (ae) to AR'])
   plot(FM,controlProy{i},'o','DisplayName',[g ' Cosine of IR to AR']);
 end
xlabel('FM lower limb')

end
saveFig(fh,'../fig/all/emg/','learnIdx');
proyC=normProy{1}; proyS=normProy{2};
diffBC=diffAE2B{1}; diffBS=diffAE2B{2};
proyBC=proyAE2B{1}; proyBS=proyAE2B{2};
save ../paramData/bioData_wLearnIdx.mat aff ageC ageS controlsNames FM sex strokesNames velsC velsS idxC idxS idxCalt idxSalt proyC proyS diffBC diffBS proyBC proyBS
%Need to add comparisons to other muscle activity, to show that these are
%high values [e.g. show what early adaptation data or late post data would
%generate if we substitute them for early post]

%Need to plot vs. contribution aftereffects
subjs=1;
figure; subplot(1,4,1); hold on; imagesc(reshape(nanmedian(AR(:,subjs),2),12,30)'); axis tight; caxis([-.5 .5]); title('Opp Init Resp'); 
subplot(1,4,2); hold on; imagesc(reshape(nanmedian(IR(:,subjs),2),12,30)'); axis tight; caxis([-.5 .5]); title('Init resp (flipped)'); 
subplot(1,4,3); hold on; imagesc(reshape(nanmedian(T2(:,subjs),2),12,30)'); axis tight; caxis([-.5 .5]); title('eP-lA')
subplot(1,4,4); hold on; imagesc(reshape(nanmedian(T0(:,subjs),2),12,30)'); axis tight; caxis([-.5 .5]); title('eB-ss')