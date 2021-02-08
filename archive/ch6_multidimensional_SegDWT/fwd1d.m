function [ y ] = fwd1d( x,lo,hi, J,varargin )

y = cell(J+1,1);

% if(length(varargin)>0)
%     if(strcmp(varargin{1},'last'))
%         tempa = x;
%         for j=1:J
%             y{j}=convSub(tempa,hi,2,'whole');
%             tempa = convSub(tempa,lo,2,'whole');
%         end
%         y{J+1} = tempa;
%         return;
%     end
% end


tempa = x;
for j=1:J
    te =convSub(tempa,hi,2,varargin{:});
    y{j} = te(:);
    tempa = convSub(tempa,lo,2,varargin{:});
end
y{J+1} = tempa(:);

