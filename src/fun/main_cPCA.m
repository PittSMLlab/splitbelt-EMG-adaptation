%Idea: given some observed dynamical system, identify the eigen-states of
%the evolution dynamics

%Generate data corresponding to over-damped second order system with 360-D
%output (Y)
D=360;
NN=900;
v1=randn(D,1);
%v1=sort(v1);
%v1=fftshift(v1);
v2=randn(D,1);
%v2=sort(v2);
%v2=fftshift(v2);
v3=randn(D,1);
%v3=sort(v3);
%v3=fftshift(v3);
tt=[exp(-[0:(NN-1)]/50); exp(-[0:(NN-1)]/200)];
Y=bsxfun(@plus,v1*tt(1,:)+v2*tt(2,:),v3);
Y=Y+randn(size(Y));


%Method one: identify dynamics from early & late components
early=nanmedian(Y(:,3:10),2);
late=nanmedian(Y(:,end-100:end),2); %This should be close to v3
C1=[early,late];
X1=C1\Y;
X1=X1';

%Method two: do PCA after subtracting steady-state
order=2;
Yinf=nanmedian(Y(:,end-100:end),2);
[X2,C2,D2]=pca(Y-Yinf,'Centered',false);
X2=X2(:,1:order);
C2=C2(:,1:order);

%Now, do canonical PCA:
[C3,J,X3,~] = cPCA((Y-Yinf)',order,2^5-1,1);
[~,JJ]=jordan(J);

%% Visualize results
figure
ex1=[.85,0,.1];
ex2=[0,.1,.6];
map=[bsxfun(@plus,ex1,bsxfun(@times,1-ex1,[0:.01:1]'));bsxfun(@plus,ex2,bsxfun(@times,1-ex2,[1:-.01:0]'))];
for i=1:4 %Three methods + original vectors
    switch i
        case 1
            PC=[C1,zeros(size(late))];
            coefs=X1;
            t=['Early/Late proj'];
        case 2
            PC=[C2 Yinf];
            coefs=X2;
            scale=median(coefs(3:10,:));
            coefs=bsxfun(@rdivide,coefs,scale);
            PC(:,1:end-1)=bsxfun(@times,PC(:,1:end-1),scale);
            t=['PCA'];
        case 3
            PC=[C3 Yinf];
            coefs=X3';
            scale=median(coefs(3:10,:));
            coefs=bsxfun(@rdivide,coefs,scale);
            PC(:,1:end-1)=bsxfun(@times,PC(:,1:end-1),scale);
            t=['cPCA, \tau= ' num2str(-1./log(diag(J)'),3)];
        case 4
            PC=[v1,v2,v3];
            coefs=tt';
            t=['Actual, \tau= 50, 200'];
    end
    for j=1:size(PC,2)+1 %Two/three PCs and dynamics plot
        subplot(4,4,(i-1)*4+j)
        if j<=size(PC,2)
        hold on
        imagesc(reshape(PC(:,j),12,30)')
        if j<size(PC,2)
        title(['PC' num2str(j)])
        else
            title(['Y_\infty'])
        end
        else
            plot(coefs)
            title(t)
            grid on
        end
        axis tight
    end
    
end
colormap(flipud(map))