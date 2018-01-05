function [V] = VAFalt(recData,origData)
%This definition of VAF was inspired by a poster at SfN2016
%They did: VAF = 1 -norm(Error,'fro')^2 / norm(demeaned(data),'fro')^2
%I don't think this is a good way to do it (error matrix is difference
%between actual reconstruction and actual data, but the normalizing term is
%the demeaned data). If the mean of the reconstructed and original data is
%the same, then this is equivalent to my VAF() function. Otherwise, it has
%an additional bias term given by the squared difference of means. In
%general this will be a small, but non-zero, value.

%A way to implement it using my EAF() function is:
errData=recData-origData;
origData=bsxfun(@minus,origData,mean(origData));

V=EAF(origData+errData,origData);
end

