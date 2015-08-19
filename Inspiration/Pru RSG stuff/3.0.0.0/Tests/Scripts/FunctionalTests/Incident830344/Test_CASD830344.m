% These tests cover 830344(Consistent scenario values).
% Update the app.config file if necessary.

function test_suite = Test_CASD830344()
    initTestSuite;
    
    if ~exist('./Cache')
        mkdir('Cache');
    end
    
    if ~exist('./simResults')
        mkdir('simResults');
    end
    
    db = prursg.Db.DbFacade;
    db.clearTables();    
    
end

% Tests RSGCalibrate.
function TestRSGCalibrate()

    RSGCalibrate('base.xml');
    %1. confirm that base_enriched.xml file is created in the current
    %folder.
    %2. confirm that all values in the model_params have three significant
    %digits.
end

% Tests base simulation.
function TestRSGSimulateBase()
    [UserMsg ScenSetID] = RSGSimulate('base.xml')
    RSGMakePruFiles(ScenSetID, []);       
    RSGMakeAlgoFiles(ScenSetID, []);   
    
    %1. confirm that all files in the pru files and algo files folder
    %contain values with three significant digits.
    %2. generate risk watch scenario file based on the algo files
    %generated.
    %3. confirm that all values in the generated CSV file contain values
    %with three significant digits.
    %4. compare the deterministic values between pru files and algo files.

end

% Tests big bang simulation.
function TestRSGSimulateBigBang()

    [UserMsg ScenSetID] = RSGSimulate('bigbang.xml')
    RSGMakePruFiles(ScenSetID, []);       
    RSGMakeAlgoFiles(ScenSetID, []);    
    
    %1. confirm that all files in the pru files and algo files folder
    %contain values with three significant digits.

end


% Tests what if  simulation.
function TestRSGSimulateWhatIf()
    [UserMsg ScenSetID] = RSGSimulate('whatif.xml')
    RSGMakePruFiles(ScenSetID, []);       
    RSGMakeAlgoFiles(ScenSetID, []);    
    %1. confirm that all files in the pru files and algo files folder
    %contain values with three significant digits.
end

% Tests critical scenario simulation.
function TestRSGRunCS()

    inputXMLFileName = 'base.xml';
    inputARAReportFilename = 'csIds.csv';
    windowsSize = '5';
    smoothingRule = 'Exponential';
    shapeParameter = [];
    
    [UserMsg ScenSetID] = RSGRunCS(inputXMLFileName, inputARAReportFilename, windowsSize, smoothingRule, shapeParameter)
    
    RSGMakePruFiles(ScenSetID, []);       
    RSGMakeAlgoFiles(ScenSetID, []);    
    
    %1. confirm that all files in the pru files and algo files folder
    %contain values with three significant digits.

end

% Tests in memory base simulation.
function TestInMemoryBaseSimulation()
    [UserMsg ScenSetID] = RSGSimulate('base-in.xml')    
    
    %1. confirm that all files in the pru files and algo files folder
    %contain the same values as the ones created in the base simulation.
    %Ignore negative zero differences.
    
end

% Tests in memory UDS.
function TestInMemoryBigBang()
    [UserMsg ScenSetID] = RSGSimulate('bigbang-in.xml')    
    
    %1. confirm that all files in the pru files and algo files folder
    %contain the same values as the ones created in the base simulation.
    %Ignore negative zero differences.
end
