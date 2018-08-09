figure; 
aa=eA(:,r2All2a<.3);
bb=eP(:,r2All2a<.3)-lA(:,r2All2a<.3);
subplot(2,3,1);imagesc(reshape(mean(aa,2),12,30)'); figuresColorMap; caxis(.5*[-1 1]); colormap(flipud(map)); title('eA bad')
subplot(2,3,2);imagesc(reshape(mean(eA,2),12,30)'); figuresColorMap; caxis(.5*[-1 1]); colormap(flipud(map)); title('eA all')
subplot(2,3,3);imagesc(reshape(mean(eA,2)-median(aa,2),12,30)'); figuresColorMap; caxis(.5*[-1 1]); colormap(flipud(map)); title('eA diff')
subplot(2,3,4);imagesc(reshape(mean(bb,2),12,30)'); figuresColorMap; caxis(.5*[-1 1]); colormap(flipud(map)); title('eP-lA bad')
subplot(2,3,5);imagesc(reshape(mean(eP-lA,2),12,30)'); figuresColorMap; caxis(.5*[-1 1]); colormap(flipud(map)); title('eP-lA all')
subplot(2,3,6);imagesc(reshape(mean(eP-lA,2)-median(bb,2),12,30)'); figuresColorMap; caxis(.5*[-1 1]); colormap(flipud(map)); title('eP-lA diff')
