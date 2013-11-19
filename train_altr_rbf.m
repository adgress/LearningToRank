function [A B] = train_altr_rbf(X, O, S, sigma, C)
    % X = train features
    % O = matrix of strongly ordered pairs. Each row has one +1 and one -1. The +1 column is ranked above the -1 column.
    %    (O for ordered)
    % S = matrix of weakly ordered pairs. Implies rough equality in ranking between +1 and -1 columns.
    %    (S for similar)
    % sigma = sigma for sigmoid function

C_O = repmat(C, size(O, 1), 1);
%C_S = repmat(10, size(S, 1), 1);

size(O)
%size(S)

B = [];
%Xnew = [O; S] * X;
Xnew = O * X;
[K] = rbf_matrix(Xnew , sigma);
%[K pos sigma] = KNNGraph(Xnew' , size(Xnew, 1) - 1, sigma, 0);
%K = K + eye(size(Xnew, 1));

size(K)

cvx_begin
    variable A(size(C_O, 1))
    %variable B(size(C_S, 1))

    maximize( sum(A) -  1/2 * quad_form(A, K)  )
    %maximize( sum(A) -  1/2 * quad_form([A; B], K)  )
    % Reformulating according to http://cvxr.com/cvx/doc/advanced.html
    % But incredibly slow to calculate Ksqrt with 8000 constraints...
    %Ksqrt = sqrtm(K);
    %maximize( sum(A) - 1/2 * norm( Ksqrt * ( [A; B] ) ) )
    subject to
      0 <= A <= C_O
      %0 <= B <= C_S
cvx_end
