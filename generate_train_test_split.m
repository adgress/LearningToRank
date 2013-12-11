function [] = generate_train_test_split(fv_file, quj_file, size_quj_header, ...
    feature_indices_to_use, output_dir, ...
    num_train_test_splits, num_test_queries, ndcg_rank, train_name, ...
    test_name, normalize)
    oldStream = RandStream.getGlobalStream();
    stream = RandStream('mt19937ar','Seed',10);
    RandStream.setGlobalStream(stream);
    trainingDataSize = 6000;
    fid = fopen(quj_file, 'rt');
    formatSpec = '%s';
    N = size_quj_header;
    queryHeader = textscan(fid, formatSpec, N, 'delimiter', '\t');
    queryHeader = queryHeader{1};
    queryIndex = find(strcmp(queryHeader, 'query'));
    queryData = textscan(fid,'%s %s %s %s', trainingDataSize,'delimiter', '\t');

    for i=1:numel(queryData)
        queryData{i} = queryData{i}(1:trainingDataSize);
    end
    fclose(fid);

    queries = queryData{queryIndex};
    data = importdata(fv_file, '\t', 1);
    features = data.data(1:trainingDataSize,:);
    labels = features(:, end);


    if (normalize)
        maxes = max(abs(features(:, 1:end-1)));
        maxes(find(~maxes)) = 1;
        normalizedFeatures = features(:, 1:end-1) ./ repmat(maxes, size(features, 1), 1);
        featuresSubset = normalizedFeatures(:, feature_indices_to_use);
    else
        featuresSubset = features(:, feature_indices_to_use);
    end
    qujHeader = queryHeader;
    fvHeader = data.colheaders([feature_indices_to_use end]);

    numPairs = 0;
    for i = 1:num_train_test_splits
        [totalPairwiseRelationships] = save_experiment(qujHeader, queryData, fvHeader, featuresSubset, ...
            labels, queries, num_test_queries, ndcg_rank, ...
            strcat(output_dir, train_name, '.', int2str(i), '.fv'), ...
            strcat(output_dir, train_name, '.', int2str(i), '.quj'), ...
            strcat(output_dir, test_name, '.', int2str(i), '.fv'), ...
            strcat(output_dir, test_name, '.', int2str(i), '.quj'));
        numPairs = numPairs + totalPairwiseRelationships;
        display(fprintf('Finished set %d of %d',i,num_train_test_splits));
    end
    display(sprintf('Average num pairs:%.2f',numPairs/num_train_test_splits));
    RandStream.setGlobalStream(oldStream);
end
