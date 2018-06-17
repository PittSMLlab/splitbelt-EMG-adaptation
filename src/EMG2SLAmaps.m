%% Load from data directory
load('dynamicsData.mat')
load('controlsEMGsummary.mat', 'labels')
%% Get some data
c=3;
subs=[1:13,15:16]; %Excluding subject 14, has bad data, (WHY???)
strides=50:205;
B=dataContribs{c}(strides,:,subs);
B1=dataContribs{1}(5:45,:,subs); %Baseline strides
B=B-mean(B1,1);
A=allDataEMG{c}(strides,:,subs);
A1=allDataEMG{1}(5:45,:,subs);
A=A-mean(A1,1);
figure; subplot(1,2,1); plot(squeeze(B));subplot(1,2,2); imagesc(reshape(median(median(A,1),3),12,size(A,2)/12)');caxis([-1 1]*.5);
%% regress
AA=reshape(permute(A,[1,3,2]),numel(strides)*numel(subs),360);
%AA=median(A,3); %Merging subjects first
AA=AA(:,1:180)-AA(:,181:360); %symmetry terms only
AA=AA(:,1:2:end)+AA(:,2:2:end); %Merging phases, to get better conditioned problem
BB=reshape(B,numel(strides)*numel(subs),1);
%BB=median(B,3);
C=BB'/AA';
%%
figure; subplot(1,2,1); imagesc(reshape(median(AA,1),6,size(AA,2)/6)');caxis([-1 1]);subplot(1,2,2);imagesc(reshape(C,6,numel(C)/6)');caxis([-1 1]*.05);
norm(BB-AA*C','fro')/norm(BB,'fro')