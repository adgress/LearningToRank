function [input] = load_configs_from_file(input,configFile)
    fid = fopen(configFile,'r');
    if fid == -1
        error('Could not open config file');
        return;
    end    
    while ~feof(fid)
        x = fgetl(fid);
        if length(x) == 0 || x(1) == '#'
            continue;
        end
        C = textscan(x,'%s','delimiter','=');
        C = C{1};
        var = C{1};
        val = '';
        if length(C) > 1
            val = C{2}; 
        end
        val = strtrim(val);
        if length(val) > 0 && ~isnan(str2double(val));
            val = str2double(val);
        end
        input(var) = val;
    end
    fclose(fid);
end