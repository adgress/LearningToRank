#!/bin/bash

# How to Use:
# ./create_test_sets.sh <config file>
# See generate_split.cfg for example config file_

source $1

mkdir -p $output_dir
matlab -nodesktop -nojvm -nosplash -glnx86 -r "generate_train_test_split('$fv_file', '$quj_file', $num_quj_columns, $feature_indices_to_use, '$output_dir', $num_train_test_splits, $num_test_queries, $ndcg_rank, '$train_name', '$test_name', $normalize)" 


