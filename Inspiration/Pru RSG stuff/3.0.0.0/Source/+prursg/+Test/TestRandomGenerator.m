function TestRandomGenerator()
    clc;
    clear;
    seed = 19;
    %stream = RandStream.create('mt19937ar','seed', seed);
    %rand(stream, 10, 1)    
    disp(seed);   
    changeSeed();
    function changeSeed()
        seed = 44;
    end
    disp(seed);
end

