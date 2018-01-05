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
clear normProy index p1
fh=figure;
for i=1%:2
    switch i
        case 1
            group=controls;
            g='C';
        case 2
            group=patients;
            g='P';
    end
    dd1=group.getGroupedData(label,{'TM base'},0,-100,5,5);
    b=squeeze(nanmedian(dd1{1}));
    normalizationFactors=reshape(repmat(max(reshape(b,12,30,size(b,2)),[],1),12,1,1),360,size(b,2));
    subtractFactors=reshape(repmat(min(reshape(b,12,30,size(b,2)),[],1),12,1,1),360,size(b,2));
    b2=(b-subtractFactors)./(normalizationFactors-subtractFactors);
    conds={'TM base','Adap','Wash'};
    clear dd NN
    for j=1:length(group.ID)
        dd{j}=group.adaptData{j}.data.getDataAsVector(label);
        inds{j}=group.adaptData{j}.getIndsInCondition(conds);
        inds{j}=cell2mat(inds{j}');
        dd{j}=bsxfun(@minus,bsxfun(@rdivide,bsxfun(@minus,dd{j}(inds{j},:)',subtractFactors(:,j)),normalizationFactors(:,j)-subtractFactors(:,j)),0);
        NN(j)=size(dd{j},2);
    end
    allData=cell2mat(dd);
    m=nanmean(allData,2);
    m=repmat(m,1,size(allData,2));
    allData(isnan(allData))=m(isnan(allData));
    [ccAll,ppAll,aaAll]=pca([allData(1:180,:) allData(181:end,:)]');
    ppAllF=ppAll(1:size(allData,2),:);
    ppAllS=ppAll(size(allData,2)+1:end,:);
    
     for j=1:length(group.ID)
         N2=NN(j);
          ppF=ppAllF(sum([0 NN(1:(j-1))])+[1:N2],:);
          ppS=ppAllS(sum([0 NN(1:(j-1))])+[1:N2],:);
          pp=[ppF;ppS];
        for k=1:length(conds)
            figure(fh);
            inds2=group.adaptData{j}.getIndsInCondition(conds(k));
            if ~isempty(inds2{1})
                inds2=inds2{1}-inds{j}(1)+1;
                ppF=nan(length(inds2),3);
                ppS=nan(length(inds2),3);
                clear ppF ppS
                    for kk=1:3
                        ppF(:,kk)=monoLS(pp(inds2,kk),[],2,5); %Regularize
                        ppS(:,kk)=monoLS(pp(inds2+N2,kk),[],2,5); %Regularize
                        %aux=conv(pp(inds2,kk),ones(20,1),'same');
                        %ppF(:,kk)=aux(11:20:end); %Regularize
                        %aux=conv(pp(inds2+N2(2),kk),ones(10,1),'same');
                        %ppS(:,kk)=aux(11:20:end); %Regularize
                    end
                    if k==1
                        bppF=ppF(end,:);
                        bppS=ppS(end,:);
                    end
                    ppF=ppF-bppF; %Aligning baselines to origin
                    ppS=ppS-bppS; %Aligning baselines to origin
                    subplot(3,2,[2:2:6])
                    hold on
                    if j==1
                        p1(k)=plot3(ppF(:,1),ppF(:,2),ppF(:,3),'LineWidth',4);
                        p2(k)=plot3(ppS(:,1),ppS(:,2),ppS(:,3),'--','LineWidth',4,'Color',p1(k).Color);
                    else
                        p1(k)=plot3(ppF(:,1),ppF(:,2),ppF(:,3),'LineWidth',4,'Color',p1(k).Color);
                        p2(k)=plot3(ppS(:,1),ppS(:,2),ppS(:,3),'--','LineWidth',4,'Color',p1(k).Color);
                    end            
                    if k>1
                       plot3([ppF(1,1),lastF(1)],[ppF(1,2), lastF(2)] ,[ppF(1,3), lastF(3)] ,'LineWidth',4,'Color','k'); 
                       plot3([ppS(1,1),lastS(1)],[ppS(1,2), lastS(2)] ,[ppS(1,3), lastS(3)] ,'--','LineWidth',4,'Color','k'); 
                    end
                    subplot(3,2,1)
                    hold on
                    plot(inds2,ppF(:,1),'LineWidth',2,'Color',p1(k).Color)
                    plot(inds2,ppS(:,1),'--','LineWidth',2,'Color',p1(k).Color)
                    subplot(3,2,3)
                    hold on
                    plot(inds2,ppF(:,2),'LineWidth',2,'Color',p1(k).Color)
                    plot(inds2,ppS(:,2),'--','LineWidth',2,'Color',p1(k).Color)
                    subplot(3,2,5)
                    hold on
                    plot(inds2,ppF(:,3),'LineWidth',2,'Color',p1(k).Color)
                    plot(inds2,ppS(:,3),'--','LineWidth',2,'Color',p1(k).Color)
                    
                lastF=ppF(end,1:3);
                lastS=ppS(end,1:3);
            end
        end
        legend(p1,conds)
%         c2=[cc(:,1:3);cc(:,1:3)]'*b2(:,j);
%         %plot3(c2(1),c2(2),c2(3),'x')
       if j==length(group.adaptData)
           saveFig(fh,'../fig/all','PCtrajectories')
            figure; for k=1:3; subplot(1,3,k); hold on; imagesc(reshape(cc(:,k),12,15)'); caxis([-.3 .3]); axis tight; set(gca,'YTick',1:30,'YTickLabel',cellfun(@(x) x(1:end-2),label(1:12:end),'UniformOutput',false)); end;
            xlabel('PC1'); ylabel('PC2'); zlabel('PC3')
            saveFig(gcf,'../fig/all','PCs')
        end
    end
end
