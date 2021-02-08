function segment = readInput(segment, image)

dim = length(segment{1,2});

corner = segment{1,2};
dimensions = segment{1,3};
dimImage = segment{5,2};



for i=1:dim
    if corner(i)<0
      corner(i)=0;
       error(sprintf('Segment out of input bounds in dimension %d.',i));
    end
    if corner(i)>=dimImage(i);
        error(sprintf('Segment out of input bounds in dimension %d.',i));
    end
 
    if corner(i)+dimensions(i)>dimImage(i)
        dimensions(i) = dimImage(i)-corner(i);
        segment{2,3}(i) = dimImage(i)- segment{2,2}(i);
        warning(sprintf('Segment dimensions out of input bounds in dimension %d. Setting to %d.',i,dimensions(i)));
    end
end

segment{1,3} = dimensions;
segment{1,2} = corner;



segment{1,1} = zeros([dimensions(:)',1]);
switch(dim)
    case 1
     segment{1,1} = image(corner+1:corner+dimensions); 
    case 2
     segment{1,1} = image(corner(1)+1:corner(1)+dimensions(1),corner(2)+1:corner(2)+dimensions(2));
    case 3
     segment{1,1} = image(corner(1)+1:corner(1)+dimensions(1),corner(2)+1:corner(2)+dimensions(2),corner(3)+1:corner(3)+dimensions(3));
    case 4
     segment{1,1} = image(corner(1)+1:corner(1)+dimensions(1),...
                          corner(2)+1:corner(2)+dimensions(2),...
                          corner(3)+1:corner(3)+dimensions(3),...
                          corner(4)+1:corner(4)+dimensions(4)); 
    case 5
     segment{1,1} = image(corner(1)+1:corner(1)+dimensions(1),...
                          corner(2)+1:corner(2)+dimensions(2),...
                          corner(3)+1:corner(3)+dimensions(3),...
                          corner(4)+1:corner(4)+dimensions(4),...
                          corner(5)+1:corner(5)+dimensions(5)); 
    otherwise
        error('6 or more dimensional signals are not supported');
end

