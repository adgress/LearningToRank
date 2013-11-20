function w = ranksvm(X,y,opt)
    %Turn warning off because X is going to be rank deficient
    warning off;
    w = regress(y,X);
    warning on;
end