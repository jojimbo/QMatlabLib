classdef FXLognormal < prursg.Engine.Model    

    properties
        % model parameters
        sigma = [];
    end
        
    methods
        function obj = FXLognormal()
            % Constructor
            obj = obj@prursg.Engine.Model('FXLognormal');
        end

        function success_flag = calibrate(obj, dataObj, calibParamNames, calibParamTargets)
            %get data from dataObj
            y = dataObj{1}.getDataByName();

            %get log returns
            logreturn = zeros(1, length(y) - 1);
            for i = 1:length(y)-1
                logreturn(i)=log(y(i)/y(i+1));
            end
            logreturn = logreturn - mean(logreturn); % de-mean returns
            obj.sigma = std(logreturn)*sqrt(12); %assuming we have monthly data

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
            t = 12;
            series = obj.initialValue.values{1} * exp(obj.sigma*sqrt(t)*corrNumElements);
        end
        
        function s = validateCalibration(obj)
            s = 'Not implemented';
        end
        
    end
end

