function im = place2DSegment(im, PsiSty, I_facet_min, dims_facet_max)
% Recombine image coefficients coming from the inverse faceted wavelet transform
% of a single facet back into a full-size image (exclusively used for testing
% and debugging purposes).
%
% Parameters
% ----------
% im : array[:, :]
%     Input image.
% PsiSty : array[:]
%     Coefficients associated to a given facet.
% I_facet_min : int[2, 1]
%     Starting index of the associated image facet.
% dims_facet_max :
%     Dimension of the image facet.
%
% Returns
% -------
% im : array[:, :]
%     Updated image.

% input min I_overlap + max dims_overlap
im(I_facet_min(1) + 1:I_facet_min(1) + dims_facet_max(1), I_facet_min(2) + 1:I_facet_min(2) + dims_facet_max(2), :) = ...
im(I_facet_min(1) + 1:I_facet_min(1) + dims_facet_max(1), I_facet_min(2) + 1:I_facet_min(2) + dims_facet_max(2), :) + PsiSty;

end
