function w =  generate_weights(qx, qy, Qx, Qy, window_type, dims, dims_o, d, varargin)
% Generate the weighting matrix for a single facet.
%
% Generate the weighting matrix of a single facet invlved in the faceted 
% nuclear norm term.
%
% Args:
%     qx (int): facet index along axis x
%     qy (int): facet index along axis y
%     Qx (int): number of facets along axis x
%     Qy (int): number of facets along axis y
%     window_type (string): type of window considered 
%       -> possible options: 'triangular', 'hamming', 
%          'pc' (piecewise constant)
%     dims (int array): size of the tile (w/o overlap) [2, 1]
%     dims_o (int array): tile of the facet [2, 1]
%     d (int): number of pixels in the overlap (same number in both 
%              directions)
%     varargin (double): minimum value for the triangular window
%                        (only active in this case)
%
% Returns:
%     w (array): output weights.
%

%-------------------------------------------------------------------------%
%%
% Code: P.-A. Thouvenin, [22/10/2020]
%-------------------------------------------------------------------------%
%%
narginchk(8, 9)

if (~isempty(varargin)) && strcmp(window_type, 'triangular')
    tol = varargin{1};
else
    tol = 1e-3;
end

switch window_type
    case 'triangular'
        tol = 1e-3;
        if qx == 1
            wdx = [ones(1, dims(2)-d(2)), linspace(1-tol, tol, d(2))];
        elseif qx == Qx
            wdx = [linspace(tol, 1-tol, d(2)), ones(1, dims_o(2)-d(2))];
        else
            wdx = [linspace(tol, 1-tol, d(2)), ones(1, dims_o(2)-2*d(2)), linspace(1-tol, tol, d(2))];
        end    
        if qy == 1
            wdy = [ones(1, dims(1)-d(1)), linspace(1-tol, tol, d(1))];
        elseif qy == Qy
            wdy = [linspace(tol, 1-tol, d(1)), ones(1, dims_o(1)-d(1))];
        else
            wdy = [linspace(tol, 1-tol, d(1)), ones(1, dims_o(1)-2*d(1)), linspace(1-tol, tol, d(1))];
        end
        w = (wdy.').*wdx; 
    case 'hamming'
        wx = window('hamming',2*d(2)).';
        if qx == 1
            wdx = [ones(1, dims(2)-d(2)), wx(d(2)+1:end)];
        elseif qx == Qx
            wdx = [wx(1:d(2)), ones(1, dims_o(2)-d(2))];
        else
            wdx = [wx(1:d(2)), ones(1, dims_o(2)-2*d(2)), wx(d(2)+1:end)];
        end
        wy = window('hamming',2*d(1)).';
        if qy == 1
            wdy = [ones(1, dims(1)-d(1)), wy(d(1)+1:end)];
        elseif qy == Qy
            wdy = [wy(1:d(1)), ones(1, dims_o(1)-d(1))];
        else
            wdy = [wy(1:d(1)), ones(1, dims_o(1)-2*d(1)), wy(d(1)+1:end)];
        end
        w = (wdy.').*wdx;
    case 'pc'
        if qx == 1
            wdx = [ones(1, dims(2)-d(2)), ones(1,d(2))/2];
        elseif qx == Qx
            wdx = [ones(1,d(2))/2, ones(1, dims_o(2)-d(2))];
        else
            wdx = [ones(1,d(2))/2, ones(1, dims_o(2)-2*d(2)), ones(1,d(2))/2];
        end    
        if qy == 1
            wdy = [ones(1, dims(1)-d(1)), ones(1,d(1))/2];
        elseif qy == Qy
            wdy = [ones(1,d(1))/2, ones(1, dims_o(1)-d(1))];
        else
            wdy = [ones(1,d(1))/2, ones(1, dims_o(1)-2*d(1)), ones(1,d(1))/2];
        end
        w = (wdy.').*wdx;
    otherwise % make sure there is no 0 at the boundaries of the window
        w = ones(dims_o);
end 

end