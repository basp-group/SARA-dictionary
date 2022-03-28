function [dims_PsitLx_crop, Ncoefs, Ij] = compute_size(I, dims, J, status, L)
% Compute the number of wavelet coefficients generated for a facet.
%
% Compute the number of wavelet coefficients generated for one facet by the
% faceted wavelet transform described in :cite:p:`Prusa2012`.
%
% Parameters
% ----------
% I : int[2]
%     Facet start index [1,2].
% dims : int[2]
%     Dimension of the current facet (w/o overlap) .
% J : int
%     Number of decomposition levels.
% status : array
%     Status of the facet (first/last) [1,2] value {-1, 0, 1, Nan} for
%     (first, none, last, both).
% L : int
%     Length of the filter involved in the wavelet decomposition.
%
% Returns
% -------
% dims_PsitLx_crop : int[:, :]
%     Dimension of the wavelet coefficients at each stage of the
%     transform. [J+1,2]
% Ncoefs : int[:, :]
%     Number of valid coefficients. [J+1,2]
% Ij : int[:, :]
%     Start index (in the global image) of the facet needed to compute the
%     jth level of the wavelet decomposition. [J+1,2]
%

% -------------------------------------------------------------------------%
%%
% Code: P.-A. Thouvenin.
% -------------------------------------------------------------------------%
%%
% dim = length(I);
dims_PsitLx_crop = zeros(J + 1, 2);
Ncoefs = zeros(J + 1, 2); % dim = 2
Ij = zeros(J + 1, 2);

% calculating numbers of coefficients in each subband in each dimension
% (i.e., h, d, v, a)
id_next_facet = dims + I;

for d = 1:2
    for j = 1:J
        id_current_facet_scalej = floor(I(d) ./ 2^j);
        if status(d) > 0 || isnan(status(d)) % last, 1 / first && last
            id_next_facet_scalej = floor(2^(-j) .* id_next_facet(d) + (1 - 2^(-j)) * (L - 1));
        else
            id_next_facet_scalej = floor(id_next_facet(d) ./ 2^j);
        end
        Ncoefs(j, d) = id_next_facet_scalej - id_current_facet_scalej; % (4.19)
        Ij(j, d) = id_current_facet_scalej;
    end
end
Ncoefs(J + 1, :) = Ncoefs(J, :);
Ij(J + 1, :) = Ij(J, :);

for d = 1:2
    for j = 1:J - 1
        if status(d) < 0 || isnan(status(d)) % first, -1 / first & last
            dims_PsitLx_crop(j, d) = Ncoefs(j, d);
        else
            tempDisc = (2^(J - j) - 1) * (L - 2) + floor(mod(I(d), 2^J) / 2^j); % number of elements to be discarded
            dims_PsitLx_crop(j, d) = Ncoefs(j, d) + tempDisc; % Nextj (4.21)
        end
    end
end
dims_PsitLx_crop(J + 1, :) = Ncoefs(J + 1, :);
dims_PsitLx_crop(J, :) = Ncoefs(J, :);

end
