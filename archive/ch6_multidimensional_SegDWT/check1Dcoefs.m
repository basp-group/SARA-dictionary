function err = check1Dcoefs(segment,C,S,lo_r,hi_r,J)

coefs = cell(J+1,1);
coefsSelect = cell(J+1,3);

    coefs{end,1} = appcoef(C,S,lo_r,hi_r,J);
for j=1:J
     [coefs{j}] = detcoef(C,S,j); 
end


coefsSelect{J+1} = coefs{J+1,1}...
                     (segment{4,2}{J+1}(1)+1:segment{4,2}{J+1}(1)+segment{4,3}{J+1}(1));
for j=1:J
    coefsSelect{j} = coefs{j,1}...
                     (segment{4,2}{j}(1)+1:segment{4,2}{j}(1)+segment{4,3}{j}(1));
end



coefs = segment{4,1};
err = 0;
err = err +  norm(coefs{J+1,1}(:) - coefsSelect{J+1,1}(:));
for j=1:J
     err = err +  norm(coefs{j,1}(:) - coefsSelect{j,1}(:)); 
end

