function test_suite = Test_QC3184()
    initTestSuite;
end

function [inParm] = Setup()
    appConf = xmlread('app.config');
    appSettings = ReadAppSettings(appConf.getElementsByTagName('appSettings').item(0));
    rsgRoot = fullfile(appSettings('RSGRoot'));
    inParm.previousFileOutputs = fullfile(appSettings('PreviousFileOutputs'));

    disp(rsgRoot);
    disp(inParm.previousFileOutputs);
    addpath(rsgRoot);
    import prursg.*;
    disp('Clearing down database');
    inParm.db = prursg.Db.DbFacade();
    inParm.db.clearTables();
    disp('Database has been cleared down successfully');
end


function teardown(inParm)
    inParm.db.dao.close();
end


function TestFix(inParm)
    tic;
    scenarioSetIDs = ExecuteScenarios();
    fileDeltas = [];
    deltasCount = 0;
    
    assert(exist(inParm.previousFileOutputs, 'dir') == 7, 'The previous output directory does not exist or has not been set');
    
    for ii = 1 : length(scenarioSetIDs)
        [valFilePath algoFilePath algoScenarioFilePath pruFilePath] = GenerateFiles(scenarioSetIDs{1,ii});
        [oldValFilePath oldAlgoFilePath oldAlgoScenarioFilePath oldPruFilePath] = GetDirectoriesToTest(inParm.previousFileOutputs, scenarioSetIDs{1,ii});
        files = cell(3,4);
        files{1,1} = dir(algoFilePath);
        files{1,2} = dir(pruFilePath);
        files{1,3} = dir(valFilePath);
        files{1,4} = dir(algoScenarioFilePath);
        files{2,1} = algoFilePath;
        files{2,2} = pruFilePath;
        files{2,3} = valFilePath;
        files{2,4} = algoScenarioFilePath;
        files{3,1} = oldAlgoFilePath;
        files{3,2} = oldPruFilePath;
        files{3,3} = oldValFilePath;
        files{3,4} = oldAlgoScenarioFilePath;     
        
        
        % Loop through and compare all files
        %for jj = 1 : length(files{1})
        jj = 1;
            for k = 1 : length(files{1,jj})
                if ~files{1,jj}(k).isdir
                    currentFile = javaObject('java.io.File', fullfile(files{2,jj}, files{1,jj}(k).name));
                    previousFile = javaObject('java.io.File', fullfile(files{3,jj}, files{1,jj}(k).name));
                    is_equal = javaMethod('contentEquals', 'org.apache.commons.io.FileUtils', currentFile, previousFile);
                    
                    if ~is_equal
                        fileDeltas = [fileDeltas 'File: ' fullfile(files{2,jj}, files{1,jj}(k).name) char(10) ...
                            ' differs from: ' fullfile(files{3,jj}, files{1,jj}(k).name)  char(10)];
                        deltasCount = deltasCount + 1;
                    end
                end
            end
        %end
        
        toc;
        
    end
    
    
    function scenSetIDs = ExecuteScenarios()
        scenSetIDs = cell(1,1);

        RSGSimulate('R260_YE10_BBB.xml');
        [UserMsg scenSetIDs{1}] = RSGSimulate('R260_YE10_BBWI.xml');

        RSGSimulate('R260_YE11_BBB.xml');
        [UserMsg scenSetIDs{2}] = RSGSimulate('R260_YE11_BBWI.xml');    
    end
    
    function [valFilePath algoFilePath algoScenarioFilePath pruFilePath] = GenerateFiles(scenarioSetName)
        [userMsg valFilePath] = RSGValidate(scenarioSetName);
        [userMsg algoFilePath] = RSGMakeAlgoFiles(scenarioSetName,'');
        [userMsg algoScenarioFilePath] = RSGMakeAlgoScenarioFile(scenarioSetName);
        [userMsg pruFilePath] = RSGMakePruFiles(scenarioSetName,'');
    end

    function [valFilePath algoFilePath algoScenarioFilePath pruFilePath] = GetDirectoriesToTest(previousOutputDirectory, scenarioSetName)
        valFilePath = fullfile(previousOutputDirectory, 'ValReports', scenarioSetName);
        algoFilePath = fullfile(previousOutputDirectory, 'AlgoFiles', scenarioSetName);
        algoScenarioFilePath = fullfile(previousOutputDirectory, 'AlgoScenarioFiles', scenarioSetName);
        pruFilePath = fullfile(previousOutputDirectory, 'PruFiles', scenarioSetName);
    end

    
end


