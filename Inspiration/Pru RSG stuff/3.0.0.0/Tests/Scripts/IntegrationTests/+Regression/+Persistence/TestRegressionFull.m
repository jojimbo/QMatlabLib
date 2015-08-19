function test_suite = TestRegressionFull()
    initTestSuite;
end

function Setup()
    addpath('/gpfs/matlab/x1201456/RC6/Source');
    import prursg.*;
    db = prursg.Db.DbFacade();
    db.clearTables();
end

function TestFileGenerationAndCompareToPrevious()
    scenarioSetIDs = PopulateDB();
        
    for ii = 1 : length(scenarioSetIDs)
        previousFileOutputs = '/gpfs/matlab/x1201456/2.6.2/';
        assert(exist(previousFileOutputs, 'dir') == 7, 'The previous output directory does not exist or has not been set');
        [valFilePath algoFilePath pruFilePath] = GenerateFiles(scenarioSetIDs{1,ii});
        [oldValFilePath oldAlgoFilePath oldPruFilePath] = GetDirectoriesToTest(previousFileOutputs, scenarioSetIDs{1,ii});
        files = cell(3,4);
        files{1,1} = dir(valFilePath);
        files{1,2} = dir(algoFilePath);        
        files{1,3} = dir(pruFilePath);
        files{2,1} = valFilePath;
        files{2,2} = algoFilePath;
        files{2,3} = pruFilePath;
        files{3,1} = oldValFilePath;
        files{3,2} = oldAlgoFilePath;
        files{3,3} = oldPruFilePath;
        
        % Loop through and compare all files
        for jj = 1 : length(files{1})
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
        end
    end
    
    if ~isempty(fileDeltas)
        fileDeltas = [fileDeltas 'Number of files with differences = ' num2str(deltasCount) '.'];
        fid  = fopen('deltas.txt','w');
        fprintf(fid, '%s', fileDeltas);
        fclose(fid);
        display(fileDeltas);
    end
                    
    assertTrue(isempty(fileDeltas), 'There are files that are not equal');
    
    function scenSetIDs = PopulateDB()
        scenSetIDs = cell(1,1);
        [userMsg scenSetIDs{1}] = RSGSimulate('base.xml');
        [UserMsg scenSetIDs{2}] = RSGSimulate('bigbang.xml');
        [UserMsg scenSetIDs{3}] = RSGSimulate('whatif_te0.xml');
        [UserMsg scenSetIDs{4}] = RSGSimulate('whatif_tg0.xml');
        [UserMsg scenSetIDs{5}] = RSGSimulate('bigbang_whatif_te0.xml');
        [UserMsg scenSetIDs{6}] = RSGSimulate('bigbang_whatif_tg0.xml');
        [UserMsg scenSetIDs{7}] = RSGRunCS('base.xml','csIds.csv',5,'Exponential',[]);
        [UserMsg scenSetIDs{8}] = RSGSimulate('sf.xml');
    end

    function [valFilePath algoFilePath pruFilePath] = GenerateFiles(scenarioSetName)
        [userMsg valFilePath] = RSGValidate(scenarioSetName);
        [userMsg algoFilePath] = RSGMakeAlgoFiles(scenarioSetName,'');
        [userMsg pruFilePath] = RSGMakePruFiles(scenarioSetName,'');
    end

    function [valFilePath algoFilePath pruFilePath] = GetDirectoriesToTest(previousOutputDirectory, scenarioSetName)
        valFilePath = fullfile(previousOutputDirectory, 'ValReports', scenarioSetName);
        algoFilePath = fullfile(previousOutputDirectory, 'AlgoFiles', scenarioSetName);
        pruFilePath = fullfile(previousOutputDirectory, 'PruFiles', scenarioSetName);
    end
end


