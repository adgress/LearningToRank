function [] = run_experiment(configFile)
    input = containers.Map;
    input = load_configs_from_file(input,configFile);
    input = load_configs_from_file(input,'config/common.cfg');
    split = split_string(configFile,'/');
    directory = split{end-1};
    cfgName = get_cfg_name(configFile);
    
    [trainName,testName] = get_train_test_names(input);
    input('train_name_display') = trainName;
    input('test_name_display') = testName;
    %input('output_dir') = ['./results/' directory '/' 'test_on_' testName '/'];            
    input('output_dir') = ['./results/' directory '/'];
    
    mkdir(input('output_dir'));
    cArray = eval(eval(input('C')));
    weak_to_addArray = eval(eval(input('weak_to_add')));
    percent_weak_to_addArray = eval(eval(input('percent_weak_to_add')));
    percent_weak_to_useArray = eval(eval(input('percent_weak_to_use')));
    for weak_to_add = weak_to_addArray
    for percent_weak_to_add = percent_weak_to_addArray
    for percent_weak_to_use = percent_weak_to_useArray
    for C = cArray
        inputClone = input;
        inputClone('C') = C;
        inputClone('weak_to_add') = weak_to_add;
        inputClone('percent_weak_to_add') = percent_weak_to_add;
        inputClone('percent_weak_to_use') = percent_weak_to_use;
        resultsFile = make_result_file_name(inputClone,cfgName);
        inputClone('results_file') = resultsFile;
                 
        if exist([input('output_dir') '/' resultsFile],'file')
            fprintf(['Skipping:' resultsFile 'already exists\n']);
            continue;
        end
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
    end
end

function [trainName, testName] = get_train_test_names(input)
    trainName = split_string(input('train_name'),'.');
    trainName = trainName{2};
    testName = split_string(input('test_name'),'.');
    testName = testName{2};
end

function [result_file_name] = make_result_file_name(input,cfgName)
    loadConstants();
    param_string = make_param_string(input);
    result_file_name = [cfgName param_string '.mat'];
end

function [configName] = get_cfg_name(configFile)
    split = split_string(configFile,'/');
    configName = split_string(split{end},'.');
    configName = split_string(configName{1},',');
    configName = configName{1};
end
