function [UserMsg ScenSetID] = TestYE2010Base(XMLFilePath, nBatch)
    try
        % simulate, validate and make pru files bypassing Oracle
        import prursg.Xml.*;
        tic;
        % instantiate a model file object from XML model file
        fprintf('Main - reading XML model file ''%s'' \n', XMLFilePath);
        filePath = fullfile('+prursg','+Test','+testModelFiles',XMLFilePath);

        modelFile = ModelFile(filePath);
        step = 12;
        % instantiate a RSG object
        fprintf('Main - Instantiating RSG object \n');
        rsg = prursg.Engine.RSG(modelFile.riskDrivers, modelFile.correlationMatrix);
    
        % simulate, results under folder simResults
        fprintf('Main - RSG simulating \n');
        % modelFile.num_simulations = 100;
        rsg.simulate(step, modelFile.num_simulations, nBatch, modelFile.riskIndexResolver);
        toc;
               
%         fprintf('Main - RSG making Pru files \n');
%         prursg.Aggregator.makePruFiles(1, 0,modelFile.riskDrivers, modelFile.base_set, rsg.simEngine.simulationOutputs);
        
        fprintf('Main - RSG validating \n');
        rsg.validate('nothing',modelFile.base_set,rsg.simEngine.simulationOutputs);

        UserMsg = 'Main - Msg: RSG simulation run complete';
    catch ME
        UserMsg = sprintf('Main - Warning: Error during RSG simulation run:\n%s', getReport(ME));
    end
end