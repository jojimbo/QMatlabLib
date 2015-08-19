function TestAxis()
% why isequal on instances of Axis class does not work?
    clear;
    clc;

    % contents of these 2 files have been serialized from database
    a = load('axes1.mat');
    b = load('axes2.mat');
    a = a.axes1;
    b = b.axes2;
    assert(prursg.Engine.Axis.areEqual(a, b));
    assert(~isequal(a, b));
    a = a(1);
    b = b(1);
    assert(~isequal(a, b))
    assert(a.areEqual(a, b));
    
    testOtherAxis();
end

function testOtherAxis()
    a = prursg.Engine.Axis('duda', 1:10);
    b = prursg.Engine.Axis('duda', 1:10);
    c = prursg.Engine.Axis('dud', 1:10);
    d = prursg.Engine.Axis('dud', 1:2);    
    assert(check(a, b));
    assert(check(b, a));
    assert(~check(b, c));
    assert(~check(d, c));
    
    assert(check([a, a], [b, b]));
    assert(check([a; a], [b; b]));
    assert(prursg.Engine.Axis.areEqual([], []));
        
end

function yesNo = check(a, b)
    yesNo = isequal(a, b) && a.areEqual(a, b) && isequal(b, a) && b.areEqual(b, a);
end
