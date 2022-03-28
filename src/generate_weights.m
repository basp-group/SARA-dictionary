function w =  generate_weights(qx, qy, Qx, Qy, window_type, dims, dims_o, d, varargin)
% Generate the weighting matrix for a single facet.
%
% Generate the weighting matrix of a single facet invlved in the faceted
% nuclear norm term.
%
% Parameters
% ----------
% qx : int
%     Facet index along axis x.
% qy : int
%     Facet index along axis y.
% Qx : int
%     Number of facets along axis x.
% Qy : int
%     Number of facets along axis y.
% window_type : string
%     Name of the window considered. Possible values: ``'triangular'``,
%     ``'hamming'``, ``'pc'`` (piecewise constant).
% dims : int[2, 1]
%     Size of the tile (w/o overlap) [2, 1].
% dims_o : int[2, 1]
%     Dimension of the facet [2, 1].
% d : int[2, 1]
%     Number of pixels in the overlap along each direction [2, 1].
% varargin : double
%     Minimum value for the triangular window (only active in this case).

% Returns
% -------
% w : array
%     Output apodization window.
%

% -------------------------------------------------------------------------%
%%
% Code: P.-A. Thouvenin, [22/10/2020]
% -------------------------------------------------------------------------%
%%
narginchk(8, 9);

if (~isempty(varargin)) && strcmp(window_type, 'triangular')
    tol = varargin{1};
else
    tol = 1e-3;
end

switch window_type
    case 'triangular'
        tol = 1e-3;
        if qx == 1
            wdx = [ones(1, dims(2) - d(2)), linspace(1 - tol, tol, d(2))];
        elseif qx == Qx
            wdx = [linspace(tol, 1 - tol, d(2)), ones(1, dims_o(2) - d(2))];
        else
            wdx = [linspace(tol, 1 - tol, d(2)), ones(1, dims_o(2) - 2 * d(2)), linspace(1 - tol, tol, d(2))];
        end
        if qy == 1
            wdy = [ones(1, dims(1) - d(1)), linspace(1 - tol, tol, d(1))];
        elseif qy == Qy
            wdy = [linspace(tol, 1 - tol, d(1)), ones(1, dims_o(1) - d(1))];
        else
            wdy = [linspace(tol, 1 - tol, d(1)), ones(1, dims_o(1) - 2 * d(1)), linspace(1 - tol, tol, d(1))];
        end
        w = (wdy.') .* wdx;
    case 'hamming'
        wx = window('hamming', 2 * d(2) + 1).';
        if qx == 1
            wdx = [ones(1, dims(2) - d(2)), wx(d(2) + 2:end)];
        elseif qx == Qx
            wdx = [wx(1:d(2)), ones(1, dims_o(2) - d(2))];
        else
            wdx = [wx(1:d(2)), ones(1, dims_o(2) - 2 * d(2)), wx(d(2) + 2:end)];
        end
        wy = window('hamming', 2 * d(1) + 1).';
        if qy == 1
            wdy = [ones(1, dims(1) - d(1)), wy(d(1) + 2:end)];
        elseif qy == Qy
            wdy = [wy(1:d(1)), ones(1, dims_o(1) - d(1))];
        else
            wdy = [wy(1:d(1)), ones(1, dims_o(1) - 2 * d(1)), wy(d(1) + 2:end)];
        end
        w = (wdy.') .* wdx;
    case 'pc'
        if qx == 1
            wdx = [ones(1, dims(2) - d(2)), ones(1, d(2)) / 2];
        elseif qx == Qx
            wdx = [ones(1, d(2)) / 2, ones(1, dims_o(2) - d(2))];
        else
            wdx = [ones(1, d(2)) / 2, ones(1, dims_o(2) - 2 * d(2)), ones(1, d(2)) / 2];
        end
        if qy == 1
            wdy = [ones(1, dims(1) - d(1)), ones(1, d(1)) / 2];
        elseif qy == Qy
            wdy = [ones(1, d(1)) / 2, ones(1, dims_o(1) - d(1))];
        else
            wdy = [ones(1, d(1)) / 2, ones(1, dims_o(1) - 2 * d(1)), ones(1, d(1)) / 2];
        end
        w = (wdy.') .* wdx;
    otherwise % make sure there is no 0 at the boundaries of the window
        w = ones(dims_o);
end

end
