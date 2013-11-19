function [A B sigma] = train_altr_poly(X, O, S, d)
    % X = train features
    % O = matrix of strongly ordered pairs. Each row has one +1 and one -1. The +1 column is ranked above the -1 column.
    %    (O for ordered)
    % S = matrix of weakly ordered pairs. Implies rough equality in ranking between +1 and -1 columns.
    %    (S for similar)
    % d = exponent for poly kernel

C_O = repmat(0.1, size(O, 1), 1);
C_S = repmat(0.1, size(S, 1), 1);

size(O)
size(S)

Xnew = [O; S] * X;

[K] = poly_matrix(Xnew, d);

size(K)

cvx_begin
    variable A(size(C_O, 1))
    variable B(size(C_S, 1))

    % kernel:
    maximize( sum(A) -  1/2 * quad_form([A; B], K)  )

    subject to
      0 <= A <= C_O
      0 <= B <= C_S
cvx_end
