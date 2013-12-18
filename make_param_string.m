function [param_string] = make_param_string(input)
    loadConstants();
    learner = input('learner');
    C = num2str(input('C'));
    degree = num2str(input('degree'));
    sigma = num2str(input('sigma'));
    usePar = input('usePar');
    whiten = input('whiten');
    param_string = '';
    if learner == ALTR_LIN || learner == ALTR_POLY ||...
            (learner >= RANKSVM && learner <= RANKSVM_WEIGHTED_BAD) || ...
            (learner >= ALTR_LIN_DUAL && learner <= ALTR_LIN_NO_WEAK)
        param_string = [param_string ',C=' C];
    end
    if learner == ALTR_POLY || learner == ALTR_POLY_KER_CHUNKING
        param_string = [param_string ',degree=' degree];
    end
    if learner == ALTR_RBF_KER
        param_string = [param_string ',sigma=' sigma];
    end
    if usePar
        param_string = [param_string ',Parallel'];
    end
    if input('whiten')
        param_string = [param_string ',whiten'];
    end
    if input('weak_to_add') > 0
        param_string = [param_string ',num_weak=' num2str(input('weak_to_add'))];
    end
    if input('percent_weak_to_add') > 0
        param_string = [param_string ',percent_weak_added=' num2str(input('percent_weak_to_add'))];
    end
    if input('percent_weak_to_use') > 0
        param_string = [param_string ',percent_weak_used=' num2str(input('percent_weak_to_use'))];
    end
end