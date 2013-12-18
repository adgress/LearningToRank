function [] = plot_results_in_directory(path,prefix,showLegend)
    if nargin < 2
        prefix = '';
    end    
    if nargin < 2
        showLegend = true;
    end
    files = dir(path);    
    allResults = {};
    for i=1:numel(files)
        if files(i).isdir
            continue;
        end              
        if length(prefix) > 0 && isempty(strfind(files(i).name,prefix))
            continue;
        end
        x = load([path '/' files(i).name]);
        if isfield(x,'results1')
            x.results = x.results1;
        end
        if isfield(x,'results2')
            x.results = x.results2;
        end
        allResults{end+1} = x.results;
    end
    plot_results(allResults,showLegend);
end