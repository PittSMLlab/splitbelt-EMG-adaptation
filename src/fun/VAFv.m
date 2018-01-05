function [V] = VAFv(recData,origData)
%This assessment corresponds to shape comparison of the reconstructed data:
%We subtract the mean, normalize to the std and compute the corrcoef
%(Pearson's) squared

Nmusc=size(recData,2);
%V=trace(corr(recData,origData).^2)/Nmusc;

%Is this the same as above?,.
recData=bsxfun(@minus,recData,mean(recData));
recData=bsxfun(@rdivide,recData,std(recData,0));
origData=bsxfun(@minus,origData,mean(origData));
origData=bsxfun(@rdivide,origData,std(origData,0));
V=EAF(recData,origData);
end

