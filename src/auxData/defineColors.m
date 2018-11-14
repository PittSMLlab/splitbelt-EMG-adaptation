clearvars
cc=get(gca,'ColorOrder');
colorTransitions=cc(3:4,:);

%Colormap:
gamma=.5;
ex2=[0.2314    0.2980    0.7529];
ex1=[0.7255    0.0863    0.1608];
map=[bsxfun(@plus,ex1.^(1/gamma),bsxfun(@times,1-ex1.^(1/gamma),[0:.01:1]'));bsxfun(@plus,ex2.^(1/gamma),bsxfun(@times,1-ex2.^(1/gamma),[1:-.01:0]'))].^gamma;

%condColors=[.4,.4,.4; 0,.5,.4; .5,.2,.6];
condColors=[.4*ones(1,3); cc(6:7,:);cc(1,:)];
legColors=cc([5,2],:);
save Colors.mat colorTransitions condColors map legColors

figure;
subplot(3,1,1)
hold on;
for i=1:size(condColors,1)
plot(1:100,sin(2*pi*[1:100]/100+i),'LineWidth',2,'Color',condColors(i,:))
end
subplot(3,1,2)
hold on;
for i=1:size(colorTransitions,1)
plot(1:100,sin(2*pi*[1:100]/100 +i),'LineWidth',2,'Color',colorTransitions(i,:))
end
subplot(3,1,3)
imagesc(randn(30,12))
colormap(flipud(map))