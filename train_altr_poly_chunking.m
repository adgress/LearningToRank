function [A support_vectors] = train_altr_poly_chunking(X, O, d,C)
    % X = train features
    % O = matrix of strongly ordered pairs. Each row has one +1 and one -1. The +1 column is ranked above the -1 column.
    %    (O for ordered)
    % d = exponent for poly kernel

Xnew = O * X;

num_vectors = size(Xnew, 1);
support_vectors = [];
work_set = [];
epsilon =  0.0000001;
size_of_chunk = 750;

size(Xnew)

for i = 1:size_of_chunk:num_vectors
    if i + size_of_chunk - 1 < num_vectors
       top_index = i + size_of_chunk - 1;
    else
        top_index = num_vectors;
    end
    work_set = [support_vectors; Xnew(i:top_index, :)];

    [K] = poly_matrix(work_set, d);

    C_O = repmat(C, size(work_set, 1), 1);

    cvx_begin
        variable A(size(C_O, 1))
        %variable B(size(C_S, 1))
        % non-kernel:
        maximize( sum(A) - 1/2 * quad_form(A, K)  ) % shouldn't have 1/2 over the A*B terms?
        subject to
          0 <= A <= C_O
          %0 <= B <= C_S
    cvx_end

    support_vectors = work_set(find(A > epsilon), :);
    
    disp(strcat('index ', int2str(i)))
    size(support_vectors)
end

A = A(A > epsilon);
