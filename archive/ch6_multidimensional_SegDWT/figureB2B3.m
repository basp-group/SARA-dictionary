function figureB2B3
dwtmode('zpd');
set(0,'DefaultLineLineWidth',0.75);


i = double(imread('testdata/lena.bmp'));
lambda = 0;
slice = i(20,:)';
im = slice + 0*rand(length(slice),1);
  
wavelet = 'db4';
J =4;

im_hat= zeros(size(im));


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
    %segment{5,1} = segment{5,1}/255;
    im_hat = place1DSegment(im_hat,segment);
    print1DSegments(segment,fig,C{mod(ii,length(C))});
    print1DSegmentsCoeffs(segment,[5],C{mod(ii,length(C))},J,ii,5);
    print1DExtendedSegments(segment,[3,4],C{mod(ii,length(C))},4,ii);
    
    
%     figure(1);stem(0:length(segment{5,1})-1,segment{5,1});axis tight;
%     figure(2);stem(0:length(segment{2,1})-1,segment{2,1});axis tight;
%     figure(3);stem(0:length(segment{1,1})-1,segment{1,1});axis tight;
    figure(1);h =stem(0:length(im)-1,[im,im_hat]);axis tight;
 %    pause;
end
figure(5);
for ii=M:-1:1
hold on;


segment = segments{ii};
cornerOrig = segment{1,2};
segSizeOrig = segment{1,3};
cornerExt = segment{2,2};
segSizeExt = segment{2,3};
temp = segment{5,1};
% if(ii<M)
%     nextOverlap = segments{ii+1}{1,2}-segments{ii+1}{2,2};
%     tempNext =  segments{ii+1}{5,1}(1:nextOverlap);
%     temp(end-nextOverlap +1:end) =   temp(end-nextOverlap +1:end) + tempNext;  
% end



stem((cornerExt:cornerExt+segSizeExt-1),temp,'Color',C{ii});

%plot(cornerExt:cornerExt+segSizeExt-1,temp,'Color',[0 0 0],'LineWidth',2);

    xlim([0, segment{5,2}(1)]);
   if max(segment{5,1})~=0
     ylim(1.01*[min(segments{end-1}{5,1}), max(segments{end}{5,1})]);
   end

end

plot(0:length(im)-1,im_hat,'k','LineWidth',2);
hold off;


figure(2);hold on;
plot(0:length(im)-1,im,'k','LineWidth',2);
axis tight;
hold off;
xlabel('k');
ylabel('x');


figure(3);
xlabel('k');
subplot(4,1,1);ylabel('0xext');
subplot(4,1,2);ylabel('1xext');
subplot(4,1,3);ylabel('2xext');
subplot(4,1,4);ylabel('3xext');

figure(4);
xlabel('k');
subplot(4,1,1);ylabel('0xexthat');
subplot(4,1,2);ylabel('1xexthat');
subplot(4,1,3);ylabel('2xexthat');
subplot(4,1,4);ylabel('3xexthat');

figure(5);
xlabel('k');
ylabel('xhat');

figure(6);
xlabel('p');
subplot(5,1,1);ylabel('0d1');
subplot(5,1,2);ylabel('0d2');
subplot(5,1,3);ylabel('0d3');
subplot(5,1,4);ylabel('0d4');
subplot(5,1,5);ylabel('0a4');


figure(7);
xlabel('p');
subplot(5,1,1);ylabel('1d1');
subplot(5,1,2);ylabel('1d2');
subplot(5,1,3);ylabel('1d3');
subplot(5,1,4);ylabel('1d4');
subplot(5,1,5);ylabel('1a4');

figure(8);
xlabel('p');
subplot(5,1,1);ylabel('2d1');
subplot(5,1,2);ylabel('2d2');
subplot(5,1,3);ylabel('2d3');
subplot(5,1,4);ylabel('2d4');
subplot(5,1,5);ylabel('2a4');

figure(9);
xlabel('p');
subplot(5,1,1);ylabel('3d1');
subplot(5,1,2);ylabel('3d2');
subplot(5,1,3);ylabel('3d3');
subplot(5,1,4);ylabel('3d4');
subplot(5,1,5);ylabel('3a4');



assertElementsAlmostEqual(im, im_hat, 'absolute', 1e-9);
       

 