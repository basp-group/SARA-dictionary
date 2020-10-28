classdef Comm2dTest < matlab.unittest.TestCase
    
% TODO: reorganize this test to remove unnecessary variables (if any)
% TODO: avoid closing / opening the pool after each test (costly)

    properties(SetAccess = private)
        x    % test image
        N    % image size
        Qx   % number of facet (x-axis)
        Qy   % number of facet (y-axis)
        I    % start index of the image tiles (0-indexing)
        dims % dimension of image tiles
        % facets SARA parameters
        nlevel
        wavelet
        L
        I_overlap_ref
        dims_overlap_ref
        I_overlap
        dims_overlap
        status
        offset
        pre_offset
        post_offset
        Ncoefs
        pre_offset_dict
        post_offset_dict
    end
    
    methods (TestClassSetup)
        function addSplitRangeToPath(testCase)
            p = path;
            testCase.addTeardown(@path,p);
            addpath('../src');
        end
        
        function setParameters(testCase)
            testCase.x = double(imread('../data/lena.bmp'))/255;
            testCase.N = size(testCase.x);

            % facet definition
            testCase.Qy = 2;
            testCase.Qx = 2;
            rg_y = split_range(testCase.Qy, testCase.N(1));
            rg_x = split_range(testCase.Qx, testCase.N(2));
            Q = testCase.Qy*testCase.Qx;
            testCase.I = zeros(Q, 2);
            testCase.dims = zeros(Q, 2);
            for qx = 1:testCase.Qx
                for qy = 1:testCase.Qy
                    q = (qx-1)*testCase.Qy+qy;
                    testCase.I(q, :) = [rg_y(qy, 1)-1, rg_x(qx, 1)-1];
                    testCase.dims(q, :) = [rg_y(qy,2)-rg_y(qy,1)+1, rg_x(qx,2)-rg_x(qx,1)+1];
                end
            end
            
            % define faceted SARA prior
            n = 1:8;
            testCase.nlevel = 3;
            M = numel(n)+1;
            dwtmode('zpd','nodisp');
            testCase.wavelet = cell(M, 1);
            for m = 1:M-1
                testCase.wavelet{m} = ['db', num2str(n(m))];
            end
            testCase.wavelet{end} = 'self';
            testCase.L = [2*n,0].'; % filter length
            [testCase.I_overlap_ref, testCase.dims_overlap_ref, testCase.I_overlap, testCase.dims_overlap, ...
            testCase.status, testCase.offset, testCase.pre_offset, testCase.post_offset, testCase.Ncoefs, testCase.pre_offset_dict, ...
                testCase.post_offset_dict] = sdwt2_setup(testCase.N, testCase.I, testCase.dims, testCase.nlevel, testCase.wavelet, testCase.L);
        end
    end
    
    % run at the beginning of each testCase
    methods(TestMethodSetup)
        function createPoolAndParameters(testCase)
            numworkers = testCase.Qx*testCase.Qy;
            cluster = parcluster('local');
            cluster.NumWorkers = numworkers;
            cluster.NumThreads = 1;
            ncores = cluster.NumWorkers * cluster.NumThreads;
            if cluster.NumWorkers * cluster.NumThreads > ncores
                exit(1);
            end
            parpool(cluster, numworkers);
        end
    end
    
    % run at the end of each testCase
    methods(TestMethodTeardown)
        function deletePool(testCase)
            delete(gcp('nocreate'));
        end
    end
    
    methods (Test)
        
        function testUpdateBorders(testCase)
            % define parallel constants(known by each worker)
            Q = testCase.Qx*testCase.Qy;
            numworkers = Q;
            Qyp = parallel.pool.Constant(testCase.Qy);
            Qxp = parallel.pool.Constant(testCase.Qx);

            % define composite variables (local to a given worker)
            x_overlap = Composite(numworkers);
            overlap_south = Composite(numworkers);
            overlap_east = Composite(numworkers);
            overlap_south_east = Composite(numworkers);
            overlap = Composite(numworkers);

            % initialize all the composite variables
            for q = 1:Q
                overlap{q} = max(testCase.dims_overlap{q}) - testCase.dims(q,:);
                x_overlap{q} = testCase.x(testCase.I_overlap_ref(q, 1)+1:testCase.I_overlap_ref(q, 1)+testCase.dims_overlap_ref(q, 1), ...
                    testCase.I_overlap_ref(q, 2)+1:testCase.I_overlap_ref(q, 2)+testCase.dims_overlap_ref(q, 2));
            end

            % amount of overlap of the neighbour (necessary to define the overlap)
            for q = 1:Q
                [qy, qx] = ind2sub([testCase.Qy, testCase.Qx], q);
                if qy < testCase.Qy
                    % S (qy+1, qx)
                    qp = (qx-1)*testCase.Qy + qy+1;
                    overlap_south{q} = overlap{qp};
                    if qx < testCase.Qx
                        % SE (qy+1, qx+1)
                        qp = qx*testCase.Qy + qy+1;
                        overlap_south_east{q} = overlap{qp};
                    else
                        overlap_south_east{q} = [0, 0];
                    end
                else
                    overlap_south{q} = [0, 0];
                    overlap_south_east{q} = [0, 0];
                end
                if qx < testCase.Qx
                    % E (qy, qx+1)
                    qp = qx*testCase.Qy + qy;
                    overlap_east{q} = overlap{qp};
                else
                    overlap_east{q} = [0, 0];
                end
            end

            % test update if the borders
            spmd
                if labindex < Q+1
                    x_overlap(1:overlap(1),:) = 0;
                    x_overlap(:,1:overlap(2)) = 0;
                end
            end

            spmd
                if labindex < Q+1
                    x_overlap = comm2d_update_borders(x_overlap, overlap, overlap_south_east, overlap_south, overlap_east, Qyp.Value, Qxp.Value);
                end
            end

            % get the contribution from the workers back (need to see zeros on the borders)
            error_update = zeros(Q, 1);
            for q = 1:Q
                error_update(q) = norm(x_overlap{q} - testCase.x(testCase.I_overlap_ref(q, 1)+1:testCase.I_overlap_ref(q, 1)+testCase.dims_overlap_ref(q, 1), ...
                    testCase.I_overlap_ref(q, 2)+1:testCase.I_overlap_ref(q, 2)+testCase.dims_overlap_ref(q, 2)), 'fro');
            end
            
            testCase.verifyTrue(sum(error_update) < eps);
        end
        
        function testReduceBorders(testCase)
            Q = testCase.Qx*testCase.Qy;
            numworkers = Q;
            % define parallel constants(known by each worker)
            Qyp = parallel.pool.Constant(testCase.Qy);
            Qxp = parallel.pool.Constant(testCase.Qx);

            % define composite variables (local to a given worker)
            x_overlap = Composite(numworkers);
            overlap_south = Composite(numworkers);
            overlap_east = Composite(numworkers);
            overlap_south_east = Composite(numworkers);
            overlap = Composite(numworkers);

            % initialize all the composite variables
            for q = 1:Q
                overlap{q} = max(testCase.dims_overlap{q}) - testCase.dims(q,:);
                x_overlap{q} = testCase.x(testCase.I_overlap_ref(q, 1)+1:testCase.I_overlap_ref(q, 1)+testCase.dims_overlap_ref(q, 1), ...
                    testCase.I_overlap_ref(q, 2)+1:testCase.I_overlap_ref(q, 2)+testCase.dims_overlap_ref(q, 2));
            end

            % amount of overlap of the neighbour (necessary to define the overlap)
            for q = 1:Q
                [qy, qx] = ind2sub([testCase.Qy, testCase.Qx], q);
                if qy < testCase.Qy
                    % S (qy+1, qx)
                    qp = (qx-1)*testCase.Qy + qy+1;
                    overlap_south{q} = overlap{qp};
                    if qx < testCase.Qx
                        % SE (qy+1, qx+1)
                        qp = qx*testCase.Qy + qy+1;
                        overlap_south_east{q} = overlap{qp};
                    else
                        overlap_south_east{q} = [0, 0];
                    end
                else
                    overlap_south{q} = [0, 0];
                    overlap_south_east{q} = [0, 0];
                end
                if qx < testCase.Qx
                    % E (qy, qx+1)
                    qp = qx*testCase.Qy + qy;
                    overlap_east{q} = overlap{qp};
                else
                    overlap_east{q} = [0, 0];
                end
            end
            
            % test reduction feature
            spmd
                if labindex < Q+1
                    x_overlap(1:overlap(1),:) = 0;
                    x_overlap(:,1:overlap(2)) = 0;
                    x_overlap = comm2d_reduce(x_overlap, overlap, Qyp.Value, Qxp.Value);
                end
            end

            x_final = zeros(testCase.N);
            for q = 1:Q
                x_final = place2DSegment(x_final, x_overlap{q}, testCase.I_overlap_ref(q, :), testCase.dims_overlap_ref(q,:));
            end
            
            error_reduce = norm(x_final(:) - testCase.x(:));
            testCase.verifyTrue(error_reduce < eps);
        end
    end
end
