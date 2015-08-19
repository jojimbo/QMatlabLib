classdef RSG < handle

    properties
        % bUnits % Risk groups
        calEngine % Dependencies engine
        simEngine % Simulation engine
        corrEngine % Correlation engine
        valEngine % Validation engine
        
        correlatedStochasticInputs
        
        modelFile
    end
    
    properties ( SetAccess = private )
        risks % Risks to be simulated
    end
    
    
    properties ( SetAccess = private )
        simResults % Simulation results
    end
    
    methods
        function obj = RSG(riskFactors, corrMat, dependencyModel, modelFile)
            % RSG - Constructor
            %   obj = RSG( bUnits, corrMat, corrMatNames )
            % Inputs:
            %   bUnits - Risk groups
            %   corrMat - correlation matrix between risks
            %   corrMatNames - names of risks in correlation matrix
            
            import prursg.*
            obj.risks = riskFactors;
            
            % attach simulation engine
            obj.simEngine = Engine.SimulationEngine(modelFile);
            obj.simEngine.addRisk(obj.risks);
            
            % attach calibration engine
            obj.calEngine = Engine.CalibrationEngine();
            obj.calEngine.addRisk(obj.risks);
            
            % attach dependency engine
            %randomSeeds = zeros(length(obj.risks), 1);
            %for i = 1:length(obj.risks)
            %    % bypass if seeds not specified (e.g. in a UDS)
            %    if ~isempty(obj.risks(i).random_seed)
            %        randomSeeds(i) = obj.risks(i).random_seed;
            %    end
            %end
            %obj.corrEngine = Engine.DependenciesEngine(dependencyModel,randomSeeds);         
            % attach dependency engine
            randomGenerators = [];
            for i = 1:length(obj.risks)
                % bypass if seeds not specified (e.g. in a UDS)
                if ~isempty(obj.risks(i).randomnumbergenerator)
                    randomGenerators{i,1} = obj.risks(i).randomnumbergenerator;
                end
            end
            obj.corrEngine = Engine.DependenciesEngine(dependencyModel,randomGenerators);
            
            
            
            obj.corrEngine.addRisk(obj.risks);
            obj.corrEngine.setRandomBehaviour();
            obj.corrEngine.buildCorrMat(corrMat);
            
            % attach validation engine
            obj.valEngine = Engine.ValidationEngine();
            obj.valEngine.addRisk(obj.risks);
            
            obj.simResults = [];
            
            obj.modelFile = modelFile;
            
        end
        
        function buildCorrMat( obj, corrMat, riskNames )
            % RSG.buildCorrMat - build correlation between risks
            %   obj.buildCorrMat( corrMat, riskNames )
            % Use the correlation engine to generate correlated stochastic 
            % inputs.
            % Inputs:
            %   corrMat - correlation matrix between risks
            %   riskNames - names of risks in correlation matrix
            % Outputs:
            %   None
            
            obj.corrEngine.buildCorrMat(corrMat, riskNames );
        end
        
        function calibrate(obj)
            % RSG.calibrate - calibrate risks
            %   obj.calibrate()
            % Use the calibration engine to calibrate risks.
            % Inputs:
            %   None
            % Outputs:
            %   None
            
            obj.calEngine.calibrate();
        end
        
        function simulate( obj, step, nSims, nBatches, riskIndexResolver)
            % RSG.simulate - Simulate risks
            %   obj.simulate(nPeriods,tStep,nSims,nBatches)
            % Use the simulation engine to simulate risks
            % Inputs:
            %   nPeriods - number of periods to simulate
            %   tStep - simulation time step in months
            %   nSims - number of simulations to run
            %   nBatches - total number of batches 
            % Outputs:
            %   res = SimulationResults object
            
            % static model dependency resolution
            for i = 1:length(obj.risks)
                obj.risks(i).setSeniority(obj.risks, riskIndexResolver);
            end
            
            % housekeeping - empty out results folders
            delete( fullfile( 'simResults', '*.mat' ) );
            delete( fullfile( 'PruFiles', '*.csv'));
            delete( fullfile( 'AlgoFiles', '*.csv'));
            delete( fullfile( 'valReports', '*.csv'));

            % generate all correlated random numbers
            nRisks = numel( obj.risks );
            nStreams = zeros( nRisks, 1 ); % initialize
            for ii = 1:nRisks
                nStreams(ii) = obj.risks(ii).model.getNumberOfStochasticInputs();
            end
            fprintf('RSG - Msg: generating correlated random numbers \n');
            correlatedRisks = riskIndexResolver.getCorrelatedRisks();
            obj.correlatedStochasticInputs = obj.corrEngine.generateCorrelatedNumbers(correlatedRisks, nSims);
            fprintf('RSG - Msg: simulation started \n');
            
            obj.simEngine.simulate(step, nSims, nBatches, obj.correlatedStochasticInputs, riskIndexResolver);
            fprintf('RSG - Msg: simulation completed \n');
        end
        
        function validate(obj,setID,ruleSetName,detValues,stoValues)
            % detValues is a scenarioSet object
            % stoValues is a cell array of all simulation results
            obj.valEngine.validate(setID,ruleSetName,detValues,stoValues{1});
        end
        
    end 
end