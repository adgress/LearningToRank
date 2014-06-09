function [] = plot_results_matching_query(resultsDir,queries)
    if nargin < 1
        resultsDir = 'results/common4/';
    end
    if nargin < 2
        loadConstants;
        queries = {};        
        dataSets = {'answers','local','news','shopping'};
        for i=1:length(dataSets)
            query = containers.Map;
            query('C') = {.1};
            query('learner') = {ALTR_LIN}; 
            query('train_name_display') = {dataSets{i}};
            query('test_name_display') = {dataSets{i}};
            query('percent_weak_to_use') = {0};
            query('percent_weak_to_add') = {0};
            query('whiten') = {0};
            queries{i} = query;
        end
        
        
    end
    
    resultFiles = cell(length(queries));    
    
    for i=1:length(queries)
        subplot(1,length(queries),i);
        query = queries{i};
        trainName = query('train_name_display');
        testName = query('test_name_display');
        title(['train=' trainName ',test=' testName]);
        resultFiles{i} = get_files_matching_query(resultsDir,queries{i});
        plot_results(resultFiles{i},true);
    end
end






