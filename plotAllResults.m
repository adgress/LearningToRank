function [] = plotAllResults()
    testOnLocal = {'results/local_common','results/news_to_local'};
    testOnLocalTitle = 'Test on Local, Common Features';
    testOnNews = {'results/news_common' ,'results/local_to_news'};
    testOnNewsTitle = 'Test on News, Common Features';
    %resultsTitle = testOnLocalTitle;
    resultsDirectories = testOnNews;
    fig = figure;
    
    numPlots = numel(resultsDirectories);
    for i=1:numel(resultsDirectories)
        subplot(1,numPlots,i);       
        plot_results_in_directory(resultsDirectories{i},fig);
    end
    subplot(1,numPlots,1);
    v = axis;
    for i=2:numPlots
        subplot(1,numPlots,i);
        axis(v);
    end
end