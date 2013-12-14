function [] = plot_all_results()
    plotCommon4Data = false;

    if ~plotCommon4Data
        index = 2;
        testDirectories = {{'results/local_common','results/news_to_local'},...
            {'results/local_to_news','results/news_common'}};    
        dataSetNames = {'local','news'};
        testName = dataSetNames{index};
        resultsDirectories = testDirectories{index};
    else
        index = 1;
        dataSetNames = {'answers','local','news','shopping'};
        testName = dataSetNames{index};
        common4Directory = ['results/common4/test_on_' testName '/'];
    end
    fig = figure;
    if plotCommon4Data
        numPlots = numel(dataSetNames);
        for i=1:numPlots
            prefix = [dataSetNames{i} '_to_' testName];
            subplot(1,numPlots,i);
            subplotTitle = ['Train=' dataSetNames{i} ',Test=' testName];
            title(subplotTitle);
            plot_results_in_directory(common4Directory,prefix);
        end
    else 
        numPlots = numel(dataSetNames);
        for i=1:numel(dataSetNames)
            subplot(1,numPlots,i);  
            subplotTitle = ['Train=' dataSetNames{i} ',Test=' testName];
            title(subplotTitle);
            plot_results_in_directory(resultsDirectories{i});
        end        
    end
    subplot(1,numPlots,1);
    v = axis;
    for i=2:numPlots
        subplot(1,numPlots,i);
        v2 = axis;
        v(1) = min(v(1),v2(1));
        v(3) = min(v(3),v2(3));
        v(2) = max(v(2),v2(2));
        v(4) = max(v(4),v2(4));
    end
    for i=1:numPlots
        subplot(1,numPlots,i);
        axis(v);
    end
end