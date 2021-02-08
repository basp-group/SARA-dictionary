function testSegDWT2D
dwtmode('zpd');

im = double(imread('testdata/lena.bmp'))/255;
im_hat= zeros(size(im));
wavelet = 'db4';
J =4;

[lo,hi,lo_r,hi_r] = wfilters(wavelet);



segment = cell(5,3);
% segment upper left corner [y direction,x direction]
segment{1,2}= [0,0];
% segment height and width [height, width]
segment{1,3}= [251,235];
rJ = (2^J-1)*(length(lo)-1);
rJnew = (2^J-1)*(length(lo)-2);
LnoRrows = rJnew + mod(segment{1,2}(1),2^J);
LnoRcols = rJnew + mod(segment{1,2}(2),2^J);
segment{2,2}(1)= [segment{1,2}(1)-LnoRrows];
segment{2,2}(2)= [segment{1,2}(2)-LnoRcols];
segment{2,3}(1)= [segment{1,3}(1)+LnoRrows];
segment{2,3}(2)= [segment{1,3}(2)+LnoRcols];
segment{end,2} = [size(im)];


segment = readInput(segment,im);
segment = extendInput(segment,im);
segment = fwdInput(segment,lo,hi,J);
segment = inwInput(segment,lo_r,hi_r,J);
im_hat = place2DSegment(im_hat,segment);


[C,S] = wavedec2(im,J,lo,hi);
% check coefficients wit the correct ones
err = check2Dcoefs(segment,C,S,lo_r,hi_r,J);
if(err>10*eps)  disp(sprintf('Error of coefficient is to high! %d',err));  end;

figure(1);imshow(segment{5,1});truesize;
figure(2);imshow(segment{2,1});truesize;
figure(3);imshow(segment{1,1});truesize;
figure(4);imshow(im_hat);truesize;







