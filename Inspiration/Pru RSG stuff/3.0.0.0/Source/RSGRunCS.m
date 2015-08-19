% Generate critical scenarios
% parameters
% xmlFilePath - Base model file path.
% araReportFileName - Path to the critical scenario id report.
% windowSize - Size of window.
% windowShapre - Smoothing rule name.
% shapeParameter - Smoothing rule parameter.
% return parameters
% UserMsg - result message.
% ScenSetID - new scenario set name. Same as the input parameter. Created
% for the consistency purpose only.
function [UserMsg ScenSetID] = RSGRunCS(xmlFilePath, araReportFileName, windowSize, windowShape, shapeParameter)    
        
    try
        ScenSetID = '';
        import prursg.Xml.*;
        prursg.Xml.configureJava(true);
        
        if ischar(windowSize)
            windowSize = str2num(windowSize);
        end
        
        if ischar(shapeParameter)
            [numericShapeParameter, status] = str2num(shapeParameter);
            if status % if conversion succeeds, use the numeric value. Otherwise, use the string value.
                shapeParameter = numericShapeParameter;
            end
        end
        
        filePath = prursg.Util.ConfigurationUtil.GetInputPath(xmlFilePath);
        modelFile = ControlFile.ControlFileFactory.create(filePath);
        
        scenSetName = '';
        baseScenSetName = '';
        if ~isempty(modelFile)
            baseScenSetName = RetrieveScenarioSetName(modelFile);
            scenSetName = [baseScenSetName '_CS'  datestr(now, '_ddmmmyyyy_HH:MM:ss')];
        end
                
        smoothingRuleName = windowShape;
                        
        
        nBatches = prursg.Util.ConfigurationUtil.GetNoOfBatches();    
        disp([datestr(now) ' RSGRunCS started with ' num2str(nBatches) ' batch(es).']);

        % create ARA Report DAO object.
        araReportDAO = prursg.CriticalScenario.AraCsReportDAO(araReportFileName);

        % create Smoothing Rule object.
        smoothingRule = [];
        addpath(prursg.Util.ConfigurationUtil.GetModelsPackage());
        import Model.*;
        eval(['smoothingRule = Model.SmoothingRules.' smoothingRuleName '();']);        
        
        % run Critical Scenario Engine.
        engine = prursg.CriticalScenario.CriticalScenarioEngine(scenSetName, baseScenSetName, araReportDAO, smoothingRule);    
        engine.NoOfBatches = nBatches;
        if ischar(windowSize)
            windowSize = str2num(windowSize);
        end
        engine.WindowSize = windowSize;
        engine.ShapeParameter = shapeParameter;
        engine.Run();  
        
        % perform clean up.
        delete(smoothingRule);
        delete(araReportDAO);
        delete(engine);
        
        %Return outputs
        UserMsg = 'Main - Msg: RSG CS run complete'; 
        ScenSetID = scenSetName;
    catch ex
         UserMsg = sprintf('Exception occurred during RSG critical scenario run:\n%s', getReport(ex));
         disp(UserMsg);
    end     
    disp([datestr(now) ' ' UserMsg]);
    
    pctRunDeployedCleanup;    
end


function scenSetName = RetrieveScenarioSetName(modelFile)   
    scenSetName = '';
    
    switch(modelFile.scenario_type_key)
        case {1, 8} %base     
            scenSetName = modelFile.base_set.name;
        case {2, 3} %whatif                            
            scenSetName = modelFile.what_if_sets.name; %scenSetName = modelFile.what_if_sets_base_set_name;
    end       
end