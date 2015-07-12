function [] = disp_fields(confman, indent, prefix, obj)
    % print the supplied obj. Expect a simple type or structure
    % of simple types. This function is called recursively for
    % structures
    fields = fieldnames(obj);
    for fn = fields'
        key = fn{1};
        value = obj.(key);

        % Expand the conditional expression to support more types. 
        if isinteger(value)
            format = 'd';
        elseif isfloat(value)
            format = 'f';
        elseif isstruct(value)
            % recurse
            confman.disp_fields(indent, [prefix, '.', key], value);
            continue;
        else
            format = 's';
        end

        fprintf([indent, '%s.%s:\t\t''%', format, '''\n'], prefix, key, value);
    end
end