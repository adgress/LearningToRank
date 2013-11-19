#!/bin/bash

# How to Use:
# ./compile_csv.sh <config file>
# See config/csv.cfg for example config file

source $1

files_arg=''
for i in "${result_files[@]}"
do
   files_arg="$files_arg , '$i'"
done
echo $files_arg
matlab -nodesktop -nojvm -nosplash -glnx86 -r "results_to_csv('$sampling_rate_vs_ndcg_file','$test_set_vs_ndcg_file','$experiment_description_file' $files_arg)"

