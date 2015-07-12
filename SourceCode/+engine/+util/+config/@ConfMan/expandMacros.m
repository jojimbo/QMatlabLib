function [expanded] = expandMacros(confman, obj, valid_keys)
    % expandMacros search for macros in the property values and replace
    %   them with values from corrsponding properties
    %
    %   Replace all instances of \{[a-zA-Z]+\} in the input string
    %   value = "some text {foo} more text {bar}" with the value of a
    %   property e.g. {foo} will be replaced with the value returned by
    %   confman.foo. A exception will be raised if there is no such
    %   property
    %
    %   See also loadjson.

    % assume for the moment that a value will contain at most one macro
    pattern = '\{.*\}';

    fields = fieldnames(valid_keys);
    expanded = obj;

    for fn = fields'
        % fn is a 1 by 1 array so must index into it
        value = expanded.(fn{1}); % for each property value
        if isstruct(value)
            % recurse
            expanded.(fn{1}) = confman.expandMacros(value, value);
            continue;
        elseif ~ischar(value)
            % Can only expand macros in strings
            continue;
        end

        macro = regexp(value, pattern, 'match'); % search for macros
        if ~isempty(macro) % value contains {.*}
            % extract the property name
            property = macro{:}(2:end-1);
            % replace with property value
            expanded.(fn{1}) = char(strrep(value, macro, confman.(property)));
        else
            % disp(['No macros in ', value]);
        end
    end
end
