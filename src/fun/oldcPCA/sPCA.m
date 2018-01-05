function [C,A,X,Yinf,r2] = sPCA(Y,order,forcePCS)
%sPCA or smooth PCA, aims at estimating a best-fit space-state model from
%given outputs Y, and assuming constant input. It is similar to cPCA, but
%it doesn't purposefully identify the canonical states
%It returns the a (best in some sense?) fit of the form (Y-Y_\infty)'~C*X ; with X(i+1,:)=A*X(i,:)
%where C are the first #order PCs from PCA, and A is a matrix with strictly real 
%& different eigen-vectors (no complex or double-pole solutions allowed)
%X is scaled such that X(0)=1 for all states.
%INPUTS:
%Y = N x D data matrix, representing N samples of d-dimensional data
%order: number of principal components to be estimated
%forcePCS: flag to indicate if the solution is constrained to be a linear transformation of the PCA subspace determined by first #order PCs
%OUTPUTS:
%C: D x order matrix, representing map from states to output (Y)
%A: evolution matrix for states, such that X(:,i+1)=A*X(:,i)
%X: smoothed state estimators
%V: matrix such that C~W*V (exact if forcePCS==1), where Y'~=W*H is the uncentered PCA factorization using the first #order PCs
%See also: sPCA_knownYinf

% Pablo A. Iturralde - Univ. of Pittsburgh - Last rev: Jun 14th 2017

if nargin<2 || isempty(order)
    order=2; %Minimum order for which this makes sense
end
if nargin<4 || isempty(forcePCS)
    forcePCS=false; %If true, this flag forces the columns of C to lie in the subspace spanned by the first #order PCs from PCA
end

NN=size(Y,1); %Number of samples
M=min(100,round(NN/10)); %Number of samples to be used to estimate steady-state
Yinf=nanmean(Y(end-M:end,:)); %Estimate of steady-state
YY=bsxfun(@minus,Y,Yinf);

[C,~,X,~] = sPCA_knownYinf(YY,order,forcePCS);

%In order to allow for the possibility that Yinf was misestimated because not enough data was available:
YY=YY+(C*X(:,end))';
Yinf=Yinf-(C*X(:,end))';
[C,A,X,r2] = sPCA_knownYinf(YY,order,forcePCS);

r2=1-norm(YY'-C*X,'fro')^2/norm(Y','fro')^2;
%TODO: with the estimation of C,A,X, re-estimate Yinf, re-estimate C,A,X, etc.
end

