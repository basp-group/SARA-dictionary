function nfacets = sdwt2_test_nfacets(N, nfacets, nlevel, filter_length)
% Test whether a number of facets is valid for the faceted wavelet
% transform is valid.
%
% Test if a candiate number of facets is such that the overlap
% required by the faceted wavelet transform does not exceed the size of a
% tile (i.e., tessellation of ``1:N`` into non-overlapping subsets of
% successive integers). If not, the function returns the maximum admissible
% number of facets satisfying this condition.
%
% Parameters
% ----------
% N : int
%     Number if entries in the segment to be tessellated.
% nfacets : int
%     Selected number of facets.
% nlevel : int
%     Number of decomposition scales on the wavelet decomposition
% filter_length : int
%     Size of the filter associated with the wavelet considered.
%
% Returns
% -------
% int
%     Number of facets which can be considered (equal to the initial value
%     taken for ``nfacets`` if it satisfied the requirements).
%

    max_overlap = (2^nlevel - 1) * (filter_length - 1);
    fsize = floor(N./(1:nfacets).');

    if max_overlap >= fsize(end)
        warning('sdwt2_nmax_facet: The overlap required (%i) is larger than the expected size for a facet (%i).', max_overlap, fsize(end))
        nfacets = find(fsize > max_overlap, 1, 'last');
        warning('sdwt2_nmax_facet: Maximum admissible number of facets is %i.', nfacets)
    end
end
