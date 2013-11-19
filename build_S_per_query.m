function [S] = build_S_per_query(Y, queries)
% S is the similarly ranked pairs. For the mth pair (i, j) such that strength i ~ strength j,
% S(m, i) = 1 and S(m, j) = -1, rest of row m is 0s
% This function builds S such that all possible pairs of approximately equally ranked examples are
% encoded, for all pairs within each query.

% Y are test set labels
% queries are test set queries

N = size(Y, 1);
grades = unique(Y);
uniqueQueries = unique(queries);

S = sparse(0,N);
row = 1;
for i = 1:numel(uniqueQueries)
    query = uniqueQueries(i);
    for i = 1:numel(grades)
	    grade = grades(i);
	    index = find(Y == grade & strcmp(queries, query));
	    for j = 1:numel(index)
	        for k = (j+1):numel(index)
			    S(row, index(j)) = -1;
			    S(row, index(k)) = 1;
			    row = row + 1;
		    end
	    end
    end
end
