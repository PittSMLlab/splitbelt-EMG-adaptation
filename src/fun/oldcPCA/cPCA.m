function [C,J,X,Yinf,V,r2] = cPCA(Y,order,forcePCS,useSPCA,estimSize)
%cPCA or canonic PCA, aims at estimating a canonical space-state model from
%given outputs Y, and assuming constant input.
%It returns the a (best in some sense?) fit of the form (Y-Y_\infty)'~C*X;
%X(i+1,:)=J*X(i,:), where J is a Jordan's canonical form matrix.
%This function can be used to do system-identification provided that the
%data corresponds to a constant input system and the steady-state of Y is 0.
%It works in three steps:
%1) Approximate (Y-Y_\infty)' ~ W*H through uncentered PCA with #order
%2) Linearly transform C=W*V and V*Z=H , minimizing (Z-X) with X(:,i+1)=J*X(:,i), X(:,1)=1, with J canonical Jordan form
%3) If ~forcePCS (default), recompute the optimal C given the smoothed states X.
%INPUTS:
%Y = N x D data matrix, representing N samples of d-dimensional data
%order: number of principal components to be estimated
%estimSize: step-size considered to perform the estimation, larger sizes return more robust estimations.
%forcePCS: flag to indicate if the solution is constrained to be a linear transformation of the PCA subspace determined by first #order PCs
%useSPCA: (Default=true) flag to indicate the use of sPCA to initialize solution 
%OUTPUTS:
%C: D x order matrix, representing map from states to output (Y)
%J: evolution matrix for states, such that X(:,i+1)=J*X(:,i)
%X: smoothed state estimators, forcing X(:,1)=1 (WLOG)
%V: matrix such that C~W*V (exact if forcePCS==1), where (Y-Y_\infty)'~=W*H is the uncentered PCA factorization using the first #order PCs
%See also: cPCA_knownYinf, sPCA

% Pablo A. Iturralde - Univ. of Pittsburgh - Last rev: Jun 14th 2017

if nargin<2 || isempty(order)
    order=2; %Minimum order for which this makes sense
end
if nargin<3 || isempty(forcePCS)
   forcePCS=false; 
end
if nargin<4 || isempty(useSPCA)
    useSPCA=true;
end

NN=size(Y,1); %Number of samples
if nargin<5 || isempty(estimSize)
    estimSize=NN/5;
end

%Estimate Yinf:
M=min(100,round(NN/10)); %Number of samples to be used to estimate steady-state
Yinf0=nanmean(Y(end-M:end,:)); %Estimate of steady-state: this assumes the decay rates are much shorter than #samples
YY=bsxfun(@minus,Y,Yinf0);

%Do cPCA:
[C,~,X,~,~] = cPCA_knownYinf(YY,order,forcePCS,useSPCA,estimSize);

%In order to allow for the possibility that Yinf was misestimated because not enough data was available:
for i=1:5
Yinf=Yinf-.5*(C*X(:,end-M/2))';
YY=bsxfun(@minus,Y,Yinf);
[C,J,X,V,r2] = cPCA_knownYinf(YY,order,forcePCS,useSPCA,estimSize); %In practice this doesn't seem to change anything

ra=1-norm((Y'-Yinf')-C*X,'fro')^2/norm(Y','fro')^2
end
%TODO: iterate over estimations of Yinf and C,J,X

r2(2)=ra;
end

