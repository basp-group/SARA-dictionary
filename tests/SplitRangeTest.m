classdef SplitRangeTest < matlab.unittest.TestCase

    methods (TestClassSetup)

        function addSplitRangeToPath(testCase)
            p = path;
            testCase.addTeardown(@path, p);
            addpath('../src');
        end

    end

    methods (Test)

        function testNumberOfInputError(testCase)
            testCase.verifyError(@()split_range(5, 2, 2, 0), 'split_range:NumberOfInputError');
        end

        function testValueError(testCase)
            N = 5;
            nchunks = 2;
            ovlp = 3;
            testCase.verifyError(@()split_range(nchunks, N, ovlp), 'split_range:InputValueError');
            testCase.verifyError(@()split_range(nchunks, N, -1), 'split_range:InputValueError');
            testCase.verifyError(@()split_range(nchunks, nchunks - 1), 'split_range:InputValueError');
        end

        function testNoOverlap(testCase)
            N = 9;
            nchunks = 3;
            rg = split_range(nchunks, N);
            sz = size(rg);
            testCase.verifyTrue(all(diff(rg, 1, 2) + 1 == 3));
            testCase.verifyTrue(all(all(diff(rg, 1, 1) == 3)));
            testCase.verifyTrue(sz(1) == nchunks);
        end

        function testOverlap(testCase)
            N = 11;
            nchunks = 3;
            ovlp = 3;
            rg = split_range(nchunks, N, ovlp);
            sz = size(rg);
            testCase.verifyTrue(all(abs(rg(1:end - 1, 2) - rg(2:end, 1) + 1) - ovlp == 0));
            testCase.verifyTrue(sz(1) == nchunks);
        end

    end
end
