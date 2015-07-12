%% RUN P19 UNIT TESTS
% INITIALIZE
function runUT_P19

    stsRootPath = which('STS_CM.m');

    if isempty(stsRootPath)
        disp('STS-IM is currently not on MATLAB Path!');
        return
    end

    currentDir = [fileparts(stsRootPath) filesep 'UnitTests' filesep];
    csvFile    = [currentDir, 'Results', filesep, 'Report_UnitTest19_' date '.txt'];

    %diary(csvFile);
    codePath   = [fileparts(stsRootPath) filesep];
    disp(['The path of the code is: ' codePath]);

    p = 0;
    f = 0;

    %% P19_1
    testPath = [currentDir 'P19_1' filesep];
    cd(testPath);

    if Unit_Test_P19_1(testPath, codePath)
        disp('################# P19-1 Passed #################');
        b1 = true;
        p = p + 1;
    else
        disp('################# P19-1 Failed #################');
        b1 = false;
        f = f + 1;
    end


    %% P19_2
    testPath = [currentDir 'P19_2' filesep];
    cd(testPath);

    if Unit_Test_P19_2(testPath, codePath)
        disp('################# P19-2 Passed #################');
        b2 = true;
        p = p + 1;
    else
        disp('################# P19-2 Failed #################');
        b2 = false;
        f = f + 1;
    end


    %% P19_3
    testPath = [currentDir 'P19_3' filesep];
    cd(testPath);

    if Unit_Test_P19_3(testPath, codePath)
        disp('################# P19-3 Passed #################');
        b3 = true;
        p = p + 1;
    else
        disp('################# P19-3 Failed #################');
        b3 = false;
        f = f + 1;
    end


    %% P19_4
    testPath = [currentDir 'P19_4' filesep];
    cd(testPath);

    if Unit_Test_P19_4(testPath, codePath)
        disp('################# P19-4 Passed #################');
        b4 = true;
        p = p + 1;
    else
        disp('################# P19-4 Failed #################');
        b4 = false;
        f = f + 1;
    end


    %% P19_5
    testPath = [currentDir 'P19_5' filesep];
    cd(testPath);

    if Unit_Test_P19_5(testPath, codePath)
        disp('################# P19-5 Passed #################');
        b5 = true;
        p = p + 1;
    else
        disp('################# P19-5 Failed #################');
        b5 = false;
        f = f + 1;
    end


    %% P19_6
    testPath = [currentDir 'P19_6' filesep];
    cd(testPath);

    if Unit_Test_P19_6(testPath, codePath)
        disp('################# P19-6 Passed #################');
        b6 = true;
        p = p + 1;
    else
        disp('################# P19-6 Failed #################');
        b6 = false;
        f = f + 1;
    end


    %% P19_7
    testPath = [currentDir 'P19_7' filesep];
    cd(testPath);

    if Unit_Test_P19_7(testPath, codePath)
        disp('################# P19-7 Passed #################');
        b7 = true;
        p = p + 1;
    else
        disp('################# P19-7 Failed #################');
        b7 = false;
        f = f + 1;
    end


    %% SUMMARY
    disp(' ');
    disp(' ');
    disp(' ');

    if b1 && b2 && b3 && b4 && b5 && b6 && b7
        disp('################# Total score: Passed #################');
    else
        disp('################# Total score: Failed #################');
    end

    disp(' ');
    str = [num2str(p) ' passed, and ' num2str(f) ' failed.'];

    disp(str);
    disp(' ');
    disp('#######################################################');

    cd(codePath);
    %diary('off');
end