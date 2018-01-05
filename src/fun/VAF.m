function [V] = VAF(recData,origData)
%This assessment corresponds to just comparing how much variance is being
%reconstructed from the original data. The reconstructed data may have ANY
%mean (which may or may not correspond to the mean of the original data)
%and it doesn't affect the result.
% It is a good indicator of performance if we first demean the original
% data, and then come up with a reconstruction that has zero mean 
%(i.e we impose the mean of the reconstructed data on the model)
Nmusc=size(recData,2);
%V=trace(corr(recData,origData).^2)/Nmusc;

%Is this the best definition? Or the one commented above?
V=EAF(bsxfun(@minus,recData,mean(recData)),bsxfun(@minus,origData,mean(origData)));
end

