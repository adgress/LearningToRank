function [ndcg] = save_experiment(qujHeader, queryData, fvHeader, X, Y, queries, numTest, ...
         rank, train_fv, train_quj, test_fv, test_quj)
    % qujHeader = cell array containing column names for the .quj file
    % queryData = values loaded from the .quj file
    % fvHeader = cell array containing column names for .fv file
    % X = features loaded from the .fv file
    % Y = labels loaded from the .fv file
    % queries = queries (one column of queryData)
    % numTest = number of unique queries for test set. numTest unique queries will
    %         be randomly chosen and, for each query, all query-document pairs will be
    %         taken out of the train set and placed in the test set
    % rank = NDCG rank (used to ensure that there are at least this many query-document pairs
    %         for each query chosen for the test set)
    % train_fv, train_quj, test_fv, test_quj = output files for train and test set .fv and .quj
    %         files

    trainSetQueries = [];
    trainSetX = [];
    trainSetY = [];

    testSetMap = get_test_set(Y, queries, unique(queries), numTest, rank);
    testSetMapNew = containers.Map();
    testQueries = keys(testSetMap);
    testSetX = [];
    testSetY = [];
    testIndices = [];
    count = 0;
    for i = 1:length(testQueries)
        numThisQuery = numel(testSetMap(testQueries{i}));
        testIndices = [testIndices; testSetMap(testQueries{i})];
        tmp = count+1:count+numThisQuery;
        testSetMapNew(testQueries{i}) = tmp;
        count = count + numThisQuery;
    end;
    testSetX = X(testIndices, :);
    testSetY = Y(testIndices, :);
    queries(testIndices) = [];
    X(testIndices, :) = [];
    Y(testIndices) = [];
    testSetMap = testSetMapNew;

    queryField1 = queryData{1};
    queryField2 = queryData{2};
    queryField3 = queryData{3};
    queryField4 = queryData{4};

    fvHeader = cellstr(fvHeader);
    fvHeader = cat(2, fvHeader);
    qujHeader = cellstr(qujHeader);
    qujHeader = cat(2, qujHeader);

%{
    fileID = fopen(test_fv, 'wt');
    for i = 1:length(fvHeader)
        fprintf(fileID, '%s\t', fvHeader{i});
    end
    fprintf(fileID, '\n');
    fclose(fileID);
    dlmwrite(test_fv, [testSetX testSetY], '-append', 'delimiter', '\t', 'precision', '%0.6f');
%}
    tic;
    data = struct();
    data.fvHeader = fvHeader;
    data.data = [sparse(testSetX) sparse(testSetY)];
    %data.testSetX = sparse(testSetX);
    %data.testSetY = sparse(testSetY);
    save(test_fv,'data');
    x = toc;
    display(sprintf('Time to save: %f',x));
    fileID = fopen(test_quj, 'w');
    for i = 1:length(qujHeader)
        fprintf(fileID, '%s\t', qujHeader{i});
    end
    fprintf(fileID, '\n');
    for i = 1:length(testIndices)
        fprintf(fileID, '%s\t%s\t%s\t%s\n', queryField1{testIndices(i)}, queryField2{testIndices(i)}, ...
                        queryField3{testIndices(i)}, queryField4{testIndices(i)});
    end;
    fclose(fileID);

    queryField1(testIndices) = [];
    queryField2(testIndices) = [];
    queryField3(testIndices) = [];
    queryField4(testIndices) = [];

    fileID = fopen(train_quj, 'w');
    for i = 1:length(qujHeader)
        fprintf(fileID, '%s\t', qujHeader{i});
    end
    fprintf(fileID, '\n');
    for i = 1:length(queryField1)
        fprintf(fileID, '%s\t%s\t%s\t%s\n', queryField1{i}, queryField2{i}, ...
                        queryField3{i}, queryField4{i});
    end;
    fclose(fileID);
%{
    fileID = fopen(train_fv, 'wt');
    for i = 1:length(fvHeader)
        fprintf(fileID, '%s\t', fvHeader{i});
    end
    fprintf(fileID, '\n');
    fclose(fileID);
    dlmwrite(train_fv, [X Y],  '-append', 'delimiter', '\t', 'precision', '%0.6f');
%}
    tic;
    data = struct();
    data.fvHeader = fvHeader;
    data.data = [sparse(X) sparse(Y)];
    %data.testSetX = sparse(X);
    %data.testSetY = sparse(Y);
    save(train_fv,'data');
    x = toc;
    display(sprintf('Time to save: %f',x));


end
