function y = soft(z, T)
%SOFT Summary of this function goes here
%   Detailed explanation goes here

y = sign(z) .* max(abs(z)-T, 0); % see of this is needed...

end

