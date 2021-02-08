function demoSegDWT3D
close all hidden;

load 'testdata/brukner362x347x200.mat' % loaded variable: inVid
%load testdata/brukner362x347x200dwt3D.mat % loaded variable: W= wavedec3(im,3,'db2','zpd');

im_hat= zeros(size(inVid));
wavelet = 'db4';
J = 3;

% video segments
% [y,x,z,height,width,depth]
segDims = [0  , 0, 0, 181,177,102;...
           181  , 0, 0, 181,177,52;...
           0  , 0, 102, 181,177,98;...
           0  , 177, 0, 362,170,82;...
           181  , 0, 52, 181,177,148;...
           0  , 177, 82, 362,170,118;...
           ];
% !!! CAUTION !!! it may take a while (10 min. an more) to compute the segmentwise transforms,
% for the implementation is unoptimized and horriblly slow.      
segments=segDWT3DtoSegments(inVid,wavelet,J,segDims);

M = length(segments);
for ii=1:M
    segment = segments{ii};
    im_hat = place3DSegment(im_hat,segment);
    implay(im_hat);
end 
