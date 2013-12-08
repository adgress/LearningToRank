function [split] = split_string(string,delim)
    split = {};
    while numel(string) > 0
        [split{end+1}, string] = strtok(string,delim);     
    end
end