function [Psi, Psit] = op_sp_wlt_basis(basis, nlevel, Ny, Nx)
% Resturns anynomous functions corresponding to the sparsity wavelet basis
% SARA :cite:p:`Carrillo2012` specified from the wavelets taken in `basis`.
%
% Parameters
% ----------
% basis : cell (strings)
%     Cell of strings with the names of the wavelets to be used.
% nlevel : int
%     Number of decomposition levels.
% Ny : int
%     Image size (axis 1).
% Nx : int
%     Image size (axis 2).
%
% Returns
% -------
% Psi : anonymous function
%     Anonymous function implementating the direct SARA operator.
% Psit : anonymous function
%     Anonymous function implementating the inverse SARA operator.
%
% Example
% -------
% >>> basis = {'db1', 'db2', 'self'};
% >>> nlevel = 2;
% >>> Ny = 128;
% >>> Nx = 128;
% >>> [Psi, Psit] = op_sp_wlt_basis(basis, nlevel, Ny, Nx);
%

%% sparsity operator definition
% dwtmode('per');
% construct a sting to repesent the desired inline function
f = '@(x) [';
for i = 1:length(basis)
    if strcmp(basis{i}, 'self')
        f = sprintf('%s x(:);', f);
    else
        f = sprintf('%s wavedec2(x, %d, ''%s'')'';', f, nlevel, basis{i});
    end
end
f = sprintf('%s ]/sqrt(%d)', f, length(basis));
Psit = eval(f);

% for Psi it is a bit more complicated, we need to do some extra
% precomputations
Psi = make_Psi(basis, nlevel, Ny, Nx);

end

function Psi = make_Psi(basis, nlevel, Ny, Nx)

    % estimate the structure of the data used to performe the
    % reconstruction
    S = cell(length(basis), 1);
    ncoef = cell(length(basis), 1);

    for i = 1:length(basis)
        if ~strcmp(basis{i}, 'self')
            [Cb, Sb] = wavedec2(zeros(Ny, Nx), nlevel, basis{i});
            S{i} = Sb;
            ncoef{i} = length(Cb(:));
        end
    end

    % construct a sting to repesent the desired inline function
    f = '@(x) (';
    idx = 1;
    for i = 1:length(basis)
        if strcmp(basis{i}, 'self')
            f = sprintf('%s reshape(x(%d:%d), [Ny Nx]) + ', f, idx, idx + Ny * Nx - 1);
            idx = idx + idx + Ny * Nx;
        else
            f = sprintf('%s waverec2(x(%d:%d), S{%d}, ''%s'') + ', f, idx, idx + ncoef{i} - 1, i, basis{i});
            idx = idx + ncoef{i};
        end
    end
    f = sprintf('%s 0)/sqrt(%d)', f, length(basis));
    Psi = eval(f);
end
