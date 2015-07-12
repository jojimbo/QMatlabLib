%% RUN P20 UNIT TESTS
% INITIALIZE

function runUT_P20

    stsRootPath = which('STS_CM.m');

    if isempty(stsRootPath)
        disp('STS-IM is currently not on MATLAB Path!');
        return
    end

    currentDir = [fileparts(stsRootPath) filesep 'UnitTests' filesep];
    csvFile    = [currentDir, 'Results', filesep, 'Report_UnitTest20_' date '.txt'];

    %diary(csvFile);
    codePath   = [fileparts(stsRootPath) filesep];
    disp(['The path of the code is: ' codePath]);

    p = 0;
    f = 0;


    %% Test Inclusion Flags
    doP20_1 = true;
    doP20_2 = true;
    doP20_3 = true;
    doP20_4 = true;
    doP20_5 = true;
    doP20_7 = true;


    %% P20_1
    %#ok<*UNRCH>
    testPath = [currentDir 'P20_1' filesep];
    cd(testPath);

    if doP20_1
        % Include Test
        if Unit_Test_P20_1(testPath, codePath)
            disp('################# P20-1 Passed #################');
            b1 = true;
            p = p + 1;
        else
            disp('################# P20-1 Failed #################');
            b1 = false;
            f = f + 1;
        end
    else
        % Pass Test
        b1 = true;
    end


    %% P20_2
    testPath = [currentDir 'P20_2' filesep];
    cd(testPath);

    if doP20_2
        % Include Test
        if Unit_Test_P20_2(testPath, codePath)
            disp('################# P20-2 Passed #################');
            b2 = true;
            p = p + 1;
        else
            disp('################# P20-2 Failed #################');
            b2 = false;
            f = f + 1;
        end
    else
        % Pass Test
        b2 = true;
    end


    %% P20_3
    testPath = [currentDir 'P20_3' filesep];
    cd(testPath);

    if doP20_3
        if Unit_Test_P20_3(testPath, codePath)
            disp('################# P20-3 Passed #################');
            b3 = true;
            p = p + 1;
        else
            disp('################# P20-3 Failed #################');
            b3 = false;
            f = f + 1;
        end
    else
        % Pass Test
        b3 = true;
    end


    %% P20_4
    testPath = [currentDir 'P20_4' filesep];
    cd(testPath);

    if doP20_4
        if Unit_Test_P20_4(testPath, codePath)
            disp('################# P20-4 Passed #################');
            b4 = true;
            p = p + 1;
        else
            disp('################# P20-4 Failed #################');
            b4 = false;
            f = f + 1;
        end
    else
        % Pass Test
        b4 = true;
    end


    %% P20_5
    testPath = [currentDir 'P20_5' filesep];
    cd(testPath);

    if doP20_5
        if Unit_Test_P20_5(testPath, codePath)
            disp('################# P20-5 Passed #################');
            b5 = true;
            p = p + 1;
        else
            disp('################# P20-5 Failed #################');
            b5 = false;
            f = f + 1;
        end
    else
        % Pass Test
        b5 = true;
    end


    %% P20_7
    testPath = [currentDir 'P20_7' filesep];
    cd(testPath);

    if doP20_7
        if Unit_Test_P20_7(testPath, codePath)
            disp('################# P20-7 Passed #################');
            b7 = true;
            p = p + 1;
        else
            disp('################# P20-7 Failed #################');
            b7 = false;
            f = f + 1;
        end
    else
        % Pass Test
        b7 = true;
    end


    %% SUMMARY
    disp(' ');
    disp(' ');
    disp(' ');

    if b1 && b2 && b3 && b4 && b5 && b7
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