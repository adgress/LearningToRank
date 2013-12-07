function [w_0 v_1 v_2] = train_multi_linear(TrainSet_1, O_1, TrainSet_2, O_2, lambda,C)
    % TrainSet_1 = train set 1 features
    % O_1 = matrix of strongly ordered pairs for train set 1. Each row has one +1 and one -1.
    %    The +1 column is ranked above the -1 column (O for ordered)
    % TrainSet_2 = train set 2 features
    % O_2 = matrix of strongly ordered pairs for train set 2. Same structure as O_1
    % lambda = parameter

C_O_1 = repmat(C, size(O_1, 1), 1);
C_O_2 = repmat(C, size(O_2, 1), 1);

M = 2; % Number of attributes. For now, fixed at 2 (local and news searches)

padded_O_1 = [O_1 zeros(size(O_1, 1), size(TrainSet_2, 1))];
padded_O_2 = [zeros(size(O_2, 1), size(TrainSet_1, 1)) O_2];

K_full = linear_matrix([padded_O_1; padded_O_2] * [TrainSet_1; TrainSet_2]);
K_1 = linear_matrix(O_1 * TrainSet_1);
K_2 = linear_matrix(O_2 * TrainSet_2);

cvx_begin quiet
    variable A_1(size(C_O_1, 1))
    variable A_2(size(C_O_2, 1))

    maximize( sum(A_1) + sum(A_2) - 1/2 * quad_form([A_1; A_2], K_full) - M / (2*lambda) * [quad_form(A_1, K_1) + quad_form(A_2, K_2)] )
    subject to
      0 <= A_1 <= C_O_1
      0 <= A_2 <= C_O_2
cvx_end

w_0 = zeros(1, size(TrainSet_1, 2));
for i = 1:numel(A_1)
    indPos = find(O_1(i,:) == 1);
    indNeg = find(O_1(i, :) == -1);
    xPos = TrainSet_1( indPos, :);
    xNeg = TrainSet_1( indNeg, : );
    tmp = ( xPos - xNeg);
    w_0 = w_0 + A_1(i) * tmp;
end
for i = 1:numel(A_2)
    tmp = ( TrainSet_2( find(O_2(i,:) == 1), : ) - TrainSet_2( find(O_2(i, :) == -1), : ));
    w_0 = w_0 + A_2(i) * tmp;
end

v_1 = zeros(1, size(TrainSet_1, 2));
for i = 1:numel(A_1)
    tmp = ( TrainSet_1( find(O_1(i,:) == 1), : ) - TrainSet_1( find(O_1(i, :) == -1), : ));
    v_1 = v_1 + A_1(i) * tmp;
end
v_1 = v_1 * M / lambda;

v_2 = zeros(1, size(TrainSet_1, 2));
for i = 1:numel(A_2)
    tmp = ( TrainSet_2( find(O_2(i,:) == 1), : ) - TrainSet_2( find(O_2(i, :) == -1), : ));
    v_2 = v_2 + A_2(i) * tmp;
end
v_2 = v_2 * M / lambda;


