function [] = results_to_csv(sampling_rate_vs_ndcg_file, test_set_vs_ndcg_file, ...
         experiment_description_file, varargin)
         
% sampling_rate_vs_ndcg_file is the path where a CSV file will be written with the following
%     columns: sampling rate, ndcg of <learner 1>, ndcg of <learner 2>, ...
% test_set_vs_ndcg_file is the path where a CSV file will be written with the following
%     columns: test set #, ndcg of <learner 1>, ndcg of <learner 2>, ...  where NDCG is taken
%     at the highest sampling rate recorded
% experiment_description_file is the path where a CSV file will be written with the following
%     columns: name of learner, iterations, train set, test set, number of splits, ndcg_rank
% varargin is a variable number of additional argument. Each additional argument
% should be the path to a .mat file containing the saved results of an experiment
% created with run_experiment.sh.

% IMPORTANT: All .mat results file must be from experiments run with the same sampling rates,
% NDCG rank, testing sets, and number of train/test splits for the generated CSV files to be meaningful.

sampling_rate_vs_ndcg = [];
test_set_vs_ndcg = [];
experiment_desc = cell(1, 6);

% Header indices for experiment_desc
LEARNER_I = 1;
ITERATIONS_I = 2;
TRAIN_SET_I = 3;
TEST_SET_I = 4;
NUM_SPLITS_I = 5;
NDCG_RANK_I = 6;
experiment_desc_header = {'Learner', 'Iterations', 'Train Set', ...
                       'Test Set', 'Number Splits', 'NDCG Rank'};

sampling_rate = [];
num_splits = 0;
test_set_in_use = '';

% Each element of varargin is a file path pointing to a .mat file containing
% a results container.Map()
num_learners = length(varargin);

% Iterate over each results .mat file
for k = 1:num_learners
    load(varargin{k});

    % These two variables (should) be constant for all the result sets
    num_splits = results('num_train_test_splits');
    sampling_rate = results('sampling_rate');
    
    % These will vary for each result
    learner = results('learner');
    train_set = results('train_set');
    test_set = results('test_set');
    ndcg_rank = results('ndcg_rank');
    iterations = results('iterations');

    % If results are for a multi-attribute learner, compare
    % test set to others to determine which results of the multi-attribute
    % learner to include
    if (strcmp(learner, 'Multi Attribute'))
       if (strcmp(test_set_in_use, test_set))
          ndcg_key_base = 'ndcg_';
       else
           ndcg_key_base = 'ndcg2_';
       end;
    else
        ndcg_key_base = 'ndcg_';
        test_set_in_use = test_set;
    end;

    % Iterate over the NDCG scores in results for this learner
    % For each test set, the score is in results('ndcg_<#>')
    test_set_ndcg = [];
    sampling_rate_ndcg = [];
    for i = 1:num_splits
        % Get the ndcgs for test set i
        test_set_i_ndcg = results(strcat(ndcg_key_base, int2str(i)));

        % Build a matrix where entry i,j is ndcg at sampling rate i on test
        % set j
        sampling_rate_ndcg = [sampling_rate_ndcg test_set_i_ndcg];

        % Add last entry (highest sampling rate) to test_set_vs_ndcg matrix
        test_set_ndcg = [test_set_ndcg; test_set_i_ndcg(end)];
    end;

    sampling_rate_vs_ndcg = [sampling_rate_vs_ndcg mean(sampling_rate_ndcg, 2)];
    test_set_vs_ndcg = [test_set_vs_ndcg test_set_ndcg];

    experiment_desc{k, LEARNER_I} = learner;
    experiment_desc{k, ITERATIONS_I} = iterations;
    experiment_desc{k, TRAIN_SET_I} = train_set;
    experiment_desc{k, TEST_SET_I} = test_set;
    experiment_desc{k, NUM_SPLITS_I} = num_splits;
    experiment_desc{k, NDCG_RANK_I} = ndcg_rank;
end

% By assumption that all result sets use same sampling rate, we can prepend the
% last sets sampling_rate vector to form the sampling rate column
sampling_rate_vs_ndcg = [sampling_rate' sampling_rate_vs_ndcg];

% Likewise, we can prepend test_set_vs_ndcg with 1:num_splits
test_set_vs_ndcg = [(1:num_splits)' test_set_vs_ndcg];

% Write sampling_rate_vs_ndcg to CSV file, sampling_rate_vs_ndcg_file
fileID = fopen(sampling_rate_vs_ndcg_file, 'wt');
fprintf(fileID, 'Sampling Rate');
for i = 1:num_learners
    fprintf(fileID, ',%s', experiment_desc{i, 1});
end
fprintf(fileID, '\n');
fclose(fileID);
dlmwrite(sampling_rate_vs_ndcg_file, sampling_rate_vs_ndcg, '-append', 'delimiter', ',');

% Write test_set_vs_ndcg to CSV file, test_set_vs_ndcg_file
fileID = fopen(test_set_vs_ndcg_file, 'wt');
fprintf(fileID, 'Test Set');
for i = 1:num_learners
    fprintf(fileID, ',%s', experiment_desc{i, 1});
end
fprintf(fileID, '\n');
fclose(fileID);
dlmwrite(test_set_vs_ndcg_file, test_set_vs_ndcg, '-append', 'delimiter', ',');

% Write experiment_desc to CSV file, experiment_description_file
fileID = fopen(experiment_description_file, 'w');
fprintf(fileID, '%s', experiment_desc_header{1});
for i = 2:length(experiment_desc_header)
    fprintf(fileID, ',%s', experiment_desc_header{i});
end
fprintf(fileID, '\n');
for i = 1:num_learners
    fprintf(fileID, '%s', experiment_desc{i, 1});
    for j = 2:length(experiment_desc_header)
        if ischar(experiment_desc{i, j}),
            fprintf(fileID, ',%s', experiment_desc{i, j});
        else
            fprintf(fileID, ',%d', experiment_desc{i, j});
        end
    end
    fprintf(fileID, '\n');
end;
fclose(fileID);


exit;