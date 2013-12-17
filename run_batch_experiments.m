function [] = run_batch_experiments(configFile)
    input = containers.Map;
    input = load_configs_from_file(input,configFile);
    input = load_configs_from_file(input,'config/common.cfg');
    inputDirs = eval(input('input_dir'));
    names=eval(input('names'));
    numColumns = eval(input('num_quj_columns'));
    split = split_string(configFile,'/');
    configDirectory = [split{1} '/' split{2} '/'];
    output_dir = (input('output_dir'));
    learnerName = get_learner_name(input);
    learner = input('learner');
    input_dir = '../';
    mkdir(configDirectory);
    for i=1:numel(inputDirs)
        for j=1:numel(inputDirs)
            %{
            results_file = [names{i} '_to_' names{j} '_' learnerName '.mat']
            if exist(results_file,'file')
                fprintf(['Skipping:' results_file 'already exists']);
                continue;
            end
            %}
            configFile = [configDirectory names{i} '_to_' names{j} '_' learnerName '.cfg'];
            
            fid = fopen(configFile,'w');
            fprintf(fid,'input_dir=%s\n',input_dir);
            train_name = ['train_name=' inputDirs{i} '/train.' names{i}];
            fprintf(fid,'%s\n',train_name);
            test_name = ['test_name=' inputDirs{j} '/test.' names{j}];
            fprintf(fid,'%s\n',test_name);
            fprintf(fid,'output_dir=%s\n',[output_dir '/test_on' names{j} '/']);
            %fprintf(fid,'%results_file=\n',results_file);
            fprintf(fid,'learner=%d\n',learner);
            fprintf(fid,'input_dir_2=\n');
            fprintf(fid,'train_name_2=\n');
            fprintf(fid,'test_name_2=\n');
            fclose(fid);
            run_experiment(configFile);
            delete(configFile);
            break;
        end        
    end
end