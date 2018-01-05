function [B,rowPermutation] = permuteRowsMaxAbsTrace(W)
%W needs to be a square matrix


MaxIter=100;
iter=0;
oldAbsTrace=0;
rowPermutation=1:size(W,2);
newB=nan(size(W));
stop=false;
B=W;
while ~stop
    iter=iter+1;
    
    if mod(iter,2)==1 %Odd iterations
        %Find the max element on each row:
        [~,ii]=max(abs(B),[],2); 

        %Make sure there are no colisions:
        ii=solveColitions(ii);

        %Permute
        if any(ii~=[1:size(W,2)]') %Change in row order
            newB(ii,:)=B; 
            %Compute new trace
            newAbsTrace=trace(abs(newB));
            change=(newAbsTrace>oldAbsTrace);
        else
            change=false;
        end
        
        %Update if we found a better permutation
        if change
            oldAbsTrace=newAbsTrace;
            B=newB;
            rowPermutation(ii)=rowPermutation;
        end
    
    else %Even iterations
        %Find the max element on each COLUMN:
        [~,ii]=max(abs(B),[],1); 

        %Make sure there are no colisions:
        ii=solveColitions(ii);

        %Permute
        if any(ii~=[1:size(W,2)]) %Change in row order
            newB=B(ii,:); 
            %Compute new trace
            newAbsTrace=trace(abs(newB));
            change=newAbsTrace>oldAbsTrace;
        else
            change=false;
        end
        
        %Update if we found a better permutation
        if change
            oldAbsTrace=newAbsTrace;
            B=newB;
            rowPermutation=rowPermutation(ii);
        end
    end
    
    

    %Determine end of loop
    stop = iter==MaxIter | ~change;
end

%Check for convergence:
if iter==MaxIter
    warning('MAx number of iterations reached')
end

%Validate permutation
if norm(B - W(rowPermutation,:),'fro')~=0
    error('Mis-computed permutation')
end



end

function newII=solveColitions(ii)
    list=1:length(ii);
    missingValues=setdiff(list,unique(ii)); %Returns elements NOT in the intersection and not repeated
    aux=bsxfun(@minus,ii,ii');
    [i,j]=find(aux==0);
    jj=find(j>i);
    repeatedPositions=(unique(j(jj)));
    repeatedValues=ii(repeatedPositions);
    newII=ii;
    newII(repeatedPositions)=missingValues(randperm(length(missingValues))); %Assigning in random order
end
