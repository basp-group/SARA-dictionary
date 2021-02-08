function segment = extendInput(segment, image)

dim = length(segment{2,2});
dimImage = size(image);

corner = segment{2,2};
dimensions = segment{2,3};
segment{end} = cell(1,1);



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

cornerReal = segment{1,2};
dimensionsReal = segment{1,3};
for i=1:dim
    segment{end}{i,1} = 'new';
    if cornerReal(i)==0
        segment{end}{i,end+1} = 'first';
        temLIdxs(i) = 0;
    end
    if cornerReal(i)+dimensionsReal(i)== segment{end,2}(i)
        segment{end}{i,end+1} = 'last';
        temRIdxs(i) = 0;
    end
end


zerosNum = dimensions(:) + temLIdxs + temRIdxs;
segment{2,1} = zeros([zerosNum(:)',1]);



switch(dim)
    case 1
     segment{2,1}(temLIdxs+1:end-temRIdxs) = image(corner+1:corner+dimensions); 
    case 2
     segment{2,1}(temLIdxs(1)+1:end-temRIdxs(1),...
                  temLIdxs(2)+1:end-temRIdxs(2))...
         = image(corner(1)+1:corner(1)+dimensions(1),corner(2)+1:corner(2)+dimensions(2));
    case 3
     segment{2,1}(temLIdxs(1)+1:end-temRIdxs(1),...
                  temLIdxs(2)+1:end-temRIdxs(2),...
                  temLIdxs(3)+1:end-temRIdxs(3)) = image(corner(1)+1:corner(1)+dimensions(1),corner(2)+1:corner(2)+dimensions(2),corner(3)+1:corner(3)+dimensions(3));
    case 4
     segment{2,1}(temLIdxs(1)+1:end-temRIdxs(1),...
                  temLIdxs(2)+1:end-temRIdxs(2),...
                  temLIdxs(3)+1:end-temRIdxs(3),...
                  temLIdxs(4)+1:end-temRIdxs(4)) = image(corner(1)+1:corner(1)+dimensions(1),...
                          corner(2)+1:corner(2)+dimensions(2),...
                          corner(3)+1:corner(3)+dimensions(3),...
                          corner(4)+1:corner(4)+dimensions(4)); 
    case 5
     segment{2,1}(temLIdxs(1)+1:end-temRIdxs(1),...
                  temLIdxs(2)+1:end-temRIdxs(2),...
                  temLIdxs(3)+1:end-temRIdxs(3),...
                  temLIdxs(4)+1:end-temRIdxs(4),...
                  temLIdxs(5)+1:end-temRIdxs(5)) = image(corner(1)+1:corner(1)+dimensions(1)+1,...
                          corner(2)+1:corner(2)+dimensions(2),...
                          corner(3)+1:corner(3)+dimensions(3),...
                          corner(4)+1:corner(4)+dimensions(4),...
                          corner(5)+1:corner(5)+dimensions(5)); 
    otherwise
        error('6 or more dimensional signals are not supported');
end

