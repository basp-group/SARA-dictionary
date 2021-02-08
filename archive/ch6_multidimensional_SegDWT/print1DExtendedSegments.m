function print1DExtendedSegments(segment,fig,c,no,ii)
cornerOrig = segment{1,2};
segSizeOrig = segment{1,3};
cornerExt = segment{2,2};
segSizeExt = segment{2,3};


figure(fig(1));
subplot(no,1,ii);

hold on;

stem(cornerExt:cornerExt+segSizeExt-1,segment{2,1}(end-segSizeExt+1:end),'Color',[0.7 0.7 0.7]);
stem(cornerOrig:cornerOrig+segSizeOrig-1,segment{1,1},'Color',c);
plot(cornerExt:cornerExt+segSizeExt-1,segment{2,1}(end-segSizeExt+1:end),'Color',[0 0 0],'LineWidth',2);

xlim([0, segment{5,2}(1)]);
ylim(1.01*[0, max(segment{2,1})]);
hold off;

figure(fig(2));
subplot(no,1,ii);
hold on;
stem(cornerExt:cornerExt+segSizeExt-1,segment{5,1}(end-segSizeExt+1:end),'Color',c);
plot(cornerExt:cornerExt+segSizeExt-1,segment{5,1}(end-segSizeExt+1:end),'Color',[0 0 0],'LineWidth',2);

xlim([0, segment{5,2}(1)]);
if max(segment{5,1})~=0
ylim(1.01*[min(segment{5,1}), max(segment{5,1})]);
end
hold off;




