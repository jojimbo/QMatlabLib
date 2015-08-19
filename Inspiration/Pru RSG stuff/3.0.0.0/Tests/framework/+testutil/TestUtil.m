classdef TestUtil
    % Wrapper for code common to the tests
    
    methods(Static)
        % Return the name of the calling method
        function name = func()
            frame = dbstack(1);
            name = frame.name;
        end
        
        % The caller should convert the returned value as required
        function value = GetConfigValue(key)
            import prursg.Configuration.*;
            cm = prursg.Configuration.ConfigurationManager();
            value = '';
            
            if isKey(cm.AppSettings, key)
                value = cm.AppSettings(key);
            end
        end
        
        function RebuildScenarioDB()
            if (testutil.TestUtil.proceed('All scenario tables will be dropped, do you wish to proceed?', 'N'))
                import prursg.*;
                db = prursg.Db.DbFacade();
                db.clearTables();
            end
        end
        
        function RebuildMDSDB()
            if (proceed('All MDS tables will be dropped, do you wish to proceed?', 'N'))
                import prursg.*;
                db = prursg.Db.DbFacade();
                db.clearMdsTables();
            end
        end
        
        function result = proceed(message, default)
            if isempty(default)
                default = 'N';
            else
                if isempty(regexpi(default, '^(n|y|no|yes)$'));
                    error(['Unexpected default value "' default '"']);
                end
            end
            
            reply = input([message ' (y/n) (default: ' default '): '], 's');
            if (isempty(reply))
                reply = default;
            end
            
            if (strcmpi(reply, 'y') || strcmpi(reply, 'yes'))
                result = true;
            else
                result = false;
            end
        end
        
        % Replace keys(macros) in source with values(macros) and write the
        % result to target. Called with an empty macro lits it has the
        % effect of replaceing line endings in source with '\n';
        function file_strrep(macros, source, target)
            fprintf('Processing file %s\n', source)
            
            fin = fopen(source, 'rt');
            if fin == -1
                error(['Unable to open ' source ' for reading'])
            end
            
            fout = fopen(target, 'w+t');
            if fout == -1
                error(['Unable to open ' target ' for writing'])
            end
            
            % Transform file
            key_list = keys(macros);
            while ~feof(fin)
                line = fgetl(fin);
                
                if line == -1
                    % end-of-file marker
                    % why foef doesn't detect eof is unclear
                    break;
                end
                
                for i = 1:length(key_list)
                    % Transforms are applied line by line...
                    key = key_list{i};
                    value = macros(key);
                    
                    if isempty(value)
                        % Warn about each missing values
                        fprintf('Skipping  "%s" as value is empty\n', key);                        
                        continue;
                    end
                    line = strrep(line, key, value);
                end
                fprintf('.');
                fprintf(fout, '%s\n', line);
            end
            fprintf('\n');
            fclose(fin);
            fclose(fout);
            
            fprintf('Processing complete for source %s\n\n', source);
            fprintf('Processing complete for target %s\n\n', target);
        end
        
        function GenerateFiles(scenarioSetId)
            fprintf('\nGenerating files for "%s"\n', scenarioSetId); 
            % Run the files generation processes for a given scenario set
            % id.
            if ~isempty(scenarioSetId)
                owo = testutil.TestUtil.GetConfigValue('OverwriteOutputs');
                assertFalse(strcmpi(owo, 'false'));
                % This is almost certainly an error.
                % If OverwriteOutputs is false then no output is
                % generated if a folder named after the scen id already
                % exists                                   
                
                fprintf('\nCreating Algo files for "%s"\n', scenarioSetId);
                [message algoFilesPath] = RSGMakeAlgoFiles(scenarioSetId, []);
                fprintf('Create Algo files completed with message: "%s"\n', message);
                fprintf('Files can be found in "%s"\n\n', algoFilesPath); 
                
                fprintf('\nCreating Pru files for "%s"\n', scenarioSetId);
                [message pruFilesPath] = RSGMakePruFiles(scenarioSetId, []);
                fprintf('Create Pru files completed with message: "%s"\n', message);
                fprintf('Files can be found in "%s"\n\n', pruFilesPath); 
                
                fprintf('\nCreating Validation files for "%s"\n', scenarioSetId);
                [message valReportPath] = RSGValidate(scenarioSetId);
                fprintf('Create Pru files completed with message: "%s"\n', message);
                fprintf('Files can be found in "%s"\n\n', valReportPath); 
            else
                error('The scenario set ID is empty!')
            end            
        end
        
        function filesList = GetFilesFromDirectory(dirToIterate)            
            dirOutput = dir(dirToIterate);
            dirIndex = [dirOutput.isdir];
            filesList = {dirOutput(~dirIndex).name};  
            
            % Remove MKS project.pj files from the comparison
            filesList(strcmp('project.pj',filesList)) = [];
        end
        
        function CompareDirs(basePath, baseScenId, testPath, testScenId)
           import testutil.*;
           % Moved the original implementation into RSGDiff and revised the
           % implementation in RSGDiff2
           % RSGDiff.CompareDirs(basePath, baseScenId, testPath, testScenId);
           RSGDiff2.CompareDirs(basePath, baseScenId, testPath, testScenId);
        end      
        
        function CompareFiles(pathToOutput, scenarioSetId, pathToBaseline)            
            import testutil.*;
            % Moved the original implementation into RSGDiff and revised the
            % implementation in RSGDiff2
            % RSGDiff.CompareFiles(pathToOutput, scenarioSetId, pathToBaseline);
            RSGDiff2.CompareFiles(pathToOutput, scenarioSetId, pathToBaseline);
        end
    end
end
