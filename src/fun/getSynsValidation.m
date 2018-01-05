function [syns,coefsTrain,coefsTest,vapsTrain,vapsTest]=getSynsValidation(dataA,centered,methodFlag)
%% Pre-process
M=size(dataA);
m=mean(dataA,3); %Avg. waveform
mm=mean(m,2); % DC component
   
data=dataA(:,:,:,:,1); %Baseline only
if centered==1
    %Centered:
    data=bsxfun(@minus,data,mm);
elseif centered==2 
    %Trial-to-trial var
    data=bsxfun(@minus,data,m);
end
%Separating into testing & training sets (2-fold CV)
data1=data(:,:,1:2:end,:); 
data2=data(:,:,2:2:end,:);

data1=reshape(data1,M(1),M(2)*size(data1,3),M(4),1);
data2=reshape(data1,M(1),M(2)*size(data2,3),M(4),1);

newData1=bsxfun(@rdivide,data1,sqrt(sum(data1.^2,2))); %Normalizing by energy
newData2=bsxfun(@rdivide,data2,sqrt(sum(data2.^2,2))); %Normalizing by energy

%% Factorization
disp(['Computing synergy decomposition for all subjects...']);
for i=1:M(4)
    aux=newData1(:,:,i);
    aux2=newData2(:,:,i);
     switch methodFlag
         case 1 %NNMF
         %error('Under construction: This is not yet allowed for NNMF')
         [cc{i},pp{i},a{i}]=NNMFextract(aux,10);
         for j=1:M(1)
             ppTest{i}{j}=(cc{i}\aux2)'; %(?)
             aTest{i}(j)=norm(aux2-cc{i}*ppTest{i}{j}','fro').^2/norm(aux2,'fro'.^2);
         end
         
         case 2 %PCA
         [cc{i},pp{i},a{i}]=PCAextract(aux); 
         ppTest{i}=(cc{i}\aux2)';
         aTest{i}=norm(cc{i}'*aux2,'fro').^2 / norm(cc{i}'*cc{i},'fro').^2; %Is this right? Alt: do iteratively as in NNMF
     end
end
syns=cc;
coefsTrain=pp;
vapsTrain=a;
vapsTest=aTest;
coefsTest=ppTest;
disp(['... Done!'])
end

function [syns,coefs,vaps]=NNMFextract(data,replicates)
if nargin<2 || isempty(replicates)
    replicates=1;
end
for j=1:size(data,1);
    [syns{j},aux,vaps(j)] = nnmf(data,j,'replicates',replicates);
    coefs{j}=aux'; %So that the output has the same orientation as in PCA
end
vaps=-diff([1 vaps.^2/(norm(data,'fro')^2/numel(data))]);
end

function [syns,coefs,vaps]=PCAextract(data)
    [coefs,syns,vaps]=pca(data,'centered',false);
end

function [syns,coefs,vaps]=FAextract(data)
for j=1:size(data,1);
    [syns, vaps, ~, ~, coefs] = factoran(data', j);
end
end
function [syns,coefs,vaps]=ICAextract(data)
for j=1:size(data,1);
    [coefs, syns, ~] = fastica(data, 'numOfIC',j); %From FASTICA_25, external package
    vaps=[];
end

end