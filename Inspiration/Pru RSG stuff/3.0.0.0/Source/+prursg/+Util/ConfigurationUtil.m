classdef ConfigurationUtil
    % Provides utility functions for the configuration.
    
    properties
        
    end
    
    methods(Static)
        
        % retrieve no of batches from the configuration file.
        function noOfBatches = GetNoOfBatches()
            noOfBatches = 1; % default value.
            
            import prursg.Configuration.*;                            
            
            cm = prursg.Configuration.ConfigurationManager();
            
            if isKey(cm.AppSettings, 'NoOfBatches')
                noOfBatches = str2num(cm.AppSettings('NoOfBatches'));
            end
        end
        
        function tf = GetOverwriteOutputs()
            tf = 1;
            
            import prursg.Configuration.*;                                        
            cm = prursg.Configuration.ConfigurationManager();            
            if isKey(cm.AppSettings, 'OverwriteOutputs') && strcmpi(cm.AppSettings('OverwriteOutputs'), 'false')
                tf = 0;
            end            
        end
        
        function modelsFolder = GetModelsPackage()
            import prursg.Configuration.*;                                        
            cm = prursg.Configuration.ConfigurationManager();
            
            if isKey(cm.AppSettings, 'ModelsFolder')
                modelsFolder = fullfile(cm.AppSettings('ModelsFolder'));
            else
                error('The ModelsFolder has not been set correctly in the app.config, please address.');
            end
        end
        
        function tf = GetDebugMode()
            tf = 0;
            
            import prursg.Configuration.*;                                        
            cm = prursg.Configuration.ConfigurationManager();            
            if isKey(cm.AppSettings, 'DebugMode') && strcmpi(cm.AppSettings('DebugMode'), 'true')
                tf = 1;
            end            
        end
        
        function outputPath = GetOutputPath(outputFolderType, scenSetName)
            import prursg.Configuration.*;                                        
            cm = prursg.Configuration.ConfigurationManager();
            
            if (~isempty(outputFolderType) && isempty(scenSetName))
                outputPath = CheckKeyExistsAndReturnPath(cm, 'RSGBootstrapValidate', '');
            elseif (~isempty(outputFolderType) && ~isempty(scenSetName))
                switch outputFolderType
                    case prursg.Util.OutputFolderType.Validate
                        outputPath = CheckKeyExistsAndReturnPath(cm, 'ValReports', scenSetName);
                    case prursg.Util.OutputFolderType.Pru
                        outputPath = CheckKeyExistsAndReturnPath(cm, 'PruFiles', scenSetName);
                    case prursg.Util.OutputFolderType.Algo
                        outputPath = CheckKeyExistsAndReturnPath(cm, 'AlgoFiles', scenSetName);
                    case prursg.Util.OutputFolderType.AlgoScenario
                        outputPath = CheckKeyExistsAndReturnPath(cm, 'AlgoScenarioFiles', scenSetName);
                end
            else
                throw(MException('RSG:outputFolderTypeEmpty', 'Either the RSG output type or scenario set name have not been specified'));
            end
        end
        
        function saveAsHDF5 = SaveMatFilesAsHDF5()
            import prursg.Configuration.*;                                        
            cm = prursg.Configuration.ConfigurationManager();
            
            if isKey(cm.AppSettings, 'SaveMatFilesAsHDF5')
                saveAsHDF5 = cm.AppSettings('SaveMatFilesAsHDF5');
            else
                throw(MException('RSG:saveMatFilesAsHDF5Key', 'The HDF5 file format key is missing from the config file! Should be ''SaveMatFilesAsHDF5'''));
            end
        end
        
        function inputPath = GetInputPath(xmlFile)
            import prursg.Configuration.*;                                        
            cm = prursg.Configuration.ConfigurationManager();
            
            if isKey(cm.AppSettings, 'InputFolderPath')
                inputPath = fullfile(cm.AppSettings('InputFolderPath'), xmlFile);
            else
                throw(MException('RSG:inputFolderPathKey', 'The RSG input folder key is missing from the config file! Should be ''InputFolderPath'''));
            end
        end
        
        function inputPath = GetBootstrapInputPath()
            import prursg.Configuration.*;                                        
            cm = prursg.Configuration.ConfigurationManager();
            
            if isKey(cm.AppSettings, 'MarketDataInputFolderPath')
                inputPath = fullfile(cm.AppSettings('MarketDataInputFolderPath'));
            else
                throw(MException('RSG:marketDataInputFolderPathKey', 'The RSG market data input folder key is missing from the config file! Should be ''MarketDataInputFolderPath'''));
            end
        end
        
        function inputPath = GetRootFolderPath()
            import prursg.Configuration.*;                                        
            cm = prursg.Configuration.ConfigurationManager();
            
            if isKey(cm.AppSettings, 'RSGRoot')
                inputPath = fullfile(cm.AppSettings('RSGRoot'));
            else
                throw(MException('RSG:rsgRootKey', 'The RSG root folder key is missing from the config file! Should be ''RSGRoot'''));
            end
        end
        
        function useGrid = GetUseGrid()
            useGrid = 0;            
            cm = prursg.Configuration.ConfigurationManager();            
            if isKey(cm.AppSettings, 'UseGrid') && strcmpi(cm.AppSettings('UseGrid'),'true')
                useGrid = 1;
            end
        end
        
        function clusterMatlabRoot = GetClusterMatlabRoot()
            clusterMatlabRoot = '';            
            cm = prursg.Configuration.ConfigurationManager();            
            if isKey(cm.AppSettings, 'ClusterMatlabRoot')
                clusterMatlabRoot = cm.AppSettings('ClusterMatlabRoot');
            end
        end
        
        
        function location = GetDataLocation()
            location = '';                         
            cm = prursg.Configuration.ConfigurationManager();            
            if isKey(cm.AppSettings, 'DataLocation')
                location = cm.AppSettings('DataLocation');            
            end
        end
        
        function tf = AllowWriteMarketData()
            tf = 0;
            cm = prursg.Configuration.ConfigurationManager();            
            if isKey(cm.AppSettings, 'AllowWriteMarketData')
                value = cm.AppSettings('AllowWriteMarketData');            
                if ~isempty(value) && strcmpi(value, 'true')
                    tf = 1;
                end
            end
        end  
        
        function schedulerType = GetSchedulerType()
            schedulerType = '';            
            cm = prursg.Configuration.ConfigurationManager();            
            if isKey(cm.AppSettings, 'SchedulerType')
                schedulerType = cm.AppSettings('SchedulerType');
            end
        end
        
        function userId = GetSymphonyUserId()
            userId = '';            
            cm = prursg.Configuration.ConfigurationManager();            
            if isKey(cm.AppSettings, 'SymphonyUserId')
                userId = cm.AppSettings('SymphonyUserId');
            end
        end
        
        function password = GetSymphonyPassword()
            password = '';            
            cm = prursg.Configuration.ConfigurationManager();            
            if isKey(cm.AppSettings, 'SymphonyPassword')
                password = cm.AppSettings('SymphonyPassword');
            end
        end
        
        function appName = GetSymphonyAppName()
            appName = '';            
            cm = prursg.Configuration.ConfigurationManager();            
            if isKey(cm.AppSettings, 'SymphonyAppName')
                appName = cm.AppSettings('SymphonyAppName');
            end
        end
        
        function appName = GetSymphonyInMemoryProcessingAppName()
            appName = '';            
            cm = prursg.Configuration.ConfigurationManager();            
            if isKey(cm.AppSettings, 'SymphonyInMemoryProcessingAppName')
                appName = cm.AppSettings('SymphonyInMemoryProcessingAppName');
            end
        end
        
        function appName = GetSymphonyAppProfileName(isInMemory)            
            if isInMemory
                appName = prursg.Util.ConfigurationUtil.GetSymphonyInMemoryProcessingAppName();
            else
                appName = prursg.Util.ConfigurationUtil.GetSymphonyAppName();
            end
        end

        function sourceCodePath = GetRSGSourceCodePath()
            sourceCodePath = '';            
            cm = prursg.Configuration.ConfigurationManager();            
            if isKey(cm.AppSettings, 'RSGSourceCodePath')
                sourceCodePath = cm.AppSettings('RSGSourceCodePath');
            end
        end
        
        function numberFormat = GetHistoricalDataDaoNumberFormat()
            numberFormat = '';
            cm = prursg.Configuration.ConfigurationManager();            
            if isKey(cm.AppSettings, 'HistoricalDataDaoNumberFormat')
                numberFormat = cm.AppSettings('HistoricalDataDaoNumberFormat');
            end                        
        end
        
        function numberFormat = GetScenarioValueNumberFormat()
            numberFormat = '';
            cm = prursg.Configuration.ConfigurationManager();            
            if isKey(cm.AppSettings, 'ScenarioValueNumberFormat')
                numberFormat = cm.AppSettings('ScenarioValueNumberFormat');
            end                        
        end
        
        function numberFormat = GetCalibrationNumberFormat()
            numberFormat = '';
            cm = prursg.Configuration.ConfigurationManager();            
            if isKey(cm.AppSettings, 'CalibrationNumberFormat')
                numberFormat = cm.AppSettings('CalibrationNumberFormat');
            end                        
        end
                
        
        function name = GetScenarioValueConverterName()
            name = '';
            cm = prursg.Configuration.ConfigurationManager();            
            if isKey(cm.AppSettings, 'ScenarioValueConverterName')
                name = cm.AppSettings('ScenarioValueConverterName');
            end                        
        end                

        % Allow the validation of control files to be controlled
        % externally.
        % out:
        %   value, The logical value read from the configuration file or
        %   false if the parameter is missing
        function value = ValidateControlFileSchema()
            value = false;
            cm = prursg.Configuration.ConfigurationManager();            
            if isKey(cm.AppSettings, 'ValidateControlFileSchema')
                str = cm.AppSettings('ValidateControlFileSchema');
                value = logical(strcmpi('true', str));
            end                        
        end 
        
    end
end
      
function outputPath = CheckKeyExistsAndReturnPath(cm, subOutputFolderPath, scenSetName)
    if (isKey(cm.AppSettings, 'OutputFolderPath') && isempty(scenSetName))
        outputPath = fullfile(cm.AppSettings('OutputFolderPath'), subOutputFolderPath);
    elseif (isKey(cm.AppSettings, 'OutputFolderPath'))
        outputPath = fullfile(cm.AppSettings('OutputFolderPath'), subOutputFolderPath, prursg.Util.FileUtil.FormatFolderName(scenSetName));
    else
        throw(MException('RSG:outputFolderPathKey', 'The RSG output folder key is missing from the config file! Should be ''OutputFolderPath'''));
    end
end
