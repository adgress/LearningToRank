function [] = create_test_sets(configFile)
    input = containers.Map;
    input = load_configs_from_file(input,configFile);
   
    fv_file = input('fv_file');
    quj_file = input('quj_file');
    ndcg_rank = (input('ndcg_rank'));    
    num_quj_columns = (input('num_quj_columns'));
    feature_indices_to_use = eval(eval(input('feature_indices_to_use')));
    output_dir = input('output_dir');
    num_train_test_splits = (input('num_train_test_splits'));
    num_test_queries = (input('num_test_queries'));
    train_name = input('train_name');
    test_name = input('test_name');
    normalize = input('normalize');
    generate_train_test_split(fv_file, quj_file, num_quj_columns, ...
         feature_indices_to_use, output_dir, ...
         num_train_test_splits, num_test_queries, ndcg_rank, train_name, ...
         test_name, normalize)
end