function [f1,ph]=assessDimExcess(vapsI,vapDistI,subList,bilateral,vapsC,vapDistC,meanOnly,plotHandles)

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
allVapsDist(:,:,i)=vapsDist;

%First plot: cumulative energy explained
[~,ii]=max((cumsum(vaps(:))-prctile(cumsum(vapsDist)',95)')); %Get max-gap to the 95% percentile.
%[zz,ii]=max((cumsum(vaps(:))-mean(cumsum(vapsDist),2))./(std(cumsum(vapsDist),[],2)));
%%Get max z-score: this doesn't work well, because there is a cumulative
%%effect
allII(i)=ii;
if meanOnly==0
    actualPlot(cumsum(vaps(:)),cumsum(vapsDist),subList{i}([1,4,5]),ph(k),{[subList{i}([1,4,5]) ' = ' num2str(ii) ' \rightarrow']},ii)
else
   if i== length(vapsI)
       ii=[mean(allII),median(allII)];
       actualPlot(cumsum(allVaps),cumsum(allVapsDist),subList{i}([1,4,5]),ph(k),{['Avg. dim = ' num2str(ii(1)) ' \rightarrow     '],['       \leftarrow ' num2str(ii(2)) ' = Median. dim ']},ii);
   end
end
if i==length(vapsI)
axis([1 N 0 .25])
grid on
if k==1
    title('Paretic/Non-dominant (slow)')
else
    title('Non-paretic/Dominant (fast)')
end
ylabel('Excess EAF as %')
xlabel('Dims')
text(length(vaps)/2,.1,['Dimension chosen as max cumulative explanation in excess of 95% CI'])
end


%Second plot: energy explained per dim
[ii]=find(vaps(:)>prctile(vapsDist',95)',1,'last');
try
    allII2(i)=ii;
catch %Empty case
    allII2(i)=0;
end
if meanOnly==0
    actualPlot(vaps,vapsDist,subList{i}([1,4,5]),ph(bigK+k),{'',['\leftarrow = ' num2str(ii) ' ' subList{i}([1,4,5])]},[1,ii])
else
   if i== length(vapsI)
       ii=[mean(allII2),median(allII2)];
       actualPlot(allVaps,allVapsDist,'Group avg',ph(bigK+k),{['Avg. dim = ' num2str(ii(1)) ' \rightarrow     '],['       \leftarrow ' num2str(ii(2)) ' = Median. dim ']},ii);
   end
end
if i==length(vapsI)
axis([1 N -.02 .08])
ylabel('Add. excess EAF %')
xlabel('Dims')
text(length(vaps)/2,.05,['Dimension chosen as last above 95% CI'])
end


%Third plot: energy explained per dim, as % of remaining energy
[ii]=15;
values=vaps./cumsum(vaps,'reverse');
sample=(vapsDist./cumsum(vapsDist,1,'reverse'));
[pp,ii]=max(getPval(values(1:end-1)',sample(1:end-1,:)'));
%[zz,ii]=max((vaps./cumsum(vaps,'reverse') - mean(vapsDist./cumsum(vapsDist,1,'reverse'),2))./(std(vapsDist./cumsum(vapsDist,1,'reverse'),[],2)));
allII3(i)=ii;
if meanOnly==0
    actualPlot(vaps./cumsum(vaps,'reverse'),vapsDist./cumsum(vapsDist,1,'reverse'),subList{i}([1,4,5]),ph(2*bigK+k),{'',['\leftarrow = ' num2str(ii) ' ' subList{i}([1,4,5])]},[1,ii])
else
   if i== length(vapsI)
       ii=[mean(allII3),median(allII3)];
       aux=allVaps./cumsum(allVaps,'reverse');
       aux2=allVapsDist./cumsum(allVapsDist,1,'reverse');
       actualPlot(aux,aux2,'Group avg',ph(2*bigK+k),{['Avg. dim = ' num2str(ii(1)) ' \rightarrow     '],['       \leftarrow ' num2str(ii(2)) ' = Median. dim ']},ii);
   end
end
if i==length(vapsI)
%patch([[1:N] [N:-1:1]],[1./[N:-1:1] zeros(1,N)],0*[.7,.7,.7],'FaceAlpha',.4,'EdgeColor','none')
axis([1 N -.03 .1])
ylabel('Add. excess EAF as % of remainder')
xlabel('Dims')
text(length(vaps)/2,.05,['Dimension chosen as max p-value'])
end
    end
end
end

function actualPlot(plotVar,varDist,name,plotHandle,textC,textIdx)
subplot(plotHandle)
hold on
if ndims(varDist)==3 %Distribution for many subjects
    b=mean(prctile(varDist,95,2),3)';
    c=mean(prctile(varDist,5,2),3)';
    d=mean(prctile(varDist,50,2),3)';
    plotVar=mean(plotVar,2);
else
b=prctile(varDist',95);
c=prctile(varDist',5);
d=prctile(varDist',50);
end
plotVar=plotVar-d';
N=numel(c);
[h,icons,plots,s] = legend;
p=plot(plotVar,'LineWidth',1);
%pp=patch([[1:N] [N:-1:1]],[b c(end:-1:1)],p.Color,'FaceAlpha',.2,'EdgeColor','none');

%Add legend element with name

%Add text
if nargin>5
    %textIdx=round(textIdx);
    for i=2%1:length(textIdx)
        switch i
            case 2
                tt='left';
            case 1
                tt='right';
        end 
        text(textIdx(i),plotVar(round(textIdx(i)))+.01,textC{i},'horizontalalignment',tt,'FontSize',8,'Color',p.Color);
    end
end
hold off
end

function pp=getPval(value,empiricSample)
    %uses empiricSample to construct CDF by COLUMNS
    %Number of ROWS of empiricSample needs to be the same as value 
    p=[.1:.1:1,2:10,20:80,90:98,99:.1:99.9];
    pp=nan(size(value));
    for i=1:size(empiricSample,2)
        x=prctile(empiricSample(:,i),p);
        pp(i)=interp1(x,p,value(i));
    end
end