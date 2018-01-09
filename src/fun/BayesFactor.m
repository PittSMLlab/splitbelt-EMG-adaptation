function [BF,Delta_BIC] = BayesFactor(linModel,robustFlag)
%Computes the Bayes Factor (approxmated from BIC) of a given linear model vs. a constant model
%linModel needs to come from fitlm()
%If robustFlag is true, BayesFactor is computed N-times, leaving 1 sample
%out of model estimation each time, and computing likelihood through that
%sample alone, then taking the product of individual sample likelihoods

if nargin>1 && robustFlag
    error('Unimplemented')
    %Should we take the product of likelihoods for each sample or, for
    %robustness, take something like the median across them?
    
    
else    
    %Using BIC approximation
    nullModel=fitlm(linModel.Variables,[linModel.ResponseName '~1']);
    
    BIC_0=BIC(nullModel);
    BIC_1=BIC(linModel);
    Delta_BIC=BIC_1-BIC_0;
    
    %Sanity check with Matlab's computation of BIC:
    DB=linModel.ModelCriterion.BIC-nullModel.ModelCriterion.BIC;
    if abs(Delta_BIC-DB)>1e-9
        error('Inconsistent BIC with Matlab''s computation')
    end
    BF=exp(-Delta_BIC/2); %Approximation from Wagenmaker 2007 
end





end

