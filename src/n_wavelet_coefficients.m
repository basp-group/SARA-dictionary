function [dims, s] = n_wavelet_coefficients(m, N, extension_mode, nlevel)
% Compute number of wavelet coefficients.
%
% Determine the number of wavelet coefficients resulting from a 2D
% decomposition by a filter of length m [1, 2] (2D), for a given type of  
% boundary conditions and number of decomposition levels.
%
% Args:
%     m (array): size of the considered filters [K, 1] (1 per type of 
%                dictionary)
%     N (array): image dimension [1, 2]
%     extension_mode (string): type of boundary extension ('per', 'zpd', 'sym')
%     nlevel (int): number of decomposition level
%
% Returns:
%     dims (array): size of the coefficients at each level of the 
%                   decomposition [nlevel+1,2]
%     s (int): total number of wavelet coefficients
 
%-------------------------------------------------------------------------%
%%
% Reference:
% Discrete wavelet transform of finite signals: detailed study of the
% algorithm, P. Rajmic, Z. Prusa, Initernational Journal of Wavelets,
% Multiresolution and Information Processing, 12(1) 1450001 (2014).
%-------------------------------------------------------------------------%
% Code: P.-A. Thouvenin, [04/04/2019]
%-------------------------------------------------------------------------%
%%

% Check whether the input parameters make sense
if any(N < 2^nlevel)
    error('Image size in each dimension must be >=2^J=%d.',2^nlevel);
end

% Compute number of coefficients in each subband, in each dimension 
% (i.e., h, d, v, a) [for even-type downsampling]
if ~isequal(extension_mode,'per')
    %sizeEXT = m-1; last = N+m-1;
    dims = zeros(nlevel+1, 2, numel(m));
    dims(2:nlevel+1, :, :) = floor( N./(2.^(nlevel:-1:1).') + ...
                           (1-1./(2.^(nlevel:-1:1).')).*reshape((m-1), [1, 1, numel(m)]));
    dims(1, :, :) = dims(2, :, :);
    % total number of wavelet coefficients
    s = sum( 3*sum(prod(dims(2:end, :, :), 2), 1) + prod(dims(1,:, :), 2) );
else
    % periodic extension mode
    %sizeEXT = m/2; last = 2*ceil(N/2);
    dims(2:nlevel+1, :) = ceil(N./(2.^(nlevel:-1:1)'));
    dims(1, :, :) = dims(2, :, :);
    s = numel(m)*prod(N);
end

end
