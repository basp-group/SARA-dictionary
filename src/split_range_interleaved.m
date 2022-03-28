function rg = split_range_interleaved(nchunks, N)
% Tessellates 1:N into interleaved subsets.
%
% Tessellates 1:N into subsets of interleaved indices, each containing
% approximately the same number of indices (downsampling of 1:N).
%
% Parameters
% ----------
% nchunks : int
%     Number of segments.
% N : int
%     Total number of indices.
%
% Returns
% -------
% rg : cell{:, 1} of array (int)
%     First/last index of each segment {nchunks, 1}.
%

% -------------------------------------------------------------------------%
%%
% Code: P.-A. Thouvenin.
% -------------------------------------------------------------------------%
%%
if nchunks > N
    error('split_range_interleaved:ValueError', ...
    'Number of facets nchunks=%i greater than the dimension N=%i', nchunks, N);
end

rg = cell(nchunks, 1);
for q = 1:nchunks
    rg{q} = q:nchunks:N;
end

end
