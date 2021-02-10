function PsiSty = isdwt2_sara(SPsitLx, I, dims, I_overlap, dims_overlap, Ncoefs, J, wavelet, pre_offset_dict, post_offset_dict)
% Inverse facet SARA operator.
%
% Inverse operator to compute the contribution of the SARA prior to a
% single facet.
%
% Args:
%     SPsitLx (array): wavelet coefficients obtained from the facet of
%                           interest.
%     I (array): starting index of the tile (no overlap) [1,2].
%     dims (array): tile dimension (no overlap) [1,2].
%     I_overlap (array): starting index of the facet (including
%                             overlap) [1,2].
%     dims_overlap (array): dimension of the extended image facets
%                                (including overlap) [M,2].
%     Ncoefs (array): dimension of the wavelet facets for each level
%                          of the decomposition level, for each dictionary
%                          [M(J+1),2] {from level 1 to J}.
%     J (int): number of decomposition levels considered.
%     wavelet (cell): name of the wavelet dictionaries considered {M,1}.
%     pre_offset_dict (array): number of coefficients to be cropped from
%                               the start of the reconstructed facet [M,2].
%     post_offset_dict (array): number of coefficients to be cropped from
%                                the end of the reconstructed facet [M,2].
%
% Returns:
%     SPsitLx (array): inverse transform of the input matrix.
%

%
%-------------------------------------------------------------------------%
%%
% Code: P.-A. Thouvenin.
% Debug:
% [23/10/18] ok.
% [19/11/18] code acceleration.
% [18/03/19] further code acceleration [end]
%-------------------------------------------------------------------------%
%%
% Auxiliary variables
M = numel(wavelet);
start = 1;       % current position in the vector SPsitLx (contribution from several wavelet dictionaries)
start_coefs = 1; % current posisiton in the Ncoefs matrix (get number of coefficients at each scale for a each basis)

% position of the reconstructed dictionary facet within the global facet
start_facet = I_overlap-min(I_overlap, [], 1)+1; % [M, 2]
end_facet = start_facet+dims_overlap-1;   % [M, 2]

PsiSty = zeros(max(dims_overlap, [], 1));

for m = 1:M
    % inverse transform
    if ~strcmp(wavelet{m}, 'self')
        [lo_r, hi_r] = wfilters(wavelet{m}, 'r'); % reconstruction filters
        Ncoefs_m = Ncoefs(start_coefs:start_coefs+(J+1)-1,:);
        s = 3*sum(prod(Ncoefs_m(1:end-1, :), 2)) + prod(Ncoefs_m(end,:));
        PsiSty_m = isdwt2(SPsitLx(start:start+s-1), I, ...
            dims, Ncoefs_m, lo_r, hi_r, J, pre_offset_dict(m,:), post_offset_dict(m,:));
        start = start + s;
        start_coefs = start_coefs + (J+1);
    else
        s = prod(Ncoefs(start_coefs,:)); % = prod(dims) for the Dirac basis (no boundary extension)
        PsiSty_m = reshape(SPsitLx(start:start+s-1), Ncoefs(start_coefs,:));
        start = start + s;
        start_coefs = start_coefs + 1;
    end
    % position of the dictionary facet in the larger redundant image facet
    PsiSty(start_facet(m,1):end_facet(m,1), start_facet(m,2):end_facet(m,2)) = ...
        PsiSty(start_facet(m,1):end_facet(m,1), start_facet(m,2):end_facet(m,2)) + PsiSty_m;
end

% Renormalize reconstructed facet (use of several dictionaries)
PsiSty = PsiSty/sqrt(M);

end
