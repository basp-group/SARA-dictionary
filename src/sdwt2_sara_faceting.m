function SPsitLx = sdwt2_sara_faceting(x_overlap, I, offset, status, J, wavelet, Ncoefs)
% Facet SARA operator (simplified version for faceting article).
%
% Forward operator to compute the contribution of the SARA prior for a
% single input facet.
%
% Parameters
% ----------
% x_overlap : array[:, :]
%     Image facet (with overlap).
% I : int[2]
%     Starting index of the tile (without overlap) [1,2].
% offset : int[2]
%     Offset to be considered for each dictionary w.r.t. the largest
%     overlapping facet x_overlap (different overlap needed for each
%     dictionary) [M,1].
% status : int[2]
%     Indicates whether the facet is the first (or the last) along each
%     dimension [1,2].
% J : int
%     Number of decomposition levels considered.
% wavelet : cell{1, :} of string
%     Name of the wavelet dictionaries considered {1,M}.
% Ncoefs : int[:]
%     Number of wavelet coefficients for each scale, corresponding to each
%     dictionary involved in the transform [M*(J+1),1].
%
% Returns
% -------
% SPsitLx : array[:]
%     Wavelet coefficients.
%

% -------------------------------------------------------------------------%
%%
% Debug:
% [23/10/18] ok.
% [18/03/19] further code acceleration.
% -------------------------------------------------------------------------%
%%
% Auxiliary variables
szS = size(x_overlap);
M = numel(wavelet);
id = 0;
% id_Ncoefs = 0;

% Compute total number of wavelet coefficients
p = prod(Ncoefs, 2);
s = 3 * sum(p(1:end)) - 2 * sum(p(J + 1:J + 1:end)) - 2 * p(end); % number of coeffs with the Dirac basis
SPsitLx = zeros(s, 1);

% Renormalize wavelet coefficients (use of several dictionaries)
x_overlap = x_overlap / sqrt(M); % fewer coefs at this stage

% Offsets
LId   = zeros(2, M);
for i = 1:2
    if I(i) > 0
        LId(i, :) = offset.'; % no offset if I(q, i) == 0
        LId(i, M) = LId(i, M) + mod(I(i), 2^J); % for Dirac basis
    end
end
LId = LId + 1;

for m = 1:M - 1
    % crop_offset = zeros(2, 1); % cropping due to the differences in the
    % length of the wavelet filters (different wavelet transforms)

    % forward transform (not Dirac dictionary)
    % define the portion of x_overlap to be exploited for the dictionary considered
    % x_overlap_tmp = x_overlap(crop_offset(1)+1:end, crop_offset(2)+1:end);
    % [lo, hi] = wfilters(wavelet{m}, 'd'); % decomposition filters
    sm = 3 * sum(p((m - 1) * (J + 1) + 1:m * (J + 1) - 1)) + p(m * (J + 1));
    SPsitLx(id + 1:id + sm) = sdwt2_faceting(x_overlap(LId(1, m):szS(1), LId(2, m):szS(2)), status, wavelet{m}, J, Ncoefs((m - 1) * (J + 1) + 1:m * (J + 1), :));
    id = id + sm;
end

SPsitLx(id + 1:end) = col(x_overlap(LId(1, M):end, LId(2, M):end));

end
