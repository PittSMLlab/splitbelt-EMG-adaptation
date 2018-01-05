function [B,rowPermutation] = permuteRowsMaxAbsEigenOrder(W,check)
%Permutes row such that the (1,1) element is the highest it can be, then
%the (2,2) element is the highest it can be leaving (1,1) fixed, and so on.
if nargin<2 || isempty(check)
    check=0;
end
%W needs to be a square matrix
D=size(W,1);
rowPermutation=nan(1,D);
B=W;
blockedRows=zeros(D,1);
blockedColumns=zeros(D,1);
for iter=1:D
    BB=abs(W);
    BB(blockedRows==1,:)=-1;
    BB(:,blockedColumns==1)=-1;
    %Find the max element:
    %if max(abs(BB(:)))>0
        [ii,jj]=find((BB)==max((BB(:))));
        rowPermutation(jj)=ii;
        blockedRows(ii)=1;
        blockedColumns(jj)=1;
        
    %end
end
%rowPermutation(isnan(rowPermutation))=find(diff([0 sort(unique(rowPermutation),'ascend')])>1);
B=W(rowPermutation,:);
if check==0
    [B1,rowPermutation1] = permuteRowsMaxAbsEigenOrder(B,1);
    if any(rowPermutation1~=1:D)
        error('Mis-permutation')
    end
end
end