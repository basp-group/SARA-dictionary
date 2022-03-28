function rg = local_split_range(nchunks, N, index, varargin)
% Returns the indices delimiting the portion of 1:N in position ``index``.
%
% Tessellates 1:N into (non-)overlapping subsets, each containing
% approximately the same number of indices, following the decomposition
% rules specified in varargin. Returns only the first and last indices
% corresponding to the chunk in position ``index``.
%
% Parameters
% ----------
% nchunks : int
%     Number of segments.
% N : int
%     Number of indices.
% index : int
%     Position of the chunk considered.
% varargin : int
%     Defines the amount of pixels in the overlap between consecutive
%     segments (if any).
%
% Returns
% -------
% rg : int[`nchunks`, 2]
%     First/last index of the segment in position ``index`` [1, 2].
%

% -------------------------------------------------------------------------%
%%
% Code: P.-A. Thouvenin.
% -------------------------------------------------------------------------%
%%
if nargin > 4
    error('local_split_range:NumberOfInputError', 'Too many input arguments');
end

if nchunks > N
    error('local_split_range:InputValueError', 'nchunks should be larger than or equal to N');
end

if nchunks < index
    % error('local_split_range:InputValueError', 'Index should be smaller than nchunks');
    rg = [];
    return
end

if index < 1
    % error('local_split_range:InputValueError', 'Index should be larger than or equal to 1 (1-based indexing)');
    rg = [];
    return
end

step = N / nchunks;
start = (index - 1) * step;
stop = round(start + step);
start = round(start) + 1;
rg = [start, stop];

if ~isempty(varargin)
    % split with overlap
    overlap = varargin{1};
    if overlap < 0
        error('local_split_range:InputValueError', 'Overlap must be positive');
    end
    if overlap > floor(step)
        error('local_split_range:InputValueError', ['More than 100% overlap' ...
              'between two consecutive segments']);
    end
    if index > 1
        rg(1) = rg(1) - overlap;
    end
end

end
