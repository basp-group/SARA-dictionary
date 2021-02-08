function out = checkStringVarargin( in, string )


[M] = length(in);
if(M==0) out = 0; return; end;


for i=1:M
    if(ischar(in{i}))
        if(strcmp(in{i},string))
            out = 1;return;
        end
    end
end

out = 0;

