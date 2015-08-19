classdef CredTiltedLaplace < prursg.Engine.Model    

    properties
        % model parameters
        mu = [];
        sigma = [];        
        theta = [];
        r0 = [];
        pivot = [];
        Scalar = [];
    end
        
    methods
        function obj = CredTiltedLaplace()
            % Constructor
            obj = obj@prursg.Engine.Model('CredTiltedLaplace');
        end

        function success_flag = calibrate(obj, dataObj, calibParamNames, calibParamTargets)
	    % no calibration in RSG for moment
            success_flag = 1;
        end
        
        function inputs = getNumberOfStochasticInputs(obj)
            inputs = 1;
        end
        
        function outputs = getNumberOfStochasticOutputs(obj)
            outputs = obj.initialValue.getSize();
        end
        
        function series = simulate(obj, workerObj, corrNumElements)            
            % MODEL API NOTE
            % 10) see below for API to pull out precedents of the current
            % risk factor, note it is in general a cell array of strings, which are names
            % matching the names given in the XML model file
            precedentList = obj.getPrecedentObj();
            if str2num(precedentList('parent_spread')) == 0 % modeller has to remember that zero denotes no precedent credit risk factor
                parent = 0;
                parentinit = 0;
            else
                precedent = precedentList('parent_spread');
            	parent = precedent;
                % MODEL API NOTE
                % 13) the getInitVal method allows you to access the initial
                % value of any other risks, and again it comes in as a
                % DataSeries object, within which the "values" property
                % contains a cell array of hypercubes, since it's an
                % initial value there is only one cube so we pick the first
                % one
                parentinit = workerObj.getInitVal(precedent).values{1};
                parentresults = workerObj.getSimResults(precedent);
            end

            initValue = obj.initialValue.values{1}; % pulls out entire curve of initial values

            %all parameters
            mu = obj.mu;
            sigma = obj.sigma;        
            theta = obj.theta;
            r0 = obj.r0;
            pivot = obj.pivot;
            Scalar = obj.Scalar;
            
            %Uniform random number
            rnum = normcdf(corrNumElements);
            
            threshold = ((1 - theta) / 2) * ones(size(rnum,1),1);
            simVal = (rnum<threshold) .* (mu + log(2 * rnum / (1 - theta)) * (1 - theta) * sigma) + ...
                (rnum>=threshold) .* (mu - log(2 * (1 - rnum) / (1 + theta)) * (1 + theta) * sigma);
            
            
%             if rnum < (1 - theta) / 2
%               simVal = mu + log(2 * rnum / (1 - theta)) * (1 - theta) * sigma;
%             else
%               simVal = mu - log(2 * (1 - rnum) / (1 + theta)) * (1 + theta) * sigma;
%             end
            
            %Lambda transformation
            shift = log(exp(simVal) * (exp(r0/pivot) - 1) + 1) * pivot - r0;
            shift = shift * Scalar;
            %calibSpread = shift + initValue(1);
            %calibSpread = (calibSpread<=0)*0.0001 + (calibSpread>0).*calibSpread;
            
            %now form output
            for i =1:length(initValue)
                if parent == 0
                    series(i,:) = shift' + initValue(i);
                else
                    minimumShiftValue = 0.0001;
                    series(i,:) = max(shift' + initValue(i) - parentinit(i) + parentresults(:,i)',parentresults(:,i)'+ minimumShiftValue) ; %limit spread so that not less than parent's spread
                end
            end
            outputFloorValue = 0.0001;
            series = max(series, outputFloorValue)';
        end
        
        function s = validateCalibration( obj )
            s = 'Not implemented';
        end
        
    end
    
end

