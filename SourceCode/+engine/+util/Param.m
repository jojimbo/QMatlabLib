classdef Param < handle
    %PARAM Wrapper for function arguments
    % Simplify processing of function arguments by converting cell
    % key-value pairs into struct property-value pairs
    %
    % Based on posts http://stackoverflow.com/questions/2775263/how-to-deal-with-name-value-pairs-of-function-arguments-in-matlab
    %
    % Varag is a cell array containing key-value pairs (so the array length
    % is even). Keys must be valid struct property names.
    % Spec can be a cell array or a struct. Spec is used in one of two modes    
    % 1) strict = true (the default)
    %   spec strictly specifies required parameters with defaults. Keys in
    %   varargs that don't match keys in spec will generate an error.
    % 2) strict = false
    %   spec specifies default values that are used where a parameter is
    %   missing from vararg. A user can supply more parameters in vararg than
    %   specified in spec. This approach is lax and may obscure user error
    %
    % s = process()
    % returns a structure representing vararg. Proceesing is case
    % sensitive so Foo in varargs *will not* match foo in spec
    %    
    % s = processi()
    % returns a structure representing vararg. Proceesing is case
    % insensitive so Foo in varargs *will* match foo in spec
    %
    % Examples:
    %
    % No spec - not strict
    % p = Param({'foo', 123, 'bar', 'abc');
    % p.strict = false;
    % s = p.process
    % s = 
    %   foo: 123
    %   bar: 'abc'
    %
    %
    % No spec - strict by default
    % p = Param({'foo', 123, 'bar', 'abc'});
    % s = p.process
    % Error using engine.util.Param/processargs (line 212)
    % Argument: foo position 1 was not expected
    %
    %
    % With spec - not strict
    % p = Param({'Foo', 123, 'bar', 'abc'}, struct('foo', 456, 'bar', magic(3)), false);
    % or
    % p = Param({'Foo', 123, 'bar', 'abc'}, {'foo', 456, 'bar', magic(3)}, false);
    %
    % Case sensitive match means Foo != foo and both appear in the output.
    % This is not recommended as it can lead to subtle defects
    % s = p.process
    % s =
    %   foo: 456
    %   bar: 'abc'
    %   Foo: 123
    %
    % Case insensitive match means Foo == foo
    % s = p.processi
    % s =
    %   foo: 123
    %   bar: 'abc'
    %
    % Strict mode - varargs must match the specification
    % p = Param({'Foo', 123, 'bar', 'abc'}, {'foo', 456, 'bar', magic(3)});
    %
    % Case sensitive match means Foo != foo and we get an error
    % s = p.process
    % Error using engine.util.param.Param/processargs (line 198)
    % Argument: Foo position 1 was not expected
    %
    % Case insensitive match means Foo == foo
    % s = p.processi
    % s =
    %   foo: 123
    %   bar: 'abc'
    %
    properties
        varargin % varargin contains key-value parameters to be processed in a cell array. Default is empty.
        spec % spec defines the expected parameters as key value pairs. Values in spec that are  default parameters and values. Default is empty.
        strict % if true the keys in defaults defines the allowed parameters, additional args in vararg generates an error. Default is true.
        casesensitive % if true keys in defaults will be compared to keys in varargs case sensitively
        params % params is a struct containing processed arguments
    end
    
    properties (Access = private)
        cmp; % the compaator function strcmp or strcmpi
    end
    
    methods
        % General methods
        
        %% Constructor
        function [param] = Param(vararg, spec, strict)
            if ~exist('vararg', 'var')
                % if varargin is not supplied set it to an empty cell array
                param.varargin = {};
            else
                param.varargin = vararg;
            end
            
            if ~exist('spec', 'var')
                % spec defaults to an empty empty struct. This implies
                % strict = false. We don't enforce this as spec could be
                % supplied later
                param.spec = struct;
            else
                param.spec = spec;
            end
            
            if ~exist('strict', 'var')
                % strict defaults to true
                param.strict = true;
            else
                param.strict = strict;
            end
            
            % initialise params to an empty struct
            param.params = struct;
        end
        
        function [argstruct] = processi(param)
            %processsi Case insensitive conversion of varargs key-values to struct properties.
            % based on a previously supplied specification.
            param.casesensitive = false;
            argstruct = param.processargs(param.varargin, param.spec, param.strict, param.cmp);
        end
        
        function [argstruct] = process(param)
            %processsi Case insensitive conversion of varargs key-values to struct properties
            % based on a previously supplied specification.
            param.casesensitive = true;
            argstruct = param.processargs(param.varargin, param.spec, param.strict, param.cmp);
        end
        
        function [] = set.varargin(param, varargin)
            if ~iscell(varargin)
                error('setvarargin:NotACellArray', ...
                    'varargin was not a cell');
            end
            
            if (numel(varargin) == 1)
                if iscell(varargin{:})
                    param.varargin = varargin{:};
                else
                    error('setvarargin:NotACellArray', ...
                        'varargin was not a cell array or a nested cell array');
                end
            else
                param.varargin = varargin;
            end
            
            % The number of arguments mus be at least two
            nArgs = length(param.varargin);
            if rem(nArgs, 2) ~= 0
                error('setvarargin:NotKeyValuePairs', ...
                    'varargin was not composed of key-value pairs');
            end
        end
        
        function [] = set.spec(param, spec)
            if iscell(spec)
                % If defaults is a cell convert it to struct
                param.spec = struct(spec{:});
            else
                param.spec = spec;
            end
        end
        
        function [] = set.casesensitive(param, value)
            param.casesensitive = value;
            
            if value
                param.cmp = @strcmp;
            else
                param.cmp = @strcmpi;
            end
        end
    end
    
    methods (Access = private)
        function argStruct = processargs(param, vararg, spec, strict, comparator)
            nArgs = length(vararg);
            
            % copy over the defaults: by default, all arguments will have the default
            % value. Overwrite the defaults with any values in vararg.
            argStruct = spec;
            
            if strict && isempty(spec)
                % if strict and spec empty then no arguments allowed
                if nArgs > 0
                    error('processargs:InvalidState', ...
                        'Strict mode and empty spec requires an empty varargin');
                end
                
                % This is allowed but odd as Param is being used for a no
                % argument function
                % TODO log warning
                return;
            end
            
            % extract all default arguments names (useful for strict)
            optionNames = fieldnames(spec);
            
            % iterate over key-value pairs
            for i = 1:2:nArgs
                varname = vararg{i};
                
                if ~isvarname(varname)
                    % check that the supplied name is a valid variable identifier (it does
                    % not check if the variable is allowed/declared in defaults, just that
                    % it's a possible variable name!)
                    error('processargs:InvalidName', ...
                        'A variable name was not valid: %s position %i', varname, i);
                end
                
                if strict && ...  % if spec is strict
                        ~any(comparator(varname, optionNames)) % and varname not in spec
                    
                    % if options are restricted, check that the argument's name exists
                    % in the supplied defaults. With this we can restrict allowed
                    % arguments to those in specifed in the defaults.
                    error('processargs:UnexpectedArgument', ...
                        'Argument: %s position %i was not expected', varname, i);
                end
                
                if ~param.casesensitive
                    existing = optionNames(comparator(varname, optionNames));
                    
                    if ~isempty(existing)
                        argStruct.(char(existing)) = vararg{i + 1};
                        continue;
                    end
                end
                % Replace the default value for this argument with the user supplied
                % one or we create the variable if it wasn't in the defaults as the
                % restrict_flag was not set
                argStruct = setfield(argStruct, varname, vararg{i + 1});  %#ok<SFLD>
            end
        end
    end
end