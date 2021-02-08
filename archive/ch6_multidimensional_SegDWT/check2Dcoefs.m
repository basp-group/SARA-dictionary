function err = check2Dcoefs(segment,C,S,lo_r,hi_r,J)

coefs = cell(J+1,3);
coefsSelect = cell(J+1,3);

    coefs{end,1} = appcoef2(C,S,lo_r,hi_r,J);
for j=1:J
     [coefs{j,1},coefs{j,2},coefs{j,3}] = detcoef2('all',C,S,j); 
end


coefsSelect{J+1,1} = coefs{J+1,1}...
                     (segment{4,2}{J+1}(1)+1:segment{4,2}{J+1}(1)+segment{4,3}{J+1}(1),...
                     segment{4,2}{J+1}(2)+1:segment{4,2}{J+1}(2)+segment{4,3}{J+1}(2));
for j=1:J
    coefsSelect{j,1} = coefs{j,1}...
                     (segment{4,2}{j}(1)+1:segment{4,2}{j}(1)+segment{4,3}{j}(1),...
                     segment{4,2}{j}(2)+1:segment{4,2}{j}(2)+segment{4,3}{j}(2));
    coefsSelect{j,2} = coefs{j,2}...
                     (segment{4,2}{j}(1)+1:segment{4,2}{j}(1)+segment{4,3}{j}(1),...
                     segment{4,2}{j}(2)+1:segment{4,2}{j}(2)+segment{4,3}{j}(2));
   coefsSelect{j,3} = coefs{j,3}...
                     (segment{4,2}{j}(1)+1:segment{4,2}{j}(1)+segment{4,3}{j}(1),...
                     segment{4,2}{j}(2)+1:segment{4,2}{j}(2)+segment{4,3}{j}(2));
end



coefs = segment{4,1};
err = 0;
err = err +  norm(coefs{J+1,1}(:) - coefsSelect{J+1,1}(:));
for j=1:J
     err = err +  norm(coefs{j,1}(:) - coefsSelect{j,1}(:)); 
    err = err +  norm(coefs{j,2}(:) - coefsSelect{j,2}(:)); 
     err = err +  norm(coefs{j,3}(:) - coefsSelect{j,3}(:)); 
end

