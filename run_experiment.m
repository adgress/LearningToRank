function [] = run_experiment(config)
    fid = fopen(config,'r');
    if fid == -1
        display(sprintf('Could not open config file'));
        return;
    end
    input = containers.Map;
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
    mkdir(input('output_dir'));
    run_experiments(input('input_dir'), input('train_name'), input('test_name'), input('num_train_test_splits'), input('iterations'), input('ndcg_rank'), eval(eval(input('sampling_rate'))), input('output_dir'), input('results_file'), input('learner'), input('input_dir_2'), input('train_name_2'), input('test_name_2'), input('cvx_path'));
end

