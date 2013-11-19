function [O] = build_O_per_query(Y, queries)
% O is the strongly ranked pairs. For the mth pair (i, j) such that strength i > strength j,
% O(m, i) = 1 and O(m, j) = -1, rest of row m is 0s
% This function builds O such that all possible pairs of higher to lower ranked examples are
% encoded, for all pairs within each query.

% Y are test set labels
% queries are test set queries
N = size(Y, 1);
grades = unique(Y);
uniqueQueries = unique(queries);

O = sparse(0,N);
row = 1;
for i = 1:numel(uniqueQueries)
    query = uniqueQueries(i);
    for i = numel(grades):-1:1
        grade = grades(i);
        gradeIndex = find(Y == grade & strcmp(queries, query));
        lesserIndex = find(Y < grade & strcmp(queries, query));
        for j = 1:numel(gradeIndex)
            for k = 1:numel(lesserIndex)
                lesserGrade = Y(lesserIndex(k));
                gradeDiff = (grade-lesserGrade);
                O(row, gradeIndex(j)) = gradeDiff;
                O(row, lesserIndex(k)) = -gradeDiff;
                row = row + 1;
            end
        end
    end
end
