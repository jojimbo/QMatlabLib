function [] = use(confman, config)
    % use switches confman to the specified configuration
    %   use(name) switch to use the configuration specified in
    %   the name.config file
    %
    %   See also list.
    [names, values] = confman.list;

    if ~isempty(names)
        configs = containers.Map(names, values);

        if configs.isKey(config)
            configFilePath = configs(config);
            [~, name, ext] = fileparts(configFilePath);
            confman.configFile = [name, ext];
            confman.loadConfig(configFilePath);
            return
        end
    end

    % config is not a valid config file. Try using config as configuration 
    % data instead
    try
        flipped = regexprep(config, '\', '/');
        confman.parseConfig(flipped);
    catch ex
        disp(ex);
        confman.displayConfigNotFound(config);
    end
end