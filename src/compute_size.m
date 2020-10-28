function [dims_PsitLx_crop, Ncoefs, Ij] = compute_size(I, dims, J, status, L)
% Compute the number of wavelet coefficients generated for a facet.
%
% Compute the number of wavelet coefficients generated for one facet by the
% faceted wavelet transform described in :cite:`Prusa2012`.
%
% Args:
%     I (array): facet start index [1,2].
%     dims (array): dimension of the current facet (w/o overlap) .
%     J (int): number of decomposition levels.
%     status (array): status of the facet (first/last) [1,2] 
%                  value {-1, 0, 1, Nan} for (first, none, last, both).
%     L (int): filter length (wavelet decomposition).
%
% Returns:
%     dims_PsitLx_crop (array): dimension of the wavelet coefficients 
%                  at each stage of the transform. [J+1,2]
%     Ncoefs (array): number of valid coefficients. [J+1,2]
%     Ij (array): start index (in the global image) of the  
%                  needed to compute the jth level of the wavelet
%                  decomposition. [J+1,2]
%

%-------------------------------------------------------------------------%
%%
% Code: P.-A. Thouvenin.
%-------------------------------------------------------------------------%
%%
% dim = length(I);
dims_PsitLx_crop = zeros(J+1,2);
Ncoefs = zeros(J+1,2); % dim = 2
Ij = zeros(J+1,2);

% calculating numbers of coefficients in each subband in each dimension [P.-A.] (i.e., h, d, v, a)
id_next_facet = dims + I;

for d = 1:2
    for j = 1:J
        id_current_facet_scalej = floor(I(d)./2^j);
        if status(d) > 0 || isnan(status(d)) % last, 1 / first && last
            id_next_facet_scalej = floor(2^(-j).*id_next_facet(d)+(1-2^(-j))*(L-1));
        else
            id_next_facet_scalej = floor(id_next_facet(d)./2^j);
        end
        Ncoefs(j,d) = id_next_facet_scalej - id_current_facet_scalej; % [P.-A.] (4.19)
        Ij(j,d) = id_current_facet_scalej;
    end
end
Ncoefs(J+1,:) = Ncoefs(J,:);
Ij(J+1,:) = Ij(J,:);

for d=1:2
    for j=1:J-1
        if status(d) < 0 || isnan(status(d)) % first, -1 / first & last
            dims_PsitLx_crop(j,d) = Ncoefs(j,d);
        else
            tempDisc = (2^(J-j)-1)*(L-2) + floor(mod(I(d),2^J)/2^j); % number of elements to be discarded
            dims_PsitLx_crop(j,d) = Ncoefs(j,d) + tempDisc; % [P.-A.] Nextj (4.21)
        end
    end
end
dims_PsitLx_crop(J+1,:) = Ncoefs(J+1,:);
dims_PsitLx_crop(J,:) = Ncoefs(J,:);

end
