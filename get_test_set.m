function [testSet] = get_test_set(grades, queries, testableQueries, T, rank)
    % T = number of queries to test on
    % Return values:
    % testSet - map. keys are queries, values are indices for a query

    testSet = containers.Map();

    testableQueriesPerm = randperm(numel(testableQueries));
    testableQueries = testableQueries(testableQueriesPerm);

    testSetSize = 0;
    for i = 1:numel(testableQueries)
        queryIndex = find(strcmp(testableQueries(i), queries));
        
        if numel(queryIndex) < rank || (numel(unique(grades(queryIndex))) == 1)
            continue;
        end;

        testSet(testableQueries{i}) = queryIndex(1:end);

        testSetSize = testSetSize + 1;
        if testSetSize >= T
            break;
        end;
    end

