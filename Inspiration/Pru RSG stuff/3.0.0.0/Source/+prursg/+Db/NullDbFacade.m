classdef NullDbFacade < handle
    % empty implementation of DbFacade useful for testing without 
    % database support
    
    
    methods 
        
                
        function [job_id riskNameToIdMap ] = storeJob(obj, modelFile, startTime, endTime) %#ok<*MANU,*INUSD>
            job_id = [];
            riskNameToIdMap = [];
        end
        
        function scenarioSetId = storeScenarioSet(obj, jobId, risks, scenarioSet, setType, setKey, stochasticScenario, chunks)             %#ok<*STOUT>
            scenarioSetId = [];
        end
           
        function clearTables(obj)
        end
        
        function commitTransaction(obj)
        end
        
        function [xmlModelFile scenarioSet chunks] = readScenarioSet(obj, name)
            xmlModelFile = [];
            scenarioSet = [];
            chunks = [];
        end        
    end
    
end
