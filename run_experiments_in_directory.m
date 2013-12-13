function [] = run_experiments_in_directory(path)
    files = dir(path);
    for i=1:numel(files)
        if files(i).isdir
            continue;
        end
        configFile = [path '/' files(i).name];
        run_experiment(configFile);
    end
end