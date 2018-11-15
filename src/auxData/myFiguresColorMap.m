%Matlab default colors:
cc=[0    0.4470    0.7410
    0.8500    0.3250    0.0980
    0.9290    0.6940    0.1250
    0.4940    0.1840    0.5560
    0.4660    0.6740    0.1880
    0.3010    0.7450    0.9330
    0.6350    0.0780    0.1840];
colorTransitions=cc(3:4,:);

%Colormap:
gamma=.5;
ex2=[0.2314    0.2980    0.7529];
ex1=[0.7255    0.0863    0.1608];
map=[bsxfun(@plus,ex1.^(1/gamma),bsxfun(@times,1-ex1.^(1/gamma),[0:.01:1]'));bsxfun(@plus,ex2.^(1/gamma),bsxfun(@times,1-ex2.^(1/gamma),[1:-.01:0]'))].^gamma;

%condColors=[.4,.4,.4; 0,.5,.4; .5,.2,.6];
condColors=[.4*ones(1,3); cc(6:7,:);cc(1,:)];
legColors=cc([5,2],:);