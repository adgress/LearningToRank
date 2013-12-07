function [param_string] = make_param_string(input)
    loadConstants();
    learner = input('learner');
    C = num2str(input('C'));
    degree = num2str(input('degree'));
    sigma = num2str(input('sigma'));
    param_string = '';
    if learner == ALTR_LIN || learner == ALTR_POLY ||...
            (learner >= RANKSVM && learner <= RANKSVM_WEIGHTED_BAD) || ...
            (learner >= ALTR_LIN_DUAL && learner <= ALTR_LIN_NO_WEAK)
        param_string = [param_string ', C = ' C];
    end
    if learner == ALTR_POLY || learner == ALTR_POLY_KER_CHUNKING
        param_string = [param_string ', degree = ' degree];
    end
    if learner == ALTR_RBF_KER
        param_string = [param_string ', sigma = ' sigma];
    end
end