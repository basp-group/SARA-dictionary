function segment=fwd3d(segment,lo,hi,J,varargin)

numSubbands = 7;
segment{3,1}=cell(J+1,numSubbands);
for j=1:J
    for ns =1:numSubbands
        segment{3,1}{j,ns} = zeros(segment{3,3}{j});
    end
end
segment{3,1}{J+1,1} = zeros(segment{3,3}{J+1});

 
dim = size(segment{2,1});


%rows
in = segment{2,1};
rows = dim(1);
cols = dim(2);
slides = segment{3,3}{1}(3);

for j=1:J

tempa = zeros([rows,cols,slides]);
tempd = zeros([rows,cols,slides]);
    
 
for row = 1:rows
    for col = 1:cols
         tempa(row,col,1:slides)= convSub(in(row,col,:),lo,2,segment{end}{3,:});
         tempd(row,col,1:slides)= convSub(in(row,col,:),hi,2,segment{end}{3,:});
    end
end

% for row = 1:rows
%    tempa(row,1:cols)= convSub(in(row,:),lo,2,segment{end}{2,:});
%    tempd(row,1:cols)= convSub(in(row,:),hi,2,segment{end}{2,:});
% end

rows = segment{3,3}{j}(1);
tempaa = zeros([rows,cols,slides]);
tempad = zeros([rows,cols,slides]);
tempda = zeros([rows,cols,slides]);
tempdd = zeros([rows,cols,slides]);

for slid = 1:slides
    for col = 1:cols
       tempaa(1:rows,col,slid) = convSub(tempa(:,col,slid),lo,2,segment{end}{1,:});
       tempad(1:rows,col,slid) = convSub(tempa(:,col,slid),hi,2,segment{end}{1,:});
       tempda(1:rows,col,slid) = convSub(tempd(:,col,slid),lo,2,segment{end}{1,:});
       tempdd(1:rows,col,slid) = convSub(tempd(:,col,slid),hi,2,segment{end}{1,:});
    end
end

cols = segment{3,3}{j}(2);
in = zeros(segment{3,3}{j});
for slid = 1:slides
    for row = 1:rows
       segment{3,1}{j,2}(row,1:cols,slid) = convSub(tempaa(row,:,slid),hi,2,segment{end}{2,:});
       segment{3,1}{j,1}(row,1:cols,slid) = convSub(tempad(row,:,slid),lo,2,segment{end}{2,:});
       segment{3,1}{j,3}(row,1:cols,slid) = convSub(tempad(row,:,slid),hi,2,segment{end}{2,:});
       segment{3,1}{j,4}(row,1:cols,slid) = convSub(tempda(row,:,slid),lo,2,segment{end}{2,:});
       segment{3,1}{j,6}(row,1:cols,slid) = convSub(tempda(row,:,slid),hi,2,segment{end}{2,:});
       segment{3,1}{j,5}(row,1:cols,slid) = convSub(tempdd(row,:,slid),lo,2,segment{end}{2,:});
       segment{3,1}{j,7}(row,1:cols,slid) = convSub(tempdd(row,:,slid),hi,2,segment{end}{2,:});
       in(row,1:cols,slid) = convSub(tempaa(row,:,slid),lo,2,segment{end}{2,:});
    end
end


slides = segment{3,3}{j+1}(3);

end


segment{3,1}{J+1,1} = in;







