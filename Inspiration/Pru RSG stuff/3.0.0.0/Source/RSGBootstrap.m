function RSGBootstrap(inputXmlFilePath)
    
    % test command line call
    % RSGBootstrap('BootstrapInstruction.xml');
    totalTime = tic;
    fprintf([datestr(now) ' Main - applying bootstrapping algorithm \n']);    
    bootstrapEngine = prursg.Bootstrap.BootstrapEngine();
    bootstrapEngine.Bootstrap(inputXmlFilePath);            
    fprintf([datestr(now) ' Main - bootstrapping done \n']);
    toc(totalTime);
  
    pctRunDeployedCleanup;
end
