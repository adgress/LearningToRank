function [] = run_experiment(configFile)
    input = containers.Map;
    input = load_configs_from_file(input,configFile);
    input = load_configs_from_file(input,'config/common.cfg');
    split = split_string(configFile,'/');
    directory = split{end-1};
    cfgName = get_cfg_name(configFile);
    input('output_dir') = ['./results/' directory '/'];
    input('results_file') = make_result_file_name(input,cfgName);
    
    mkdir(input('output_dir'));
    run_experiments(input('input_dir'), input('train_name'), input('test_name'), input('num_train_test_splits'), input('iterations'), input('ndcg_rank'), eval(eval(input('sampling_rate'))), input('output_dir'), input('results_file'), input('learner'), input('input_dir_2'), input('train_name_2'), input('test_name_2'), input('cvx_path'),input);
end

function [result_file_name] = make_result_file_name(input,cfgName)
    loadConstants();
    param_string = make_param_string(input);
    result_file_name = [cfgName param_string '.mat'];
end

function [input] = load_configs_from_file(input,configFile)
    fid = fopen(configFile,'r');
    if fid == -1
        display(sprintf('Could not open config file'));
        return;
    end    
    while ~feof(fid)
        x = fgetl(fid);
        if length(x) == 0 || x(1) == '#'
            continue;
        end
        C = textscan(x,'%s','delimiter','=');
        C = C{1};
        var = C{1};
        val = '';
        if length(C) > 1
            val = C{2}; 
        end
        if length(val) > 0 && ~isnan(str2double(val));
            val = str2double(val);
        end
        input(var) = val;
    end
    fclose(fid);
end

function [name] = get_cfg_name(configFile)
    split = split_string(configFile,'/');
    name = split_string(split{end},'.');
    name = name{1};
end
