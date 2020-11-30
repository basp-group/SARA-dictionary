function [I_overlap_ref, dims_overlap_ref, I_overlap, dims_overlap, ...
    status, offset, pre_offset, post_offset, Ncoefs, pre_offset_dict, ...
    post_offset_dict] = sdwt2_setup(N, I, dims, J, wavelet, L)
% Setup faceted SARA prior.
%
% Compute the auxliary variables (offset, overlap extension per dictionary)
% necessary to define the segmented wavelet transforms underlying the 
% faceted SARA prior.
%
% Args:
%     N (array): full image dimension. [1,2]
%     I (array): start index of each image tile (using 0-indexing) [Q,2]
%     dims (array): dimensions of the image tiles. [Q,2]
%     J (int): number of wavelet decomposition levels.
%     wavelet (cell): name of the wavelet dictionaries. {M,1}
%     L (array): size of the wavelet filters. [M,1]     
%
% Returns:
%     I_overlap_ref (array): start index of the facet within the full 
%                     image. [Q,2] 
%     dims_overlap_ref (array): dimension of the facet (i.e., with 
%                     overlap) to be extracted from the full image. [Q,2]
%     I_overlap (array): start index of the facet (for each 
%                     dictionary) within the full image. {Q,1}[M,2]
%     dims_overlap (array): dimension of the facet considered by each 
%                    dictionary (including 0 coefficients from padding). 
%                    {Q,1}[M,2]
%     status (array): status of the facet along each dimension (i.e., 
%                    whether it is the 'first' facet, 'last', 'none' of the
%                    previous option or 'both'). The associated status 
%                    value are respectively -1, 1, 0 and NaN. [Q,2]
%                    (could be 2 instead...)
%     offset (array): offset to get the index of the first element 
%                    (along each dimension) to be considered in the facet 
%                    for each wavelet dictionary
%     pre_offset (array): number of coefficients to be cropped from 
%                    the beginning of the global facet [M,2].
%                    (offset to get position of the first non-zero element 
%                     in the "global" facet)
%     post_offset (array): number of coefficients to be cropped from 
%                    the end of the global facet [M,2].
%                    (offset to get position of the last non-zero element 
%                     in the "global" facet)
%     Ncoefs (cell): size of the details coefficients for each dictionary
%                    at each level of the decomposition
%                    {Q}[(M-1)*(J+1)+1,2] if Dirac dict. is present
%     pre_offset_dict (array): for each dictionary, number of 
%                    coefficients to be cropped from the beginning of the 
%                    global facet [M,2].
%     post_offset_dict (array): for each dictionary, number of 
%                    coefficients to be cropped from the end of the global
%                    facet [M,2].
%     Ij (cell):     starting index of the correct wavelet coefficients for
%                    dictionary at each level of the decomposition 
%                    {Q}[(M-1)*(J+1)+1,2] if Dirac dict. is present
%
% Note: all indexes reported above (I_*) start from 0 (not from 1).

%
%-------------------------------------------------------------------------%
%%
% Code: P.-A. Thouvenin.
% Note: 
% all the facet indices "I_*" use 0-indexing (i.e., indices start at 0, 
% not 1).
%
% Vocabulary: 
% 1. image tile: no overlap 
% 2. image facet: overlapping image tessellation

% Notes:  1. I_overlap_ref / dims_overlap_ref do not include the zeros added!
% only indicates portion to be extracted from the global image to
% create the local facet
% 2. I_overlap / dims_overlap include the additional zeros
%-------------------------------------------------------------------------%
%%
% TODO: add condition: do not allow overlap to extend over more than 1 
% consecutive tiles !!!

% keep the most general version for now, but add a condition to avoid any
% issue if the overlap extends over more than 1 facets (or needs additional 
% zeros)

% check independently: error if any(dims(:, i) < (2^J-1)*(max(L(:))-1))
% (worst case overlap)
%%

% check dimension of the image tiles is larger than worst-case overlap 
% (avoid overlap with more than one facet along each dimension)
err_check = any(dims <= (2^J-1)*(max(L(:))-1), 1);
if (any(err_check))
   error('sdwt2_setup:DimensionError', ['Facet size smaller than the ' ...
       'worst-case overlap required along dimension(s): ', num2str(find(err_check))]);
end

M = numel(wavelet);                 % number of wavelet dictionaries
rJ_max = (2^J-1)*(max(L(:))-2);     % value of rJ for the largest filter
rJ = zeros(M, 1);
for m = 1:M
    if ~strcmp(wavelet{m}, 'self')
        rJ(m) = (2^J-1)*(L(m) - 2); % r_red(J) (4.12)
    else
        rJ(m) = 0; % do not forget to add mod(I(q, :), 2^J) (see l.64 below) to the normal offset
    end
end
offset = rJ_max - rJ; % compute offset (in the facet) to determine which 
                      % portion of the facet should be used for each 
                      % wavelet dictionary

Q = size(I, 1); % number of facets / image tiles
dim = 2;        % number of dimensions

I_overlap = cell(Q, 1);
I_overlap_ref = zeros(Q, 2);
status = zeros(Q, 2);
dims_overlap = cell(Q, 1);
dims_overlap_ref = zeros(Q, 2);
pre_offset = zeros(Q, 2);      % offset to get position of the first non-zero element in the "global" facet
post_offset = zeros(Q, 2);     % offset to get position of the last non-zero element in the "global" facet
pre_offset_dict = cell(Q, 1);  % offset to get position of the first non-zero element in the facet (for each dict) {Q}[M, 2]
                               % offset for left cropping in isdwt2 (see possible simplification)
post_offset_dict = cell(Q, 1); % offset to get position of the first non-zero element in the facet (for each dict) {Q}[M, 2]
                               % offset for right cropping in isdwt2 (see possible simplification)

% determine if the Dirac basis ('self') is among the dictionaries
dirac_present = any(ismember(wavelet, 'self'));
if dirac_present
   s_Ncoefs = (M-1)*(J+1)+1; % number of rows in the Ncoefs matrix (sizes for all the local decomposition levels)
else
   s_Ncoefs = M*(J+1);
end
Ncoefs = cell(Q, 1); % number of coefficients corresponding to each dictionary, at each scale of interest
% Ij = cell(Q, 1);   % starting coefficients of each "facet" at each scale (indexing within wavelet coefficients) 

for q = 1:Q % define facet parameters    
    % note: extension width and dimensions are amended later, depending on the
    % position of the facet (first/last along each dimension)

    %% see if this can be simplified
    
    LnoR = rJ_max + mod(I(q,:),2^J); % extension width for longest filter in the dictionary
    dimensions = dims(q, :)+LnoR;    % dimension after left extension
    corner = I(q,:)-LnoR;            % starting index after left extension
    for i=1:dim
        if corner(i)<0                                 % if border facet (left or top)
            pre_offset(q,i)= -corner(i);               % index of the first non-zero value in the facet
            dimensions(i) = dimensions(i) + corner(i);
            corner(i)=0;
        end
        if corner(i)+dimensions(i)>=N(i)
            post_offset(q,i) = corner(i) + dimensions(i) - N(i);
            dimensions(i) = N(i)-corner(i);
        end
    end
    I_overlap_ref(q, :) = corner;
    dims_overlap_ref(q, :) = dimensions;
    
    % try to simplify this part (determine whether facet is first, last, or "both" along its dimension)
    for i=1:dim
        bool_first = false;
        if I(q, i)==0
            status(q,i) = -1; % first
            pre_offset(q,i) = 0;
            bool_first = true;
        end
        if I(q, i)+dims(q, i) == N(i)
            if bool_first % first & last
                status(q,i) = NaN;
            else
                status(q,i) = 1; % last
            end
            post_offset(q,i) = 0;
        end
    end
    
    %% to be simplified
    % Compute starting index/size of the overlapping facets
    I_overlap{q} = zeros(M, 2);
    dims_overlap{q} = zeros(M, 2);
    pre_offset_dict{q} = zeros(M, 2);  % offset for left cropping in isdwt2 (see possible simplification)
    post_offset_dict{q} = zeros(M, 2); % offset for right cropping in isdwt2 (see possible simplification)    
    % LnoR_M = (rJ + mod(I(q,:),2^J)).*(rJ > 0); % [M,2]
    % corner = I(q,:)-LnoR_M;
    % dimensions = I(q,:)+LnoR_M;
    for m = 1:M
        if strcmp(wavelet{m}, 'self')
            I_overlap{q}(m, :) = I(q, :);
            dims_overlap{q}(m, :) = dims(q, :);
        else
            LnoR_m = rJ(m) + mod(I(q,:),2^J);    % extension width
            corner = I(q,:)-LnoR_m;              % starting index after left extension
            dimensions = dims(q,:)+LnoR_m;       % dimension after left extension
            for i=1:dim
                if corner(i)<0
                    % pre_offset_dict{q}(m,i)= -corner(m,i);
                    % dimensions(m,i) = dimensions(m,i) + corner(m,i);
                    % corner(m,i)=0;
                    pre_offset_dict{q}(m,i)= -corner(i);
                    dimensions(i) = dimensions(i) + corner(i);
                    corner(i)=0;
                end
                if corner(i)+dimensions(i)>=N(i)
                    % post_offset_dict{q}(m,i) = corner(m,i)+dimensions(m,i) - N(i);
                    % dimensions(m,i) = N(i)-corner(m,i);
                    post_offset_dict{q}(m,i) = corner(i)+dimensions(i) - N(i);
                    dimensions(i) = N(i)-corner(i);
                end
            end
            I_overlap{q}(m,:) = corner;
            dims_overlap{q}(m,:) = dimensions;
        end
    end
    
    %% to be simplified (only change name of variables)
    % Compute number of coefficients for each dictionary at each scale
    Ncoefs{q} = zeros(s_Ncoefs,2);
    idx_current = I(q, :);              % start index current facet
    idx_next = dims(q,:) + idx_current; % start index next facet
    id_Ncoefs = 0;
    %Ij{q} = zeros(s_Ncoefs,2);
    for m = 1:M
        if ~strcmp(wavelet{m}, 'self')
            for d = 1:dim
                idx_current_j = floor(idx_current(d)./(2.^(1:J).')); % start index current facet at scale j
                if status(q, d) > 0 || isnan(status(q, d)) % last / first & last
                    idx_next_j = floor(2.^(-(1:J).').*idx_next(d)+(1-2.^(-(1:J).'))*(L(m)-1));
                else
                    idx_next_j = floor(idx_next(d)./(2.^(1:J).'));
                end
                Ncoefs{q}(id_Ncoefs+1:id_Ncoefs+J,d) = idx_next_j - idx_current_j; % [P.-A.] (4.19)
                %Ij{q}(id_Ncoefs+1:id_Ncoefs+J,d) = idx_current_j;
            end
            Ncoefs{q}(id_Ncoefs+J+1,:) = Ncoefs{q}(id_Ncoefs+J,:);
            id_Ncoefs = id_Ncoefs + (J+1);
        else
            Ncoefs{q}(id_Ncoefs+1, :) = dims(q, :);
            %Ij{q}(id_Ncoefs+1, :) = [0, 0];
            id_Ncoefs = id_Ncoefs + 1;
        end
    end
end

end
