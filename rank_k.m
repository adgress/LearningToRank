function t_x = rank_k(x, X, O, S, A, B, sigma)

t_x = 0;
for i = 1:numel(A)
    t_x = t_x + A(i) * ( kernel( X( find(O(i,:) == 1), : )', x', sigma) - (kernel( X( find(O(i, :) == -1), : )', x', sigma) ) );
end
for i = 1:numel(B)
    t_x = t_x + B(i) * ( kernel( X( find(S(i,:) == 1), : )', x', sigma) - (kernel( X( find(S(i, :) == -1), : )', x', sigma) ) );
end


