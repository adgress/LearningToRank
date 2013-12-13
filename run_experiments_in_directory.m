function [] = run_experiments_in_directory(path)
    files = dir(path);
    files = files(3:end);
    for i=1:numel(files)
        configFile = [path '/' files(i).name];
        run_experiment(configFile);
    end
end