function [] = buildProxy(confman, data)
    % buildProxy adds fields to the class instance
    %   buildProxy(data) transfer fields from the input structure to
    %   the confman instance. All existing dynamic properties are removed.
    %
    %   See also loadjson.
    for k = 1:length(confman.dynProps)
        delete(confman.dynProps{k});
    end

    confman.dynProps = {};

    fields = fieldnames(data);
    for fn = fields'
        % fn is a 1 by 1 array so must index into it
        prop = fn{1};

        confman.dynProps{end + 1} = confman.addprop(prop);
        confman.(prop) = data.(prop);
    end
end