function TestSerialisedHyperCubeImport()
    clc;
    clear;

    runTests(true);
    runTests(false);
        
end

function runTests(enableJava)
    prursg.Xml.configureJava(enableJava);    
    testSwaptionVola('serial-3d-cube.xml');
    testNyc('serial-1d-cube.xml');
    testStockIndex('serial-0d-cube1.xml');
end

function testSwaptionVola(fileName)
    [axis cube] = testImport(fileName);
    assert(numel(axis) == 3);
    assert(ndims(cube) == 3);
    assert(isequal(axis(1).values, 100));
    assert(isequal(axis(2).values, [ 5 10 20]));
    assert(isequal(axis(3).values, [ 10 20 30]));    
    assert(cube(1, 1, 2) == 0.1940);
    assert(cube(1, 2, 1) == 0.18);
    assert(cube(1, 3, 3) == 0.137);
end

function testNyc(fileName)
    [axis cube] = testImport(fileName);
    assert(numel(axis) == 1);
    assert(size(cube, 1) == 90);
    assert(size(cube, 2) == 1);
    
    assert(isequal(axis(1).values, 1:90));
    assert(strcmp(axis(1).title, 'term'));
    assert(cube(1) == 1.03253206390773E-02);
    assert(cube(10) == 4.81083854647603E-02);
    assert(cube(90) == 4.19991281134348E-02);
end

function testStockIndex(fileName)
    [axis cube] = testImport(fileName);
    assert(numel(axis) == 0);
    assert(cube == 5000);
end

function [axes cube] = testImport(fileName)
    fileName = fullfile('+prursg', '+Test', '+Xml', fileName);
    dom = xmlread(fileName);
    riskTag = dom.getFirstChild();
    [axes cube] = prursg.Xml.SerialisedHyperCubeDao.read(riskTag);
    nDims = max(numel(axes), 2); % there is no 1d in matlab. everything is 2d
    assert(ndims(cube) == nDims);     
    %cube structure
    for i = 1:numel(axes)
        dim = size(cube, i);
        adim = numel(axes(i).values);
        assert(dim == adim);
    end
end