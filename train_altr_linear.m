function [w O S] = train_altr_linear(X, O, S,solveDual,useWeaklyOrderedPairs)
    % X = train features
    % O = matrix of strongly ordered pairs. Each row has one +1 and one -1. The +1 column is ranked above the -1 column.
    %    (O for ordered)
    % S = matrix of weakly ordered pairs. Implies rough equality in ranking between +1 and -1 columns.
    %    (S for similar)
loadConstants();
C_O = repmat(C, size(O, 1), 1);
C_S = repmat(C, size(S, 1), 1);

if solveDual
    if useWeaklyOrderedPairs
        cvx_begin quiet
            variable A(size(C_O, 1))
            variable B(size(C_S, 1))
            % non-kernel:
            maximize( sum(A) - 1/2 * quad_form([A; B], ([O; S] * X) * ([O; S] * X)' )  ) % shouldn't have 1/2 over the A*B terms?
            subject to
              0 <= A <= C_O
              0 <= B <= C_S
        cvx_end


        otherW = zeros(1, size(X, 2));
        for i = 1:numel(A)
            tmp = ( X( find(O(i,:) == 1), : ) - X( find(O(i, :) == -1), : ));
            otherW = otherW + A(i) * tmp;
        end
        for i = 1:numel(B)
            otherW = otherW + B(i) * ( X( find(S(i,:) == 1), : ) - X( find(S(i, :) == -1), : ));
        end
        w = otherW;
    else
        error('Not yet implemented');
    end
else
    if useWeaklyOrderedPairs
        cvx_begin quiet
            variable w(size(X,2),1)
            variable z(size(C_O,1),1)
            variable g(size(C_S,1),1)
            minimize(.5*w'*w + C*(sum(z) + sum(g)))
            subject to
                0 <= z
                0 <= g
                O*X*w >= 1 - z
                S*X*w >= -g
        cvx_end
    else
        cvx_begin quiet
            variable w(size(X,2),1)
            variable z(size(C_O,1),1)
            minimize(.5*w'*w + C*(sum(z)))
            subject to
                0 <= z
                O*X*w >= 1 - z
        cvx_end
    end
    w = w';
end
