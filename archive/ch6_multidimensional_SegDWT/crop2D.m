function segment=crop2D(segment,J)
dim = length(segment{5,2});
noSubb = 2^dim-1;
segment{4,1} = cell(size(segment{3,1}));

for j=1:J-1
    for i=1:noSubb
     segment{4,1}{j,i}=segment{3,1}{j,i}(end-segment{4,3}{j}(1)+1:end,...
                              end-segment{4,3}{j}(2)+1:end);
    end
end

for i=1:noSubb
 segment{4,1}{J,i}=segment{3,1}{J,i};
 end
 segment{4,1}{J+1,1}=segment{3,1}{J+1,1};