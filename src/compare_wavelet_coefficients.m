function [s_dictionary, coeffs, coeffs_facets] = compare_wavelet_coefficients(y, y_faceted, N, Ij, Ncoefs, wavelet, filter_length, nlevel, extension_mode)

% y_serial : coming from standard dwt2
% y_faceted: coming from faceted dwt2
% Ij, Ncoefs: variables allowing to index properly into the coefficients
% for comparison

% compare on a per dictionary basis (standard SARA coeffs concatenated by dictionary)
Q = numel(Ncoefs);
M = numel(Ncoefs{1});

% number of wavelet coefficients per dictionary (allows indexing in SARA wavelet coefficients)
s_dictionary = zeros(M, 1);
coeffs = cell(M, 1);
coeffs_faceted = cell(M, 1);
start = 1;
for m = 1:M
    if ~strcmp(wavelet{m}, 'self')
        [~, s_dictionary(m)] = n_wavelet_coefficients(filter_length(m), N, extension_mode, nlevel);
    else
        s_dictionary(m) = prod(N);
    end
    coeffs{m} = y(start:start+s_dictionary(m)-1);
    coeffs_faceted{m} = zeros(s_dictionary(m), 1);
    start = start+s_dictionary(m);
end

% extract "valid" wavelet coefficients from each facet for each dictionary
% for comparison
start_global = ones(M, 1);
for q = 1:Q
    start = 1;       % current position in the vector SPsitLx (contribution from several wavelet dictionaries)
    start_coefs = 1; % current posisiton in the Ncoefs matrix (get number of coefficients at each scale for a each basis)
    for m = 1:M
        % inverse transform
        if ~strcmp(wavelet{m}, 'self')
            Ncoefs_m = Ncoefs{q}(start_coefs:start_coefs+(J+1)-1,:);
            s = 3*sum(prod(Ncoefs_m(1:end-1, :), 2)) + prod(Ncoefs_m(end,:));
            x0 = y_faceted{q}(start:start+s-1);
            x1 = 
            start = start + s;
            start_coefs = start_coefs + (J+1);
        else
            s = prod(Ncoefs{q}(start_coefs,:)); % = prod(dims) for the Dirac basis (no boundary extension) 
            x = y_faceted{q}(start:start+s-1);
            start = start + s;
            start_coefs = start_coefs + 1;
        end
        coeffs_faceted{m}(start_global(m):start_global(m)+s-1) = x;
        start_global(m) = start_global(m) + s;
    end
end


% coefs = cell(J+1,3);
% coefsSelect = cell(J+1,3);
% 
%     coefs{end,1} = appcoef2(C,S,lo_r,hi_r,J);
% for j=1:J
%      [coefs{j,1},coefs{j,2},coefs{j,3}] = detcoef2('all',C,S,j); 
% end
% 
% 
% coefsSelect{J+1,1} = coefs{J+1,1}...
%                      (segment{4,2}{J+1}(1)+1:segment{4,2}{J+1}(1)+segment{4,3}{J+1}(1),...
%                      segment{4,2}{J+1}(2)+1:segment{4,2}{J+1}(2)+segment{4,3}{J+1}(2));