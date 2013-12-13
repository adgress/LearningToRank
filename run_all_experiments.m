function [] = run_all_experiments()
    fullDirectories = {'config/local_full','config/news_full'};
    commonDirectories = {'config/local_common','config/news_common'};
    transferDirectories = {'config/local_to_news','config/news_to_local'};
    
    allCommonDirectories = {commonDirectories{:}, transferDirectories{:}};
    
    directoriesToRun = commonDirectories;
    for i=1:numel(directoriesToRun);
        configDir = directoriesToRun{i};
        run_experiments_in_directory(configDir);
    end
end