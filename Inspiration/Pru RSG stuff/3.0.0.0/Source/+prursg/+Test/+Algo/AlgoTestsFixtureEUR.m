classdef AlgoTestsFixtureEUR
    %AlgoTestsFixture creates dummy test data for various algo scenario
    %files generators. Supports 3 eur risk factors
    
    methods (Static)
        
        function curr = getBaseCurrency()
            curr = 'GBP';
        end
        
        function tDate = getSessionDate()
            tDate = '2010/12/31';
        end
        
        function name = getCurveRoomFileName()
            name = 'risk_drivers.csv';
        end
        
        function name = getDeterministicScenarioFileName()
            name = 'LM_Asset_Macro_ScenSet.csv';
        end
        
        function name = getManifestScenarioName()
            name = 'SCEN_LM_GENERIC';
        end
        
        function risks = makeRisks()
            % creates a list of several risk factors
            % the values of Model params are bogus but not essential
            % euro exchange rate
            fxModel = prursg.Model.FXLognormal(1., 12);
            r0 = prursg.Engine.Risk('EUR_fx', fxModel, []);
            r0.risk_family = 'fx';
            r0.currency = 'eur';
            % simple equity
            equityModel = prursg.Model.EquityLognormal(2048, [0.05, 0.02]);
            r1 = prursg.Engine.Risk('EUR_equity_dax', equityModel, []);
            r1.risk_family = 'equitycri';
            r1.currency = 'eur';
            %
            % need 90 points for the yield curve time offsets    
            ycModel = prursg.Model.YCCIR_Parallel(zeros(1, 90), [ 0.01, 0.02, 0.03 ]);
            r2 = prursg.Engine.Risk('EUR_nyc', ycModel, []);
            r2.risk_family = 'nyc';
            r2.currency = 'eur';
            risks = [ r0 r1 r2 ];            
        end
        
        function timesteps = prepareBaseTZeroScenarioTimesteps()
            % creates the timestep of a 'base t=0' scenario
            m = csvread(fullfile('+prursg', '+Algo', '+Data', 'risk-factor-scenarios.csv'), 1, 2);    
            universe = m(1, :);
            universe = universe(2:end); % first column is the duplicated EUR_fx exchange rate
            %
            theDate = '2010/12/31';
            expandedUniverse = containers.Map();
            expandedUniverse('EUR_fx') = universe(1);
            expandedUniverse('EUR_equity_dax') = universe(2);
            expandedUniverse('EUR_nyc') = universe(3:end);
            %
            timesteps = prursg.Algo.Timestep(theDate, expandedUniverse);
        end
                
    end %methods
    
end