function [] = plot_results_in_directory(path)
    files = dir(path);
    files = files(3:end);
    allResults = {};
    for i=1:numel(files)
        if files(i).isdir
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
    plot_results(allResults);
end