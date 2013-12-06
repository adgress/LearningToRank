function [] = plot_results_in_directory(path)
    files = dir(path);
    files = files(3:end);
    allResults = {};
    for i=1:numel(files)
        if files(i).isdir
            continue;
        end        
        x = load([path '/' files(i).name]);
        allResults{end+1} = x.results;
    end
    plot_results(allResults);
end