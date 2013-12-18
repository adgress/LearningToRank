function [] = plot_all_results()
    plotCommon4Data = true;

    if ~plotCommon4Data
        index = 1;        
        testDirectories = {{'results/local_common','results/news_to_local'},...
            {'results/local_to_news','results/news_common'}};    
        dataSetNames = {'local','news'};
        testName = dataSetNames{index};
        resultsDirectories = testDirectories{index};
    else
        index = 4;
        C = '.01';
        dataSetNames = {'answers','local','news','shopping'};
        testName = dataSetNames{index};
        common4Directory = ['common4/test_on_' testName '/C=' C ];
        %resultsDir = 'results_just-strong_whiten/';
        resultsDir = 'results_just-strong_percent-weak-added/';
        %resultsDir = 'results_just-strong_percent-weaken-used';
        common4Directory = [resultsDir '/' common4Directory];
    end
    fig = figure;
    startI = 2;
    if plotCommon4Data
        numPlots = numel(dataSetNames);
        for i=startI:numPlots
            prefix = [dataSetNames{i} '_to_' testName];
            subplot(1,numPlots,i);
            subplotTitle = ['Train=' dataSetNames{i} ',Test=' testName];
            title(subplotTitle);
            plot_results_in_directory(common4Directory,prefix,i==startI);
        end
    else 
        numPlots = numel(dataSetNames);
        for i=startI:numel(dataSetNames)
            subplot(1,numPlots,i);  
            subplotTitle = ['Train=' dataSetNames{i} ',Test=' testName];
            title(subplotTitle);
            plot_results_in_directory(resultsDirectories{i},i==startI);
        end        
    end
    subplot(1,numPlots,startI);
    v = axis;
    for i=startI+1:numPlots
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