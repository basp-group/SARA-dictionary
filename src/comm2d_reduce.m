function x_overlap = comm2d_reduce(x_overlap, overlap_size, Qy, Qx)
% Reduce overlapping borders between contiguous facets (2D).
%
% Additive reduction of the duplicated area (overlap regions) for a 2D
% image tessellation (2D communication grid).
%
% Parameters
% ----------
% x_overlap : double[:, :]
%     Spatial facet considered (with overlap).
% overlap_size : int[2, 1]
%     Size of the left and top facet extensions [2,1].
% Qy : int
%     Number of spatial facets along the y axis.
% Qx : int
%     Number of spatial facets along the x axis.
%
% Returns
% -------
% x_overlap : double[:, :]
%     Updated spatial facet.
%

% -------------------------------------------------------------------------%
%%
% Code: P.-A. Thouvenin.
% [22/03/2019] final debug, code ok
% [03/04/2019] add basic support for wideband, see if further modifications
% are needed later on (for the spectral splitting)
% -------------------------------------------------------------------------%
%%

% communications to aggregate information
[qy, qx] = ind2sub([Qy, Qx], labindex);

% destination
dest_vert = []; % workers sending information to the current worker
dest_horz = []; % workers waiting for informations from the current worker
dest_diag = [];

% reception
src_vert = []; % workers sending information to the current worker
src_horz = []; % workers waiting for informations from the current worker
src_diag = [];

% data to send
data_vert = [];
data_horz = [];
data_diag = [];

% define communications (to N, W, NW)
if qy > 1
    % N communication (qy-1, qx) -> q = (qx-1)*Qy + qy-1
    dest_vert = (qx - 1) * Qy + qy - 1;
    data_vert = x_overlap(1:overlap_size(1), 1:end, :);
    if qx > 1
        % NW communication (qy-1, qx-1) -> q = (qx-2)*Qy + qy-1
        dest_diag = (qx - 2) * Qy + qy - 1;
        data_diag = x_overlap(1:overlap_size(1), 1:overlap_size(2), :);
        % another set of variables overlap_size will be needed to update the borders (adjoint communicationss)
    end
end

if qx > 1
    % W communication (qy, qx-1) -> q = (qx-2)*Qy + qy
    dest_horz = (qx - 2) * Qy + qy;
    data_horz = x_overlap(1:end, 1:overlap_size(2), :);
end

% define receptions (from S, E, SE)
if qy < Qy
    % S reception (qy+1, qx) -> q = (qx-1)*Qy + qy+1
    src_vert = (qx - 1) * Qy + qy + 1;
    if qx < Qx
        % SE reception (qy+1, qx+1) -> q = qx*Qy + qy+1
        src_diag = qx * Qy + qy + 1;
    end
end

if qx < Qx
    % E reception (qy, qx+1) -> q = qx*Qy + qy
    src_horz = qx * Qy + qy;
end

% is there a way to do everything at once? (i.e., reduce the
% synchronization phasea induced by the three calls to labSendReceive?)
% see if this can be as efficient as the gop operation (to be confirmed)
% vertical communications
rcv_vert_data = labSendReceive(dest_vert, src_vert, data_vert);
% horizontal communications
rcv_horz_data = labSendReceive(dest_horz, src_horz, data_horz);
% diagonal communications
rcv_diag_data = labSendReceive(dest_diag, src_diag, data_diag);

% update portions of the overlapping facet with the received data (aggregate and sum)
if ~isempty(rcv_vert_data) % from S
    x_overlap(end - size(rcv_vert_data, 1) + 1:end, 1:end, :) = ...
        x_overlap(end - size(rcv_vert_data, 1) + 1:end, 1:end, :) + rcv_vert_data;
end

if ~isempty(rcv_horz_data) % from E
    x_overlap(1:end, end - size(rcv_horz_data, 2) + 1:end, :) = ...
        x_overlap(1:end, end - size(rcv_horz_data, 2) + 1:end, :) + rcv_horz_data;
end

if ~isempty(rcv_diag_data) % from SE
    x_overlap(end - size(rcv_diag_data, 1) + 1:end, end - size(rcv_diag_data, 2) + 1:end, :) = ...
        x_overlap(end - size(rcv_diag_data, 1) + 1:end, end - size(rcv_diag_data, 2) + 1:end, :) + rcv_diag_data;
end

end
