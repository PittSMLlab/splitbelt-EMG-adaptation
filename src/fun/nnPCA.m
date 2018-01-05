function [p,c,a] = nnPCA(data,k,centeredFlag)
%data needs to be in columns (size(data,1)>size(data,2))
%k needs to be number of dimensions (k<=size(data,2))
%First: do uncentered PCA
if nargin<3 || isempty(centeredFlag)
    centeredFlag=false;
end
[p_un,c_un]=pca(data,'Centered',centeredFlag);


i=k;
    if i>1
        [p,T]=rotatefactors(p_un(:,1:i),'MaxIt',1e3);
        c=c_un(:,1:i)*T;
    else
        p=p_un(:,1);
        c=c_un(:,1);
    end
    
    %Decide the best sign for each PC BEFORE rectifying:
    for j=1:size(p,2)
        %if abs(min(p(:,j)))>abs(max(p(:,j)))
        if mean(p(:,j))<0
            p(:,j)=-p(:,j);
        end
    end
    
    %Rectify PCs:
    p(p<0)=0;
    
    %Recompute projection onto PCs & rectify:
    c=data/p';
    c(c<0)=0;
    %Alt: Find optimal non-neg solution
    %for i=1:size(data,1) %Inefficient
    %    c(i,:)=lsqnonneg(p,data(i,:)');
    %end
    
    
    %Compute errors:
    D=c*p';
    a=norm(D - data,'fro')^2;
 


