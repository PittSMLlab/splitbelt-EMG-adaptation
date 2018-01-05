function f2=seeSyns(syns,coefs,rotateFlag,mList,subList,Nclust)

%%
f2=figure('Name','See syns','Units','Normalized','OuterPosition',[0 0 1 1]);
cc=syns;
pp=coefs;
if size(cc{1},1)>size(pp{1},1)
    warning('Syns and coefs matrices appear to be switched, permuting.')
    cc=coefs;
    pp=syns;
end
Nsyns=size(pp{1},2);
Nmusc=length(mList);
Nsubs=length(subList);
Nlegs=Nsubs;
NN=size(pp{1},1);

newC=nan(Nmusc,Nsyns,Nsubs);
newP=nan(NN,Nsyns,Nsubs);
for i=1:Nsubs
   switch rotateFlag
       case 1 %Varimax
           [newC(:,:,i),T]=rotatefactors(cc{i},'MaxIt',5000); 
            newP(:,:,i)=pp{i}*T; 
       case 2 %ICA - kurtosis based
           [aux, newC(:,:,i),~] = fastica(cc{i}*pp{i}','approach','symm','maxNumIterations',10000,'verbose','off');
           newP(:,:,i)=aux';
       case 0 %No rotation - as is
            newC(:,:,i)=cc{i}; 
            newP(:,:,i)=pp{i}; 
    end
end

figure(f2)
col=get(gca,'ColorOrder');
col=[col;col.^2;col.^3];
nnC=newC;
nnP=newP;

D=nnC(:,:)'*nnC(:,:);
%if centered
DD=1-abs(D)./sqrt(diag(D)*diag(D)'); %This disimilarity is 1-abs(cos()), which allows to consider opposite vectors as equivalent
%else
%    DD=1-(D)./sqrt(diag(D)*diag(D)');
%end
d=mdscale(DD,3);
%d=mdscale(pdist(nnC(:,:)'),3);
if nargin<6 || isempty(Nclust)
    N=Nsyns+ceil(Nsyns/2);
else
    N=Nclust;
end
%N=Nsyns;
%N=10;
%N=2*Nsyns;
%N=10;
idx=kmeans(d,N,'Replicates',100);%,'Distance','cityblock');

tex=subList;

clear syns
for i=1:N
    %See synergies:
   subplot(N,3,3*i-1)
   hold on
   n=sum(idx==i);
   titl=[];
   if n>(Nlegs/2)
       titl=['Missing: (' strjoin(tex(~any(reshape(idx==i,Nsyns,Nlegs)))') ')']; %List of absent subjects
   else
       titl=[ strjoin(tex(any(reshape(idx==i,Nsyns,Nlegs)))') ]; %List of present subs
   end
   titl=['\fontsize{8}' titl ' Reps: [' strjoin(tex(sum(reshape(idx==i,Nsyns,Nlegs))>1)') ']']; %adding List of repeated subs
   
   nnC2=nnC(:,idx==i);
   nnC2=bsxfun(@rdivide,nnC2,sqrt(sum(nnC2.^2,1))); %Normalization
   syn{i}=median(nnC2,2);
   
   nnC2=bsxfun(@rdivide,nnC2,sign(nnC2' * syn{i})');
   sim=(nnC2' * syn{i})./sqrt(sum(nnC2.^2,1) * sum(syn{i}.^2))';
   b=nnC2;
   bar(nnC2,'EdgeColor','None')
   bar(syn{i},'EdgeColor','k','FaceAlpha',0,'LineWidth',2)
   errorbar(1:Nmusc,syn{i},.001*ones(size(b,1),1),std(b,[],2),'k.','LineWidth',2)
   syn{i}=syn{i}/norm(syn{i});
   syns(i,:)=syn{i};
   bar(syn{i},'EdgeColor','k','FaceAlpha',0,'LineWidth',1)
   
   title(['n=' num2str(n) '; ' num2str(mean(sim),2) '\pm' num2str(std(sim),2) '; ' titl ])
   if i==N
       set(gca,'XTick',1:Nmusc,'XTickLAbel',mList,'XTickLabelRotation',90)
   else
       set(gca,'XTick',[])
   end
   axis tight
   hold off
   
   %See activations:
   subplot(N,3,3*i)
   hold on
   %plot(nnP(:,idx==i),'Color',.6*ones(1,3))
   nnP2=bsxfun(@rdivide,nnP(:,idx==i),sign(nnC(:,idx==i)' * median(nnC(:,idx==i),2))');
   plot(squeeze(mean(reshape(nnP2,120,NN/120,sum(idx==i)),2)),'LineWidth',1,'Color',.7*ones(1,3));
   plot(mean(mean(reshape(nnP2,120,NN/120,sum(idx==i)),2),3),'LineWidth',2,'Color',0*ones(1,3));
   
   if i==N
       set(gca,'XTick',[1 15 60 75 120],'XTickLAbel',{'iHS','cTO','cHS','iTO','iHS'},'XTickLabelRotation',90)
   else
       set(gca,'XTick',[1 15 60 75 120],'XTickLabel',{})
   end
   grid on
   axis tight
   hold off
end

subplot(N,3,1:3:3*N)
hold on; 

for i=1:Nlegs;
    for j=1:Nsyns
    
    if i>16
        tt='f';
        m='.';
    else
        tt='s';
        m='x';
    end
    %plot(d(3*i+j-3,1),d(3*i+j-3,2),m,'Color',col(mod(i-1,16)+1,:));
    %text(d(3*i+j-3,1)+2,d(3*i+j-3,2),[tt num2str(mod(i-1,16)+1)],'FontSize',6);
    plot3(d(Nsyns*i+j-Nsyns,1),d(Nsyns*i+j-Nsyns,2),d(Nsyns*i+j-Nsyns,3),m,'Color',col(idx(Nsyns*i+j-Nsyns),:),'MarkerSize',10);
    text(d(Nsyns*i+j-Nsyns,1),d(Nsyns*i+j-Nsyns,2),d(Nsyns*i+j-Nsyns,3),tex{i},'FontSize',6);
    end
end
sim=syns*syns';
sim(sim>.9999)=nan;
title([num2str(nanmean(sim(:)),2) '\pm' num2str(nanstd(sim(:)),2)])
hold off