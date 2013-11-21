function [] = plot_results_in_directory(path)
    files = dir(path);
    files = files(3:end);
    allResults = cell(numel(files),1);
    for i=1:numel(files)
        x = load([path '/' files(i).name]);
        allResults{i} = x.results;
    end
    plot_results(allResults);
end