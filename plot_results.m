function [] = plot_results(allResults)
    figure
    hold on
    leg = {};
    symbols = {'.','+','v','x'};
    %colors = {'r','g','b','c','m','y','k'};
    colors = colormap(hsv(numel(allResults)));
    for i=1:numel(allResults)
        results = allResults{i};
        learner = results('learner');
        %ndcg_rank = results('ndcg_rank');
        %iterations = results('iterations');
        sampling_rates = results('sampling_rate');
        vars = getVariances(results);
        ndcgs = getNDCGs(results);
        average_ndcgs = sum(ndcgs,2)/size(ndcgs,2);
        average_ndcgs_var = var(ndcgs,0,2);
        errorbar(sampling_rates,average_ndcgs,average_ndcgs_var,...
            'color',colors(i,:));
        leg{i} = learner;
    end
    legend(leg);
    xlabel('Sampling Rate','FontSize',8);
    ylabel('Average NDCG','FontSize',8);
    hold off;
end

function [vars] = getVariances(results)
    vars = getValuesWithPrefix(results,'var_');
end

function [ndcgs] = getNDCGs(results)
    ndcgs = getValuesWithPrefix(results,'ndcg_');
end

function [values] = getValuesWithPrefix(results,prefix)
    numSamples = length(results('sampling_rate'));
    iters = results('iterations');
    values = zeros(numSamples,iters);
    for i=1:iters
        key = [prefix num2str(i)];
        val = results(key);
        values(:,i) = val;
    end
end