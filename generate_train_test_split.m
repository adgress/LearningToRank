function [] = generate_train_test_split(fv_file, quj_file, size_quj_header, ...
         feature_indices_to_use, output_dir, ...
         num_train_test_splits, num_test_queries, ndcg_rank, train_name, ...
         test_name, normalize)

data = importdata(fv_file, '\t', 1);

fid = fopen(quj_file, 'rt');
formatSpec = '%s';
N = size_quj_header;
queryHeader = textscan(fid, formatSpec, N, 'delimiter', '\t');
queryHeader = queryHeader{1};
queryIndex = find(strcmp(queryHeader, 'query'));
queryData = textscan(fid,'%s %s %s %s', 'delimiter', '\t');
fclose(fid);

queries = queryData{queryIndex};
features = data.data;
labels = features(:, end);

if (normalize)
    maxes = max(abs(features(:, 1:end-1)));
    maxes(find(~maxes)) = 1;
    normalizedFeatures = features(:, 1:end-1) ./ repmat(maxes, size(features, 1), 1);
    featuresSubset = normalizedFeatures(:, feature_indices_to_use);
else
    featuresSubset = features(:, feature_indices_to_use);
end;

qujHeader = queryHeader;
fvHeader = data.colheaders([feature_indices_to_use end]);

for i = 1:num_train_test_splits
    save_experiment(qujHeader, queryData, fvHeader, featuresSubset, ...
                    labels, queries, num_test_queries, ndcg_rank, ...
                    strcat(output_dir, train_name, '.', int2str(i), '.fv'), ...
                    strcat(output_dir, train_name, '.', int2str(i), '.quj'), ...
                    strcat(output_dir, test_name, '.', int2str(i), '.fv'), ...
                    strcat(output_dir, test_name, '.', int2str(i), '.quj'));
     display(fprintf('Finished set %d of %d',i,num_train_test_splits));
end;

exit;
