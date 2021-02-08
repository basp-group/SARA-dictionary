function segments=segDWT1DtoSegments(im,wavelet,J,sizes,varargin)
fc = 0;
if length(varargin)>0
fc = varargin{1};
end
[rows,cols] = size(sizes);
segments = cell(rows,1);
lambda = 150;

dwtmode('zpd','nodisp');

[lo,hi,lo_r,hi_r] = wfilters(wavelet);


for ii=1:rows

segment = cell(5,3);
segment{1,2}= [sizes(ii,1)];
segment{1,3}= [sizes(ii,2)];
rJ = (2^J-1)*(length(lo)-1);
rJnew = (2^J-1)*(length(lo)-2);
LnoR = rJnew + mod(segment{1,2}(1),2^J);
segment{2,2}(1)= [segment{1,2}(1)-LnoR];
segment{2,3}(1)= [segment{1,3}(1)+LnoR];
segment{end,2} = [size(im)];


segment = readInput(segment,im);
segment = extendInput(segment,im);
segment = fwdInput(segment,lo,hi,J);

if length(varargin)>0
segment = fc(segment);
end

segment = inwInput(segment,lo_r,hi_r,J);


segments{ii} = segment;

end
