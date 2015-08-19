classdef RSGDiff
    methods(Static)
      function CompareDirs(basePath, baseScenId, testPath, testScenId)
            fprintf('CompareDirs() called\n');
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
                    TestUtil.CompareDirContents(...
                        fullfile(basePath, folder, baseScenId),...
                        fullfile(testPath, folder, testScenId));
                    fprintf('Completed examination of %s files...\n\n', folder);
                catch e
                    % Catch the exception, report the failure
                    % Process the remaining file sets
                    failures = [failures ; folder ];
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
        % Note, files that do not appear in baselinePath will not be
        % compared. In order to ensure any gaps are closed call this method
        % again with the paths reversed.
        % Any files with a .flipped extension are ignored as they will be
        % the output of an earlier test run where the output from two tests
        % are being compared
        % The method will assert on error or if any files do not match.
        % in:
        %   baselinePath, A fully qualified path to the reference directory.
        % in:
        %   testPath, A fully qualified path to the files under test.
        function CompareDirContents(baselinePath, testPath)
            import testutil.*;            
            % Track which comparisons fail for summary logging
            % Keys must be uniqiue but then so are the names of items in a
            % directory
            passes = containers.Map();
            failures = containers.Map();
            
            % Show which folders we are comparing
            fprintf('Comparing baseline:\n"%s"\nto:\n"%s"\n\n',...
                baselinePath, testPath);
            
            % Check the folders exist
            assertTrue(exist(baselinePath, 'dir') ~= 0,...
                'The baseline folder does not exist.');
            
            % Check the folders exist
            assertTrue(exist(testPath, 'dir') ~= 0,...
                'The test folder does not exist.');
            
            % Grab a list of the baseline files
            outputList = TestUtil.GetFilesFromDirectory(baselinePath);
            testFileList = TestUtil.GetFilesFromDirectory(testPath);
            
			assertTrue(numel(outputList) == numel(testFileList),...
						'The baseline and test directories contain a different number of files');
			
            % Check if there are any files in the baseline folder
            assertFalse(isempty(outputList),...
                'The baseline folder is empty. No files to compare.');
            
            % Compare each file in the baseline with the respective file in the
            % test folder.
            for y = 1:length(outputList)
                filename = outputList{y};
                fprintf('Processing file: "%s"\n', filename);
                
                [~, ~, ext] = fileparts(filename);
                if strcmpi(ext, '.flipped')
                    fprintf('Skipping file %s\n', filename);
                    continue;
                end
                
                baseFilePath = fullfile(baselinePath, filename);
                testFilePath = fullfile(testPath, filename);
                
                % Make sure that the test file exists
                assertTrue(exist(testFilePath, 'file') ~= 0,...
                    ['File ' testFilePath ' does not exist.']);
                
                fprintf('Comparing base file:\n"%s"\nto:\n"%s"\n\n',...
                    baseFilePath, testFilePath);
                
                % Compare the files.
                result = TestUtil.Compare(baseFilePath, testFilePath);
                
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
            assertTrue(isempty(failures), 'The test has failed.');
        end
        
        function CompareFiles(pathToOutput, scenarioSetId, pathToBaseline)            
            import testutil.*;
            
            % First use the baseline folder and compare against the
            % generated output
            TestUtil.CompareDirs(pathToBaseline, scenarioSetId, pathToOutput, scenarioSetId);
            
            % Use the generated output in case more files have been
            % generated. Comment out for now as we know that the same number of files is generated.

			% The two way comparison is inefficient and generates suprious
			% errors as we generate e.g. flipped files. Instead check that each
			% folder has the same number of files.

			%TestUtil.CompareDirs(pathToOutput, scenarioSetId, pathToBaseline, scenarioSetId);            
        end
        
        function result = Compare(baseFilePath, testFilePath)
            import testutil.*;
            
            [path, name, ext] = fileparts(testFilePath);          
            if strcmpi(ext, '.bin')
                % COnvert Algo files to CSV for comparison
                baseFileCSVPath = TestUtil.Bin2CSV(baseFilePath);
                testFileCSVPath = TestUtil.Bin2CSV(testFilePath);
                result = TestUtil.AssertFilesEqual(baseFileCSVPath, testFileCSVPath);
                % Give up if not equal - no point flipping the file
                return;
            end
            
            result = TestUtil.AssertFilesEqual(baseFilePath, testFilePath);
            if ~result                
                fprintf('Will attempt to flip %s and retry\n', testFilePath);
                flippedTestFile = TestUtil.FlipFile(testFilePath);
                result = TestUtil.AssertFilesEqual(baseFilePath, flippedTestFile);
            end
        end
        
        function result = AssertFilesEqual(baseFilePath, testFilePath)
            fprintf('Asserting base file:\n"%s"\nis equal to:\n"%s"\n\n',...
                    baseFilePath, testFilePath);
            
            [~, filename, ~] = fileparts(testFilePath);
            
            % Compare the files.
            try
                % Try to compare the files
                assertFilesEqual(baseFilePath, testFilePath,...
                    ['File: ' filename ' is not identical to the baseline']);
                fprintf('**File: "%s" is identical to the baseline**\n\n', filename);
                result = true;
            catch e
                % Catch the exception, report the failure
                % Leave it up to the caller to decide how to proceed
                fprintf('ERROR: File: "%s" is not identical to the baseline\n\n', filename);
                   
                result = false;
            end    
        end
        
        % Convert source line endings to '\n'
        function target = FlipFile(source)
            import testutil.*;
            
            [path, name, ext] = fileparts(source);          
            if strcmpi(ext, '.bin')
                % refuse to flip binary file
                fprintf('ERROR: File: "%s" is a binary file\n', source);
                throw(MExecption('TestUtil:FlipFile:NoSupported',...
                    'Not flipping a binary file'));
            end

            fprintf('Flipping line endings in %s\n', source);
            target = fullfile(path, [name ext '.flipped']);
            macros = containers.Map(); % Empty
            TestUtil.file_strrep(macros, source, target)
            fprintf('Flipped file is %s\n', target);
        end
        
        % Convert an Algo binary to CSV format with width columns
        function CSVFile = Bin2CSV(file)
            fprintf('Converting binary file %s to CSV\n', file);
            [path, name, ext] = fileparts(file);
            CSVFile = fullfile(path, [name ext '.csv']);            
       		
			fid = 0;
			try 
            	% read the binary file into am vector
           	 	fid = fopen(file);
           	 	binVec = fread(fid, 'double');
				fclose(fid);
            catch e
				fprintf('Caught an exception while attempting to read the binary file');
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
            csvwrite(CSVFile, binMat);
            
            % Check the file is non-empty
            fileInfo = dir(CSVFile);
            assertTrue(fileInfo.bytes >  0);
        end 
    end    
end

