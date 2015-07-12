classdef (Sealed) ConfMan < handle & dynamicprops
    %ConfMan Provide access to configuration data
    %   The configuration class loads data from file and makes it available
    %   to the system
    %
    %   ConfMan Properties
    %   configFile - The default configuration file
    %
    %   ConfMan Methods
    %   instance - retrieve the sintleton instance
    %   disp - disp display configuration data
    %   get - retrieve configuration values
    %   exists - determine if a configuration key exists
    
    properties
        configPath; % The config folder
        configFile = 'default.config'; % The default config file to parse
        extension = '.config'; % Config file extension
    end
    
    methods (Static)
      function i = instance
      % instance singleton accessor
      %   instance() access the single instance of this class configuration data
      % 
        persistent singleton
        if isempty(singleton) || ~isvalid(singleton)
            singleton = engine.util.config.ConfMan();
        end
        i = singleton;
      end
    end
   
    methods
        [] = use(confman, config);
        
        function set.configPath(confman, path)
        % set.configPath translate relative paths to absolute so that
        % changing directory des not impact reload where a relative path
        % has been specified
            confman.configPath = GetFullPath(path);
        end
        
        function [status] = reload(confman)
        % reload load configuration data from file
        %   reload() reloads the configuration. This is required in order
        %   to reflect changes to the underlying file.
            config = fullfile(confman.configPath, confman.configFile);
            if exist(config, 'file')
                confman.parseConfig(config);   
                status = true;
                return;
            end
            
            confman.displayConfigNotFound(config);                
            status = false;
        end
        
        function [names, values] = list(confman)
        % list print the list of available configurations
        %   list() prints the configuration names that can be passed to use
        %
        % See also use.
            fileList = dir(fullfile(confman.configPath, ['*', confman.extension]));
            
            [names, values] = arrayfun(@(x) deal(x.name(1:end-length(confman.extension)), ...
                fullfile(confman.configPath, x.name)), fileList, 'UniformOutput', false);
        end
        
        function [] = disp(confman)
        % disp display processed configuration data
        %   disp() display configuration data
        %            
            confman.disp_fields('\t\t', 'confman', confman);
        end
        
        function [] = raw(confman)
        % raw display raw (unexpanded) configuration data
        %   disp() display configuration data
        %
            disp(confman.data);
        end
        
        function [value] = get(confman, key)
        % get retrieve configuration
        %   get(key) retrieve configuration value for key
        %
        %   See also exists.   
            value = confman.(key);
        end
        
        function [result] = has(confman, key)
        % has confirm specifed configuration exists
        %   has(key) determine if key exists in the configuration 
        %
        %   See also get.        
            result = isprop(confman, key);
        end
    end
    
    properties (Access=private)
        data % object representing the raw cofiguration
        dynProps = {} % maintain a list of props to delete on reload
    end
    
    methods (Access = private)
        [expanded] = expandMacros(confman, obj, valid_keys);
        [] = disp_fields(confman, indent, prefix, obj);
        [] = buildProxy(confman, data);
        
        function [confman] = ConfMan()
        % ConfMan construct a configuration instance
        %   ConfMan() load default configuration
        %   ConfMan(configFile) load configration from configFile
        % 
            confman.configPath = fullfile(pwd, 'config');
            confman.configFile = confman.findConfig();
            confman.reload();
        end
        
        function [] = validateConfig(confman)
        % validateConfig perform basic validation on the configuration 
        %   validateConfig() check that mandatory keys have been supplied
        %
        %   See also checkDir.
            confman.checkDir('root');
            confman.checkDir('quant');
            confman.checkDir('engine');
        end
        
        function checkDir(confman, key)
        % checkDir perform basic validation on the configuration 
        %   checkDir(key) check that key has been supplied and it's a valid
        %   path
        %
        %   See also validateConfig.
            if ~confman.has(key)                
                fprintf('Warning: Mandatory config item "%s" not found!\n', key);
            end
            
            value = confman.(key);
            if ~exist(value, 'dir')              
                fprintf('Warning: %s directory ''%s'' not found!\n'  , key, value);
            end
        end
        
        function name = getUserName(~)
        % getUserName return the user name of the logged in user
        %   getUserName() returns the users name. Unix and Windows is
        %   currently supported
            if isunix() 
                name = getenv('USER'); 
            else 
                name = getenv('username'); 
            end
        end
        
        function [config] = findConfig(confman)
        % findConfig finds a user specific config or returns the default
        % configuration
        %
        % See alos getUserName
            user = confman.getUserName();
            config = [user, '.config'];
            if ~exist(fullfile(confman.configPath, config), 'file')
                config = confman.configFile;
            end
        end
        
        function [data] = loadConfig(confman, config)
        % loadConfig loads the specified config from file
        %   loadConfig(config) load the specifid config and process the
        %   data
        %
        % See also buildProxy, expansMacros, validateConfig.
            data = loadjson(config);
            
            confman.buildProxy(data);
            confman.expandMacros(confman, data);
            confman.validateConfig();      
        end
        
        function [] = parseConfig(confman, config)
            fprintf('Attempting to load configuration from %s\n', config);
            confman.data = confman.loadConfig(config);  
        end
        
        function [] = displayConfigNotFound(confman, config)
            [keys, ~] = confman.list;
            if isempty(keys)
                fprintf('No configs found!\n'); 
                return;
            end
            
            fprintf('''%s'' config not found. Available configs are:\n', config);
            disp(keys);            
        end
    end
end

