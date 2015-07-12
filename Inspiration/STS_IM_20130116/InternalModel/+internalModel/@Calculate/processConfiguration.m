function [obj] = processConfiguration(obj, varargin)
%% processConfiguration
% |[obj] = processConfiguration(obj, varargin)|
%
% Process STS Configuration.
% Consist of five sections:
% 1. Process Configuration File contents
% 2. Acquire CSV Header File
% 3. Import CSV Files listed in configuration
% 4. Acquire Collections (Instruments, Scenarios etc)
% 5. Acquire Portfolio
%

% Try to acquire the data collections
    % 1. Process Configuration File contents
    obj.parameters = obj.utilities.loadParamsFromConfigFile(obj.configFile);
    
    % 2. Acquire CSV Header File
    obj.header = obj.utilities.csvreadCell(obj.parameters.headerFile);
    
    % 3. Import CSV Files listed in configuration
    obj.configuration = internalModel.Configuration(obj);
    
    % 4. Acquire Collections (Instruments, Scenarios etc)
    obj.instCol   = internalModel.InstrumentCollection(obj);
    obj.scenCol   = internalModel.ScenarioCollection(obj);
    obj.forexCol  = internalModel.ForeignExchange(obj);
    obj.equityreCol = internalModel.Equity(obj);
    obj.corrMat   = internalModel.NonMarketCorrMatrix(obj.parameters.corrMatFile, ...
        obj.parameters.baseEntityFile, obj.parameters.riskTypeFile);
    
    % 5. Acquire Portfolio
    obj.portfolio = internalModel.Portfolio(obj.parameters.portFile);
    
    % 6. Add Credit Spread, if applicable
    %    ------------------------------------------------------------------
    %    TO BE REFACTORED (P19-2, on-hold for now)
    %    NEW FILE FORMAT AVAILABLE - DOES NOT MATCH CURRENT IMPLEMENTATION
    %    ------------------------------------------------------------------
    if isfield(obj.parameters, 'spreadFile') && ...
            eq(exist(obj.parameters.spreadFile, 'file'), 2)
        
        % If available and properly referenced, acquire credit spread data
        obj.creditSpread = obj.utilities.csvreadCell(obj.parameters.spreadFile);
    end
    

if  isempty(obj.instCol)  || ...
        isempty(obj.scenCol)  || ...
        isempty(obj.forexCol) || ...
        isempty(obj.portfolio)
    
    % Initialized have failed...
    error('STS_CM:ConfigError', 'Non proper initialization of Collections');
    return
end

end
