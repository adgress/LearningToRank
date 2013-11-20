function learner = get_learner_name(learner_flag)
    name_array = cell(10, 1);
    name_array{1} = 'Relative Attributes';
    name_array{2} = 'ALTR Linear Kernel';
    name_array{3} = 'ALTR Poly Kernel';
    name_array{4} = 'Random';
    % 5 was fixed, or just the source file's ordering
    name_array{6} = 'RankSVM';
    name_array{7} = 'ALTR RBF Kernel';
    name_array{8} = 'ALTR Linear Kernel Chunking';
    name_array{9} = 'ALTR Poly Kernel Chunking';
    name_array{10} = 'Multi Attribute';
    name_array{11} = 'RankSVM Weighted';
    name_array{12} = 'ALTR LKC Weighted';
    name_array{13} = 'RankSVM Weighted Bad';
    name_array{14} = 'Regression';
    learner = name_array{learner_flag};
end