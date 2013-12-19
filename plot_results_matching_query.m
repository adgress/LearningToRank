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
            query('percent_weak_to_add') = {0,.5,1};            
            queries{i} = query;
        end
        
        
    end
    
    resultFiles = cell(length(queries));    
    
    for i=1:length(queries)
        subplot(1,length(queries),i);
        resultFiles{i} = get_files_matching_query(resultsDir,queries{i});
        plot_results(resultFiles{i},true);
    end
end

function [allResults] = get_files_matching_query(resultsDir,query)
    files = dir(resultsDir);
    allResults = {};
    for i=1:numel(files)
        if files(i).isdir
            continue;
        end              
        x = load([resultsDir '/' files(i).name]);
        input = x.results('input');
        isMatch = true;
        queryKeys = query.keys;
        for j = 1:length(queryKeys)
            key = queryKeys{j};
            if ~input.isKey(key)
                error('Cannot find query key in results.input: %s',key);
            end
            queryValues = query(key);
            inputValue = input(key);
            for k=1:length(queryValues)
                queryValue = queryValues{k};
                if isa(inputValue,'char')
                    if ~strcmp(inputValue,queryValue)
                        isMatch = false;
                        break;
                    end
                else
                    if inputValue ~= queryValue
                        isMatch = false;
                        break;
                    end
                end
            end 
            if ~isMatch
                break;
            end
        end
        if isMatch
            fprintf('Adding: %s\n',files(i).name);
            allResults{end+1} = x.results;
        end
    end
end






