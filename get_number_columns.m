function N = get_number_columns(filename)

fid = fopen(filename, 'r');
header_line = fgetl(fid);
columns = regexp(header_line, '\t', 'split');

N = length(find(~strcmp(columns, '')));
