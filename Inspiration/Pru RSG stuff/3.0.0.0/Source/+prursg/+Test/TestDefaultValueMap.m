function TestDefaultValueMap()
    clc;
    clear;
    resolver = prursg.Engine.DefaultValueMap();
    resolver('dida') = 'biba';
    assert(isequal('biba', resolver('dida')));
    assert(isequal([], resolver('alabala')));
end

