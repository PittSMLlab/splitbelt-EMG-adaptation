function [C,J,X,V,r2] = cPCA_knownYinf(Y,order,forcePCS,useSPCA,estimSize)
%cPCA or canonic PCA, aims at estimating a canonical space-state model from
%given outputs Y, and assuming constant input.
%It returns the a (best in some sense?) fit of the form Y'~C*X;
%X(i+1,:)=J*X(i,:), where J is a Jordan's canonical form matrix.
%This function can be used to do system-identification provided that the
%data corresponds to a constant input system and the steady-state of Y is 0.
%It works in three steps:
%1) Approximate Y' ~ W*H through uncentered PCA with #order
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
%V: matrix such that C~W*V (exact if forcePCS==1), where Y'~=W*H is the uncentered PCA factorization using the first #order PCs

% Pablo A. Iturralde - Univ. of Pittsburgh - Last rev: Jun 14th 2017


NN=size(Y,1); %Number of samples
D=size(Y,2); %Dimensionality of data
if nargin<2 || isempty(order)
    order=2; %Minimum order for which this makes sense
end
if nargin<5 || isempty(estimSize)
    N=2^6; %Integer geq 0 & leq NN [ideally N < 3*tau, where tau is the fastest decay rate]
else
    N=estimSize;
end
if nargin<3 || isempty(forcePCS)
   forcePCS=false; 
end
if nargin<4 || isempty(useSPCA)
   useSPCA=true;
end

%Initialize solution:
if useSPCA
    %Pro: we can use N=1 because PP is smooth
    %Con: requires an optimization in sPCA
    [W,An,H] = sPCA_knownYinf(Y,order,forcePCS); N=1;
else
    %Pro: fast to compute
    %Con: requires large N, and we should optimize over N
    [p,c]=pca(Y','Centered',false);
    H=p(:,1:order)'; W=c(:,1:order);
    An=H(:,N+1:end)/H(:,1:end-N); %Robust identification: Estimate A^N, ie the system evolution N steps in the future
end

if any(eig(An)<0) %Throw error if we have discrete eigen values <0
    error('Best-fit dynamics matrix returned a negative eigen-value, which makes no sense. Try with smaller order.')
    %If N is even, this means at least one complex eigen value (not paired!) for J.
    %If N is odd we can salvage this for strictly diagonal matrices by taking J=diag(diag(Jn).^(1/N)); which has at least one real solution.   
    %Long run solution: instead of just taking the Jordan form of An, find the J matrix that is Jordan form AND minimizes norm( J^N -jordan(An),'fro').
end

%% Find linear transformation to Jordan's canonical form [transformation for A^N -> J^N is the valid for A->J too]
[V,Jn] = jordan(An);
% Deal with complex solutions:
a=imag(diag(Jn)); b=real(diag(Jn));
if any(abs(a./b)>1e-15) %If there are (truly) complex eigen-values, will transform to the real-jordan form
    [~,Jn] = cdf2rdf(V,Jn);
else %This is to avoid numerical errors from negligible imaginary parts
    Jn=real(Jn);
end
J=Jn^(1/N); %Estimate of J: Equivalent if N is power of 2: N=2^n and then take sqrtm n times.

%% Estimate X: arbitrary scaling: (there has to be a more efficient way to do it)
X=ones(order,NN); %A different initial condition will be needed if one of the true states has 0 initial value, and J is not diagonal.
for i=2:NN
    X(:,i)=J*X(:,i-1);
end

%% Estimate C:
if ~forcePCS %This allows C to escape the subspace spanned by the PCs from PCA
    C=Y'/X; %Improves performance (r2) and suggests use of alternating optimization scheme by repeating the first steps with the new X
else
    C=(W*H)/X; %Only projecting data within PCA subspace, just for scaling purposes
end
V=W\C; %Best linear projection of states onto PCA states

%% Compute reconstruction value
r2=1-norm(Y'-C*X,'fro')^2/norm(Y','fro')^2; %This is for the smoothed/estimated states, otherwise it would just be the same as PCA performance
end

