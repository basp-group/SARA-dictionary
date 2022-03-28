function SPsitLx = sdwt2_sara(x_overlap, I, dims, offset, status, J, wavelet, Ncoefs)
% Facet SARA operator.
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
% dims : int[2]
%     Dimensions of the image tile [1,2]
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
% Code: P.-A. Thouvenin.
% -------------------------------------------------------------------------%
%%
% Auxiliary variables
M = numel(wavelet);
dim = numel(I);
id = 0;
id_Ncoefs = 0;

% Compute total number of wavelet coefficients
p = prod(Ncoefs, 2);
id_dirac = find(ismember(wavelet, 'self'), 1);
if ~isempty(id_dirac)
    s = 3 * sum(p(1:end)) - 2 * sum(p(J + 1:J + 1:end)) - 2 * p((id_dirac - 1) * (J + 1) + 1);
else
    s = 3 * sum(p) - 2 * sum(p(J + 1:J + 1:end));
end
SPsitLx = zeros(s, 1);

% Renormalize wavelet coefficients (use of several dictionaries)
x_overlap = x_overlap / sqrt(M); % fewer coefs at this stage, faster then

for m = 1:M
    crop_offset = zeros(2, 1); % cropping due to the differences in the
    % length of the wavelet filters (different wavelet transforms)

    % forward transform
    if ~strcmp(wavelet{m}, 'self')
        % define the portion of x_overlap to be exploited for the dictionary considered
        for i = 1:dim
            if I(i) > 0
                crop_offset(i) = offset(m); % no offset if I(q, i) == 0
            end
        end
        x_overlap_m = x_overlap(crop_offset(1) + 1:end, crop_offset(2) + 1:end);
        [lo, hi] = wfilters(wavelet{m}, 'd'); % decomposition filters
        sm = 3 * sum(p((m - 1) * (J + 1) + 1:m * (J + 1) - 1)) + p(m * (J + 1));
        SPsitLx_m = sdwt2(x_overlap_m, dims, status, lo, hi, J, Ncoefs(id_Ncoefs + 1:id_Ncoefs + (J + 1), :));
        SPsitLx(id + 1:id + sm) = SPsitLx_m;
        id = id + sm;
        id_Ncoefs = id_Ncoefs + (J + 1);
    else
        % define the portion of x_overlap to be exploited for the
        % dictionary considered (remove the overlap from the facet)
        for i = 1:dim
            if I(i) > 0
                crop_offset(i) = offset(m) + mod(I(i), 2^J); % no offset if I(q, i) == 0
            end
        end
        x_overlap_m = x_overlap(crop_offset(1) + 1:end, crop_offset(2) + 1:end);
        SPsitLx_m = x_overlap_m(:);
        sm = numel(x_overlap_m);
        SPsitLx(id + 1:id + sm) = SPsitLx_m;
        id = id + sm;
        id_Ncoefs = id_Ncoefs + 1;
    end
end

end
