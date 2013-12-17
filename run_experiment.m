function [] = run_experiment(configFile)
    input = containers.Map;
    input = load_configs_from_file(input,configFile);
    input = load_configs_from_file(input,'config/common.cfg');
    split = split_string(configFile,'/');
    directory = split{end-1};
    cfgName = get_cfg_name(configFile);
    input('output_dir') = ['./results/' directory '/'];    
    
    mkdir(input('output_dir'));
    cArray = eval(eval(input('C')));
    weak_to_addArray = eval(eval(input('weak_to_add')));
    for weak_to_add = weak_to_addArray
    for C = cArray
        inputClone = input;
        inputClone('C') = C;
        inputClone('weak_to_add') = weak_to_add;
        inputClone('results_file') = make_result_file_name(inputClone,cfgName);
        run_experiments(input('input_dir'), input('train_name'), ...
            input('test_name'), input('num_train_test_splits'), ...
            input('iterations'), input('ndcg_rank'), ...
            eval(eval(input('sampling_rate'))), input('output_dir'), ...
            input('results_file'), input('learner'), input('input_dir_2'), ...
            input('train_name_2'), input('test_name_2'), input('cvx_path'), ...
            inputClone);
    end
    end
end

function [result_file_name] = make_result_file_name(input,cfgName)
    loadConstants();
    param_string = make_param_string(input);
    result_file_name = [cfgName param_string '.mat'];
end

function [name] = get_cfg_name(configFile)
    split = split_string(configFile,'/');
    name = split_string(split{end},'.');
    name = split_string(name{1},',');
    name = name{1};
end
