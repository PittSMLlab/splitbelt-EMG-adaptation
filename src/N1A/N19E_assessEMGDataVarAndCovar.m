clearvars
%%
strokes={'P0001','P0002','P0003','P0004','P0005','P0006','P0007','P0008','P0009','P0010','P0011','P0012','P0013','P0014','P0015','P0016'};
healthies={'0003','0004','0008'};
strokesUp={'P0003u','P0004u','P0010u','P0011u','P0013u','P0014u','P0015u','P0016u'};
controls={'C0001','C0002','C0003','C0004','C0005','C0006','C0007','C0008','C0009','C0010','C0011','C0012','C0013','C0014','C0015','C0016'}; 
subs=[strokes controls];
    cc={'TM base','Adaptation','Washout'};
    ccAlt={'TM mid','Adap','TM post'};
    ccAlt2={'','','Post-adap'};
    list={'TA','PER','LG','MG','SOL','BF','SEMT','SEMB','RF','VM','VL','GLU','TFL','ADM','SAR','ILP','HIP'};
    raw=false;
    %raw=true;
    
    rawDataDir='S:\Shared\Exp0001\mat\';%This works in TORRES-PRC
    %rawDataDir='../../../rawData/synergy/mat/'; %This works elsewhere
    
    saveDir=[rawDataDir '../res/all/'];
    %% Loading
for k=1:length(subs)
    % load subject data
    disp(['Loading ' subs{k}])
    load([rawDataDir subs{k} '.mat']);

    % Get relevant timeseries for last trial of each cond

    for i=1:3
        disp(['Getting data for ' cc{i}])
        cidx=expData.metaData.getConditionIdxsFromName(cc{i},0,1);
        if isempty(cidx) || isnan(cidx)
            cidx=expData.metaData.getConditionIdxsFromName(ccAlt{i},0,1);
        end
        if isempty(cidx) || isnan(cidx)
            cidx=expData.metaData.getConditionIdxsFromName(ccAlt2{i},0,1);
        end
        tidx=expData.metaData.trialsInCondition(cidx);
        s{k}=expData.getRefLeg;
        sList=strcat(s{k},list);
        if strcmp(s{k},'R')
            f{k}='L';
        else
            f{k}='R';
        end
        fList=strcat(f{k},list);
        aux=expData.data{tidx{1}(end)}.EMGData;
        t0=max(aux.Time(1),aux.Time(end)-120);
        t1=aux.Time(end);
        if raw
            dts{i,k}=expData.data{tidx{1}(end)}.EMGData.getDataAsTS([sList,fList]).split(t0,t1);
        else
            dts{i,k}=expData.data{tidx{1}(end)}.procEMGData.getDataAsTS([sList,fList]).split(t0,t1);
        end
        ets{i,k}=expData.data{tidx{1}(end)}.gaitEvents.split(t0,t1);

        
        ats{i,k}=dts{i,k}.align(ets{i,k},{'RHS','LTO','LHS','RTO'},[32,96,32,96]); %Aligned version of the last two minutes
        %ats2=dts.align(ets,'RHS',sum([32,96,32,96])); %Alternate aligned version
    end
    clear expData
end

for k=1:length(subs)
    for i=1:3
        t0=max(dts{i,k}.Time(1),dts{i,k}.Time(end)-120);
        t1=dts{i,k}.Time(end);
        dts{i,k}=dts{i,k}.split(t0,t1);
        ets{i,k}=ets{i,k}.split(t0,t1);
    end
end
saveName=[saveDir 'alignedEMG__'];
if raw
    saveName=[saveName 'RAW'];
end
save(saveName,'dts','ats','ets','subs','s','f','-v7.3')
%% Variance decomp for indiv. channels
    v=nan(3,30,2,3,length(subs));
    totalV=nan(30,2,3,length(subs));
    a=nan(30,3,2,length(subs));
    a2=nan(30,3,length(subs));
    aS=nan(15,3,2,length(subs));
    a2S=nan(15,3,length(subs));
    aF=nan(15,3,2,length(subs));
    a2F=nan(15,3,length(subs));
for k=1:length(subs)
    for i=1:3 %Conditions: Base, adap, post
        for j=1:2 %Aligned/unaligned
            switch j 
                case 1 %Not aligned 
                    dd=dts{i,k}.Data;
                case 2 %Aligned
                    dd=ats{i,k}.Data;
            end
            dd=dd(:,:,~any(any(isnan(dd),1),2)); %Remove strides that have NaNs
            avgWave=mean(dd,3); %avgWave=ats{i,k}.mean.Data;
            m=mean(avgWave,1); %ats{i,k}.mean.castAsTS.mean;
            
            % 1st: decompose variance of each channel into mean, avg wave and T2T var
            v(1,:,j,i,k)=m.^2;
            v(2,:,j,i,k)=mean(bsxfun(@minus,avgWave,m).^2,1);
            v(3,:,j,i,k)=sum(sum(bsxfun(@minus,dd,avgWave).^2,1),3)/(size(dd,1)*size(dd,3));
            totalV(:,j,i,k)=sum(sum(dd.^2,1),3)/(size(dd,1)*size(dd,3)); %This should equal sum(v,1);
            %Alt: v=dts{i,k}.energyDecomposition

            % 2nd: take the centered and t2t data and perform PCA

            aux=permute(bsxfun(@minus,dd,m),[2,1,3]);
            [~,~,a(:,i,j,k)]=pca(aux(:,:)','Centered',false,'VariableWeights','variance'); %Full data
            if j==2 %This only makes sense in aligned data
                aux=permute(bsxfun(@minus,dd,avgWave),[2,1,3]);
                %Alt: aux=ats{i,k}.demean.catStrides.Data;
                [~,~,a2(:,i,k)]=pca(aux(:,:)','Centered',false,'VariableWeights','variance');
            end
            
            %3rd: repeat 2nd, but on each leg independently
            aux=permute(bsxfun(@minus,dd,m),[2,1,3]);
            [~,~,aS(:,i,j,k)]=pca(aux(1:15,:)','Centered',false,'VariableWeights','variance'); %Full data
            [~,~,aF(:,i,j,k)]=pca(aux(16:30,:)','Centered',false,'VariableWeights','variance'); %Full data
            if j==2 %This only makes sense in aligned data
                aux=permute(bsxfun(@minus,dd,avgWave),[2,1,3]);
                %Alt: aux=ats{i,k}.demean.catStrides.Data;
                [~,~,a2S(:,i,k)]=pca(aux(1:15,:)','Centered',false,'VariableWeights','variance');
                [~,~,a2F(:,i,k)]=pca(aux(16:30,:)','Centered',false,'VariableWeights','variance');
            end
            
        end
    end
end
saveName=[saveDir  'alignedEMGvars'];
if raw
    saveName=[saveName 'RAW'];
end
save(saveName,'v','totalV','aS','aF','a2','a','a2S','a2F','-v7.3')

%% Covariances calculation
N=30;
if ~raw
       c=nan(N,N,length(subs),3,3);
       t=[];
for data=1:3%T2T, centered, unaligned centered
   for i=1:3      %Cnditions
       for k=1:length(subs)
           switch data
               case 1
                   dd=ats{i,k}.removeStridesWithNaNs.demean.catStrides.equalizeEnergyPerChannel;
               case 2
                   dd=ats{i,k}.removeStridesWithNaNs.catStrides.demean.equalizeEnergyPerChannel;
               case 3
                   dd=dts{i,k}.demean.equalizeEnergyPerChannel;
           end
        c(:,:,k,i,data)=cov(dd.Data);
       end
   end
end
dataNames={'T2T','centered','unaligned centered'};
else

% Maximal correlation calculations (allowing for offsets)
 %Doesn't make sense for others, and needs to be RAW
    c=nan(N,N,length(subs),3,3);
    t=nan(N,N,length(subs),3);
    for i=1:3   %Conditions    
       for k=1:length(subs)
           dd=dts{i,k}.demean.equalizeEnergyPerChannel;

        c(:,:,k,i,1)=cov(dd.Data); %Covariance of RAW data as is
        %Find maximal correlations for ANY pair of muscles
        for j=1:N
            for l=j+1:N
                %cc1=ifft(fft(dd.Data(:,j)).*conj(fft(dd.Data(:,j))))/norm(dd.Data(:,j))^2;
                %cc2=ifft(fft(dd.Data(:,l)).*conj(fft(dd.Data(:,l))))/norm(dd.Data(:,l))^2;
                cc=ifft(fft(dd.Data(:,j)).*conj(fft(dd.Data(:,l))))/(norm(dd.Data(:,j))*norm(dd.Data(:,l)));
                %cc1=conv((dd.Data(:,j)),flipud((dd.Data(:,j))))/norm(dd.Data(:,j))^2;
                %cc2=conv((dd.Data(:,l)),flipud((dd.Data(:,l))))/norm(dd.Data(:,l))^2;
                %cc=conv((dd.Data(:,j)),flipud((dd.Data(:,l))))/(norm(dd.Data(:,j))*norm(dd.Data(:,l)));
                %figure;hold on; plot(cc1); plot(cc); plot(cc2);
                %pause
                [c(j,l,k,i,2),t(j,l,k,i)]=max(abs(cc));
                %c(j,l,k,i,2)=cc(t(j,l,k,i));
                if t(j,l,k,i)>length(cc)/2
                    t(j,l,k,i)=t(j,l,k,i)-length(cc)-1;
                end
            end
        end
       end
    end
   c(:,:,:,:,3)=t*dts{1,1}.sampPeriod; %Assuming all subjects/conds were sampled at the same rate
   c(isnan(c))=0;
    c2=c+permute(c,[2,1,3,4,5]);
    c(:,:,:,:,2:3)=c2(:,:,:,:,2:3);
    dataNamesRAW={'Time-synchd covar','Max time-delayed covar','Time-delay for max covar(s)'};
end

saveName=[saveDir 'EMGcovars'];
if raw
    saveName=[saveName 'RAW'];
end
save(saveName,'c','t','-v7.3')

%% -----------------------Begin plots!------------------------------------
%% Plot of variance decomposition
for mode=1:2; %Mode =1 decompose energy, mode=2 decompose variance only
f=figure;
title('Distribution of signal energy on EMG amplitude traces')
subP=1:16;
subC=17:32;
switch mode
    case 1
        vv=bsxfun(@rdivide,v,sum(v,1));
    case 2
        vv=v;
        vv(1,:)=0;
        vv=bsxfun(@rdivide,vv,sum(vv,1));
end
list=list(1:15);
hold on
for g=1:2 %1=patients, 2=controls;
    switch g
        case 1
            subG=subP;
            xOff=0;
            xOff2=0;
            alpha=1;
            marker='x';
        case 2
            subG=subC;
            xOff=.4;
            xOff2=1;
            alpha=.5;
            marker='.';
    end
bb=bar([1:30]+xOff,squeeze(mean(vv(:,:,2,1,subG),5))','stacked','BarWidth',.4,'FaceAlpha',alpha,'EdgeColor','none');
cc=get(gca,'ColorOrder');
for i=1:length(bb)
    bb(i).FaceColor=cc(4-i,:);
end
if mode==1
%errorbar([1:30]+xOff,squeeze(mean(vv(1,:,2,1,subG),5))',squeeze(std(vv(1,:,2,1,subG),[],5))'/4,'LineStyle','none','LineWidth',3,'Color',ones(1,3) * (.4)^(g-1))
plot([1:30]+xOff+.1,squeeze((vv(1,:,2,1,subG))),['k' marker])
for i=1:30
plot(i+xOff +[0 0],squeeze(mean(vv(1,i,2,1,subG),5))'+squeeze(std(vv(1,i,2,1,subG),[],5))'/4 *[1 -1],'LineStyle','-','LineWidth',3,'Color',ones(1,3) * (.5)^(g))
end
end
%errorbar([1:30]+xOff,squeeze(1-mean(vv(3,:,2,1,subG),5))',squeeze(std(vv(3,:,2,1,subG),[],5))'/4,'LineStyle','none','LineWidth',3,'Color',ones(1,3) * (.5)^((g)))
for i=1:30
plot(i+xOff +[0 0],squeeze(1-mean(vv(3,i,2,1,subG),5))'+squeeze(std(vv(3,i,2,1,subG),[],5))'/4 *[1 -1],'LineStyle','-','LineWidth',3,'Color',ones(1,3) * (.4)^((g-1)))
end
plot([1:30]-.1+xOff,1-squeeze((vv(3,:,2,1,subG))),['w' marker])

dd1=squeeze(mean((vv(:,1:15,2,1,subG)),2));
dd2=squeeze(mean((vv(:,16:30,2,1,subG)),2));
dd=[mean(dd1,2) mean(dd2,2)]';
bbb=bar(32+[1,3]+xOff2,dd,'stacked','BarWidth',.5,'FaceAlpha',alpha);
for i=1:length(bb)
    bbb(i).FaceColor=cc(4-i,:);
end
if mode==1
errorbar(32+[1,3]+xOff2,dd(:,1),std([dd1(1,:); dd2(1,:)]')/4,'LineStyle','none','LineWidth',3,'Color',ones(1,3) * (.5)^(g))
plot(32+[1,3]+.2+xOff2,[dd1(1,:); dd2(1,:)]',['k' marker])
end
errorbar(32+[1,3]+xOff2,1-dd(:,3),std([dd1(3,:); dd2(3,:)]')/4,'LineStyle','none','LineWidth',3,'Color',ones(1,3) * (.5)^((g-1)))
plot(32+[1,3]-.2+xOff2,1-[dd1(3,:); dd2(3,:)],['w' marker])

end

set(gca,'XTick',[[1:30]+.25, 33:36],'XTickLabel',[strcat('s',list) strcat('f',list) {'sP','sC','fP','fC'}],'XTickLabelRotation',90)

axis tight
switch mode
    case 1
    ylabel('% of energy')
    legend('Mean','Periodic behavior','T2T')
    case 2
        ylabel('% of variance')
        legend(bb(2:3),'Periodic behavior','T2T')
end
xlabel('Muscles')
grid on
set(gca,'FontSize',20)
saveName='varDecomp';
if raw
    saveName=['RAW/' saveName];
end
if mode==2
    saveName=[saveName 'NoDC'];
end
saveFig(f,'../../fig/all/emg/varDecomp/',saveName)

end
%% Plot of covariances
sym=false;
rawConditionsFlag=false;
%sym=true
mapColors=[.85,0,.1;0,.1,.6];
close all
    list={'TA','PER','LG','MG','SOL','BF','SEMT','SEMB','RF','VM','VL','GLU','TFL','ADM','SAR','ILP','HIP'};
subsP=1:16;
subsC=17:32;
mOrder1=[1:2,5,3,4,7:8,6,10:11,9,15,14,13,12];
mOrder=[mOrder1,mOrder1+15];
ccc=c;
if sym
    ccc=ccc-ccc([16:30,1:15],[16:30,1:15],:,:,:);
end

if ~rawConditionsFlag
ccc(:,:,:,2:3,:)=bsxfun(@minus,ccc(:,:,:,2:3,:),ccc(:,:,:,1,:)); %Measures are stacked against baseline
cLim2=[1,.5,.5];
else
    cLim2=ones(1,3);
end
subs2={subsP,subsC};
%subs={subsP([1:6,8:end]),subsC([1:14,16])};
dataNames={'T2T','centered','unaligned centered'};
%dataNamesRAW={'Time-synchd covar','Max time-delayed covar','Time-delay for max covar (s)'};
gNames={'P','C','DiffPvsC'};
ccA={'Base','Change in late adap','Change in late post'};
ex2=mapColors(1,:);
ex1=mapColors(2,:);
mid=[1,1,1];
n=2;
cmap=[bsxfun(@plus,ex1 , [0:.01:1].^n'*(mid-ex1));bsxfun(@plus,ex2,[1:-.01:0].^n'*(mid-ex2));];%ones(100,1)*ex2];
modeNames={'Mean','Median'};
modo=2; %Mean or median
for g=1:2%1:3;%1:3 %patients, controls, differenced
    f1=figure;
    set(f1,'Units','Normalized','OuterPosition',[0 0 1 1])
for data=1:3%3%T2T, centered, unaligned centered; or, if RAW: no time-delay correlations, maximal time-delayed correlations, and time-delay of maximal correlation
   for i=1:3   
       N=size(ccc,1);
       alpha=.05;
       if g==3
           cA=ccc(mOrder,mOrder,subs2{1},i,data);
           cB=ccc(mOrder,mOrder,subs2{2},i,data);
           cLim=[.5 ,.5,.5];
           p=nan(N,N);
           for j=1:N
               for k=j+1:N
                    p(j,k)=ranksum(squeeze(cA(j,k,:)),squeeze(cB(j,k,:)));
                    %[~,p(j,k)]=ttest2(squeeze(cA(j,k,:)),squeeze(cB(j,k,:)));
               end
           end
       else
           cA=ccc(mOrder,mOrder,subs2{g},i,data);
           cB=0;
           cLim=cLim2;
           p=nan(N,N);
           for j=1:N
               for k=j+1:N
                    p(j,k)=signrank(squeeze(cA(j,k,:)),0,'method','exact');
                    %[~,p(j,k)]=ttest(squeeze(cA(j,k,:)));
               end
           end
       end
       if sym
          p([N/2+1:N],:)=nan;
          p=p-triu(p,15);
          p(p==0)=nan;
       end
       [hA,pThreshold,i1] = BenjaminiHochberg(p(~isnan(p(:))),alpha);
       h=nan(size(p));
       h(~isnan(p(:)))=hA;
       %h=p<.05; %Uncomment to use .05 threshold as-is, no FDR correction method.
       figure(f1)
       
       xx=repmat(1:N,N,1);
       yy=xx';
       subplot(3,3,3*(data-1)+i)
       %subplot(1,2,3-data)
       switch modo
           case 1 %Mean
                imagesc(mean(cA-cB,3))
           case 2 %Median
               dd=median(cA,3)-median(cB,3);
               if ~sym
                   dd=triu(dd);
                imagesc(dd)
               else
                  dd(16:30,:)=0; 
                  dd=triu(dd);
                  dd=dd-triu(dd,15);
                  imagesc(dd)
               end
                %text(1,23,['Median r^2= ' num2str(median(abs(dd(h(:)==1))))])
                %text(2,27,['#signif ' num2str(sum(h(:)==1))])
                aux=zeros(size(h));
                aux(1:15,16:30)=1;
                aux=aux-diag(diag(aux));
                aux=triu(aux);
                text(1,27,['#inter ' num2str(sum(h(:)==1 & aux(:)==1)) '/225,med=' num2str(median(abs(dd(h(:)==1 & aux(:)==1))))])
                aux=zeros(size(h));
                aux(3:5,3:5)=1;
                aux(6:8,6:8)=1;
                aux(9:11,9:11)=1;
                aux(12:13,12:13)=1;
                aux(14:15,14:15)=1;
                aux=aux+aux([16:30,1:15],[16:30,1:15]);
                aux=aux-diag(diag(aux));
                aux=triu(aux);
                text(1,29,['#anat. ' num2str(sum(h(:)==1 & aux(:)==1)) '/22,med=' num2str(median(abs(dd(h(:)==1 & aux(:)==1))))])
                aux=zeros(size(h));
                aux(1:15,1:15)=1;
                aux(16:30,16:30)=1;
                aux=aux-diag(diag(aux));
                aux=triu(aux);
                text(1,25,['#intra ' num2str(sum(h(:)==1 & aux(:)==1)) '/210,med=' num2str(median(abs(dd(h(:)==1 & aux(:)==1))))])
       end
       hold on
       plot(xx(h(:)==1),yy(h(:)==1),'k.')
       hold off
       if ~sym
       set(gca,'XTick',[[1:30]],'XTickLabel',[strcat('s',list(mOrder1)) strcat('f',list(mOrder1))],'XTickLabelRotation',90)
       set(gca,'YTick',[[1:30]],'YTickLabel',[strcat('s',list(mOrder1)) strcat('f',list(mOrder1))],'YTickLabelRotation',0)
       else
           set(gca,'XTick',[[1:30]],'XTickLabel',[strcat('i',list(mOrder1)) strcat('c',list(mOrder1))],'XTickLabelRotation',90)
           set(gca,'YTick',[[1:15]],'YTickLabel',[strcat('i',list(mOrder1))],'YTickLabelRotation',0)
       end
       if data==1
          title([ccA{i} ' ' gNames{g}]) 
       end
       if i==1
          if ~raw
                ylabel(dataNames{data})
          else
              ylabel(dataNamesRAW{data})
          end
       end
       caxis([-1 1]*cLim(i))
       colorbar
       colormap(cmap)
       axis equal
       axis tight
       hold on
       plot([.5,30.5],15.5*[1,1],'k')
       plot(15.5*[1,1],[.5,30.5],'k')
       hold off
   end
end
saveName=['covar' modeNames{modo} gNames{g}];
if raw
    saveName=['RAW/' saveName];
end
if sym
    saveName=[saveName 'Sym'];
end
if rawConditionsFlag
    saveName=[saveName '_NoCompareToBase'];
end
saveFig(f1,'../../fig/all/emg/varDecomp/',saveName)
end
%% Plot of eigen values and cumulative sums
    cc={'TM base','Adaptation','Washout'};
subP=[1:6,7,8:16];
subC=[17:32];
f=figure;
clear p pp
nNames={'Bilateral','Paretic/slow','Non-paretic/fast'};
for j=[2] %Aligned data only
    for i=1:3
        for n=1:3 %bilateral or unilateral
            switch  n
                case 1
                    aa=a;
                    aa2=a2;
                    i2=0;
                case 2
                    aa=aS;
                    aa2=a2S;
                    i2=1;
                case 3
                    aa=aF;
                    aa2=a2F; 
                    i2=2;
            end
        for l=1:2 % centered or T2T
            switch l
                case 1
                    d=squeeze(bsxfun(@rdivide,aa(:,i,j,:),sum(aa(:,i,j,:),1)));
                    ii=0;
                    t2='Centered';
                case 2
                    d=bsxfun(@rdivide,aa2(:,i,:),sum(aa2(:,i,:),1));
                    ii=3;
                    t2='T2T';
            end
            for m=2 %eigs or cumsum
                t1='Eigs';
                if m==2
                    d= cumsum(d,1);
                    t1='Cum Eigs';
                end
                %d=[zeros(size(d,2));d];
                    
        subplot(2,3,ii+i2+1)
        title([t1 ' - ' t2 ' data'])
        hold on
            
            p(i)=plot(0:size(d,1),[0; mean(d(:,subP),2)]);
            pp(i)=plot(0:size(d,1),[0;mean(d(:,subC),2)],'--','Color',p(i).Color);
            plot(mean(d(:,subP),2)-mean(d(:,subC),2),'.-','Color',p(i).Color);
            %             patch([1:30,30:-1:1],[mean(d(:,subP),2)+std(d(:,subP),[],2)/4; flipud(mean(d(:,subP),2))-flipud(std(d(:,subP),[],2))/4],p(i).Color,'EdgeColor','none','FaceAlpha',.2)
            %             patch([1:30,30:-1:1],[mean(d(:,subC),2)+std(d(:,subC),[],2)/4; flipud(mean(d(:,subC),2))-flipud(std(d(:,subC),[],2))/4],p(i).Color,'EdgeColor','none','FaceAlpha',.2)
            patch([1:size(d,1),size(d,1):-1:1],[mean(d(:,subP),2)-mean(d(:,subC),2)+std(d(:,subC),[],2)/4+std(d(:,subP),[],2)/4; flipud(mean(d(:,subP),2)-mean(d(:,subC),2))-flipud(std(d(:,subC),[],2)/4+std(d(:,subP),[],2))/4],p(i).Color,'EdgeColor','none','FaceAlpha',.2)
        if  i==3
            legend([p pp],[strcat(cc,' Aligned P') strcat(cc,' Aligned C')])        
        end
        grid on
        xlabel('Dims')
        ylabel(['Explained % of energy in ' nNames{n}])
        hold off
            end
        end
        end
    end
end
saveName='explainedVars';
if raw
    saveName=['RAW/' saveName];
end
saveFig(f,'../../fig/all/emg/varDecomp/',saveName)
%%
subP=[1:6,7,8:16];
subC=[17:32];
mode=2; %1=line plots, 2=bars of areas
dataNames={'T2T','centered','unaligned centered'};
modeNames={'Plot','Bar'};
dataNamesShort={'T2T','Cent','CentUnalign'};
if raw
    datas=1; %For raw data, T2T is the only dataset available
else
    datas=[1:3];
end
for data=datas; %1=T2T, 2=centered, 3=centered, not aligned

for mode=1:2;

f=figure; %2: symmetry and epoch effects on T2T
switch data
    case 1
        dS=1-cumsum(bsxfun(@rdivide,a2S,sum(a2S,1)));
        dF=1-cumsum(bsxfun(@rdivide,a2F,sum(a2F,1)));
    case 2
        dS=1-cumsum(bsxfun(@rdivide,aS,sum(aS,1)));
        dS=squeeze(dS(:,:,2,:));
        dF=1-cumsum(bsxfun(@rdivide,aF,sum(aF,1)));
        dF=squeeze(dF(:,:,2,:));
    case 3
        dS=1-cumsum(bsxfun(@rdivide,aS,sum(aS,1)));
        dS=squeeze(dS(:,:,1,:));
        dF=1-cumsum(bsxfun(@rdivide,aF,sum(aF,1)));
        dF=squeeze(dF(:,:,1,:));
        
end
%dS=2*dS/size(dS,1); %To normalize to the [0,1] interval. 0= absolute covaraition, 1=absolute independence
%dF=2*dF/size(dF,1);

t={'Baseline','Change in adap (w.r.t. baseline)','Change in post (w.r.t. baseline)'};
for j=1:3
    t1=t{j};
    if j==2
        dS=bsxfun(@minus,dS,dS(:,1,:));
        dF=bsxfun(@minus,dF,dF(:,1,:));
    end
subplot(2,3,j)
%Baseline asymmetries
title([t1 ' ' dataNames{data}])
hold on
switch mode
    case 1
        dde=dS(:,j,subP)-dF(:,j,subP);
        pp=plot(mean(dde,3),'LineWidth',2);
        patch([1:size(dde,1),size(dde,1):-1:1],[mean(dde,3)+std(dde,[],3)/sqrt(size(dde,3)); flipud(mean(dde,3)-std(dde,[],3)/sqrt(size(dde,3)))],pp.Color,'EdgeColor','none','FaceAlpha',.2)
        
        dde=dS(:,j,subC)-dF(:,j,subC);
        pp1=plot(mean(dde,3),'LineWidth',2);
        patch([1:size(dde,1),size(dde,1):-1:1],[mean(dde,3)+std(dde,[],3)/sqrt(size(dde,3)); flipud(mean(dde,3)-std(dde,[],3)/sqrt(size(dde,3)))],pp1.Color,'EdgeColor','none','FaceAlpha',.2)

        dde=dS(:,j,subP)-dF(:,j,subP);
        %plot(squeeze(dde),'LineWidth',.1,'Color',pp.Color)
        legend('Patients mean','STE','Controls mean','STE')
        xlabel('Dims')
        ylabel('Explained var % asymmetry')
    case 2
     ddd=2*cat(4,dS(:,j,subP)-dF(:,j,subP),dS(:,j,subC)-dF(:,j,subC))/size(dS,1);
      ttt=squeeze(mean(sum(ddd,1),3));
      bar(ttt) 
      plot(1:2,squeeze(sum(ddd,1)),'k.','MarkerSize',8)
      ttt2=squeeze(std(sum(ddd,1),[],3))/sqrt(size(dde,3)); %ste
      errorbar(1:2,ttt,ttt2)
      set(gca,'XTick',1:2,'XTickLabel',{'Patients','Controls'})
      xlabel('Groups')
      ylabel('Indep. index asymmetry')
end
hold off

subplot(2,3,j+3)
title([t1 ' ' dataNames{data}])
hold on
switch mode
    case 1
p1=plot(mean(dS(:,j,subP),3),'LineWidth',2);
p2=plot(mean(dS(:,j,subC),3),'LineWidth',2);
plot(mean(dF(:,j,subP),3),'--','Color',p1.Color,'LineWidth',2)
plot(mean(dF(:,j,subC),3),'--','Color',p2.Color,'LineWidth',2)
patch([1:size(dde,1),size(dde,1):-1:1],[mean(dS(:,j,subP),3)+std(dS(:,j,subP),[],3)/sqrt(size(dS(:,j,subP),3)); flipud(mean(dS(:,j,subP),3)-std(dS(:,j,subP),[],3)/sqrt(size(dde,3)))],p1.Color,'EdgeColor','none','FaceAlpha',.2)
patch([1:size(dde,1),size(dde,1):-1:1],[mean(dS(:,j,subC),3)+std(dS(:,j,subC),[],3)/sqrt(size(dS(:,j,subC),3)); flipud(mean(dS(:,j,subC),3)-std(dS(:,j,subC),[],3)/sqrt(size(dde,3)))],p2.Color,'EdgeColor','none','FaceAlpha',.2)
patch([1:size(dde,1),size(dde,1):-1:1],[mean(dF(:,j,subP),3)+std(dF(:,j,subP),[],3)/sqrt(size(dF(:,j,subP),3)); flipud(mean(dF(:,j,subP),3)-std(dF(:,j,subP),[],3)/sqrt(size(dde,3)))],p1.Color,'EdgeColor','none','FaceAlpha',.1)
patch([1:size(dde,1),size(dde,1):-1:1],[mean(dF(:,j,subC),3)+std(dF(:,j,subC),[],3)/sqrt(size(dF(:,j,subC),3)); flipud(mean(dF(:,j,subC),3)-std(dF(:,j,subC),[],3)/sqrt(size(dde,3)))],p2.Color,'EdgeColor','none','FaceAlpha',.1)

legend('Patients Slow','Controls Slow','Patients Fast','Controls Fast')
xlabel('Dims')
ylabel('Explained var %')
    case 2
        ddd=2*cat(4,dS(:,j,subP),dF(:,j,subP),dS(:,j,subC),dF(:,j,subC))/size(dS,1);
        ttt=squeeze(mean(sum(ddd,1),3));
        bar(ttt)  
        plot(1:4,squeeze(sum(ddd,1)),'k.','MarkerSize',8)
        ttt2=squeeze(std(sum(ddd,1),[],3))/sqrt(size(dde,3)); %ste
        errorbar(1:4,ttt,ttt2)
      set(gca,'XTick',1:4,'XTickLabel',{'Patients Slow','Patients Fast','Controls Slow','Controls Fast'})
      xlabel('Legs/Groups')
      ylabel('Indep. index')
end
hold off
end
saveName=['indepIdx' dataNamesShort{data} modeNames{mode}];
if raw
    saveName=['RAW/' saveName];
end
saveFig(f,'../../fig/all/emg/varDecomp/',saveName)
end
end
%% Variance decomposition and correlations of independence index vs. Fugl-Meyer
dataNames={'T2T','centered','unaligned centered'};
dataNamesShort={'T2T','Cent','CentUnalign'};
subP=[1:6,7,8:16];
subC=[17:32];
modeNames={'Baseline indep.','Change in indep. to late adap.','Change in indep. to late post'};
modeNamesShort={'Base','Adap','Post'};
load ../../paramData/bioData.mat %speeds, ages and Fugl-Meyer
if raw
    datas=1; %For raw data, T2T is the only (meaningful) dataset available
else
    datas=[1:3];
end
for data=datas; %1=T2T, 2=centered, 3=centered, not aligned

for mode=1:3;

switch data
    case 1
        dS=1-cumsum(bsxfun(@rdivide,a2S,sum(a2S,1)));
        dF=1-cumsum(bsxfun(@rdivide,a2F,sum(a2F,1)));
    case 2
        dS=1-cumsum(bsxfun(@rdivide,aS,sum(aS,1)));
        dS=squeeze(dS(:,:,2,:));
        dF=1-cumsum(bsxfun(@rdivide,aF,sum(aF,1)));
        dF=squeeze(dF(:,:,2,:));
    case 3
        dS=1-cumsum(bsxfun(@rdivide,aS,sum(aS,1)));
        dS=squeeze(dS(:,:,1,:));
        dF=1-cumsum(bsxfun(@rdivide,aF,sum(aF,1)));
        dF=squeeze(dF(:,:,1,:));        
end
if mode~=1
    dS=dS(:,mode,:)-dS(:,1,:);
    dF=dF(:,mode,:)-dF(:,1,:);
end

f=figure('Name',[modeNames{mode} ' in ' dataNames{data} ' data']);
titles={'Paretic/slow','Non-paretic/fast','Difference'};
for i=1:3
    switch i
        case 1
            d=sum(dS(:,1,subP),1)/7.5;
            d2=sum(dS(:,1,subC),1)/7.5;
        case 2
            d=sum(dF(:,1,subP),1)/7.5;
            d2=sum(dF(:,1,subC),1)/7.5;
        case 3
            d=sum(dS(:,1,subP),1)/7.5-sum(dF(:,1,subP),1)/7.5;
            d2=sum(dS(:,1,subC),1)/7.5-sum(dF(:,1,subC),1)/7.5;
    end
ph(i)=subplot(1,3,i);
if i==2
title([modeNames{mode} ' in ' dataNames{data} ' data'])
end
hold on
x=FM(subP);
x2=34*ones(size(subC));
y=squeeze(d);
y2=squeeze(d2);
plot(x,y,'.')
plot(x2,y2,'.')
text(x,y,cellfun(@(x) x([1,4:5]),subs(subP),'UniformOutput',false))
text(x2,y2,cellfun(@(x) x([1,4:5]),subs(subC),'UniformOutput',false))
p=polyfit(x,y',1);
yy=polyval(p,x);
plot(x,yy)
xlabel('Fugl-Meyer score')
ylabel(['Independence index in ' titles{i}])
hold off
end
linkaxes(ph,'xy')
saveName=['indepIdxVsFM' modeNamesShort{mode} dataNamesShort{data}];
if raw
    saveName=['RAW/' saveName];
end
saveFig(f,'../../fig/all/emg/varDecomp/',saveName)
end
end

%% Now variance decomp vs. FM
close all
load ../../paramData/bioData.mat %speeds, ages and Fugl-Meyer
condNamesShort={'Base','Adap','Post'};
mode=1; %1 is mean, 2 is median
modeNames={'mean','median'};
subP=[1:6,7,8:16];
subC=[17:32];
quantNames={'energy','var'};
for quant=1:2 %Decomposing energy or variance
for cond=1:3;
fh=figure('Units','Normalized','OuterPosition',[0 0 1 1],'Name',['Var. decomposition vs. biographical variables. ' condNamesShort{cond} ' ' modeNames{mode}]);
for k=1:3
    switch k
        case 1
           xxx=FM;
           name='lower limb Fugl-Meyer score (/34)';
           disp('----------------------------------------Fugl-Meyer')
        case 2
            xxx=velsS;
            name='TM speed (/34)';
            disp('-----------------------------------------Speed')
        case 3
            xxx=ageS;
            name='Age (yrs)';
            disp('-----------------------------------------Age')
    end

slopeP=nan(2);
subplot(1,3,k)
switch quant
    case 1
        vvM=bsxfun(@rdivide,v,sum(v,1));
    case 2
        vvM=v;
        vvM(1,:)=0;
        vvM=bsxfun(@rdivide,vvM,sum(vvM,1));
end
vv1=vvM(:,1:15,:,:,:); %first 15 muscles= paretic/slow
vv2=vvM(:,16:30,:,:,:); %non-paretic/fast
hold on
legStr={};
for i=1:2 %Both sides L/R
    switch i
        case 1 %PAretic side muscles
            vv=vv1;
            m='';
            m1='o';
            aph=.2;
            col2=false;
            disp('------Paretic--------')
            mec='none';
        case 2 %Non-paretic
            vv=vv2;
            m='--';
            m1='o';
            aph=.1;
            col2=true;
            mec='k';
            disp('------Non-paretic--------')
    end
x=xxx(subP);
for j=1:2 %DC or T2T
    switch j
        case 1
            y=squeeze((vv(1,:,2,cond,subP)));
            col=[1,0,0];
        case 2
            y=squeeze((sum(vv(1:2,:,2,cond,subP),1)));
            col=[0,.6,.2];
    end
    if mode==1
        y=mean(y,1)';
    else
        y=median(y,1)';
    end
    if ~col2
        cc2=col;
    else
        cc2='none';
    end
    plot(x,y,m1,'Color',col,'MarkerFaceColor',cc2,'MarkerEdgeColor',col)
    [p,S]=polyfit(x,y',1);
    %lm=fitlm(34-x,y')
    %lm.Coefficients.pValue(2)
    [~,pSp]=corr(x',y,'type','spearman')
    [~,pCorr]=corr(x',y)
    %slopeP(i,j)=lm.Coefficients.pValue(2);
    yy=polyval(p,[min(x) max(x)]);
    pp=plot([min(x) max(x)],yy,m,'Color',col);
    switch j
        case 1
            p1='DC var % ';
        case 2
            p1 ='T2T var (100-%) ';
    end
    switch i
        case 1
          p2 ='[par]';
        case 2
            p2='[non-par]';
    end
    %aux=num2str(slopeP(i,j),3);
    aux2=num2str(pSp,3);
    aux3=num2str(pCorr,3);
    legStr=[legStr {[p1 p2],['p_{spRank}=.' aux2(3:min(5,length(aux2))) ',p_{corr}=.' aux3(3:min(5,length(aux3)))]}];
    %[Y,DELTA] = polyconf(p,[[min(x) max(x)]],S,'alpha',.1);
    %patch([[[min(x) max(x)]] [34:-1:21]],[Y+DELTA fliplr(Y-DELTA)],pp.Color,'EdgeColor','none','FaceAlpha',aph)
end

end
aux=num2str(slopeP(:),3);
%legend('DC var % [par]',['Lin. reg. (p_{slope}=.' aux(1,3:5) ')'],'T2Tvar (100-%) [par]',['Lin. reg. (p_{slope}=.' aux(3,3:5) ')'],'DC var % [non-par]',['Lin. reg. (p_{slope}=.' aux(2,3:5) ')'],'T2Tvar (100-%) [non-par]',['Lin. reg. (p_{slope}=.' aux(4,3:5) ')']);
legend(legStr)
if k>1
    disp('----Controls----')
    p2='[control]';
    if k==2
        x=velsC;
    elseif k==3
        x=ageC;
    end
    for j=1:2
    switch j
        case 1
            y=squeeze((vvM(1,:,2,cond,subC)));
            col=[1,0,0];
            m='-.';
            m1='x';
        case 2
            y=squeeze((sum(vvM(1:2,:,2,cond,subC),1)));
            col=[0,.6,.2];
            m='-.';
            m1='x';
    end
    if mode==1
        y=mean(y,1)';
    else
        y=median(y,1)';
    end
    plot(x,y,m1,'Color',col,'MarkerFaceColor',col)
    [p,S]=polyfit(x,y',1);
    %lm=fitlm(34-x,y');
    %lm.Coefficients.pValue(2) %This is the same as p-value for lin corr
    [~,pSp]=corr(x',y,'type','spearman')
    [~,pCorr]=corr(x',y)
    %slopeP(1,j)=lm.Coefficients.pValue(2);
    yy=polyval(p,[min(x) max(x)]);
    pp=plot([min(x) max(x)],yy,m,'Color',col);
    %aux=num2str(slopeP(1,j),3);
    aux2=num2str(pSp,3);
    aux3=num2str(pCorr,3);
    legStr=[legStr {[p1 p2],['p_{spRank}=.' aux2(3:min(5,length(aux2))) ',p_{corr}=.' aux3(3:min(5,length(aux3)))]}];
    end
else
    dd3=squeeze(((vvM(:,1:15,2,cond,subC))));
    dd4=squeeze(((vvM(:,16:30,2,cond,subC))));
    dd5=squeeze(((vvM(:,:,2,cond,subC))));
    if mode==1
        dd3=squeeze(mean(dd3,2));
        dd4=squeeze(mean(dd4,2));
        dd5=squeeze(mean(dd5,2));
    else
        dd3=squeeze(median(dd3,2));
        dd4=squeeze(median(dd4,2));
        dd5=squeeze(median(dd5,2));
    end
    dd=[mean(dd3,2) mean(dd4,2)]'; %Mean across subjects
    dd(:,2)=1-sum(dd(:,[1,3]),2);
    ccc=get(gca,'ColorOrder');
    bb=bar(max(x)*(1+1/33)*[1,1.02],dd ,'stacked','BarWidth',1,'FaceAlpha',.5);
    for jj=1:length(bb)
        bb(jj).FaceColor=ccc(4-jj,:);
    end
    text(max(x)*.87,.1,'CONTROLS:','FontSize',20)
    text(max(x)*(1+1/33)*.99,.1,'nD','FontSize',12)
    text(max(x)*(1+1/33)*1.01,.1,'D','FontSize',12)
    errorbar(max(x)*(1+1/33)*[1,1.02],dd(:,1),std([dd3(1,:); dd4(1,:)]')/4,'LineStyle','none','Color','w','LineWidth',3)
    errorbar(max(x)*(1+1/33)*[1,1.02],1-dd(:,3),std([dd3(3,:); dd4(3,:)]')/4,'LineStyle','none','Color','k','LineWidth',3)
    plot(max(x)*(1+1/33)*[1,1.02],[dd3(1,:); dd4(1,:)]','x','Color',[1,0,0])
    plot(max(x)*(1+1/33)*[1,1.02],1-[dd3(3,:); dd4(3,:)],'x','Color',col)
end
title(['Var decomp. vs ' name])
xlabel(name)
ylabel('% Variance explained (muscle avg.)')
if k>1
    legend(legStr)
end
set(findobj(gcf,'Type','Legend'),'Location','SouthWest')
set(gca,'YTick',sort(cumsum(mean(dd,1)),'ascend'))
grid on
hold off
axis tight
aa=axis;
axis([aa(1:2) 0 1])
end

saveName=[quantNames{quant} 'DecompVsFM' condNamesShort{cond}];
if raw
    saveName=['RAW/' saveName];
end
if mode==1
    saveName=[saveName '_Mean'];
end
saveFig(fh,'../../fig/all/emg/varDecomp/',saveName)
end
end