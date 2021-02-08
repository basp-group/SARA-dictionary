function err = check3Dcoefs(segment,W)

J = W.level;
subbands = 7;
coefsSelect = cell(J+1,subbands);



coefsSelect{J+1,1} = W.dec{1}...
                     (segment{4,2}{J+1}(1)+1:segment{4,2}{J+1}(1)+segment{4,3}{J+1}(1),...
                     segment{4,2}{J+1}(2)+1:segment{4,2}{J+1}(2)+segment{4,3}{J+1}(2),...
                     segment{4,2}{J+1}(3)+1:segment{4,2}{J+1}(3)+segment{4,3}{J+1}(3));
for j=1:J
     for sub=1:subbands
         jcoef = J+1-j;
     coefsSelect{jcoef,sub} = W.dec{1+sub+(j-1)*subbands}...
                     (segment{4,2}{jcoef}(1)+1:segment{4,2}{jcoef}(1)+segment{4,3}{jcoef}(1),...
                     segment{4,2}{jcoef}(2)+1:segment{4,2}{jcoef}(2)+segment{4,3}{jcoef}(2),...
                     segment{4,2}{jcoef}(3)+1:segment{4,2}{jcoef}(3)+segment{4,3}{jcoef}(3));
   
     end
end



coefs = segment{4,1};
err = 0;
err = err +  norm(coefs{J+1,1}(:) - coefsSelect{J+1,1}(:));
for j=1:J
    for sub=1:subbands
     err = err +  norm(coefs{j,sub}(:) - coefsSelect{j,sub}(:)); 
    end
end

