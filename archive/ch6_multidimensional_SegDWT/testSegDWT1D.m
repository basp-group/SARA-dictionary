function testSegDWT1D
dwtmode('zpd');


i = double(imread('testdata/lena.bmp'))/255;
slice = i(20,:)';
im = slice + 0*rand(length(slice),1);
im_hat = zeros(size(im));

wavelet = 'db4';
J = 3;

[lo,hi,lo_r,hi_r] = wfilters(wavelet);



segment = cell(5,3);
% segment start index
segment{1,2}= [123];
% segment length
segment{1,3}= [149];
rJ = (2^J-1)*(length(lo)-1);
rJnew = (2^J-1)*(length(lo)-2);
LnoR1 = rJnew + mod(segment{1,2}(1),2^J);
segment{2,2}= [segment{1,2}-LnoR1];
segment{2,3}= [segment{1,3}+LnoR1];
segment{end,2} = [size(im)];


segment = readInput(segment,im);
segment = extendInput(segment,im);
segment = fwdInput(segment,lo,hi,J);
[C,S] = wavedec(im,J,lo,hi);
err = check1Dcoefs(segment,C,S,lo_r,hi_r,J);
if(err>10*eps)  disp(sprintf('Error of coefficient is to high! %d',err));  end;
segment = inwInput(segment,lo_r,hi_r,J);


%assertVectorsAlmostEqual(im,im_hat,10*eps);


im_hat = place1DSegment(im_hat, segment);

stem(0:length(im)-1,[im,im_hat]);
axis tight;
