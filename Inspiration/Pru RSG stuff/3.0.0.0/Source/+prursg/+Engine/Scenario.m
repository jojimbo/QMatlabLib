classdef Scenario < handle
    %SCENARIO replaces the obsoleted timestep class
    
    properties
        id
        name % name follows PRU file convention
        scen_step % relative offset from the session date
        date %datenum of the timestep
        number % 0 means - historical point. >0 means stochastic scenario        
        %
        %
        expandedUniverse % a container.Map(risk.name, DataSeriesObject)
        isNoRiskScenario
        isStochasticScenario
        isShockedBase
        
        % CR 161
        simResults % store stochastic sim results.
    end
        
    methods
        function obj = Scenario()
            obj.expandedUniverse = containers.Map();
            obj.isNoRiskScenario = 0;
            obj.isStochasticScenario = 0;
            obj.isShockedBase = 0;
        end
        
        function hyperCube = getRiskScenarioValues(obj, riskName)
            hyperCube = obj.expandedUniverse(riskName).values{1};
        end
                      
        % get sim results in a matrix form.
        function values = getSimResults(obj, risks)
            if isempty(risks)
                values = obj.simResults;
            else
                chunks = cell(1, numel(risks));
                for i = 1:numel(risks)
                    chunks(i) = { obj.expandedUniverse(risks(i).name).serialise() }; 
                end
                values = cell2mat(chunks);
            end
        end

        % newValues is taken from the database, if we inspect function
        % insertExpandedUniverser in NoRiskScenarioDao.m, we can see that:
        % THE VALUES ARE STORED IN THE ORDER OF THE EXPANDEDUNIVERSE!
        function updateExpandedUniverse(obj, newValues, riskDrivers, numSubRisks)
            for i = 1:numel(riskDrivers)
                riskDriverName = riskDrivers(i).name;
                startIndex = numSubRisks(i, 2); 
                endIndex = numSubRisks(i, 3); 
                dataSeries = obj.expandedUniverse(riskDriverName); 
                dataSeries.values = {prursg.Engine.HyperCube.deserialise(dataSeries.axes, newValues(startIndex:endIndex))};
                obj.expandedUniverse(riskDriverName) = dataSeries;
            end
        end           


        
    end
    
    methods (Static)
        % according to pru file format 
        function s = makeDeterministicScenario(date, step)
            s = prursg.Engine.Scenario();
            s.name = 'assets';
            s.number = 0;
            s.date = date;
            s.scen_step = step;
        end

        % apparently 'expandedUniverse' should be a full blown class and
        % this method must be defined ot its scope.
        function size = getExpandedUniverseSize(expandedUniverse)
            riskNames = keys(expandedUniverse);
            size = 0;
            for i = 1:numel(riskNames)
                hyperCube = expandedUniverse(riskNames{i}).values{1};
                size = size + numel(hyperCube);
            end
        end
        
        % and this one as well
        function nAxes = getTotalNumberOfAxes(expandedUniverse)        
            riskNames = keys(expandedUniverse);
            nAxes = 0;
            for i = 1:numel(riskNames)
                dseries = expandedUniverse(riskNames{i});
                nAxes = nAxes + numel(dseries.axes);
            end
        end
        
                
        function yesNo = areEqual(one, other)
            yesNo = isempty(one) && isempty(other) ...
                || (isequal(class(one), class(other)) ...
                 && areArrayEqual(one, other)); 
        end
        
        
    end
    
end

function yesNo = areArrayEqual(one, two)
    yesNo = isequal(size(one), size(two));
    if yesNo
        for i = 1:numel(one)
                yesNo = isequal(one(i).name, two(i).name) ...
                     && (one(i).scen_step == two(i).scen_step) ...
                     && (one(i).date == two(i).date) ...
                     && (one(i).number == two(i).number) ...
                     && universesAreEqual(one(i).expandedUniverse, two(i).expandedUniverse);            
        end
    end
end



function yesNo = universesAreEqual(one, two)
    yesNo = (numel(keys(one)) == numel(keys(two)));
    if yesNo
        risks = keys(one);
        for i = 1:numel(risks)
            ds1 = one(risks{i});
            ds2 = two(risks{i});
            yesNo = yesNo && isequal(ds1.values, ds2.values);        
            yesNo = yesNo && prursg.Engine.Axis.areEqual(ds1.axes, ds2.axes);
        end        
    end
end
