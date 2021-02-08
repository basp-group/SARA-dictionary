function im=place1DSegment(im,segment)

corner = segment{2,2};
segSize = segment{2,3};
im(corner(1)+1:corner(1)+segSize(1)) = ...
im(corner(1)+1:corner(1)+segSize(1))+segment{5,1};