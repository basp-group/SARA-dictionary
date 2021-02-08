function print1DSegments(segment,fig,c)

corner = segment{1,2};
segSize = segment{1,3};


figure(fig);
xlim([0, segment{5,2}(1)]);
hold on;
stem(corner:corner+segSize-1,segment{1,1},'Color',c);
hold off;

