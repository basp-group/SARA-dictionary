function overlap_size = get_overlap_size(N, Q, overlap_fraction)
% Convert fraction of overlap into the corresponding number of pixels.
%
% Compute the number of pixels corresponding to a prescribed overlap
% fraction (specified relatively to the size of the overlapping facet).
%
% Parameters
% ----------
% N : int[2]
%     Size of the full image [1, 2].
% Q : int[2]
%     Number of facets along each dimension [1, 2].
% overlap_fraction : array, double
%     Overlap fraction between two consecutive facets, given along each
%     dimension (fraction expressed with respect to the final facet size).
%
% Raises
% ------
% AssertionError
%     All entries in ``overlap_fraction`` need to be strictly lower than 0.5
%     (only overlap between consecutive facets is supported).
%
% Returns
% -------
% overlap_size : int[2]
%     Number of pixels contained in the overlap region.
%

if any(overlap_fraction > 1)
    error('get_overlap_size:InputValueError', 'All entries in overlap_fraction need to be < 0.5');
end

overlap_size = floor((Q > 1) .* (N ./ Q) .* (overlap_fraction ./ (1 - overlap_fraction)));

end
