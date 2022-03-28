function max_nfacets = sdwt2_max_nfacets(N, nlevel, filter_length)
% Maximum number of facets admissible for the faceted wavelet transform.
%
% Returns the maximum admissible number of facets so that the overlap
% required by the faceted wavelet transform does not exceed the size of a
% tile (i.e., tessellation of ``1:N`` into non-overlapping subsets of
% successive integers).
%
% Parameters
% ----------
% N : int
%     Number if entries in the segment to be tessellated.
% nlevel : int
%     Number of decomposition scales on the wavelet decomposition
% filter_length : int
%     Size of the filter associated with the wavelet considered.
%
% Returns
% -------
% int
%     Maximum number of facets which can be considered.
%

    max_overlap = (2^nlevel - 1) * (filter_length - 1);
    fsize = floor(N./(1:N).');
    max_nfacets = find(fsize > max_overlap, 1, 'last');

end
