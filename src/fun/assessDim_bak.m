function [f1,ph]=assessDim(vapsI,vapDistI,subList,bilateral,vapsC,vapDistC,meanOnly,plotHandles)

if bilateral==0 && nargin<6
    error('')
end
if nargin<7 || isempty(meanOnly)
    meanOnly=0;
end
bigK=2-bilateral;
if nargin<8 || isempty(plotHandles) || numel(plotHandles)<bigK*3
    f1=figure('Name','Assess dimensionality','Units','Normalized','OuterPosition',[0 0 1 1]);
    for k=1:3*bigK
        ph(k)=subplot(3,bigK,k);
    end
else
    f1=gcf;
    ph=plotHandles;
end



N=numel(vapsI{1});
for k=1:bigK
    clear all*
for i=1:length(vapsI) %Subjects

        switch k
            case 1
                vaps=vapsI{i}/sum(vapsI{i});
                vapsDist=bsxfun(@rdivide,vapDistI{i},sum(vapDistI{i},1));
            case 2
                vaps=vapsC{i}/sum(vapsC{i});
                vapsDist=bsxfun(@rdivide,vapDistC{i},sum(vapDistC{i},1));
        end
allVaps(:,i)=vaps;
subplot(ph(k))
b=prctile(cumsum(vapsDist)',95);
allB(:,i)=b;
c=prctile(cumsum(vapsDist)',5);
allC(:,i)=c;
m=prctile(cumsum(vapsDist)',50);
[dd,ii]=max((cumsum(vaps)-b'));
i3=ii;
allII(i)=ii;
hold on
if meanOnly==0
patch([[1:N] [N:-1:1]],[b c(end:-1:1)],.6*ones(1,3),'FaceAlpha',.2,'EdgeColor','none')
%patch([[1:size(datos,1)] [size(datos,1):-1:1]],[b [numel(b):-1:1]/numel(b)],.6*ones(1,3),'FaceAlpha',.2,'EdgeColor','none')
%plot(1:size(datos,1),m'/sum(a),'k','LineWidth',1)
plot(cumsum(vaps),'LineWidth',1)
text(ii,(1.1*dd+b(ii)),[subList{i}([1,4,5]) ' = ' num2str(ii) ' \rightarrow'],'horizontalalignment','right','FontSize',8)
else
   if i== length(vapsI)
       b=mean(allB,2)';
       c=mean(allC,2)';
       ii=mean(allII);
       ii2=median(allII);
       patch([[1:N] [N:-1:1]],[b c(end:-1:1)],.6*ones(1,3),'FaceAlpha',.2,'EdgeColor','none')
        plot(mean(cumsum(allVaps),2),'LineWidth',1)
        text(ii,(1.1*dd+b(round(ii))),['Avg. dim = ' num2str(ii) ' \rightarrow     '],'horizontalalignment','right','FontSize',8)
        text(ii2,(1.1*dd+b(round(ii2))),['       \leftarrow ' num2str(ii2) ' = Median. dim '],'horizontalalignment','left','FontSize',8)
   end
end
hold off
axis([1 length(b) .2 1])
if k==1
    title('Paretic/Non-dominant (slow)')
else
    title('Non-paretic/Dominant (fast)')
end
ylabel('Remaining unexplained energy as %')
xlabel('Dims')

subplot(ph(bigK+k))
b=prctile(vapsDist',95);
allB2(:,i)=b;
c=prctile(vapsDist',5);
allC2(:,i)=c;
m=prctile(vapsDist',50);
[ii]=find(vaps>b',1,'last');
try
    allII2(i)=ii;
catch
    allII2(i)=0;
end
hold on
if meanOnly==0
patch([[1:N] [N:-1:1]],[b c(end:-1:1)],.6*ones(1,3),'FaceAlpha',.2,'EdgeColor','none')
plot(vaps,'LineWidth',1);
text(ii,vaps(ii),['\leftarrow = ' num2str(ii) ' ' subList{i}([1,4,5])],'horizontalalignment','left','FontSize',8)
else
   if i== length(vapsI)
       b=mean(allB2,2)';
       c=mean(allC2,2)';
       ii=mean(allII2);
       ii2=median(allII2);
        patch([[1:N] [N:-1:1]],[b c(end:-1:1)],.6*ones(1,3),'FaceAlpha',.2,'EdgeColor','none')
        plot(mean(allVaps,2),'LineWidth',1);
        text(ii,mean(allVaps(round(ii),:)),['        \leftarrow = ' num2str(ii) ' avg.'],'horizontalalignment','left','FontSize',8)
        text(ii2,mean(allVaps(round(ii2),:)),['Median = ' num2str(ii2) '  \rightarrow        '],'horizontalalignment','right','FontSize',8)  
   end
end
axis([1 N 0 .3])
hold off
ylabel('Add. explained energy as %')
xlabel('Dims')

subplot(ph(2*bigK+k))

CC=bsxfun(@rdivide,vapsDist,cumsum(vapsDist,'reverse'));
b=prctile(CC',95);
allB3(:,i)=b;
c=prctile(CC',5);
m=prctile(CC',50);
allC3(:,i)=c;
hold on
if meanOnly==0
patch([[1:N] [N:-1:1]],[1./[N:-1:1] zeros(1,N)],0*[.7,.7,.7],'FaceAlpha',.2,'EdgeColor','none')
patch([[1:N] [N:-1:1]],[b c(end:-1:1)],.6*ones(1,3),'FaceAlpha',.2,'EdgeColor','none')
d=vaps./cumsum(vaps,'reverse');
plot(d,'LineWidth',1);
ii=find(d>b');
text(ii,d(ii),'*')
elseif i==length(vapsI)
    b=mean(allB3,2)';
    c=mean(allC3,2)';
    vaps=mean(allVaps,2);
    patch([[1:N] [N:-1:1]],[1./[N:-1:1] zeros(1,N)],0*[.7,.7,.7],'FaceAlpha',.2,'EdgeColor','none')
    patch([[1:N] [N:-1:1]],[b c(end:-1:1)],.6*ones(1,3),'FaceAlpha',.2,'EdgeColor','none')
    d=vaps./cumsum(vaps,'reverse');
    plot(d,'LineWidth',1);
    ii=find(d>b');
    text(ii,d(ii),'*')
end
hold off
axis([1 length(b) 0 1])
ylabel('Add. explained energy as % of remaining energy ')
xlabel('Dims')
    end
end

function actualPlot(plotVar,varDist,name,plotHandle,text,textIdx)
subplot(plotHandle)
hold on
b=prctile(varDist',95);
c=prctile(varDist',5);
N=numel(c);
[h,icons,plots,s] = legend;
pp=patch([[1:N] [N:-1:1]],[b c(end:-1:1)],.6*ones(1,3),'FaceAlpha',.2,'EdgeColor','none');
p=plot(plotVar,'LineWidth',1);
%Add legend element with name

%Add text
if nargin>4
    for i=1:length(text)
        text(textIdx(i),plotVar(textIdx(i)),text{i},'horizontalalignment','left','FontSize',8);
    end
end
hold off
end