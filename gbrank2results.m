function [] = gbrank2results(file,outdir,outfile)
    fid = fopen(file);
    data = {};
    currSet = [];
    fgetl(fid);
    while true
        line = fgetl(fid);
        if ~ischar(line)
            data{end+1} = currSet;
            break;
        end
        n = str2num(line);
        if isempty(n)
            data{end+1} = currSet;
            currSet = [];
        else
            currSet(end+1) = n;
        end
    end
    results = containers.Map;
    %X = zeros(numel(data),numel(data{1}));
    for i=1:numel(data)
        %X(i,:) = data{i};
        results(['ndcg_' num2str(i)]) = data{i};
        results(['var_' num2str(i)]) = 0*data{i};
    end
    results('learner') = ['GBRank: ' outfile];
    results('sampling_rate') = [0.01:0.01:0.01*numel(data{1})];
    results('iterations') = 10;
    save([outdir '/' outfile],'results');
    fclose(fid);
end