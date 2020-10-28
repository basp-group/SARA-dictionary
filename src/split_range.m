function rg = split_range(nchunks, N, varargin)
% Tessellates 1:N into multiple subsets.
%
% Tessellates 1:N into (non-)overlapping subsets, each containing
% approximately the same number of indices, following the decomposition
% rules specified in varargin
%
% Args:
%     nchunks (int): number of segments.
%     N (int): total number of indices. 
%     varargin: defines overlap between segments (if any)
%     overlap_pre (int): number of overlapping elements with the 
%                              preceding segment (in each direction);
%     overlap_post (int): number of overlapping elements with the 
%                               following segment (in each direction).
%
% Returns:
%     rg (array): first/last index of each segment [nchunks, 2].

%-------------------------------------------------------------------------%
%%
% Code: P.-A. Thouvenin.
% Last revised: [06/06/2020]
% TODO: Investigate generalization to n-dimensions (in Python or Julia)
% -> generate error if any(rg(2:end, 1) - rg(1:end-1,1) <= 0)
% ->  check: if rg(1:end-1, 2) - rg(2:end, 1) + 1 = d -> ok
%-------------------------------------------------------------------------%
%%
if nargin > 3
    error('split_range:NumberOfInputError', 'Too many input arguments');
end

splits = round(linspace(0, N, nchunks + 1));

if isempty(varargin)
    % split w/o overlap
    rg = [splits(1:end-1).'+1, splits(2:end).'];
else
    % split with overlap
    overlap = varargin{1};
    if overlap < 0
        error('split_range:InputValueError', 'Overlap must be positive');
    end
    if overlap > floor(N/nchunks)
        error('split_range:InputValueError', ['More than 100% overlap' ... 
              'between two consecutive segments']);
    end
    rg = [vertcat(splits(1)+1, splits(2:end-1).'+1-overlap), splits(2:end).'];
end     

end