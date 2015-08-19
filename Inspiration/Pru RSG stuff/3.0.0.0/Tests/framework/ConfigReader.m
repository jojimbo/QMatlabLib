% This class is for reading the defaults for the test framework
% it is not used for reading the RSG application configuration files
classdef ConfigReader
	properties
		Config;
    end

    methods
	% Properties are expected to be key values pairs separated by
	% the equals sign. There must be a space either side of the 
	% equals sign. e.g. in the following example myKey becomes a 
	% member of the Config struct with valu myValue
	% myKey = myValue
	function obj = ConfigReader(configFile)
		[keynames, values] = textread(configFile, '%s=%s', 'commentstyle', 'matlab');	
		v = str2double(values);
		idx = ~isnan(v);
		values(idx) = num2cell(v(idx));
		obj.Config = cell2struct(values, lower(keynames));

		disp('Found the follwing test framework configuration values');
		for i = 1:length(keynames)
			fprintf('Key: %s, Value: %s\n', keynames{i}, values{i});
		end
		disp('No further configuration values found');
    end
    end
end
