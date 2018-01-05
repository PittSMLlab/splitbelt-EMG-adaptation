function [Eu,Ru,Vu,Vvu] = factorizeAndAssess(Y,method)

switch method %This can be expanded to allow NNMF
    case 'Uncentered'
        cFlag=false;
    otherwise
        cFlag=true;
end
if ~iscell(Y)
    Y1{1}=Y;
    Y=Y1;
end
for i=1:length(Y)
    D=size(Y{i},2);
   [Pu{i},Cu{i},Au{i}]=pca(Y{i},'Centered',cFlag);
    for k=1:D
        recData=Cu{i}(:,1:k)*Pu{i}(:,1:k)';
        if cFlag
            recData=bsxfun(@plus,recData,mean(Y{i}));
        end
        [Eu(i,k),Ru(i,k),Vu(i,k),Vvu(i,k)] = recAssess(recData,Y{i});
    end
end

end

