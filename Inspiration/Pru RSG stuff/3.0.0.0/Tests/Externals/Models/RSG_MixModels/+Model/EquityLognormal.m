classdef EquityLognormal < prursg.Engine.Model    

    properties
        % model parameters
        mu = [];
        sigma = [];
        riskpremium = [];
    end
        
    methods
        function obj = EquityLognormal()
            obj = obj@prursg.Engine.Model('EquityLognormal');
        end

        function success_flag = calibrate(obj, dataObj, calibParamNames, calibParamTargets)
            % get historic index data from dataObj
            % MODEL API NOTE
            % 4) here first historical dataset are 0D, and we can use again the API
            % method getDataByName with no arguments
            y = dataObj{1}.getDataByName();
            r = dataObj{2}.getDataByName(1);
            % have made an assumption above as to the form of dataObj when we have more than dataseries to calibrate to.

            % get log returns minus rfr
            logreturn = zeros(length(y)-1,1);
            for i = 1:length(y)-1
                logreturn(i)=log(y(i)/y(i+1)) - log(1+r(i));
            end
            % de-mean log returns
            logreturn_adj = logreturn - mean(logreturn);
            
            obj.riskprem = (1+mean(logreturn))^12 - 1;
            obj.sigma = std(logreturn_adj)*sqrt(12); %assuming we have monthly data

            %success
            success_flag = 1;
        end
        
        function inputs = getNumberOfStochasticInputs(obj)
            inputs = 1;
        end
        
        function outputs = getNumberOfStochasticOutputs(obj)
            outputs = obj.initialValue.getSize();
        end
        
        function series = simulate(obj, workerObj, corrNumElements)
            %t = obj.simEngine.simTimeStepInMonths/12;
            % MODEL API NOTE
            % 12) results of other risks are always accessible by the
            % getSimResults method (whether they have been calculated or
            % not). One can also go via the list of
            % precedents like in NOTE (11), risk in that list will always have
            % been calculated before this risk and going that way also
            % ensures no typos here
            precedentsList = obj.getPrecedentObj();
            %Y1 = workerObj.getSimResults(precedentList('r')); 
            precedent = precedentsList('r'); % modeller would know the first one (and the only one here) is the one needed
            %Y11 = Y1(:,1); % 1y points of nyc serve as annualised short rate
            Y1 = workerObj.getInitVal(precedent);   %the risk-free rate shoudl be the initial values rather than the simulated one (also fwd=spot for term <= 1Y)
            Y11 = Y1.values{1}(3); % 1y points of nyc serve as annualised short rate (note we have 0.25 and 0.5 before 1Y)            
            
            %mu = obj.riskprem+Y11;            
            %series = obj.initialValue.values{1}.*(1+mu).*exp((mu + obj.sigma^2)*t + obj.sigma*sqrt(t)*corrNumElements);
            drift = obj.riskpremium+Y11;            
            series = obj.initialValue.values{1}.*(drift + exp(obj.mu + obj.sigma*corrNumElements));
        end
        
        function s = validateCalibration( obj )
            s = 'Not implemented';
        end       
        
    end    
end

