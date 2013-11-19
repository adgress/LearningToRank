function t_x = rank_k_poly(x, ForKFirstArg, AB, d)

t_x = 0;
for i = 1:numel(AB)
    t_x = t_x + AB(i) * poly_kernel( ForKFirstArg( i, : ), x, d);
end

