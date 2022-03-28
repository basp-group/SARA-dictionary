classdef GenerateWeightsTest < matlab.unittest.TestCase

    properties (SetAccess = private)
        N    % image size
        Qx   % number of facet (x-axis)
        Qy   % number of facet (y-axis)
        Io    % start index of the image facets (0-indexing)
        dims % dimension of image tiles
        dims_o % dimension of overlapping facets
        overlap_fraction % overlap size, as a fraction of the facet size
        d    % number of pixels on the overlap
    end

    methods (TestClassSetup)

        function addSplitRangeToPath(testCase)
            p = path;
            testCase.addTeardown(@path, p);
            addpath('../src');
        end

        function setParameters(testCase)
            testCase.N = [1024, 1024];
            testCase.overlap_fraction = 0.5;

            % facet definition
            testCase.Qy = 4;
            testCase.Qx = 4;
            testCase.d = floor(testCase.overlap_fraction * testCase.N ./ ...
                ((1 - testCase.overlap_fraction) * [testCase.Qy, testCase.Qx]));
            rg_y = split_range(testCase.Qy, testCase.N(1));
            rg_x = split_range(testCase.Qx, testCase.N(2));
            rg_yo = split_range(testCase.Qy, testCase.N(1), testCase.d(1));
            rg_xo = split_range(testCase.Qx, testCase.N(2), testCase.d(2));
            Q = testCase.Qy * testCase.Qx;
            testCase.Io = zeros(Q, 2);
            testCase.dims = zeros(Q, 2);
            testCase.dims_o = zeros(Q, 2);
            for qx = 1:testCase.Qx
                for qy = 1:testCase.Qy
                    q = (qx - 1) * testCase.Qy + qy;
                    testCase.Io(q, :) = [rg_yo(qy, 1) - 1, rg_xo(qx, 1) - 1];
                    testCase.dims(q, :) = [rg_y(qy, 2) - rg_y(qy, 1) + 1, rg_x(qx, 2) - rg_x(qx, 1) + 1];
                    testCase.dims_o(q, :) = [rg_yo(qy, 2) - rg_yo(qy, 1) + 1, rg_xo(qx, 2) - rg_xo(qx, 1) + 1];
                end
            end
        end

    end

    methods (Test)

        function testSumTriangularWeights(testCase)
            sum_w = zeros(testCase.N);
            for qx = 1:testCase.Qx
                for qy = 1:testCase.Qy
                    q = (qx - 1) * testCase.Qy + qy;
                    w = generate_weights(qx, qy, testCase.Qx, testCase.Qy, ...
                        'triangular', testCase.dims(q, :), ...
                        testCase.dims_o(q, :), ...
                        testCase.d);
                    sum_w(1 + testCase.Io(q, 1):testCase.Io(q, 1) + testCase.dims_o(q, 1), 1 + testCase.Io(q, 2):testCase.Io(q, 2) + testCase.dims_o(q, 2)) = ...
                    sum_w(1 + testCase.Io(q, 1):testCase.Io(q, 1) + testCase.dims_o(q, 1), 1 + testCase.Io(q, 2):testCase.Io(q, 2) + testCase.dims_o(q, 2)) + w;
                end
            end
            testCase.verifyTrue(norm(sum_w(:) - 1) / norm(sum_w(:)) < 1e-14);
        end

        function testSumPCWeights(testCase)
            sum_w = zeros(testCase.N);
            for qx = 1:testCase.Qx
                for qy = 1:testCase.Qy
                    q = (qx - 1) * testCase.Qy + qy;
                    w = generate_weights(qx, qy, testCase.Qx, testCase.Qy, ...
                        'pc', testCase.dims(q, :), ...
                        testCase.dims_o(q, :), ...
                        testCase.d);
                    sum_w(1 + testCase.Io(q, 1):testCase.Io(q, 1) + testCase.dims_o(q, 1), 1 + testCase.Io(q, 2):testCase.Io(q, 2) + testCase.dims_o(q, 2)) = ...
                    sum_w(1 + testCase.Io(q, 1):testCase.Io(q, 1) + testCase.dims_o(q, 1), 1 + testCase.Io(q, 2):testCase.Io(q, 2) + testCase.dims_o(q, 2)) + w;
                end
            end
            testCase.verifyTrue(norm(sum_w(:) - 1) / norm(sum_w(:)) < 1e-14);
        end

    end
end
