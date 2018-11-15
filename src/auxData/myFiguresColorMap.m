%Matlab default colors:
cc=[0    0.4470    0.7410
    0.8500    0.3250    0.0980
    0.9290    0.6940    0.1250
    0.4940    0.1840    0.5560
    0.4660    0.6740    0.1880
    0.3010    0.7450    0.9330
    0.6350    0.0780    0.1840];

%Transitions: yellow, purple
colorTransitions=cc(3:4,:);

%Colormap:
gamma=.5;
ex2=[0.2314    0.2980    0.7529];
ex2=cc(1,:); %Blue
ex1=[0.7255    0.0863    0.1608];
ex1=cc(7,:); %Deep red
map=[bsxfun(@plus,ex1.^(1/gamma),bsxfun(@times,1-ex1.^(1/gamma),[0:.01:1]'));bsxfun(@plus,ex2.^(1/gamma),bsxfun(@times,1-ex2.^(1/gamma),[1:-.01:0]'))].^gamma;

%Conditions: Gray, deep green, cyan
condColors=[.3*ones(1,3); .7*ones(1,3); 0,.5,.4; cc(6,:)];

%Legs: orange, apple-green
legColors=cc([5,2],:);