classdef CriticalScenarioEngine < handle
    % Represents the critical scenario engine
    
    
    properties
        BaseScenarioSetName;
        ScenarioSetName;
        NoOfBatches = 1;
        AraReportDAO; % Reference to a DAO object implementing IAraReportDAO interface.
        SmoothingRule; % Reference to a smoothing rule implementing ISmoothingRule interface.
        WindowSize;
        ShapeParameter;
    end
    
    methods
        
        % constructor.
        function engine = CriticalScenarioEngine(scenarioSetName, baseScenarioSetName, araReportDAO, smoothingRule)
            engine.ScenarioSetName = scenarioSetName;
            engine.BaseScenarioSetName = baseScenarioSetName;
            engine.AraReportDAO = araReportDAO;
            engine.SmoothingRule = smoothingRule;
        end
        
        % executes the critical scenario engine.
        function Run(obj)
                                   
            if isempty(obj.AraReportDAO)
                throw(MException('CriticalScenarioEngine:Run', 'The ARA report DAO object is not set.'));
            end
            
            if isempty(obj.SmoothingRule)
                throw(MException('CriticalScenarioEngine:Run', 'The smoothing rule object is not set.'));
            end
                        
            
            % load base scenario set data.
            [baseModelFile baseScenarioSet stoValues subRisks] = obj.LoadBaseScenarioSet();
            
            % load ARA report data.
            araReportData = obj.AraReportDAO.Load();
            if isempty(araReportData)
                disp('No ARA report data are loaded.');
            end
            
            disp([datestr(now) ' Applying smoothings rule...']);  
            nNodes = size(araReportData, 1);
            for i = 1:nNodes                
                weightings = araReportData{i, 3};
                scenIds = araReportData{i, 2};      
                
                scenData = [];
                filteredScenIds = find(scenIds > 0);
                if ~isempty(filteredScenIds)
                    try
                        scenData = stoValues(scenIds(filteredScenIds), :);   
                    catch ex
                        ex = MException('CriticialScenarioEngine:Run', ['Cannot find scenario data. Node Name=' araReportData{i, 1} ]);
                        throw(ex);
                    end
                end
                                
                % smooth data.
                if ~isempty(scenData)
                    araReportData(i, 4) = {obj.SmoothingRule.Smooth(scenData, weightings, obj.WindowSize, obj.ShapeParameter);};
                end                
            end
            
            % save results.
            obj.SaveScenarioSet(araReportData, baseScenarioSet, baseModelFile, subRisks);
            
        end
    end
    
    methods(Access=private)
        
        % load base scenario set data.
        function [modelFile scenarioSet stoValues subRisks] = LoadBaseScenarioSet(obj)                        
            
            if isempty(obj.BaseScenarioSetName)
                throw(MException('CriticalScenarioEngine:LoadBaseScenarioSet', 'The base scenario set name is not set.'));
            end
            
            disp([datestr(now) ' Reading base scenario set ' obj.BaseScenarioSetName '...']);  
            
            import prursg.Xml.*;           
            % establish connection to database
            db = prursg.Db.DbFacade();    
            [modelFile scenarioSet stoValues riskIds stochasticScenarioId job nBatches] = db.readScenarioSet(obj.BaseScenarioSetName, obj.NoOfBatches);        

            subRisks = prursg.Util.JobUtil.getSubRisks(modelFile.riskDrivers, scenarioSet.getBaseScenario().expandedUniverse);            
            
            delete (db);
            
            disp([datestr(now) ' The base scenario set loading is completed.']);  
        end
        
        % save critical scenario set.
        function SaveScenarioSet(obj, araReportData, scenarioSet, modelFile, subRisks)
            
            disp([datestr(now) ' Saving results.... ']);
             
            if isempty(obj.ScenarioSetName)
                throw(MException('CriticalScenarioEngine:SaveScenarioSet', 'The scenario set name is not set.'));
            end                     
                        
            stochasticScenarios = obj.CreateScenariosFromAraReport(araReportData, scenarioSet.getBaseScenario().date);      
            
            scenarioTypeKey = int32(prursg.Engine.ScenarioType.CriticalScenario);
                        
            % Create a new scenario type key which will contain the
            % critical scenario enumeration and the scenario type for which
            % the CS run against encoded.
            % ex. CS run against a what-if t=0, then the new scenario type
            % key would be 9:2
            updatedScenarioTypeKey = [num2str(scenarioTypeKey) ':' num2str(modelFile.scenario_type_key)];
            
            % update model file.
            modelFile.scenario_type_key = updatedScenarioTypeKey;
            modelFile.modelFileDOM.getDocumentElement().getElementsByTagName('scenario_type_key').item(0).getFirstChild().setData(num2str(updatedScenarioTypeKey));
            
            % update scenario set name.
            scenarioSet.name = obj.ScenarioSetName;            
            
            import prursg.Xml.*;           
            % establish connection to database
            db = prursg.Db.DbFacade();  
            jobId = db.storeJob(modelFile, now(), now());
            
            [scenarioSetId scenarioId] = db.storeScenarioSet( ...
                jobId, scenarioSet, modelFile.scenario_set_type, ...
                scenarioTypeKey, stochasticScenarios, 1, modelFile.riskDrivers);


            assert(numel(scenarioId) == numel(stochasticScenarios));    
            data = araReportData(find(cell2mat(cellfun(@(x){~isempty(x)}, araReportData(:, 4)))), :);
            mcNumber = 0;
            for i = 1: numel(scenarioId)
                simulationOutputs = data{i, 4};                 
                if ~isempty(simulationOutputs)
                    simulationOutputs = mat2cell(simulationOutputs, size(simulationOutputs, 1), subRisks(:, 1)');
                    db.storeScenarioChunk( ...
                    mcNumber, ...
                    modelFile.riskDrivers, scenarioSetId, scenarioId(i), ...
                    simulationOutputs ...
                    );
                    mcNumber = mcNumber + size(simulationOutputs{1}, 1);
                end
            end   
            
            delete(db);
            
            disp([datestr(now) ' Saved all results.']);  
                        
        end   
        
        % create scenario objects based on the ARA report data.
        % data - ARA report data.
        % date - The last deterministc date of the base scenario set.
        function scenarios = CreateScenariosFromAraReport(obj, data, date)
            
            scenarios = [];
            if ~isempty(data)
                for i = 1:size(data, 1)
                    if ~isempty(data{i, 4}) % check whether or not the smoothed data is contained.
                        scenario = prursg.Engine.Scenario();
                        scenario.name = data{i, 1};
                        scenario.number = i;
                        scenario.date = date;
                        scenario.scen_step = 0;

                        scenarios = [scenarios scenario];
                    end
                end
            end        
        end
        
    end    
end

