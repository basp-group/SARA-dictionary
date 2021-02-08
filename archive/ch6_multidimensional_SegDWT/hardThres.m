function segment=hardThres(segment,lambda)

coeffs = segment{4,1};

for el=1:numel(coeffs)
    subband = coeffs{el};
    subband(find(abs(subband)<=lambda))=0;
    segment{4,1}{el} = subband;
end

