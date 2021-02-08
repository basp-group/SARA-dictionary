function segment=fwd2d(segment,lo,hi,J,varargin)

numSubbands = 3;
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
cols = segment{3,3}{1}(2);

for j=1:J

tempa = zeros([rows,cols]);
tempd = zeros([rows,cols]);
    
    
for row = 1:rows
   tempa(row,1:cols)= convSub(in(row,:),lo,2,segment{end}{2,:});
   tempd(row,1:cols)= convSub(in(row,:),hi,2,segment{end}{2,:});
end

rows = segment{3,3}{j}(1);
in = zeros(segment{3,3}{j});
for col = 1:cols
   segment{3,1}{j,1}(1:rows,col)= convSub(tempa(:,col),hi,2,segment{end}{1,:}); % LH
   segment{3,1}{j,2}(1:rows,col)= convSub(tempd(:,col),lo,2,segment{end}{1,:}); % HL
   segment{3,1}{j,3}(1:rows,col)= convSub(tempd(:,col),hi,2,segment{end}{1,:}); % HH
   in(1:rows,col) = convSub(tempa(:,col),lo,2,segment{end}{1,:}); % LL
end

cols = segment{3,3}{j+1}(2);

end


segment{3,1}{J+1,1} = in;







