function B=BIC(SSR,k,n)
%Computes the BIC (under gaussian assumption) using the sum-of-squared-residuals SSR, number of free
%parameters k, and number of samples N

if nargin==1 %Assume SSR is actually a linear model from fitlm()
    B=BIC(SSR.SSE, SSR.NumCoefficients, SSR.NumObservations);
else
    B=n*log(SSR/n)+k*log(n);
end

%REF: https://en.wikipedia.org/wiki/Bayesian_information_criterion

end
