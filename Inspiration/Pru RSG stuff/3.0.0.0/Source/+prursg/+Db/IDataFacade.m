classdef IDataFacade < handle
    %IDATAFACADE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties  
        riskNameToIdResolver
    end
    
    methods(Abstract)
        [job_id riskNameToIdMap ] = storeJob(obj, modelFile, startTime, endTime)
        [scenarioSetId scenarioId] = storeScenarioSet(obj, jobId, scenarioSet, setType, setKey, stochasticScenario, noOfChunks, risks) 
        [xmlModelFile scenarioSet chunks riskIds stochasticScenarioId job nBatches] = readScenarioSet(obj, name, nBatches)
        newChunk = storeScenarioChunk(obj, monteCarloNumber, risks, scenarioSetId, scenarioId, chunk)            
        storeValidationSchedule(obj, batchIndex, scenSetId, valData)
        convertScenarioSet(obj, scenarioSet);
    end
    
end

