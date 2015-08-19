function TestPassByReference()
    clear;
    clc;
    ref = prursg.Engine.PassByReference(ones(3));
    makeBigChanges(ref);
    assert(isequal(ref.data, magic(length(ref.data))));
end


function makeBigChanges(ref)
    m = magic(length(ref.data));
    for i = 1:size(ref.data, 1)
        for j = 1:size(ref.data, 2)
            ref.data(i, j) = m(i, j);
        end
    end
end
