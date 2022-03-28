function val = op_norm(A, At, im_size, tol, max_iter, verbose)
% Computes the maximum eigen value of the compound operator :math:`A^TA`.
%
% Parameters
% ----------
% A : anonymous function
%     Direct linear operator :math:`A`.
% At : anonymous function
%     Adjoint of the linear operator :math:`A`, denoted :math:`A^T`.
% im_size : array (int)
%     Size of the variable on which :math:`A` operates.
% tol : double
%     Convergence tolerance (relative variation between two consecutive
%     iterates).
% max_iter : int
%     Maximum number of iterations.
% verbose : int
%     Activate verbose mode (if > 0).
%
% Returns
% -------
% val : double
%     Maximum eigenvalue of the linear operator :math:`A^TA`.
%

%A. Onose, A. Dabbech, Y. Wiaux - An accelerated splitting algorithm for radio-interferometric %imaging: when natural and uniform weighting meet, MNRAS 2017, arXiv:1701.01748
%https://github.com/basp-group/SARA-PPD
%%
x = randn(im_size);
x = x/norm(x(:));
init_val = 1;

for k = 1:max_iter
    y = A(x);
    x = At(y);
    val = norm(x(:));
    rel_var = abs(val-init_val)/init_val;
    if (verbose > 1)
        fprintf('Iter = %i, norm = %e \n',k,val);
    end
    if (rel_var < tol)
       break;
    end
    init_val = val;
    x = x/val;

end

if (verbose > 0)
    fprintf('Norm = %e \n\n', val);
end

end
