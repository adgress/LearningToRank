function [] = create_transfer_matrix(trainingSetSize,resultsDir)
    if nargin < 2
        resultsDir = 'results/common4/';
    end

    loadConstants;
    queries = {};
    dataSets = {'answers','local','news','shopping'};
    for i=1:length(dataSets)
        query = containers.Map;
        query('C') = {.1};
        query('learner') = {ALTR_LIN};
        query('train_name_display') = dataSets;
        query('test_name_display') = {dataSets{i}};
        query('percent_weak_to_use') = {0};
        query('percent_weak_to_add') = {0};
        query('whiten') = {0};
        queries{i} = query;
    end
    dataSetIndexMap= containers.Map(dataSets,{1,2,3,4})
    meanMatrix = zeros(numel(dataSets));
    varMatrix = zeros(numel(dataSets));
    resultFiles = cell(length(queries));        
    for i=1:length(queries)
        results = get_files_matching_query(resultsDir,queries{i});                
        for j=1:length(results)
            currResults = results{j};
            resultsInputs = currResults('input');
            trainDisplayName = resultsInputs('train_name_display');
            testDisplayName = resultsInputs('test_name_display');
            trainIndex = dataSetIndexMap(trainDisplayName);
            testIndex = dataSetIndexMap(testDisplayName);
            [m,v] = get_mean_and_variance(currResults,trainingSetSize);
            meanMatrix(trainIndex,testIndex) = m;
            varMatrix(trainIndex,testIndex) = v;
        end
        resultFiles{i} = results;
    end
    columnNames = {'test=answers','test=local','test=news','test=shopping'};    
    rowNames = {'train=answers','train=local','train=news','train=shopping'};
    f = figure('Position', [100 100 600 300]);
    t = uitable('Parent', f, 'Position', [0 0 600 200],'RowName',rowNames,...
        'ColumnName',columnNames);    
    set(t, 'Data', meanMatrix);
    MyBox = uicontrol(f,'Style','text');
    set(MyBox,'String',sprintf('Num Constraints = %d',trainingSetSize));
    set(MyBox,'Position',[150 220 200 25]);
end

function [m,v] = get_mean_and_variance(results,numPairs)
    allNumPairs = results('num_pairs');
    numSamples = length(allNumPairs);
    iters = results('num_train_test_splits');
    values = zeros(numSamples,iters);
    for i=1:iters
        key = ['ndcg_' num2str(i)];
        val = results(key);
        values(:,i) = val;
    end
    allMeans = mean(values);
    allVars = var(values);
    assert(sum(allNumPairs==numPairs) == 1);
    m = allMeans(allNumPairs==numPairs);
    v = allVars(allNumPairs==numPairs);
end

