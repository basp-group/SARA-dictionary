function testSegDWT3D
dwtmode('zpd');


load testdata/brukner362x347x200.mat % % loaded variable: inVid
load testdata/brukner362x347x200dwt3D.mat % loaded correct wavelet coefficients for J=3 and db2: W= wavedec3(im,3,'db2','zpd');
videoDim =  size(inVid);
im_hat= zeros(size(inVid));
wavelet = 'db2';
J =3;

[lo,hi,lo_r,hi_r] = wfilters(wavelet);



segment = cell(5,3);
segment{1,2}= [53,139,10];
segment{1,3}= [101,103,75];
rJ = (2^J-1)*(length(lo)-1);
rJnew = (2^J-1)*(length(lo)-2);
LnoRrows = rJnew + mod(segment{1,2}(1),2^J);
LnoRcols = rJnew + mod(segment{1,2}(2),2^J);
LnoRtime = rJnew + mod(segment{1,2}(3),2^J);
segment{2,2}(1)= [segment{1,2}(1)-LnoRrows];
segment{2,2}(2)= [segment{1,2}(2)-LnoRcols];
segment{2,2}(3)= [segment{1,2}(3)-LnoRtime];
segment{2,3}(1)= [segment{1,3}(1)+LnoRrows];
segment{2,3}(2)= [segment{1,3}(2)+LnoRcols];
segment{2,3}(3)= [segment{1,3}(3)+LnoRtime];
segment{end,2} = [videoDim];


segment = readInput(segment,inVid);
segment = extendInput(segment,inVid);
segment = fwdInput(segment,lo,hi,J);
err = check3Dcoefs(segment,W);
if(err>1e-10)  disp(sprintf('Error of coefficient is to high! %d',err));  end;

segment = inwInput(segment,lo_r,hi_r,J);
im_hat = place3DSegment(im_hat,segment);

implay(im_hat);









