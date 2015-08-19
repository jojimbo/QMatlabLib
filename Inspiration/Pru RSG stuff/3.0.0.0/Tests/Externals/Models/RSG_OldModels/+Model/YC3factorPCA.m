classdef YC3factorPCA < prursg.Engine.Model    
   
    properties
        % model parameters
        PC1 = [];
        PC2 = [];
        PC3 = [];
        sigma1 = [];
        sigma2 = [];
        sigma3 = [];
	FwdCalib = []; 
    end
        
    methods
        function obj = YC3factorPCA()
            % Constructor
            obj = obj@prursg.Engine.Model('YC3factorPCA');
        end
        
        % Perform calibration
        function success_flag = calibrate(obj, dataObj, calibParamNames, calibParamTargets)
	    % no calibration in RSG
            success_flag = 1;
        end

        function inputs = getNumberOfStochasticInputs(obj)
            inputs = 3;
        end
        
        function outputs = getNumberOfStochasticOutputs(obj)
            outputs = obj.initialValue.getSize();
        end        
        
        function series = simulate(obj, workerObj, corrNumElements)


            % MODEL API NOTE
            % 7) initial values are contained again in the familiar
            % DataSeries object, this object has property "values" which is
            % a cell array of hypercubes, with as many hypercubes as there
            % are dates. Since this is an initialValue, there will always
            % only be one hypercube hence we can pull out the entire
            % initial value curve by obj.initialValue.values{1} and used
            % directly
            Y0 = obj.initialValue.values{1};

	    %convert init yield to fwd
	    FWD0(1)=Y0(1);
	    for i = 2:length(Y0)
		FWD0(i) = (1+Y0(i))^i /(1+Y0(i-1))^(i-1) - 1;
	    end

            % MODEL API NOTE
            % 8) random numbers come in an array, as many row as there are
            % number of sims, and as many columns as there are sources of
            % randomness
            for i = 1:length(Y0)
                for j = 1:size(corrNumElements,1)
		    %simulation on calibration forward
                    series(i,j) = obj.FwdCalib(i)*exp(sqrt(12)*(obj.sigma1 * corrNumElements(j,1) * obj.PC1(i) + obj.sigma2 * corrNumElements(j,2) * obj.PC2(i) + obj.sigma3 * corrNumElements(j,3) * obj.PC3(i)));
                    %apply shifts to initial forward
		    series(i,j) = FWD0(i) + series(i,j) - obj.FwdCalib(i);
		    %convert fwd to spot
		    if i > 1
			series(i,j) = ((1+series(i-1,j))^(i-1) * (1+series(i,j)))^(1/i)-1;
		    end
		end
            end
            % MODEL API NOTE
            % 9) simulation output should always have scenarios going along
            % rows and risk factor going along columns, so taking transpose
            % here

            series = series';
	end
        
        function s = validateCalibration( obj ) %#ok<MANU>
            s = 'Not implemented';
        end
    end
end

