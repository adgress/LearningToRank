function [w O S] = train_altr_linear_chunking(X, O,C)
    % X = train features
    % O = matrix of strongly ordered pairs. Each row has one +1 and one -1. The +1 column is ranked above the -1 column.
    %    (O for ordered)


margins = max(O,[],2);
O = sign(O);

%Xnew = [O; S] * X; % this holds the pairwise differences, which we are classifying
Xnew = O * X;

num_vectors = size(Xnew, 1);
support_vectors = [];
work_set = [];

loadConstants();
support_vector_margins = [];
for i = 1:600:num_vectors
    if i + 599 < num_vectors
       top_index = i + 599;
    else
        top_index = num_vectors;
    end
    work_set = [support_vectors; Xnew(i:top_index, :)];
    work_set_margins = [support_vector_margins ; margins(i:top_index)];
    [K] = linear_matrix(work_set);

    C_O = repmat(C, size(work_set, 1), 1);
    %C_S = repmat(0.1, size(S, 1), 1);

    cvx_begin quiet
        variable A(size(C_O, 1))
        %variable B(size(C_S, 1))
        % non-kernel:
        maximize( A'*work_set_margins - 1/2 * quad_form(A, K)  ) % shouldn't have 1/2 over the A*B terms?
        subject to
          0 <= A <= C_O
          %0 <= B <= C_S
    cvx_end

    support_vectors = work_set(find(A > epsilon), :);
    support_vector_margins = work_set_margins(find(A > epsilon));
end

A = A(A > epsilon);

otherW = zeros(1, size(support_vectors, 2));
for i = 1:numel(A)
    otherW = otherW + A(i) * support_vectors(i, :);
    %tmp = ( X( find(O(i,:) == 1), : ) - X( find(O(i, :) == -1), : ));
    %otherW = otherW + A(i) * tmp;
end
%for i = 1:numel(B)
%    otherW = otherW + B(i) * ( X( find(S(i,:) == 1), : ) - X( find(S(i, :) == -1), : ));
%end

%size(otherW)
w = otherW;
