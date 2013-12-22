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
            valueFound = false;
            for k=1:length(queryValues)
                queryValue = queryValues{k};
                if isa(inputValue,'char')
                    if strcmp(inputValue,queryValue)
                        valueFound = true;
                        break;
                    end
                else
                    if inputValue == queryValue
                        valueFound = true;
                        break;
                    end
                end
            end 
            if ~valueFound
                isMatch = false;
                break;
            end
        end
        if isMatch
            fprintf('Adding: %s\n',files(i).name);
            allResults{end+1} = x.results;
        end
    end
end