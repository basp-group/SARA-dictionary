clc; clear all; close all;
format compact;
addpath ../src;
addpath ../lib;

%%
max_iter = 3000;
tol = 1e-8;
verbose = 2;

%%
N = [1024, 2048];
overlap_fraction = 0.5;
Qy = 4;
Qx = 2;
Q = Qx * Qy;
wintype = 'triangular'; % norm of the operator is greater than 1 for hamming window, 1 for the normalized windows

overlap_size = get_overlap_size(N, [Qy, Qx], overlap_fraction);
rg_y = split_range(Qy, N(1));
rg_x = split_range(Qx, N(2));
rg_yo = split_range(Qy, N(1), overlap_size(1));
rg_xo = split_range(Qx, N(2), overlap_size(2));

dims = zeros(Q, 2);
dims_o = zeros(Q, 2);
I = zeros(Q, 2);
Io = zeros(Q, 2);
w = cell(Q, 1);
for qx = 1:Qx
    for qy = 1:Qy
        q = (qx - 1) * Qy + qy;
        I(q, :) = [rg_y(qy, 1) - 1, rg_x(qx, 1) - 1];
        dims(q, :) = [rg_y(qy, 2) - rg_y(qy, 1) + 1, rg_x(qx, 2) - rg_x(qx, 1) + 1];
        Io(q, :) = [rg_yo(qy, 1) - 1, rg_xo(qx, 1) - 1];
        dims_o(q, :) = [rg_yo(qy, 2) - rg_yo(qy, 1) + 1, rg_xo(qx, 2) - rg_xo(qx, 1) + 1];
        w{q} = generate_weights(qx, qy, Qx, Qy, wintype, dims(q, :), dims_o(q, :), overlap_size);
    end
end

% w2d = generate_weights(1, 1, Qx, Qy, wintype, dims(q,:), dims_o(q,:), overlap_size);
% % test_win_x = window('hamming',2*overlap_size(2)+1);
% % test_win_y = window('hamming',2*overlap_size(1)+1);
% %
% % w2d = test_win_y.*(test_win_x');
% w2d2 = w2d(1:overlap_size(1), 1:overlap_size(2)).^2 + w2d(1:overlap_size(1), overlap_size(2)+2:end).^2 + ...
%     w2d(overlap_size(1)+2:end, 1:overlap_size(2)).^2 + w2d(overlap_size(1)+2:end, overlap_size(2)+2:end).^2;
% val0 = max(w2d2(:).^2);

%%
% analytical value for the operator norm
x_test = zeros(N);
for q = 1:Q
    x_test(Io(q, 1) + 1:Io(q, 1) + dims_o(q, 1), Io(q, 2) + 1:Io(q, 2) + dims_o(q, 2)) = ...
        x_test(Io(q, 1) + 1:Io(q, 1) + dims_o(q, 1), Io(q, 2) + 1:Io(q, 2) + dims_o(q, 2)) + ...
        w{q}.^2;
end

max(x_test(:));

%%
Ax = cell(Q, 1);
x = randn(N);
x = x / norm(x(:));
init_val = 1;

for k = 1:max_iter
    % y = A(x);
    for q = 1:Q
        Ax{q} = w{q} .* x(Io(q, 1) + 1:Io(q, 1) + dims_o(q, 1), ...
            Io(q, 2) + 1:Io(q, 2) + dims_o(q, 2));
    end

    % x = At(y);
    x = zeros(N);
    for q = 1:Q
        x(Io(q, 1) + 1:Io(q, 1) + dims_o(q, 1), Io(q, 2) + 1:Io(q, 2) + dims_o(q, 2)) = ...
            x(Io(q, 1) + 1:Io(q, 1) + dims_o(q, 1), Io(q, 2) + 1:Io(q, 2) + dims_o(q, 2)) + ...
            w{q} .* Ax{q};
    end

    val = norm(x(:));
    rel_var = abs(val - init_val) / init_val;

    if verbose > 1
        fprintf('Iter = %i, norm = %e \n', k, val);
    end
    if rel_var < tol
        break
    end

    init_val = val;
    x = x / val;
end

%%
if verbose > 0
    fprintf('Norm = %e \n\n', val);
end
