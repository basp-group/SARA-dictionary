function demoSegDWT1D
close all;
i = double(imread('testdata/lena.bmp'));
lambda = 0;
slice = i(20,:)';
im = slice + 0*rand(length(slice),1 );
  
wavelet = 'db4';
J =4;

im_hat= zeros(size(im));

% segments, [startIdx, length]
segDims = [0  ,49;...
           49 ,126;...
           175,255;...
           430,82];
       
fc = @(segment) hardThres(segment,lambda);

segments=segDWT1DtoSegments(im,wavelet,J,segDims,fc);
figure(2);clf;
C = {[0 0 1],[0 0.5 0],[1 0 0],[0 0.75 0.75],[0.75 0 0.75],[0.75 0.75 0],[0.25 0.25 0.25]};
fig=2;
M = length(segments);

for ii=1:M
    segment = segments{ii};
    im_hat = place1DSegment(im_hat,segment);
    print1DSegments(segment,fig,C{mod(ii,length(C))});
    print1DExtendedSegments(segment,[3,4],C{mod(ii,length(C))},4,ii);
    figure(1);h =stem(0:length(im)-1,[im,im_hat]);axis tight;
     pause;
end
figure(5);
for ii=M:-1:1
hold on;


segment = segments{ii};
cornerExt = segment{2,2};
segSizeExt = segment{2,3};
temp = segment{5,1};




stem((cornerExt:cornerExt+segSizeExt-1),temp,'Color',C{ii});


    xlim([0, segment{5,2}(1)]);
   if max(segment{5,1})~=0
     ylim(1.01*[min(segments{end-1}{5,1}), max(segments{end}{5,1})]);
   end

end

plot(0:length(im)-1,im_hat,'k','LineWidth',2);
hold off;


figure(2);hold on;
plot(0:length(im)-1,im,'k','LineWidth',2);
     pause;
close all;



       

 