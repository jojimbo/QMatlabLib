classdef Empirical < prursg.Engine.Model    

    properties
        % model parameters        
    end
        
    methods
        function obj = Empirical()
            % Constructor
            obj = obj@prursg.Engine.Model('Empirical');
        end

        function success_flag = calibrate(obj, dataObj, calibParamNames, calibParamTargets)		
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
            %Load calibration parameters (empirical calibration targets and
            %values are just the model parameters and values
            calibTargets = obj.calibrationTargets;
            for j = 1:length(calibTargets)
                percentiles{j} = calibTargets(j).percentile;
                values{j} = calibTargets(j).value;
            end
            percentiles = str2double(percentiles); %array of percentiles
            values = cell2mat(values);             %array of values
            u = normcdf(corrNumElements);
            
            series = zeros(size(u));
            for i=1:size(u,1)
                for j=1:length(percentiles)
                    if u(i)<=percentiles(j)
                        series(i) = values(j);
                        break
                    end
                end
            end
        end
        
        function s = validateCalibration( obj )
            s = 'Not implemented';
        end
       
        
    end
    
end

