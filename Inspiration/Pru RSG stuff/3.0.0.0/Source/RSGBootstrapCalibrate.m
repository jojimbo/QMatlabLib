function outputXmlPath = RSGBootstrapCalibrate(inputXmlPath)
    
    % test command line call
    % outputXmlPath = RSGBootstrapCalibrate('BootstrapInstruction.xml');
    
    totalTime = tic;
    fprintf([datestr(now) ' Main - applying bootstrapping calibration algorithms \n']);    
    
    calibrationEngine = prursg.Bootstrap.BootstrapEngine();
    outputXmlPath = calibrationEngine.Calibrate(inputXmlPath);
    
    fprintf([datestr(now) ' Main - bootstrapping calibration done \n']);
    toc(totalTime);
       
    pctRunDeployedCleanup;
    
end

  