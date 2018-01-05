function [E] = R2(recData,origData)
%Check matrix sizes:

E=1-norm(recData-origData,'fro')^2/sum(size(origData,1)*var(origData,1));
end

