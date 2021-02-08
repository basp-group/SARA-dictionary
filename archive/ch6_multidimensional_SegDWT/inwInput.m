function segment = inwInput(segment,lo,hi,J,varargin);

corner = segment{1,2};
dim = length(segment{1,2});
dimensions = segment{1,3};

switch(dim)
    case 1
        segment = inwZeros1D(segment,lo,hi,J);
    case 2
        segment = inwZeros2D(segment,lo,hi,J);
    case 3
        segment = inwZeros3D(segment,lo,hi,J);
    case 4
    case 5
end



corner = segment{2,2};
dim = length(segment{2,2});
dimensions = segment{2,3};
dimImage = segment{5,2};


temLIdxs = zeros(dim,1);
temRIdxs = zeros(dim,1);
for i=1:dim
 
    if corner(i)<0
        temLIdxs(i)= -corner(i);
        dimensions(i) = dimensions(i) - temLIdxs(i);
        corner(i)=0;
    end
    if corner(i)+dimensions(i)>=dimImage(i)
        temRIdxs(i) = corner(i)+dimensions(i) - dimImage(i);
        dimensions(i) = dimImage(i)-corner(i);
    end
end


segment{2,2}=corner;
segment{2,3}=dimensions;

switch(dim)
  case 1
    segment{5,1} = segment{5,1}(temLIdxs+1:end-temRIdxs);
  case 2
    segment{5,1} = segment{5,1}(temLIdxs(1)+1:end-temRIdxs(1),temLIdxs(2)+1:end-temRIdxs(2)); 
   case 3
    segment{5,1} = segment{5,1}(temLIdxs(1)+1:end-temRIdxs(1),temLIdxs(2)+1:end-temRIdxs(2),temLIdxs(3)+1:end-temRIdxs(3));   
end