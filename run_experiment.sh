#!/bin/bash

# How to Use:
# ./run_experiment.sh <config file>
# See experiment.cfg for example config file

source $1

mkdir -p $output_dir
#matlab -nodesktop -nojvm -nosplash -glnx86 -r "run_experiments('$input_dir', '$train_name', '$test_name', $num_train_test_splits, $iterations, $ndcg_rank, $sampling_rate, '$output_dir', '$results_file', $learner, '$input_dir_2', '$train_name_2', '$test_name_2', '$cvx_path')"
matlab -nodesktop -nojvm -nosplash -r "run_experiments('$input_dir', '$train_name', '$test_name', $num_train_test_splits, $iterations, $ndcg_rank, $sampling_rate, '$output_dir', '$results_file', $learner, '$input_dir_2', '$train_name_2', '$test_name_2', '$cvx_path')"

