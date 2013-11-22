function model = train_regression(X,Y,opt)       
    %Turn warning off because X is going to be rank deficient
    warning off;
    %w = regress(Y,X);
    model = svmtrain(Y,X,'-t 0 -s 3 -q');
    warning on;
end