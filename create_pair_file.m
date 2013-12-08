function [] = create_pair_file(directory)
    allFiles = dir(directory);
    %{
        query   url1    url2    gdiff
        hello   test1   test2   2
    %}
    for i=1:numel(allFiles)
        display(i/numel(allFiles));
        fileInfo = allFiles(i);
        if fileInfo.isdir || isempty(strfind(fileInfo.name,'quj')) || isempty(strfind(fileInfo.name,'train'))
            continue;
        end
        nameParts = split_string(fileInfo.name,'quj');
        pairFileName = [nameParts{1} 'pair'];
        fidPairFile = fopen([directory '/' pairFileName],'w');
        tabchar = sprintf('\t');
        fprintf(fidPairFile,['group' tabchar 'query' tabchar 'url1' tabchar 'url2' tabchar 'gdiff\n']);
        fid = fopen([directory '/' fileInfo.name]);
        assert(fid > -1);
        fgetl(fid); %Read past header
        
        query = '';
        queryData = {};
        lineNumber = 0;
        while true            
            line = fgetl(fid);
            if line == -1
                break;
            end
            parsedLine = parse_line(line);
            %%TODO: Only for news
            %lineQuery = [parsedLine{2:end-2}];
            lineQuery = [parsedLine{1} tabchar [parsedLine{2:end-2}]];
            
            %lineQuery = [parsedLine{1:end-2}];
            if numel(query) == 0 || strcmp(lineQuery,query) ~= 1
                lineNumber = print_pair_data(query,queryData,fidPairFile,lineNumber);
                query = lineQuery;
                queryData = {};
            end
            queryData{end+1,1} = parsedLine{end-1};
            queryData{end,2} = parsedLine{end};
        end
        fclose(fid);
        fclose(fidPairFile);
    end
end

function [lineNumber] = print_pair_data(query,queryData,fidPairFile,lineNumber)
    numItems = size(queryData,1);
    tabChar = sprintf('\t');
    newlineChar = sprintf('\n');
    for i=1:numItems
        url1 = queryData{i,1};
        grade1 = queryData{i,2};
        for j=i+1:numItems
            grade2 = queryData{j,2};            
            diff = sign(grade1 - grade2);            
            url2 = queryData{j,1};
            outputString = [query tabChar url1 tabChar url2 tabChar...
                num2str(diff) newlineChar];
            escapedString = strrep(outputString,'%','%%');
            fprintf(fidPairFile,escapedString);
            lineNumber = lineNumber + 1;
        end
    end
end

function [parsedLine] = parse_line(line)
    tabChar = sprintf('\t');
    parsedLine = split_string(line,tabChar);
    if numel(parsedLine) == 4
        %TODO: only for local
        %parsedLine = parsedLine(2:end);
        
        %TODO: Do I need this?
        %parsedLine = parsedLine(1:end-1);
    end
    grade = parsedLine{end};    
    if strcmp(grade,'Excellent')
        grade = 5;
    elseif strcmp(grade,'Good')
        grade = 4;
    elseif strcmp(grade,'Fair');
        grade = 3;
    elseif strcmp(grade,'Bad');
        grade = 1;
    else
        error('Unhandled grade');
    end
    parsedLine{end} = grade;
end