function [UserMsg XMLFilePathOut] = RSGCalibrate(XMLFilePath)
    clc;
    try
        import prursg.Xml.*;
        tic;
        % instantiate a model file object from XML model file
        fprintf('Main - reading XML model file ''%s'' \n', XMLFilePath);
        filePath = prursg.Util.ConfigurationUtil.GetInputPath(XMLFilePath);
        modelFile = ControlFile.ControlFileFactory.create(filePath);
    
        % instantiate a RSG object
        fprintf('Main - Instantiating RSG object \n');
        rsg = prursg.Engine.RSG(modelFile.riskDrivers, modelFile.correlationMatrix.values, modelFile.dependencyModel,modelFile);
    
        % simulate, results under folder simResults
        fprintf('Main - RSG calibrating \n');
        rsg.calibrate();
        
        % save enriched model file
        modelFile.merge();
        str = modelFile.toString();
        fileName = [XMLFilePath(1:length(XMLFilePath)-4) '_enriched.xml'];
        fid = fopen(fileName, 'w');
        fwrite(fid, str);
        fclose(fid);
        toc;
        
        UserMsg = 'Main - Msg: RSG calibration run complete';
        XMLFilePathOut = pwd;
    catch ME
        UserMsg = sprintf('Main - Warning: Error during RSG calibration run:\n%s', getReport(ME));
    end
    
    pctRunDeployedCleanup;
end