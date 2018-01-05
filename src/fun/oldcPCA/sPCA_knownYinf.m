function [C,A,X,r2] = sPCA_knownYinf(Y,order,forcePCS)
%sPCA or smooth PCA, aims at estimating a best-fit space-state model from
%given outputs Y, and assuming constant input. It is similar to cPCA, but
%it doesn't purposefully identify the canonical states
%It returns the a (best in some sense?) fit of the form Y'~C*X; with X(i+1,:)=A*X(i,:)
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

% Pablo A. Iturralde - Univ. of Pittsburgh - Last rev: Jun 14th 2017

if nargin<2 || isempty(order)
    order=2; %Minimum order for which this makes sense
end
if nargin<3 || isempty(forcePCS)
    forcePCS=false; %If true, this flag forces the columns of C to lie in the subspace spanned by the first #order PCs from PCA
end

NN=size(Y,1); %Number of samples
D=size(Y,2); %Dimensionality of data

%Do PCA to extract the #order most meaningful PCs:
[p,c,a]=pca(Y','Centered',false);
C=c(:,1:order);
P=p(:,1:order);
r2=sum(a(1:order))/sum(a);

%Optimize to find best decaying exponential fits:
M0=eye(order);
t0=.33*NN*([1:order]'/order).^2;
E0=myfun(M0,t0,NN);
M0=(P')/E0;
xx=[M0(:); t0];
convergence=false;
iter=0;
if forcePCS
    maxIter=1; %If we are forcing PCA subspace there is no need to iterate
else
    maxIter=4; 
end
%M=norm(Y','fro');
lb=[-Inf*ones(size(M0(:))); zeros(size(t0))];
ub=[Inf*ones(size(M0(:))); 5*NN*ones(size(t0))];
opts=optimoptions('lsqnonlin','FunctionTolerance',1e-15,'OptimalityTolerance',1e-15,'StepTolerance',1e-15,'MaxFunctionEvaluations',1e5,'MaxIterations',3e3);
while ~convergence && iter<maxIter %Smooth p by fitting decaying exponentials:
    P=C\Y';
    iter=iter+1;
    %[xx,~,~,exitflag]=lsqnonlin(@(x) M*(1/(NN*D))/min(abs(1 - x(order^2+[1:order-1])./x(order^2+[2:order]))) + Y'-C*myfun(reshape(x(1:order^2),order,order),x(order^2+[1:order])),xx); %Penalizing time constants that are too similar
    [xx,~,~,exitflag]=lsqnonlin(@(x) P - myfun(reshape(x(1:order^2),order,order),x(order^2+[1:order]),NN),xx,lb,ub,opts);
    
    X=myfun(reshape(xx(1:order^2),order,order),xx(order^2+[1:order]),NN);
    if ~forcePCS
        C=Y'/X; %This allows C to escape the subspace spanned by the PCs from PCA, and improves r2 slightly
    end
    r2old=r2;
    r2=1-norm(Y'-C*X,'fro')^2/norm(Y','fro')^2;
    convergence=exitflag>0 & abs(r2-r2old)<1e-4;
end

A=X(:,2:end)/X(:,1:end-1); %This should have an exact solution, not just in the LS sense
r2=1-norm(Y'-C*X,'fro')^2/norm(Y','fro')^2;
end

function f=myfun(M,tau,NN) %M has to be order x order matrix, tau has to be order x 1 vector
    f=M*exp(-bsxfun(@rdivide,[0:NN-1],tau));
end
