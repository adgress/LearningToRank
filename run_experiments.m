function [] = run_experiments(input_dir, train_name, test_name, ...
         num_train_test_splits, iterations, ndcg_rank, sampling_rate, output_dir, ...
         results_file_name, learner, input_dir_2, train_name_2, test_name_2, ...
         cvx_path)
    mystream = RandStream('mt19937ar','Seed',sum(100*clock));
    RandStream.setDefaultStream(mystream);

    addpath(cvx_path);
    cvx_setup;
    learner_name = get_learner_name(learner);
    results = containers.Map();
    results('learner') = learner_name;
    results('train_set') = strcat(input_dir, train_name);
    results('test_set') = strcat(input_dir, test_name);
    results('ndcg_rank') = ndcg_rank;
    results('num_train_test_splits') = num_train_test_splits;
    results('iterations') = iterations;
    results('sampling_rate') = sampling_rate;
    strcat(input_dir, train_name, '.1.quj')
    num_quj_columns_train = get_number_columns(strcat(input_dir, train_name, '.1.quj'));
    num_quj_columns_test = get_number_columns(strcat(input_dir, test_name, '.1.quj'));

    % Find which column in the .quj files has the query string
    queryIndexTrain = get_query_index(strcat(input_dir, train_name, '.1.quj'), num_quj_columns_train);
    queryIndexTest = get_query_index(strcat(input_dir, test_name, '.1.quj'), num_quj_columns_test);
    for i = 1:num_train_test_splits
        i_str = int2str(i);
        train_fv = strcat(input_dir, train_name, '.', i_str, '.fv');
        train_quj = strcat(input_dir, train_name, '.', i_str, '.quj');
        test_fv = strcat(input_dir, test_name, '.', i_str, '.fv');
        test_quj = strcat(input_dir, test_name ,'.', i_str, '.quj');
        if (strcmp(learner_name, 'Multi Attribute'))
            results('train_set_2') = strcat(input_dir_2, train_name_2);
            results('test_set_2') = strcat(input_dir_2, test_name_2);
            train_fv_2 = strcat(input_dir_2, train_name_2, '.', i_str, '.fv');
            train_quj_2 = strcat(input_dir_2, train_name_2, '.', i_str, '.quj');
            test_fv_2 = strcat(input_dir_2, test_name_2, '.', i_str, '.fv');
            test_quj_2 = strcat(input_dir_2, test_name_2, '.', i_str, '.quj');    
            num_quj_columns_train_2 = get_number_columns(strcat(input_dir_2, train_name_2, '.1.quj'));
            num_quj_columns_test_2 = get_number_columns(strcat(input_dir_2, test_name_2, '.1.quj'));
            queryIndexTrain_2 = get_query_index(strcat(input_dir_2, train_name_2, '.1.quj'), num_quj_columns_train_2);
            queryIndexTest_2 = get_query_index(strcat(input_dir_2, test_name_2, '.1.quj'), num_quj_columns_test_2);
            [temp_ndcg temp_var temp_ndcg_2 temp_var_2] = run_saved_multi_experiment(train_fv, train_quj, ...
                                       test_fv, test_quj, queryIndexTrain, queryIndexTest, train_fv_2, train_quj_2, ...
                                       test_fv_2, test_quj_2, queryIndexTrain_2, queryIndexTest_2, sampling_rate, ...
                                       ndcg_rank, learner, iterations);
            results(strcat('ndcg_', i_str)) = temp_ndcg;
            results(strcat('var_', i_str)) = temp_var;
            results(strcat('ndcg2_', i_str)) = temp_ndcg_2;
            results(strcat('var2_', i_str)) = temp_var_2;
        else
            [temp_ndcg temp_var] = run_saved_experiment(train_fv, train_quj, test_fv, ...
                                       test_quj, queryIndexTrain, queryIndexTest, sampling_rate, ndcg_rank, ...
                                       learner, iterations);
            results(strcat('ndcg_', i_str)) = temp_ndcg;
            results(strcat('var_', i_str)) = temp_var;
        end;
        save(strcat(output_dir, results_file_name), 'results')
        
    end
    %exit;
end
% Find which column in the .quj files has the query string
function queryIndex = get_query_index(file_name, num_quj_columns)
    fid = fopen(file_name, 'rt');
    formatSpec = '%s';
    N = num_quj_columns;
    queryHeader = textscan(fid, formatSpec, N, 'delimiter', '\t');
    queryHeader = queryHeader{1};
    queryIndex = find(strcmp(queryHeader, 'query'));
    fclose(fid);
end
