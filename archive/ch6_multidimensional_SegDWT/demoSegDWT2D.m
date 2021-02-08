function demoSegDWT2D

im = double(imread('testdata/lena.bmp'))/255;
im_hat= zeros(size(im));
wavelet = 'db4';
J =4;
 
% image division into the segments
% [y,x,height,width]
segDims = [0  ,  0,182,182;...
           0  ,182,182,330;...
           182,  0,330,182;...
           182,182,250,250;...
           182,432,250, 80;...
           432,182, 80,330];

segments=segDWT2DtoSegments(im,wavelet,J,segDims);

M = length(segments);
for ii=1:M
    segment = segments{ii};
    im_hat = place2DSegment(im_hat,segment);
    figure(1);imshow(segment{5,1});truesize;
    figure(2);imshow(segment{2,1});truesize;
    figure(3);imshow(segment{1,1});truesize;
    figure(4);imshow(im_hat);truesize;
    pause;
end 

       

