%Some math to compute p(n>M|Ho), where n is the number of subjects that
%return signifcant differences out of a pop of N.
N=16;
beta=.05/180;
clear C b
for k=1:N
    C(k)=nchoosek(N,k);
end

b=beta.^([1:N]-1);

a=b.*C