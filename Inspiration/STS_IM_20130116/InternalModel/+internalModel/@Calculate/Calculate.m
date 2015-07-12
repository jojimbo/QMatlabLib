%% Calculate
% This class performs IM Calculations and prepares reports.

classdef Calculate
    %% Properties
    %
    % * |configFile|    _Char_
    % * |configuration| _Configuration_
    % * |corrMat|       _NonMarketCorrMatrix_
    % * |creditSpread|  _Struct_
    % * |cube|          _Cube_
    % * |forexCol|      _ForeignExchange_
    % * |equityreCol|   _Equity_
    % * |header|        _Cell_
    % * |instCol|       _InstrumentCollection_
    % * |parameters|    _Struct_
    % * |portfolio|     _Portfolio_
    % * |results|       _Cell_
    % * |scenCol|       _ScenarioCollection_
    % * |utilities|     _Utilities_
    %
    % *_private_*
    %
    % * shockedInterestLib _Cell_
    
    properties
        configFile
        configuration
        corrMat
        creditSpread
        cube
        forexCol
        equityreCol
        header
        instCol
        parameters
        portfolio
        results
        scenCol
        utilities
        runtime
    end % #Properties Public
    
    properties (SetAccess = private, GetAccess = public)
        shockedInterestLib
    end % #Properties Private
    
    methods
        %% Methods
        %
        % * |obj                = Calculate(configFile)| _constructor_
        % * |obj                = calcInterestRate(obj)|
        % * |[obj, errorMsg]    = processConfiguration(obj, varargin)|
        % * |PCA                = processPcaFile(obj, varargin)|
        % * |[obj, errorMsg]    = runTopLevel(obj, varargin)|
        % * |[result, errorMsg] = run(obj, confidenceLevel, reportingCurrency, varargin)|
        % * |errorMsg           = reportTopLevel(obj, varargin)|
        % * |errorMsg           = report(obj, reportFlnm, result, varargin)|
        % * |obj                = calcShockedProperties(obj)|
        % * |table              = getShockedPropTable()|
        
        function obj = Calculate(configFile)
            %% Calculate _constructor_
            % |obj = Calculate(configFile)|
            %
            % Input:
            %
            % * |configFile|      _Char_
            
            % 0. Initialize
            obj.header       = {};
            obj.instCol      = [];
            obj.scenCol      = [];
            obj.forexCol     = [];
            obj.corrMat      = [];
            obj.portfolio    = [];
            obj.creditSpread = [];
            obj.parameters   = [];
            obj.utilities    = internalModel.Utilities();
            
            modifiedStr      = strrep(datestr(now), ' ', '_');
            modifiedStr      = strrep(modifiedStr, ':', '_');
            modifiedStr      = strrep(modifiedStr, '-', '_'); % To be revisited later
            
            obj.runtime      = modifiedStr;
            
            % Configuration File must exist
            if ~exist(configFile, 'file');
                fprintf(2,'%s\n', configFile);
                error('STS_CM:FileDoesNotExist', 'above configFile does not exist, not found file');
            end
            
            % Set 'configFile' as a member, for reference purposes
            obj.configFile  = configFile;
            
            % 1. Process 'configFile' contents
            [obj] = obj.processConfiguration();
            
            % 2. Perform IM Calculation. Done in two steps: the 'runTopLevel'
            %    method checks if a batch-run is required. Subsequently, the
            %    individual-run method 'run' is invoked
            [obj] = obj.runTopLevel();
            
            
            % 3. Prepare IM Calculation Report. Also done two steps: in case a
            %    batch-run of reports is required, e.g. for multiple Reporting
            %    Currencies, it is handled by the top-level method.
            %    Subsequently, the individual-report method 'report' is invoked
            obj.reportTopLevel();
            
%             if ~isempty(errorMsg)
%                 error('STS_CM:ReportError', errorMsg);
%             end
            
        end % #Constructor
        
        
        
        function [obj] = runTopLevel(obj, varargin)
            %% runTopLevel
            % |[obj] = runTopLevel(obj, varargin)|
            %
            % Top-Level IM Calculation method. In case the user requests a
            % batch-run of multiple confidence levels, this is handled
            % here. A results structure is build, one for each run.
            
            % Calculate interest rates
            %             obj = obj.calcInterestRate();
            
            % Calculate Domestic interest rates for all Instruments
            for iInst = 1:numel(obj.instCol.Instruments)
                [obj, obj.instCol.Instruments{iInst}] = ...
                    obj.calcDomesticInterestRate(obj.instCol.Instruments{iInst});
            end
            
            % Calculate Foreign interest rates for all Instruments
            for iInst = 1:numel(obj.instCol.Instruments)
                [obj, obj.instCol.Instruments{iInst}] = ...
                    obj.calcForeignInterestRate(obj.instCol.Instruments{iInst});
            end
            
            % Calculate shocked properties
            % obj = obj.calcShockedProperties();
            
            % Calculate shocked FX Rates
            for iInst = 1:numel(obj.instCol.Instruments)
                [obj, obj.instCol.Instruments{iInst}] = ...
                    obj.calcShockedFXRates(obj.instCol.Instruments{iInst});
            end
            
            % Calculate shocked FX Vols
            for iInst = 1:numel(obj.instCol.Instruments)
                [obj, obj.instCol.Instruments{iInst}] = ...
                    obj.calcShockedFXIV(obj.instCol.Instruments{iInst});
            end
            
            % Calculate shocked Equity Indices
            for iInst = 1:numel(obj.instCol.Instruments)
                [obj, obj.instCol.Instruments{iInst}] = ...
                    obj.calcShockedEQ(obj.instCol.Instruments{iInst});
            end
            
            % Create Cube
            cubeCurr = obj.parameters.reportingCurrency{1}; % It used to be hardcoded to: 'EUR';
            obj.cube = internalModel.Cube(obj.instCol, obj.scenCol, obj.forexCol, cubeCurr);
            
            % Price all the instruments in the Cube
            obj.cube.evaluateCube(obj.instCol, obj.scenCol, obj.forexCol, cubeCurr);
            
            % Save the Cube to the outputFile specified in the configFile,
            % adding a timestamp to the folder (obj.runtime)
            obj.cube.SaveCube(fullfile(fileparts(obj.parameters.outputFile), obj.runtime));
            
            % Collect looping variables
            confidenceLevels    = obj.parameters.confidenceLvl;
            reportingCurrencies = obj.parameters.reportingCurrency;
            
            % ------------------------------------
            % Perform all individual calculations:
            % ------------------------------------
            % Initialize results member
            obj.results = cell(numel(confidenceLevels), numel(reportingCurrencies));
            
            % Loop over Reporting Currencies (RC)
            for iCL = 1:numel(confidenceLevels)
                % Loop over Confidence Levels (CL)
                
                for iRC = 1:numel(reportingCurrencies)
                    % Perform individual calculation for each currency
                    [result] = obj.run(confidenceLevels(iCL), reportingCurrencies{iRC});
                    
                    
                    % Propagate individual result to Results object member
                    obj.results{iCL, iRC} = result;
                end
                
            end
            
        end % #runTopLevel
        
        
        
        function reportTopLevel(obj, varargin)
            %% reportTopLevel
            % |reportTopLevel(obj, varargin)|
            %
            % Top-Level Reporting method. Reports are generated for each
            % confidence level, for each reporting currency.
            
            % Collect looping variables
            confidenceLevels    = obj.parameters.confidenceLvl;
            reportingCurrencies = obj.parameters.reportingCurrency;
            
            % ------------------------------
            % Create all individual reports:
            % ------------------------------
            % Loop over Reporting Currencies (RC)
            for iCL = 1:numel(confidenceLevels)
                % Loop over Confidence Levels (CL)
                
                for iRC = 1:numel(reportingCurrencies)
                    % Create individual report for each currency
                    result   = obj.results{iCL, iRC};
                    [a b c] = fileparts(obj.parameters.outputFile);
                    obj.report(fullfile(a, obj.runtime, [b c]), result);
                    clear a b c
                    
%                     % Error handling
%                     if ~isempty(errorMsg)
%                         break
%                     end
                end
                
%                 % Error handling
%                 if ~isempty(errorMsg)
%                     break
%                 end
            end
            
            % Extra csv file with the PnL vectors
            %csvwrite(fullfile(obj.parameters.outputFile));
            obj.SaveResults(fullfile(fileparts(obj.parameters.outputFile), obj.runtime));
            
        end % #reportTopLevel
        
        function saved = SaveResults(obj, path)
            % To get the path to the ouputFolder, just use the following
            % fullfile(evalin('caller', 'fileparts(obj.parameters.outputFile)'))
            try
                if ~exist(fullfile(path), 'dir')
                    mkdir(fullfile(path));
                end
                results = obj.results;
                save(fullfile(path, 'Results.mat'), 'results')
                saved = 1;
            catch ME
                saved = 0;
                error('STS:ResultsNotSaved', 'Not able to save Results');
            end
        end
        
    end % #methods
    
    
    
    methods (Static)
        
        function table = getShockedPropTable()
            %% getShockedPropTable _static_
            % |table = getShockedPropTable()|
            %
            % Table is a cell matrix with columns being:
            %
            % # Instrument Class Name
            % # Instrument Property (as defined in class)
            % # Prefix in scenario file
            % # Post fix
            % # evaluation to obtain base value
            table = {
                'internalModel.Instruments.EquityForward', 'Spot', 'EQ_', 'RiskDriver'
                };
        end
        
    end % #Methods Static
    
end
