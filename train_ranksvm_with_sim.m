function [w O S] = train_ranksvm_with_sim(X, O, S,C)
        % X = train features
        % O = matrix of strongly ordered pairs. Each row has one +1 and one -1. The +1 column is ranked above the -1 column.
        %    (O for ordered)
        % S = matrix of weakly ordered pairs. Implies rough equality in ranking between +1 and -1 columns.
        %    (S for similar)

    %try without S
    %S = sparse(0, 0);

    C_O = repmat(C, size(O, 1), 1);
    C_S = repmat(C, size(S, 1), 1);

    size(O)
    size(S)

    d = size(X,2);
    w = zeros(d,1);

    opt.lin_cg = 1;
    opt.iter_max_Newton = 200;
    w = ranksvm_with_sim(X,O,S,C_O,C_S, w, opt);
end