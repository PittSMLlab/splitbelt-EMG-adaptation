clearvars
figuresColorMap
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