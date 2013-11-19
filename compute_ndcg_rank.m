function ndcg = compute_ndcg_rank(rank, Y, R)

[junk, Rindex] = sort(R, 'descend');
idcg = sum( (2.^R(Rindex(1:rank)) - 1) ./ log2(1 + [1:rank]) );

[junk, Yindex] = sort(Y, 'descend');
dcg = sum( (2.^R(Yindex(1:rank))-1) ./ log2(1 + [1:rank]) );

ndcg = dcg / idcg;
