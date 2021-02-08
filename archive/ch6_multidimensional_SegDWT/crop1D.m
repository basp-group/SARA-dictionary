function segment=crop1D(segment,J)

segment{4,1} = cell(size(segment{3,1}));

for j=1:J-1

     segment{4,1}{j}=segment{3,1}{j}(end-segment{4,3}{j}(1)+1:end);

end


 segment{4,1}{J}=segment{3,1}{J};
 segment{4,1}{J+1}=segment{3,1}{J+1};