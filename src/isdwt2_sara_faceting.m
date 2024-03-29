function PsiSty = isdwt2_sara_faceting(SPsitLx, I, dims, I_overlap, dims_overlap, Ncoefs, J, wavelet, left_offset, right_offset)
% Inverse facet SARA operator (simplified version for faceting code).
%
% Inverse operator to compute the contribution of the SARA prior to a
% single facet.
%
% Parameters
% ----------
% SPsitLx : array[:]
%     Wavelet coefficients obtained from the facet of interest.
% I : int[2]
%     Starting index of the facet (without overlap) [1,2].
% dims : int[2]
%     Facet dimension (without overlap) [1,2].
% I_overlap : int[2]
%     Starting index of the facet (including overlap) [1,2].
% dims_overlap : int[:, :]
%     Dimension of the extended image facets (including overlap) [M,2].
% Ncoefs : int[:, :]
%     Dimension of the wavelet facets for each level of the decomposition
%     level, for each dictionary [M(J+1),2] {from level 1 to J}.
% J : int
%     Number of decomposition levels considered.
% wavelet : cell{1, :} of string
%     Name of the wavelet dictionaries considered {M,1}.
% left_offset : int[:, :]
%     Number of coefficients to be cropped from the left of the
%     reconstructed facet [M,2].
% right_offset : int[:, :]
%     Number of coefficients to be cropped from the right of the
%     reconstructed facet [M,2].
%
% Returns
% -------
% PsiSty : array
%    Inverse transform of the input matrix.
%

% -------------------------------------------------------------------------%
%%
% Debug:
% [23/10/18] ok.
% [19/11/18] code acceleration.
% [18/03/19] further code acceleration [end]
% -------------------------------------------------------------------------%
%%
% Auxiliary variables
M = numel(wavelet);
start = 1;       % current position in the vector SPsitLx (contribution from several wavelet dictionaries)
start_coefs = 1; % current posisiton in the Ncoefs matrix (get number of ceofficients at each scale for a each basis)

% position of the reconstructed dictionary facet inside the global facet
start_facet = I_overlap - min(I_overlap, [], 1) + 1; % [M, 2]
end_facet = start_facet + dims_overlap - 1; % [M, 2]

% Ncoefs = reshape(Ncoefs(1:end-1, :), [J+1, M-1, 2]);
PsiSty = zeros(max(dims_overlap, [], 1));

% precompute s
% Ncoefs_tmp = reshape(Ncoefs(1:end-1, :), [J+1, M-1, 2]);
% s = squeeze(3*sum(prod(Ncoefs_tmp(1:end-1, :, :), 3), 1) + sum(prod(Ncoefs_tmp(end, :, :), 3), 1));
%
% Ncoefs   = reshape(Ncoefs,J+1,M,2);
% NcoefsRE = reshape((prod(Ncoefs,3)),[J+1,M]);
% sE = col(3*sum(NcoefsRE(1:J,:),1)) + col(NcoefsRE(J+1,:)) ;

%% inverse transform

for m = 1:M - 1
    % inverse transform
    % [lo_r, hi_r] = wfilters(wavelet{m}, 'r'); % reconstruction filters
    Ncoefs_m = Ncoefs(start_coefs:start_coefs + (J + 1) - 1, :);
    s = 3 * sum(prod(Ncoefs_m(1:end - 1, :), 2)) + prod(Ncoefs_m(end, :));

    % position of the dictionary facet in the larger redundant image facet
    PsiSty(start_facet(m, 1):end_facet(m, 1), start_facet(m, 2):end_facet(m, 2)) = ...
        PsiSty(start_facet(m, 1):end_facet(m, 1), start_facet(m, 2):end_facet(m, 2)) + ...
        isdwt2_faceting(SPsitLx(start:start + s - 1), I, dims, Ncoefs_m, wavelet{m}, J, left_offset(m, :) + 1, right_offset(m, :));

    start = start + s;
    start_coefs = start_coefs + (J + 1);
end

% last coeffs = Dirac basis
s = prod(Ncoefs(end, :)); % = prod(dims) for the Dirac basis (no boundary extension)
PsiSty(start_facet(M, 1):end_facet(M, 1), start_facet(M, 2):end_facet(M, 2)) = ...
    PsiSty(start_facet(M, 1):end_facet(M, 1), start_facet(M, 2):end_facet(M, 2)) + reshape(SPsitLx(start:start + s - 1), Ncoefs(end, :));

% Renormalize reconstructed facet (use of several dictionaries)
PsiSty = PsiSty / sqrt(M);

end
