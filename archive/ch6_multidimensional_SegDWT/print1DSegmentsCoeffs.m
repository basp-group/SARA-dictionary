function print1DSegmentsCoeffs(segment,fig,c,no,ii,varargin)
paintUncropped = 0;
if(length(varargin)>0)
    paintUncropped= 1;
end   

cornerOrig = segment{4,2};
segSizeOrig = segment{4,3};
cornerExt = segment{3,2};
segSizeExt = segment{3,3};


figure(fig(1)+ii);
for j = 1:no+1
subplot(no+1,1,j);
hold on;
if(paintUncropped>0)
 stem(cornerExt{j}:cornerExt{j}+segSizeExt{j}-1,segment{3,1}{j},'Color',[0.7 0.7 0.7]);
else
 stem(cornerOrig{j}:cornerOrig{j}+segSizeOrig{j}-1,segment{3,1}{j}(end-segSizeOrig{j}+1:end),'Color',[0.7 0.7 0.7]);  
end
stem(cornerOrig{j}:cornerOrig{j}+segSizeOrig{j}-1,segment{4,1}{j},'Color',c);
hold off;
axis tight;


ylim(1.01*[min(segment{3,1}{j})-10, max(segment{3,1}{j})]);
ylabel('0a0');
end
