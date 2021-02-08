function segments=segDWT2DtoSegments(im,wavelet,J,sizes)

[rows,cols] = size(sizes);
segments = cell(rows,1);
lambda = 0;

dwtmode('zpd','nodisp');

[lo,hi,lo_r,hi_r] = wfilters(wavelet);


for ii=1:rows

segment = cell(5,3);
segment{1,2}= [sizes(ii,1),sizes(ii,2)];
segment{1,3}= [sizes(ii,3),sizes(ii,4)];
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
segment = hardThres(segment,lambda);
segment = inwInput(segment,lo_r,hi_r,J);


segments{ii} = segment;

end
