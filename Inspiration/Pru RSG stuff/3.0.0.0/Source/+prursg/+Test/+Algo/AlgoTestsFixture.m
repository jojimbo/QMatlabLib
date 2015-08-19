classdef AlgoTestsFixture
    %AlgoTestsFixture creates dummy test data for various algo scenario
    %files generators. Supports USD_fx, USD_nyc, GBP_equitycri_asx, GBP_nyc
    % as per Shauns' xml sample files
    
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
        
        function name = getAlgoBinaryFileName()
            name = 'SCEN_LM_GENERIC.bin';
        end
        
        function risks = makeRisks()
            % creates a list of several risk factors
            % the values of Model params are bogus but not essential
            % euro exchange rate
            %fxModel = prursg.Model.FXLognormal(1., 12);
            fxModel = prursg.Model.FXLognormal();
            r0 = prursg.Engine.Risk('USD_fx', fxModel);
            r0.risk_family = 'fx';
            r0.currency = 'USD';
            % simple equity
            %equityModel = prursg.Model.EquityLognormal(2048, [0.05, 0.02]);
            equityModel = prursg.Model.EquityLognormal();
            r1 = prursg.Engine.Risk('GBP_equitycri_asx', equityModel);
            r1.risk_family = 'equitycri';
            r1.currency = 'gbp';
            %
            % need 90 points for the yield curve time offsets    
            %ycModel = prursg.Model.YCCIR_Parallel(zeros(1, 90), [ 0.01, 0.02, 0.03 ]);
            ycModel = prursg.Model.YCCIR_Parallel();
            r2 = prursg.Engine.Risk('GBP_nyc', ycModel);
            r2.risk_family = 'nyc';
            r2.currency = 'GBP';
            
            % need 90 points for the yield curve time offsets    
            %ycModel = prursg.Model.YCCIR_Parallel(zeros(1, 90), [ 0.01, 0.02, 0.03 ]);
            ycModel = prursg.Model.YCCIR_Parallel();
            r3 = prursg.Engine.Risk('USD_nyc', ycModel);
            r3.risk_family = 'nyc';
            r3.currency = 'usd';
                        
            risks = [ r1 r2 r3 r0 ];            
        end
        
        function timesteps = prepareBaseTZeroScenarioTimesteps()
            % creates the timestep of a 'base t=0' scenario
            m = csvread(fullfile('+prursg', '+Algo', '+Data', 'base_t_greater_than_zero.csv'), 2, 3); % skip year 2009 go directly to 2010   
            universe = m(1, :);
            %
            theDate = '2010/12/31';
            expandedUniverse = containers.Map();
            expandedUniverse('GBP_equitycri_asx') = universe(1);
            expandedUniverse('GBP_nyc') = universe(2:2 + 90 - 1);
            expandedUniverse('USD_nyc') = universe(2 + 90:2 + 90 + 90 - 1);
            expandedUniverse('USD_fx') = universe(2 + 90 + 90);
            %
            timesteps = prursg.Engine.Timestep(theDate, expandedUniverse);
        end
                
    end %methods
    
end