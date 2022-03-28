classdef Sdwt2FacetingTest < matlab.unittest.TestCase

% TODO: add comparison with Matlab wavelet transform (need to extract valid
% TODO  coefficients)

    properties (SetAccess = private)
        x % test image
        N % size(x)
    end

    methods (TestClassSetup)

        function addToPath(testCase)
            p = path;
            testCase.addTeardown(@path, p);
            addpath('../src');
            addpath('../data');
        end

        function setupProperties(testCase)
            testCase.x = double(imread('data/lena.bmp')) / 255;
            testCase.N = size(testCase.x);
        end

    end

    methods (Test)

        function testSetup(testCase)
            % verify each tile is larger than the worst-case overlap needed
            % for the faceted wavelet transform. Trigger an error otherwise
            Qy = 5;
            Qx = 3;
            Q = Qx * Qy;
            rg_y = split_range(Qy, testCase.N(1));
            rg_x = split_range(Qx, testCase.N(2));

            I = zeros(Q, 2);
            dims = zeros(Q, 2);
            for qx = 1:Qx
                for qy = 1:Qy
                    q = (qx - 1) * Qy + qy;
                    I(q, :) = [rg_y(qy, 1) - 1, rg_x(qx, 1) - 1];
                    dims(q, :) = [rg_y(qy, 2) - rg_y(qy, 1) + 1, ...
                                  rg_x(qx, 2) - rg_x(qx, 1) + 1];
                end
            end

            % SARA wavelet dictionary
            n = 8;
            nlevel = 3;
            M = numel(n) + 1;
            wavelet = cell(M, 1);
            for m = 1:M - 1
                wavelet{m} = ['db', num2str(n(m))];
            end
            wavelet{end} = 'self';
            L = [2 * n, 0].'; % filter length

            testCase.verifyError(@()sdwt2_setup(testCase.N, I, dims, ...
                nlevel, wavelet, L), 'sdwt2_setup:DimensionError');
        end

        function testForwardInverseSARA(testCase)
            Qy = 4;
            Qx = 4;
            Q = Qx * Qy;
            rg_y = split_range(Qy, testCase.N(1));
            rg_x = split_range(Qx, testCase.N(2));

            I = zeros(Q, 2);
            dims = zeros(Q, 2);
            for qx = 1:Qx
                for qy = 1:Qy
                    q = (qx - 1) * Qy + qy;
                    I(q, :) = [rg_y(qy, 1) - 1, rg_x(qx, 1) - 1];
                    dims(q, :) = [rg_y(qy, 2) - rg_y(qy, 1) + 1, ...
                                  rg_x(qx, 2) - rg_x(qx, 1) + 1];
                end
            end

            % SARA wavelet dictionary
            n = 8;
            nlevel = 3;
            M = numel(n) + 1;
            wavelet = cell(M, 1);
            for m = 1:M - 1
                wavelet{m} = ['db', num2str(n(m))];
            end
            wavelet{end} = 'self';
            L = [2 * n, 0].'; % filter length

            [I_overlap_ref, dims_overlap_ref, I_overlap, dims_overlap, ...
                status, offset, pre_offset, post_offset, Ncoefs, ...
                pre_offset_dict, post_offset_dict] = ...
                sdwt2_setup(testCase.N, I, dims, nlevel, wavelet, L);

            % Faceted wavelet transform
            SPsitLx = cell(Q, 1);
            PsiStu = cell(Q, 1);
            for q = 1:Q

                full_facet_size = dims_overlap_ref(q, :) + pre_offset(q, :) + ...
                                    post_offset(q, :);
                x_overlap = zeros(full_facet_size);
                x_overlap(pre_offset(q, 1) + 1:end - post_offset(q, 1), ...
                pre_offset(q, 2) + 1:end - post_offset(q, 2)) = ...
                testCase.x(I_overlap_ref(q, 1) + 1:I_overlap_ref(q, 1) + ...
                dims_overlap_ref(q, 1), I_overlap_ref(q, 2) + 1:I_overlap_ref(q, 2) + dims_overlap_ref(q, 2));

                % forward operator
                SPsitLx{q} = sdwt2_sara_faceting(x_overlap, I(q, :), ...
                offset, status(q, :), nlevel, wavelet, Ncoefs{q});

                % inverse operator
                PsiStu{q} = isdwt2_sara_faceting(SPsitLx{q}, I(q, :), dims(q, :), ...
                I_overlap{q}, dims_overlap{q}, Ncoefs{q}, nlevel, ...
                wavelet, pre_offset_dict{q}, post_offset_dict{q});
            end

            LtPsiStu = zeros(testCase.N);
            for q = 1:Q
                LtPsiStu = place2DSegment(LtPsiStu, PsiStu{q}, ...
                    I_overlap_ref(q, :), dims_overlap_ref(q, :));
            end

            err = norm(LtPsiStu(:) - testCase.x(:)) / norm(testCase.x(:));
            testCase.verifyTrue(err < 1e-10);
        end

    end
end
