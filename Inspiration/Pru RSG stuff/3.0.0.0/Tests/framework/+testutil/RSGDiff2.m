classdef RSGDiff2
    methods(Static)
        
        % Compare the output from a test to a baseline. Both directories
        % are expected to contain AlgoFiles, PruFiles and ValReports
        % directories. The parent folder of these file types is expected to
        % be derived from the specified scenarioSetId.
        % This method is a convenience wrapper for CompareTestOutputDirs
        function CompareFiles(pathToOutput, scenarioSetId, pathToBaseline)
            import testutil.*;
            fprintf('CompareFiles() called\n');
            fprintf('This method is deprecated. Call CompareTestOutputDirs instead!');
            
            % Compare the baseline folder to the generated output
            RSGDiff2.CompareTestOutputDirs(pathToBaseline, scenarioSetId, pathToOutput, scenarioSetId);
        end
        
        % Compare the output from a test to a baseline. See CompareTestOutput
        function CompareDirs(basePath, baseScenId, testPath, testScenId)
            import testutil.*;
            fprintf('CompareDirs() called\n');
            fprintf('This method is deprecated. Call CompareTestOutputDirs instead!');
            
            % Compare the baseline folder to the generated output
            RSGDiff2.CompareTestOutputDirs(basePath, baseScenId, testPath, testScenId);
        end
        
        % Compare the output from a test to a baseline. See CompareTestOutput
        function CompareTestOutputDirs(basePath, baseScenId, testPath, testScenId)
            import testutil.*;
            fprintf('CompareTestOutputDirs() called\n');
            
            % Compare the baseline folder to the generated output
            RSGDiff2.CompareTestOutput(basePath, baseScenId, testPath, testScenId);
        end
    end
    
    
    %%%
    %% Private methods & data
    %%%
    properties(Constant)
        outputRoot=fullfile(pwd, 'test_tmp_dir');
        formatString = '%.9g';
    end
    
    methods(Static, Access=private)
        
        % Compare the output from a test to a baseline. Both directories
        % are expected to contain AlgoFiles, PruFiles and ValReports
        % directories. The parent folders of these file types are expected
        % to be derived from the specified scenarios ids.
        % The scenario IDs have illegal path characters replaced with
        % underscore before being added to theit respective paths.
        function CompareTestOutput(basePath, baseScenId, testPath, testScenId)
            import testutil.*;
            % If the scenario set id contains any colons, replace them with
            % underscore characters to get the correct output folder
            baseScenId = prursg.Util.FileUtil.FormatFolderName(baseScenId);
            testScenId = prursg.Util.FileUtil.FormatFolderName(testScenId);
            
            % Currently we produce file for RiskWatch, Aggregator and
            % Validation reports
            baselineFolders = {'AlgoFiles', 'PruFiles', 'ValReports'};
            failures = {};
            
            for i = 1:length(baselineFolders)
                folder = baselineFolders{i};
                try
                    fprintf('Examining %s files...\n\n', folder);
                    RSGDiff2.CompareDirContents(...
                        fullfile(basePath, folder, baseScenId),...
                        fullfile(testPath, folder, testScenId));
                    fprintf('Completed examination of %s files...\n\n', folder);
                catch e
                    % Catch the exception, report the failure
                    % Process the remaining file sets
                    failures = [failures ; folder ]; %#ok<AGROW>
                    fprintf('==============================================\n');
                    fprintf('Error: While comparing %s outputs.\n%s\n',...
                        folder, getReport(e));
                    fprintf('Error: Skip to next file set if applicable.\n');
                    fprintf('==============================================\n\n');
                end
            end
            
            if isempty(failures)
                fprintf('There were no failures examining the file sets!\n');
            else
                fprintf('==============================================\n');
                fprintf('Error: The following file sets did NOT compare equal:\n');
                fprintf('==============================================\n');
                for j = 1:length(failures)
                    fprintf('%s\n', failures{j});
                end
                fprintf('==============================================\n');
            end
            fprintf('\nCompareDirs() completed\n\n');
            % If there was a failure and then fail the whole test
            assertTrue(isempty(failures), 'The test has failed.');
        end
        
        % Compare the contents of two directories.
        % Note, files that do not appear in basePath will not be
        % compared.
        % Any files with a .flipped extension are ignored as they will be
        % the output of an earlier test run where the output from two tests
        % are being compared
        % The method will assert on error or if any files do not match.
        % in:
        %   basePath, A fully qualified path to the reference directory.
        % in:
        %   testPath, A fully qualified path to the files under test.
        function CompareDirContents(basePath, testPath)
            import testutil.*;
            % Track which comparisons fail for summary logging
            % Keys must be uniqiue but then so are the names of items in a
            % directory
            passes = containers.Map();
            failures = containers.Map();
            
            % Show which folders we are comparing
            fprintf('Comparing baseline:\n"%s"\nto:\n"%s"\n\n',...
                basePath, testPath);
            
            %%
            %% Perform some early checks
            %%
            
            % Check the folders exist
            assertTrue(exist(basePath, 'dir') ~= 0,...
                'The baseline folder does not exist.');
            
            % Check the folders exist
            assertTrue(exist(testPath, 'dir') ~= 0,...
                'The test folder does not exist.');
            
            % Grab a list of the baseline files
            baseFileList = TestUtil.GetFilesFromDirectory(basePath);
            testFileList = TestUtil.GetFilesFromDirectory(testPath);
            
            % Check if there are any files in the baseline folder
            assertFalse(isempty(baseFileList),...
                'The baseline folder is empty. No files to compare.');
            % Check if there are any files in the baseline folder
            assertFalse(isempty(testFileList),...
                'The test folder is empty. No files to compare.');
            
            % The two way comparison is inefficient and generates suprious
            % errors as we generate e.g. flipped files. Instead check that each
            % folder has the same number of files.
            fileCountsMatch = numel(baseFileList) == numel(testFileList);
            if (~fileCountsMatch)
                fprintf('Error: The baseline and test directories contain a different number of files\n');
                fprintf('Will continue with the comparison but this will cause a failure\n');
            end
            
            %%
            %% Perform the comparison
            %%
            
            % Compare each file in the baseline with the respective file in the
            % test folder.
            for y = 1:length(baseFileList)
                filename = baseFileList{y};
                fprintf('Processing file: "%s"\n', filename);
                
                baseFilePath = fullfile(basePath, filename);
                testFilePath = fullfile(testPath, filename);
                
                % Make sure that the test file exists. We assume base files
                % do as we've got the names from the filesystem
                if (exist(testFilePath, 'file') ~= 2)
                    failures(baseFilePath) = (testFilePath);
                    fprintf('File does not exist! %s\n', testFilePath);
                    continue; % compare as many files as possible
                end
                
                fprintf('Comparing base file:\n"%s"\nto:\n"%s"\n\n',...
                    baseFilePath, testFilePath);
                
                % Compare the files.
                result = RSGDiff2.Compare(baseFilePath, testFilePath);
                
                if (result)
                    passes(baseFilePath) = (testFilePath);
                else
                    failures(baseFilePath) = (testFilePath);
                end
            end
            
            fprintf('==============================================\n');
            fprintf('Comparison START\n');
            fprintf('==============================================\n\n');
            
            if isempty(passes)
                fprintf('There were no passes!\n');
            else
                fprintf('==============================================\n');
                fprintf('The following files compared equal:\n');
                fprintf('==============================================\n');
                % Produce a summary log
                kp = keys(passes);
                vp = values(passes);
                
                for i = 1:numel(kp)
                    fprintf('PASS:A\t"%s"\n', kp{i});
                    fprintf('PASS:B\t"%s"\n', vp{i});
                end
                fprintf('\n');
            end
            
            if isempty(failures)
                fprintf('There were no failures!\n');
            else
                fprintf('==============================================\n');
                fprintf('Error: The following files did NOT compare equal:\n');
                fprintf('==============================================\n');
                
                kf = keys(failures);
                vf = values(failures);
                for j = 1:numel(kf)
                    fprintf('FAIL:A\t"%s"\n', kf{j});
                    fprintf('FAIL:B\t"%s"\n', vf{j});
                end
                fprintf('\n');
            end
            
            fprintf('==============================================\n');
            fprintf('Comparison END\n');
            fprintf('==============================================\n\n');
            
            % If there was a failure and then fail the whole test
            assertTrue(isempty(failures),...
                'Differences were found. The comparison has failed.');
            assertTrue(fileCountsMatch,...
                'The baseline and test directories contain a different number of files');
        end
        
        % Compare the two files. Process and recompare them once if the
        % comparison fails
        function result = Compare(baseFilePath, testFilePath)
            import testutil.*;
            
            result = RSGDiff2.areFilesEqual(baseFilePath, testFilePath);
            
            if ~result
                fprintf('The compare failed. Will attempt to process the files and retry\n');
                processedTestFile = RSGDiff2.processFile(testFilePath);
                processedBaseFile = RSGDiff2.processFile(baseFilePath);
                result = RSGDiff2.areFilesEqual(processedBaseFile, processedTestFile);
            end
        end
        
        % XUnit's assertFilesEqual performs a block compare. This methods
        % returns true if the files identical byte for byte
        function result = areFilesEqual(baseFilePath, testFilePath)
            import testutil.*;
            fprintf('Asserting base file:\n"%s"\nis equal to:\n"%s"\n\n',...
                baseFilePath, testFilePath);
            
            [~, filename, ~] = fileparts(testFilePath);
            
            % Compare the files.
            try
                % Try to compare the files
                assertFilesEqual(baseFilePath, testFilePath,...
                    ['File: ' filename ' is not identical to the baseline']);
                fprintf('File: "%s" is identical to the baseline\n\n', filename);
                result = true;
            catch e
                % Catch the exception, report the failure
                % Leave it up to the caller to decide how to proceed
                fprintf('Error: File: "%s" is not identical to the baseline\n%1\n',...
                    filename, getReport(e));
                
                result = false;
            end
        end
        
        %%
        %% File processing. We have three issues:
        %% -    line endings i.e. \r\n vs \n
        %% -    binary files
        %% -    Microsoft XLS files
        
        % Perform benign transformations to assist comparison
        function path = processFile(filePath)
            import testutil.*;
            [~, name, ext] = fileparts(filePath);
            fprintf('Attempting to transform %s\n', filePath);
            
            % Create the files in a local directory to avoid polluting
            % either the baseline or test results
            targetDir = fullfile(RSGDiff2.outputRoot, filePath);
            RSGDiff2.createDir(targetDir);
            targetFilePath = fullfile(targetDir, [name ext]);
            
            switch ext
                case '.bin'
                    path = RSGDiff2.Bin2CSV(filePath, targetFilePath);
                case '.xls'
                    path = RSGDiff2.XLS2CSV(filePath, targetFilePath);
                otherwise
                    path = RSGDiff2.FlipFile(filePath, targetFilePath);
            end
        end
        
        % Create a directory. Delete an directory if it already exsists.
        function targetDir = createDir(targetDir)
            import testutil.*;
            
            if exist(targetDir, 'dir') == 7
                rmdir(targetDir, 's');
            end
            
            if ~mkdir(targetDir)
                fprintf('Error: Could not create folder %s', targetDir);
                throw(MException('Could not create directory'))
            end
            
            if ~(exist(targetDir, 'dir') == 7)
                fprintf('Failed to create %s', targetDir);
                throw(MException('Could not create directory'));
            end
        end
        
        %%
        %% White space conversion - todo compress all white space to one space
        %%
        
        % Convert source line endings to '\n'
        function flippedFile = FlipFile(source, targetFilePath)
            import testutil.*;
            
            [~, ~, ext] = fileparts(source);
            if strcmpi(ext, '.bin') || strcmpi(ext, '.xls')
                % refuse to flip binary file
                fprintf('Error: File is a binary file\n');
                throw(MExecption('RSGDiff2:FlipFile:NotSupported',...
                    'Not flipping a binary file'));
            end
            
            fprintf('Flipping line endings in %s\n', source);
                       
            flippedFile = [targetFilePath '.flipped'];
            
            macros = containers.Map(); % Empty
            TestUtil.file_strrep(macros, source, flippedFile)
            
            % Check the file is non-empty
            fileInfo = dir(flippedFile);
            assertTrue(fileInfo.bytes >  0);
            
            fprintf('Flipped file can be found here %s\n', flippedFile);
        end
        
        %%
        %% Binary file conversion
        %%
        
        % Convert an Algo binary to CSV format. The dimensions are not
        % 'correct' but the objective is merely to automate the conversion
        % process to aid analysis - typically examining precision
        % differences
        function csvFile = Bin2CSV(file, targetFilePath)
            import testutil.*;
            fprintf('Converting binary file to CSV\n');
            csvFile = [targetFilePath '.csv'];
            fid = 0;
            try
                % read the binary file into am vector
                fid = fopen(file);
                binVec = fread(fid, 'double');
                fclose(fid);
            catch e
                fprintf('Caught an exception while attempting to read the binary file\n %s',...
                    getReport(e));
                if fid
                    fclose(fid);
                end
            end
            % reshape the vector into an m*n matrix
            len = numel(binVec);
            f1 = max(factor(len)); % find largest prime factor
            f2 = len/f1;
            sz = sort([f1, f2], 'descend'); % prefer more rows then columns
            binMat = reshape(binVec, sz);
            
            % write the matrix as a CSV file
            csvwrite(csvFile, binMat);
            
            % Check the file is non-empty
            fileInfo = dir(csvFile);
            assertTrue(fileInfo.bytes >  0);
            
            fprintf('The CSV file can be found here %s\n', csvFile);
        end
        
        %%
        %% XLS File conversion
        %%
        
        % Convert an Microsoft XLS file to CSV format. The objective is
        % merely to automate the conversion process to aid analysis -
        % typically examining precision differences
        %
        % We assume we are converting XLS files produced by the RSG i.e.
        % file containing data only
        function csvFile = XLS2CSV(file, targetFilePath)
            import testutil.*;
            
            fprintf('Converting XLS file to CSV\n');
            csvFile = [targetFilePath '.csv'];
                      
            RSGDiff2.extractSheets(file, csvFile);
            fprintf('The CSV file can be found here %s\n', csvFile);
        end
        
        % Iterate over each sheet. Return an array of file names named
        % according to the sheet they represent.
        % Output the combined contents of all sheets to a CSV file in filePath
        % with name fileName.csv
        function extractSheets(file, csvFile)
            import testutil.*;
            fid = 0;
            try
                import java.io.FileInputStream;
                import org.apache.poi.ss.usermodel.WorkbookFactory;
                import org.apache.poi.ss.usermodel.Workbook;
                
                in = FileInputStream(file);
                wb = WorkbookFactory.create(in);
                
                fid = fopen(csvFile, 'w');
                
                for i = 0:(wb.getNumberOfSheets - 1)
                    sheet = wb.getSheetAt(i);
                    sheetName = char(sheet.getSheetName());
                    sheetData = RSGDiff2.readSheet(sheet);
                   
                    fprintf(fid, 'Start sheet: %s\n', sheetName);
                    % All cells contains strings
                    for z=1:size(sheetData, 1)
                        for s=1:size(sheetData, 2)
                            var = eval(['sheetData{z,s}']);
                            if size(var, 1) == 0
                                % Empty cell
                                var = '';
                            end
                            % Remove leading and trailing whitespace
                            % and emclose in quotes
                            var = ['"' strtrim(var) '"' ];
                        
                            fprintf(fid, '%s,', var);
                        end
                        
                        fprintf(fid, '\n');                        
                    end
                    
                    fprintf(fid, 'End sheet: %s\n', sheetName);
                end
            catch e
                fprintf('\nError: Caught an exception whilst converting XLS to CSV: \n%s\n',...
                    getReport(e));
            end
            
            if fid
                fclose(fid);
            end
        end
        
        % Read the XLS sheet from the workbook
        % in:
        %   workbook, The book containing the sheet
        % in:
        %   sheet, The sheet from which to read data
        % out:
        %   data, An N*M matrix or an exception on error
        function data = readSheet(sheet)
            import testutil.*;
            
            data = {};
            fprintf('\nProcessing sheet: "%s"\n', char(sheet.getSheetName()));
            rows = sheet.rowIterator();
            while rows.hasNext()
                row = rows.next();
                rowNum = double(row.getRowNum);
                fprintf('Row: %s: ', num2str(rowNum)); % progress feedback
                cells = row.cellIterator();
                
                fprintf('Cells: ');
                while cells.hasNext()
                    cell = cells.next();
                    cellNum = double(cell.getColumnIndex());
                    fprintf('%s,', num2str(cellNum)); % progress feedback
                    
                    value = RSGDiff2.parseCell(cell);
                    data{rowNum + 1, cellNum + 1} = value; % rows and cols are zero based
                end
                
                fprintf('\n');
            end
        end
        
        % Get the cell type as string
        function str = parseCell(cell)
            switch cell.getCellType
                case cell.CELL_TYPE_STRING
                    str = char(cell.getRichStringCellValue().getString());
                case cell.CELL_TYPE_NUMERIC
                    import org.apache.poi.ss.usermodel.DateUtil;
                    if DateUtil.isCellDateFormatted(cell)
                        str = char(cell.getDateCellValue().toString());
                    else
                        import java.lang.Double;
                        str = char(Double.toString(cell.getNumericCellValue()));
                    end
                case cell.CELL_TYPE_BLANK
                    str = 'CELL_TYPE_BLANK';
                case cell.CELL_TYPE_FORMULA
                    % cell.getCellFormula()
                    str = 'CELL_TYPE_FORMULA';
                case cell.CELL_TYPE_BOOLEAN
                    str = char(Boolean.toString(cell.getBooleanCellValue()));
                case cell.CELL_TYPE_ERROR
                    str = 'CELL_TYPE_ERROR';
                otherwise
                    str = 'Unknown!';
            end
        end
        
    end
end

