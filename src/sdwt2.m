function SPsitLx = sdwt2(x_overlap, dims, status, lo, hi, J, Ncoefs)
% Forward facet wavelet transform.
%
% Forward operator to compute the contribution of the a single input facet
% to the whole wavelet transform.
%
% Parameters
% ----------
% x_overlap : array[:, :]
%     Image facet (with overlap).
% dims : int[2]
%     Dimensions of the underlying image tile. [1,2].
% status : int[2]
%     Indicates whether the facet is the first (or the last) along each
%     dimension. [1,2] (first: -1, last: 1, none: 0, or both: NaN)).
% lo : array[1, :]
%     Low-pass analysis wavelet filter. [1,L]
% hi : array[1, :]
%     High-pass analysis wavelet filter. [1,L]
% J : int
%     Number of decomposition levels considered.
% Ncoefs : int[:]
%     Number of wavelet coefficients obtained at each scale. [J+1,1]
%
% Returns
% -------
% SPsitLx : array[:, :]
%     Associated wavelet coefficients.
%

% -------------------------------------------------------------------------%
%%
% Code: P.-A. Thouvenin.
% Notes:
% - check matrix extensions (see if extension can be deferred to a later
% stage)
% TODO: move error message to the setup function
% -------------------------------------------------------------------------%
%%

% calculating numbers of coefficients in each subband in each dimension
% (i.e., h, v, d, a)
for i = 1:2
    if dims(i) < 2^J
        error('Segment size in dim %d must be >=2^J=%d.', i, 2^J);
        % to be checked during the setup
    end
end

% determine cropping and sampling type (depending on the position of the
% facet along each dimension)
if isnan(status(2)) % first and last
    crop_start_lox = 1;
    crop_start_hix = 1;
    crop_end_offset_lox = 0;
    crop_end_offset_hix = 0;
    start_dwnsplx = 2;
elseif status(2) > 0 % last
    crop_start_lox = length(lo);
    crop_start_hix = length(hi);
    crop_end_offset_lox = 0;
    crop_end_offset_hix = 0;
    start_dwnsplx = 1;
elseif status(2) < 0 % first
    crop_start_lox = 1;
    crop_start_hix = 1;
    crop_end_offset_lox = length(lo) - 1;
    crop_end_offset_hix = length(hi) - 1;
    start_dwnsplx = 2;
else
    crop_start_lox = length(lo);
    crop_start_hix = length(hi);
    crop_end_offset_lox = length(lo) - 1;
    crop_end_offset_hix = length(hi) - 1;
    start_dwnsplx = 1;
end

if isnan(status(1)) % first and last
    crop_start_loy = 1;
    crop_start_hiy = 1;
    crop_end_offset_loy = 0;
    crop_end_offset_hiy = 0;
    start_dwnsply = 2;
elseif status(1) > 0 % last
    crop_start_loy = length(lo);
    crop_start_hiy = length(hi);
    crop_end_offset_loy = 0;
    crop_end_offset_hiy = 0;
    start_dwnsply = 1;
elseif status(1) < 0 % first
    crop_start_loy = 1;
    crop_start_hiy = 1;
    crop_end_offset_loy = length(lo) - 1;
    crop_end_offset_hiy = length(hi) - 1;
    start_dwnsply = 2;
else
    crop_start_loy = length(lo);
    crop_start_hiy = length(hi);
    crop_end_offset_loy = length(lo) - 1;
    crop_end_offset_hiy = length(hi) - 1;
    start_dwnsply = 1;
end

%% forward wavelet transform
PsitLx = cell(3); % (h, v, d) for each 1<= j <= J, a for J+1.

% do the extensions later on ! (just before the convolutions)
in = x_overlap;

% total number of coefficients
s = 3 * sum(prod(Ncoefs(1:end - 1, :), 2)) + prod(Ncoefs(end, :));
SPsitLx = zeros(s, 1); % (h, v, d), last row contains only the approximation a

start = 1;
for j = 1:J
    % convolution along the rows
    tempa = conv2(in, lo); % conv along rows
    tempd = conv2(in, hi); % extend the signal in a different manner to have another boundary condition: combine wextend and conv(., ., 'valid'), check dimension before that

    % downsampling and cropping
    tempa = tempa(:, crop_start_lox:end - crop_end_offset_lox);
    tempa = tempa(:, start_dwnsplx:2:end);
    tempd = tempd(:, crop_start_hix:end - crop_end_offset_hix);
    tempd = tempd(:, start_dwnsplx:2:end);

    % convolutions along the columns
    PsitLx{1} = conv2(tempa, hi.'); % LH
    PsitLx{2} = conv2(tempd, lo.'); % HL
    PsitLx{3} = conv2(tempd, hi.'); % HH
    in = conv2(tempa, lo.'); % LL

    % downsampling and cropping
    PsitLx{1} = PsitLx{1}(crop_start_hiy:end - crop_end_offset_hiy, :);
    PsitLx{1} = PsitLx{1}(start_dwnsply:2:end, :);
    PsitLx{2} = PsitLx{2}(crop_start_loy:end - crop_end_offset_loy, :);
    PsitLx{2} = PsitLx{2}(start_dwnsply:2:end, :);
    PsitLx{3} = PsitLx{3}(crop_start_hiy:end - crop_end_offset_hiy, :);
    PsitLx{3} = PsitLx{3}(start_dwnsply:2:end, :);
    in = in(crop_start_loy:end - crop_end_offset_loy, :);
    in = in(start_dwnsply:2:end, :);

    % cropping
    sj = prod(Ncoefs(j, :));
    if j < J
        for i = 1:3
            SPsitLx((i - 1) * sj + start:i * sj + start - 1) = reshape(PsitLx{i}(end - Ncoefs(j, 1) + 1:end, ...
                end - Ncoefs(j, 2) + 1:end), [sj, 1]);
        end
    else
        for i = 1:3
            SPsitLx((i - 1) * sj + start:i * sj + start - 1) = reshape(PsitLx{i}, [sj, 1]);
        end
    end
    start = start + 3 * sj;
end

sj = prod(Ncoefs(J + 1, :));
SPsitLx(start:start + sj - 1) = reshape(in, [sj, 1]); % approximation

end
