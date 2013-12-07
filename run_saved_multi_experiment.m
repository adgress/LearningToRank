function [ ndcg_1 var_ndcg_1 ndcg_2 var_ndcg_2] = ...
         run_saved_multi_experiment(train_fv_1, train_quj_1, test_fv_1, test_quj_1, queryIndexTrain_1, ...
                                    queryIndexTest_1, ...
                                    train_fv_2, train_quj_2, test_fv_2, test_quj_2, queryIndexTrain_2, ...
                                    queryIndexTest_2, ...
                                    perTrainArray, rank, flag, iterations,input)
    % For explanation of variables and return values, see run_saved_experiment.m.
    % Since this is training a multi-attribute learner (trains and tests simultaneously on 2
    % data sets), it requires an additional train/test set, and returns the NDCG scores and
    % variance for each data set separately. The returns values follow the same format as with
    % run_saved_experiment.m

    ndcg_1 = [];
    var_ndcg_1 = [];
    ndcg_2 = [];
    var_ndcg_2 = [];

    trainSetQueries_1 = [];
    trainSetX_1 = [];
    trainSetY_1 = [];
    O_1 = [];
    testSetMap_1 = containers.Map();

    % Load train .fv
    train_data_1 = importdata(train_fv_1, '\t', 1);
    features_1 = train_data_1.data(:, 1:end-1);
    labels_1 = train_data_1.data(:, end);
    % Load train .quj
    fid = fopen(train_quj_1,'rt');
    queryData_1 = textscan(fid,'%s %s %s %s', 'delimiter', '\t', 'HeaderLines', 1); % Group Query URL %Grade Group Query URL Grade
    fclose(fid);
    trainSetQueries_1 = queryData_1{queryIndexTrain_1};

    % Load test .fv
    test_data_1 = importdata(test_fv_1, '\t', 1);
    testSetX_1 = test_data_1.data(:, 1:end-1);
    testSetY_1 = test_data_1.data(:, end);
    % Load test .quj
    fid = fopen(test_quj_1, 'rt');
    queryData_1 = textscan(fid,'%s %s %s %s', 'delimiter', '\t', 'HeaderLines', 1); % Group Query URL %Grade Group Query URL Grade
    fclose(fid);
    queries_1 = queryData_1{queryIndexTest_1};
    testQueries_1 = unique(queries_1);

    % Generate map from unique test queries to all matching indices in test set
    for i = 1:length(testQueries_1)
        testSetMap_1(testQueries_1{i}) = find(strcmp(queries_1, testQueries_1{i}));
    end;


    trainSetQueries_2 = [];
    trainSetX_2 = [];
    trainSetY_2 = [];
    O_2 = [];
    C = input('C');
    testSetMap_2 = containers.Map();
    
    % Load train .fv
    train_data_2 = importdata(train_fv_2, '\t', 1);
    features_2 = train_data_2.data(:, 1:end-1);
    labels_2 = train_data_2.data(:, end);
    % Load train .quj
    fid = fopen(train_quj_2,'rt');
    queryData_2 = textscan(fid,'%s %s %s %s', 'delimiter', '\t', 'HeaderLines', 1); % Group Query URL %Grade Group Query URL Grade
    fclose(fid);
    trainSetQueries_2 = queryData_2{queryIndexTrain_2};

    % Load test .fv
    test_data_2 = importdata(test_fv_2, '\t', 1);
    testSetX_2 = test_data_2.data(:, 1:end-1);
    testSetY_2 = test_data_2.data(:, end);
    % Load test .quj
    fid = fopen(test_quj_2, 'rt');
    queryData_2 = textscan(fid,'%s %s %s %s', 'delimiter', '\t', 'HeaderLines', 1); % Group Query URL %Grade Group Query URL Grade
    fclose(fid);
    queries_2 = queryData_2{queryIndexTest_2};  
    testQueries_2 = unique(queries_2);

    % Generate map from unique test queries to all matching indices in test set
    for i = 1:length(testQueries_2)
        testSetMap_2(testQueries_2{i}) = find(strcmp(queries_2, testQueries_2{i}));
    end

    for k = 1:length(perTrainArray)
        disp(strcat('perTrainArray index ', int2str(k)));

        tempNDCG_1 = [];
        tempNDCG_2 = [];

        for j = 1:iterations
            disp(strcat('iteration ', int2str(j)));

            iterationNDCG_1 = containers.Map();
            iterationNDCG_2 = containers.Map();

            numTrain_1 = floor(size(features_1, 1) * perTrainArray(k));
            trainSetPerm_1 = randperm(size(features_1, 1));
            trainSetX_1 = features_1(trainSetPerm_1(1:numTrain_1), :);
            trainSetY_1 = labels_1(trainSetPerm_1(1:numTrain_1));
            usedQueries_1 = trainSetQueries_1(trainSetPerm_1(1:numTrain_1));
            O_1 = build_O_per_query(trainSetY_1, usedQueries_1);

            numTrain_2 = floor(size(features_2, 1) * perTrainArray(k));
            trainSetPerm_2 = randperm(size(features_2, 1));
            trainSetX_2 = features_2(trainSetPerm_2(1:numTrain_2), :);
            trainSetY_2 = labels_2(trainSetPerm_2(1:numTrain_2));
            usedQueries_2 = trainSetQueries_2(trainSetPerm_2(1:numTrain_2));
            O_2 = build_O_per_query(trainSetY_2, usedQueries_2);

            % Learn on train set
            lambda = 1;
            O_1 = clampToOne(O_1);
            O_2 = clampToOne(O_2);
            [w0 v1 v2] = train_multi_linear(trainSetX_1, O_1, trainSetX_2, O_2, lambda,C);

            % Evaluate NDCG on test set
            for i = 1:length(testQueries_1)
                indices = testSetMap_1(testQueries_1{i});
                y = (w0 + v1) * testSetX_1(indices, :)';
                r = testSetY_1(indices)';
                iterationNDCG_1(testQueries_1{i}) = compute_ndcg_rank(rank, y, r);
            end;
            
            for i = 1:length(testQueries_2)
                indices = testSetMap_2(testQueries_2{i});
                y = (w0 + v2) * testSetX_2(indices, :)';
                r = testSetY_2(indices)';
                iterationNDCG_2(testQueries_2{i}) = compute_ndcg_rank(rank, y, r);
            end;


            tempNDCG_1 = [tempNDCG_1; mean(cell2mat(values(iterationNDCG_1)))];
            tempNDCG_2 = [tempNDCG_2; mean(cell2mat(values(iterationNDCG_2)))];
        
        end;
        
        ndcg_1 = [ndcg_1; mean(tempNDCG_1)];
        var_ndcg_1 = [var_ndcg_1; var(tempNDCG_1)];
        ndcg_2 = [ndcg_2; mean(tempNDCG_2)];
        var_ndcg_2 = [var_ndcg_2; var(tempNDCG_2)];

    end
end

function [O] = clampToOne(O)
    posInds = O > 0;
    negInds = O < 0;
    O(posInds) = 1;
    O(negInds) = -1;
end
