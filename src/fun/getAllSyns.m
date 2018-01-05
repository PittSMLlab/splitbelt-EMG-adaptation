function [syns,coefs,vaps,vapDist,vapDistRandom]=getAllSyns(dataA,centered,methodFlag,Nreps)
%% Pre-process
M=size(dataA);
if length(M)==3
    M(4)=1;
end
m=mean(dataA,3); %Avg. waveform
mm=mean(m,2); % DC component
   if nargin<4 || isempty(Nreps)
       Nreps=1e4;
   end
data=dataA(:,:,:,:,1); %Baseline only
clear dataA
if centered==1
    %Centered:
    data=bsxfun(@minus,data,mm);
elseif centered==2 
    %Trial-to-trial var
    data=bsxfun(@minus,data,m);
end
data=reshape(data,M(1),M(2)*M(3),M(4),1); %Cat-ting strides into a single time-series
newData=bsxfun(@rdivide,data,std(data,1,2)); %Normalizing by variance
%newData=bsxfun(@rdivide,data,sqrt(sum(data.^2,2))); %Normalizing by energy
clear data


%% PCA & NNMF
disp(['Computing synergy decomposition for all subjects...']);
Nmusc=M(1);
parfor i=1:M(4)
    aux=newData(:,:,i);
     switch methodFlag
         case 1 %NNMF
         [cc{i},pp{i},a{i}]=NNMFextract(aux,10);
         case 0 %PCA
         [cc{i},pp{i},a{i}]=PCAextract(aux); 
     end
end
disp(['... Done!'])
%% Shuffling
disp(['Computing eigen-value empiric distributions for all subjects...']);
vapDistRandom=[];
for shufMethod=1:2
clear AA*
if isempty(gcp('nocreate'))
    parpool
    poolFlag=1;
else
    poolFlag=0;
end
Nsubs=M(4);
AA=cell(Nsubs,1);
%BB=cell(Nsubs,1);
for i=1:Nsubs
    disp(['Subject ' num2str(i) ' of ' num2str(Nsubs)])
    aux=nan(Nmusc,Nreps);
    %aux2=nan(Nmusc,Nmusc,Nreps);
    dataB=newData(:,:,i);
    parfor k=1:Nreps
    %for k=1:Nreps
        
        %Shuffling data:
        switch shufMethod
            case 1 %Time-shifting 
                dataA=dataB;
                t=randi(size(dataA,2),M(1),1); %Generate random time to shift data for each muscle
                for j=1:M(1) %Each muscle
                    dataA(j,:)=circshift(dataA(j,:),[0 t(j)]);
                end
            case 2 %Generating data with stride-shifting only
                dataA=reshape(newData(:,:,i),M(1),M(2),M(3));
                for j=1:M(1)
                    dataA(j,:,:)=dataA(j,:,randperm(M(3))); %Shuffling stride order in each muscle
                end
                
        end
        %aux2(:,:,k)=dataA*dataA'; %Getting inner-product matrix for data checking purposes.
        switch methodFlag
            case 1 %NNMF:
            [~,~,aux(:,k)]=NNMFextract(dataA(:,:),1);
            case 0 %PCA:
            [~,~,aux(:,k)]=PCAextract(dataA(:,:));
        end
    end
    AA{i}=aux;
end
switch shufMethod
    case 1
        vapDist=AA;
    case 2
        vapDistRandom=AA;
end
end
syns=pp;
coefs=cc;
vaps=a;
if poolFlag==1
delete(gcp('nocreate'))
end
disp(['... Done!'])

end

%% Sub-functions for synergy extraction:
function [syns,coefs,vaps]=NNMFextract(data,replicates)
if nargin<2 || isempty(replicates)
    replicates=1;
end
for j=1:size(data,1)
    [syns{j},aux,vaps(j)] = nnmf(data,j,'replicates',replicates);
    coefs{j}=aux'; %So that the output has the same orientation as in PCA
end
vaps=-diff([1 vaps.^2/(norm(data,'fro')^2/numel(data))]);
end

function [syns,coefs,vaps]=PCAextract(data)
    [coefs,syns,vaps]=pca(data','centered',false);
end

function [syns,coefs,vaps]=FAextract(data)
for j=1:size(data,1)
    [syns, vaps, ~, ~, coefs] = factoran(data', j);
end
end
function [syns,coefs,vaps]=ICAextract(data)
[aux, syns, ~] = fastica(data','approach','symm','maxNumIterations',10000,'verbose','off'); %From FASTICA_25, external package
coefs=aux';
vaps=[];

end