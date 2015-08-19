function TestHyperCubeFlattening()
    clear;
    clc;
    import prursg.Engine.*;
    tests = [ {[]}, {15}, { [ 1 2] },{ [ 1; 2] }, {magic(3)}, {rand(2,2,3)}, {rand(3, 2, 4, 2)}];
    %tests = { rand(2,2,2) };
    %tests = { rand(10,10,10,10, 10) };
    %tests = { [ 15 12]};
    for i = 1:numel(tests)
        v = tests{i};
        out1 = HyperCube.serialise(v, 2);
        out2 = HyperCube.serialise(v, 1);
        assert(isequal(out1, out2));
        v2 = HyperCube.deserialiseInCube(v .*2, out1);
        v3 = HyperCube.deserialiseInCube(v .*2, out2);
        assert(isequal(v, v2));
        assert(isequal(v3, v2));        
    end    
    
    matrix2d = tests(3:5);
    for i = 1:numel(matrix2d)
        assert(isequal(HyperCube.serialise(matrix2d{i}), HyperCube.serialise2d(matrix2d{i})));
    end
    
end

