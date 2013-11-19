function [w O S] = train_ranksvm(X, O, C)
        % X = train features
        % O = matrix of strongly ordered pairs. Each row has one +1 and one -1. The +1 column is ranked above the -1 column.
        %    (O for ordered)

    C_O = repmat(C, size(O, 1), 1);

    size(O)

    d = size(X,2);
    w = zeros(d,1);

    opt.lin_cg = 1;
    opt.iter_max_Newton = 200;
    w = ranksvm(X,O,C_O, w, opt);
end