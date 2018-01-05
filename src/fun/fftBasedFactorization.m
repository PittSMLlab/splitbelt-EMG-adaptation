function [C,P,d] = fftBasedFactorization(X,bestPhaseFlag,improveFlag)
% Takes data matrix X [NxD] and returns a low-dim factorization of rank k
if nargin<2 || isempty(bestPhaseFlag)
    bestPhaseFlag=0;
end
if nargin<3 || isempty(improveFlag)
    improveFlag=0;
end
[N,D]=size(X);
F=fft(X);
k=D;

%This can be improved by considering the (a+bi)*F direction that has
%maximal energy, as opposed to limiting ourselves to the pure real or imag
%parts.

M=ceil((N+1)/2);
Ma=floor((N+1)/2);
Faux=F(1:M,:); %Discarding second half of fft, assuming X is real
Faux(2:Ma,:)=sqrt(2)*Faux(2:Ma,:); %Doubling the components whose energy is divided in the two halves of fft
switch bestPhaseFlag %TODO: simplify this
    case 0%Separating imaginary and real as distinct components
        Faux=[real(Faux); 1i*imag(Faux)]; 
        F1=mean(abs(Faux).^2,2);
    case 2 %Find the best aligned component, and forgo the orthogonal one
        aaux=mean(Faux,2); %Contrary to my belief, this is not the direction of max energy
        aaux=aaux./abs(aaux);
        Faux=bsxfun(@times,bsxfun(@times,conj(aaux),Faux),aaux); %Projection over the best direction
        F1=mean(abs(Faux).^2,2); 
    case 3 %Find the best aligned component, but also consider the orthogonal one
        aaux=mean(Faux,2);
        aaux=aaux./abs(aaux);
        Faux2=bsxfun(@times,real(bsxfun(@times,conj(aaux),Faux)),aaux); %Projection over the best direction
        Faux3=Faux-Faux2;
        Faux=[Faux2; Faux3];
        F1=mean(abs(Faux).^2,2);
    case 1%This guarantees cos() sin() pairs will always be chosen
        %which is less generic than choosing the best across all cos()
        %sin() components, but it requires less 'info'
        %If we take the original data X and randomly time-shift each column
        %independently, the fftBasedFactorization() remains unchanged
        Faux=[abs(Faux); 1i*[zeros(1,D); abs(Faux(2:end,:))]];  
        F1=mean(abs(Faux).^2,2);
end

[F2,ii]=sort(F1,'descend');

i1=ii(1:k); %Keeping first k components
d=F2(1:k)/sum(F2); %Explanatory value of each component in terms of energy, as % of total 

C=nan(N,k);
P=nan(D,k);
for l=1:length(i1)
    aux=zeros(N,1);
    aa=mean(Faux(i1(l),:));
    aux(mod(i1(l)-1,M)+1)=aa/abs(aa);
    Caux=ifft(aux);
    C(:,l)= real(Caux);
    P(:,l)=X'*C(:,l) / norm(C(:,l))^2;
end

if improveFlag~=0
%This is an improvement: instea of considering just pure sinusoidals, ONCE we identify 
%the harmonics that explain the most variance, we look for other
%sinusoidals that are phasically aligned to the ones we identify, and we
%can partially explain those too. This means: 
%we use spectrum to choose sinusoidals, use sinusoidals to identify PCs, and then project onto those PCs 

%If we consider the fftBasedFactorization() something that depends ONLY on
%individual channel spectrums, this is cheating, as we are using some data
%correlations across channels to improve performance. However, the subspace
%chosen by the previous method (sines and cosines) remains.

%First: orthonormalize PCs
for l=1:length(i1)
    if l>1
        P(:,l)= P(:,l) -  P(:,1:(l-1))*(P(:,1:(l-1))'*P(:,l));
    end
    P(:,l)=P(:,l)/norm(P(:,l));
end
%Second: get coefs
C=X/P'; %Solving through least squares
end




end

