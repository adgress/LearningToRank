function t_x = rank_k_rbf(x, ForKFirstArg, AB, sigma)

t_x = 0;
for i = 1:numel(AB)
    mult = AB(i);
    kern_val = rbf_kernel( ForKFirstArg( i, : )', x', sigma);
    result = mult * kern_val;
    t_x = t_x + result;
end

