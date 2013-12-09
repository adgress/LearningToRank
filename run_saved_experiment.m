function [ndcg var_ndcg] = run_saved_experiment(...
    train_fv, train_quj, ...
    test_fv, test_quj, ...
    queryIndexTrain, queryIndexTest, ...
    perTrainArray, rank, flag, iterations,input)
% train_fv = path to train set .fv (features + labels)
% train_quj = path to train set .quj (queries)
% test_fv, test_quj = same as above, but for test set
% queryIndexTrain = which column of the train .quj file contains the queries
% queryIndexTest = which column of the test .quj file contains the queries
% perTrainArray = array of sampling rates. For example, [0.01 0.05] will
%               train using first 1% of the available training data, then 5%
% rank = NDCG rank for reporting scores
% flag = which learner to train (see ALL CAPs vars below)
% iterations = how many times to train and test at each sampling rate.
% Return Values:
% ndcg = vector containing the scores (NDCG calculated at <rank>) averaged over
%      <iterations> trials. The entries in ndcg correspond 1-1 with the sampling rates
%      in <perTrainArray>. Continuing the example above, ndcg = [0.70 0.80] means
%      the NDCG at <rank> using 1% of the training data was 0.70 (averaged across
%      however many iterations) and the NDCG using 5% of the training data was 0.80.
% var_ndcg = as above, but indicates the variance in the NDCG scores at each sampling
%      rate.

    ndcg = [];
    var_ndcg = [];

    loadConstants;
    trainSetQueries = [];
    trainSetX = [];
    trainSetY = [];
    O = [];
    S = [];
    
    testSetMap = containers.Map();
    % Read in train and test data
    data = importdata(train_fv, '\t', 1);
    fid = fopen(train_quj,'rt');
    queryData = textscan(fid,'%s %s %s %s', 'delimiter', '\t', 'HeaderLines', 1);
    fclose(fid);
    trainSetQueries = queryData{queryIndexTrain};
    features = data.data(:, 1:end-1);
    labels = data.data(:, end);
    data = importdata(test_fv, '\t', 1);
    fid = fopen(test_quj,'rt');
    queryData = textscan(fid,'%s %s %s %s', 'delimiter', '\t', 'HeaderLines', 1);
    fclose(fid);
    queries = queryData{queryIndexTest};
    testQueries = unique(queries);
    testSetX = data.data(:, 1:end-1);
    testSetY = data.data(:, end);
    % Find the indices of each unique test set queries (not necessarily adjacent in source files)
    for i = 1:length(testQueries)
        testSetMap(testQueries{i}) = find(strcmp(queries, testQueries{i}));
    end;
    %TODO: Make this less hacky by using different seeds each time the experiment suite is run
    stream = RandStream('mt19937ar','Seed',10);
    

    if matlabpool('size') < 4
        matlabpool(4);
    end    
    tic;
    for k = 1:length(perTrainArray)
        disp(strcat('perTrainArray index ', int2str(k)))
        tempNDCG = zeros(iterations,1); 
        numTrain = floor(size(features, 1) * perTrainArray(k));
        trainSetPerms = cell(iterations,1);            
        for j=1:iterations
            trainSetPerms{j} = randperm(stream,size(features, 1));
        end
        if input('usePar')
            parfor j = 1:iterations            
                disp(strcat('iteration ', int2str(j)))               
                trainSetPerm = trainSetPerms{j}; 
                trainSetX = features(trainSetPerm(1:numTrain), :);
                trainSetY = labels(trainSetPerm(1:numTrain));
                usedQueries = trainSetQueries(trainSetPerm(1:numTrain));
                O = build_O_per_query(trainSetY, usedQueries);
                S = build_S_per_query(trainSetY, usedQueries);

                tempNDCG(j) = runSingleIteration(trainSetX,trainSetY,O,S,...
                    testSetX,testSetY,testQueries,testSetMap,input,numTrain,stream,flag,rank);
            end
        else            
            for j = 1:iterations
                disp(strcat('iteration ', int2str(j)))               
                trainSetPerm = trainSetPerms{j};                
                trainSetX = features(trainSetPerm(1:numTrain), :);
                trainSetY = labels(trainSetPerm(1:numTrain));
                usedQueries = trainSetQueries(trainSetPerm(1:numTrain));
                O = build_O_per_query(trainSetY, usedQueries);
                S = build_S_per_query(trainSetY, usedQueries);
                display(sprintf('numO=%d, numS=%d',size(O,1),size(S,1)));
                
                tempNDCG(j) = runSingleIteration(trainSetX,trainSetY,O,S,...
                    testSetX,testSetY,testQueries,testSetMap,input,numTrain,stream,flag,rank);
            end
        end
        ndcg = [ndcg; mean(tempNDCG)];
        var_ndcg = [var_ndcg; var(tempNDCG)];
    end
    display(toc)
end

function [meanNDCG] = runSingleIteration(trainSetX,trainSetY,O,S,...
    testSetX,testSetY,testQueries,testSetMap,input,numTrain,stream,flag,rank)
    loadConstants();
    C = input('C');
    degree = input('degree');
    sigma = input('sigma');
    iterationNDCG = containers.Map();
    if (flag == RANDOM)
        error('Fix this');
        % Random Ordering NDCG
        % Evaluate NDCG on test set
        for i = 1:length(testQueries)
            indices = testSetMap(testQueries{i});
            y = randperm(length(indices));
            r = testSetY(indices)';
            iterationNDCG(testQueries{i}) = compute_ndcg_rank(rank, y, r);
        end;
        meanNDCG = mean(cell2mat(values(iterationNDCG)));
        return;
    end;    
    
    %Only use weighted constraints for weighted RankSVM
    if flag ~= RANKSVM_WEIGHTED && flag ~= ALTR_LIN_WEIGHTED && flag ~= RANKSVM_WEIGHTED_BAD
        O = sign(O);
    end
    if flag == RANKSVM_WEIGHTED_BAD
        O = -O;
    end
    if (flag == RELATIVE)
        % RankSVM with Similar Attributes
        % Learn on train set
        w = train_ranksvm_with_sim(trainSetX, O, S,C);

        % Evaluate NDCG on test set
        for i = 1:length(testQueries)
            indices = testSetMap(testQueries{i});
            y = w' * testSetX(indices, :)';
            r = testSetY(indices)';
            %[y' r']
            iterationNDCG(testQueries{i}) = compute_ndcg_rank(rank, y, r);
        end
    end
    if (flag == RANKSVM || flag == RANKSVM_WEIGHTED || flag == RANKSVM_WEIGHTED_BAD)
        % RankSVM
        % Learn on train set
        w = train_ranksvm(trainSetX, O, C);
        % Evaluate NDCG on test set
        for i = 1:length(testQueries)
            indices = testSetMap(testQueries{i});
            y = w' * testSetX(indices, :)';
            r = testSetY(indices)';
            iterationNDCG(testQueries{i}) = compute_ndcg_rank(rank, y, r);
        end
    end
    if flag == REGRESSION
        addpath('../libsvm-3.17/matlab');
        model = train_regression(trainSetX,trainSetY);
        for i=1:length(testQueries)
            indices = testSetMap(testQueries{i});
            %y = w' * testSetX(indices, :)';
            r = testSetY(indices)';
            y = svmpredict(r',testSetX(indices,:),model,'-q');
            iterationNDCG(testQueries{i}) = compute_ndcg_rank(rank, y, r);
        end
    end
    %{
                if (flag == ALTR_LIN)
                    % Learn on train set
                    w = train_altr_linear(trainSetX, O, S);
                    size(w);
                    % Evaluate NDCG on test set
                    for i = 1:length(testQueries)
                        indices = testSetMap(testQueries{i});
                        y = w * testSetX(indices, :)';
                        r = testSetY(indices)';
                        iterationNDCG(testQueries{i}) = compute_ndcg_rank(rank, y, r);
                    end
                end
    %}
    if (flag == ALTR_LIN || flag == ALTR_LIN_CHUNKING || flag == ALTR_LIN_WEIGHTED...
            || flag == ALTR_LIN_DUAL || flag == ALTR_LIN_NO_WEAK)
        % Learn on train set
        if flag == ALTR_LIN_CHUNKING
            w = train_altr_linear_chunking(trainSetX, O,C);
        else
            w = train_altr_linear(trainSetX, O, S,flag == ALTR_LIN_DUAL,flag ~= ALTR_LIN_NO_WEAK,C);
        end
        size(w);
        % Evaluate NDCG on test set
        for i = 1:length(testQueries)
            indices = testSetMap(testQueries{i});
            y = w * testSetX(indices, :)';
            r = testSetY(indices)';
            iterationNDCG(testQueries{i}) = compute_ndcg_rank(rank, y, r);
        end
    end
    if (flag == ALTR_RBF_KER)
        error('fix this');
        S = sparse(0, 0); % try without S
        % ALTR RBF Kernel (trying alt formulation of K)
        [A B] = train_altr_rbf(trainSetX, O, S, sigma, C);
        % Evaluate NDCG on test set
        ForKFirstArg = [O; S] * trainSetX;
        AB = [A; B];
        for i = 1:length(testQueries)
            y = [];
            indices = testSetMap(testQueries{i});
            for l = 1:numel(indices)
                x = testSetX(indices(l), :);
                y = [y; rank_k_rbf(x, ForKFirstArg, AB, sigma)];
            end
            r = testSetY(indices)';
            result_ndcg = compute_ndcg_rank(rank, y, r);
            iterationNDCG(testQueries{i}) = result_ndcg;
        end
    end
    if (flag == ALTR_POLY || flag == ALTR_POLY_KER_CHUNKING)
        error('fix this');
        if flag == ALTR_POLY_KER_CHUNKING
            [A support_vectors] = train_altr_poly_chunking(trainSetX, O, degree,C);
        else
            [A B support_vectors] = train_altr_poly(trainSetX, O, S,degree,C);
        end
        % Evaluate NDCG on test set
        for i = 1:length(testQueries)
            y = [];
            indices = testSetMap(testQueries{i});
            for l = 1:numel(indices)
                x = testSetX(indices(l), :);
                y = [y; rank_k_poly(x, support_vectors, A, degree)];
            end
            r = testSetY(indices)';
            error('fix results!');
            result_ndcg = compute_ndcg_rank(rank, y, r);
        end
    end
    meanNDCG = mean(cell2mat(values(iterationNDCG)));
end

