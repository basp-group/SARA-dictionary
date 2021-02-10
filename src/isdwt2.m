function PsiSty = isdwt2(SPsitLx, I, dims, Ncoefs, lo, hi, J, pre_offset, post_offset)
% Inverse facet wavelet transform.
%
% Inverse operator to compute the contribution of a single facet to the
% full wavelet transform.
%
% Args:
%     SPsitLx (array): wavelet coefficients obtained from the facet of
%                          interest.
%     I (array): starting index of the tile (no overlap) [1,2].
%     dims (array): dimension of tbe underlying tile (no overlap) [1,2].
%     Ncoefs (array): dimension of the wavelet facets for each level
%                          of the decomposition level, for each dictionary
%                          [M(J+1),2] {from level 1 to J}.
%     lo (array): low-pass synthesis wavelet filter. [1,L]
%     hi (array): high-pass synthesis wavelet filter. [1,L]
%     J (int): number of decomposition levels considered.
%     wavelet (cell): name of the wavelet dictionaries considered {M,1}.
%     pre_offset (array): number of coefficients to be cropped from
%                          the start of the reconstructed facet [1,2].
%     post_offset (array): number of coefficients to be cropped at
%                          the end of the reconstructed facet [1,2].
%
% Returns:
%     SPsitLx (array): inverse transform of the input matrix.
%

%
%-------------------------------------------------------------------------%
%%
% Code: P.-A. Thouvenin.
% TODO: ...
%-------------------------------------------------------------------------%
%%

% inverse wavelet transform
dim = 2;
noSubb = dim^2-1;

% precompute rJ
rJ = [(2.^(J-(1:J-1).')-1)*(length(lo)-2) + floor(mod(I,2^J)./(2.^(1:J-1).')); zeros(1, 2)];

% level J (index J+1)
s = 3*sum(prod(Ncoefs(1:end-1,:), 2)) + prod(Ncoefs(end,:)); % total number of coefficients
sj = prod(Ncoefs(J+1,:));
start = s-sj;
in = reshape(SPsitLx(start+1:sj+start), Ncoefs(J+1,:));

% levels J-1 to 1 (index J to 2)
for j=J:-1:2
    rows = Ncoefs(j-1,1)+rJ(j-1,1);
    sj = prod(Ncoefs(j,:));
    start = start - 3*sj;
    if j == J
        coefTemp = reshape(SPsitLx(start+1:start+3*sj), [Ncoefs(J,:), noSubb]);
        cols = Ncoefs(j,2)+rJ(j,2);
    else
        cols = Ncoefs(j,2)+rJ(j,2);
        coefTemp = zeros([rJ(j,:) + Ncoefs(j,:), 3]);
        coefTemp(end-Ncoefs(j,1)+1:end, end-Ncoefs(j,2)+1:end, :) = reshape(SPsitLx(start+1:start+3*sj), [Ncoefs(j,:), noSubb]);
    end
    
    % upsamling, convolution and cropping along the columns
    tempRows = upConv2c(in, lo, rows, cols) + upConv2c(coefTemp(:,:,1), hi, rows, cols);
    tempRows2 = upConv2c(coefTemp(:,:,2), lo, rows, cols) + upConv2c(coefTemp(:,:,3), hi, rows, cols);
    
    % upsamling, convolution and cropping along the rows
    cols = Ncoefs(j-1,2)+rJ(j-1,2);
    in = upConv2r(tempRows, lo, rows, cols) + upConv2r(tempRows2, hi, rows, cols);
end

% level 0
sj = prod(Ncoefs(1,:));
start = start - 3*sj;
coefTemp = zeros([rJ(1,:) + Ncoefs(1,:), noSubb]);
coefTemp(end-Ncoefs(1,1)+1:end, end-Ncoefs(1,2)+1:end, :) = reshape(SPsitLx(start+1:3*sj+start), [Ncoefs(1,:), noSubb]);

% upsamling, convolution and cropping along the columns
cols = Ncoefs(1,2)+rJ(1,2);
rJ = (2^J-1)*(length(lo)-2)+mod(I(1),2^J);
rows = dims(1)+rJ;
tempRows = upConv2c(in, lo, rows, cols) + upConv2c(coefTemp(:,:,1), hi, rows, cols);
tempRows2 = upConv2c(coefTemp(:,:,2), lo, rows, cols) + upConv2c(coefTemp(:,:,3), hi, rows, cols);

% upsamling, convolution and cropping along the rows
rJ = (2^J-1)*(length(lo)-2) + mod(I(2),2^J);
cols = dims(2) + rJ;
PsiSty = upConv2r(tempRows, lo, rows, cols) + upConv2r(tempRows2, hi, rows, cols);

PsiSty = PsiSty(pre_offset(1)+1:end-post_offset(1),pre_offset(2)+1:end-post_offset(2));

end

%% internal functions
function y = upConv2c(x, w, rows, cols)

z = zeros(2*size(x, 1), cols);
z(1:2:end, :) = x;
y = conv2(z, w.');
y = y(1:rows, :);

end

function y = upConv2r(x, w, rows, cols)

z = zeros(rows, 2*size(x, 2));
z(:, 1:2:end) = x;
y = conv2(z, w);
y = y(:, 1:cols);

end