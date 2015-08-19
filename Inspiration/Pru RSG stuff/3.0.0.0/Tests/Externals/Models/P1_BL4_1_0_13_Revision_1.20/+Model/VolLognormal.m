classdef VolLognormal < prursg.Engine.Model    

    properties
        % model parameters
        sigma = [];
    end
        
    methods
        function obj = VolLognormal()
            % Constructor
            obj = obj@prursg.Engine.Model('VolLognormal');
        end

        function success_flag = calibrate(obj, dataObj, calibParamNames, calibParamTargets)
        	% Model API NOTE
            % 1) dataObj is a cell array of instantiated DataSeries objects populated with historical data,
            % in the order specified under the "calibration_sources" XML node
            % Modl API NOTE
            % 2) the DataSeries object ships with API for pulling out data, for
            % example in here we are using the getDataByName method
        	y(:,1) = dataObj{1}.getDataByName(1,100);
            y(:,2) = dataObj{1}.getDataByName(3,100);
            y(:,3) = dataObj{1}.getDataByName(5,100);
		
    		% do each point's calibration seperately (could do this better)
            returns = zeros(size(y,1)-1,3);
            for i = 1:size(y,1)-1
                for j = 1:3
                    returns(i,j) = y(i,j)/y(i+1,j) - 1;
                end
            end
            obj.sigma = std(returns)';
            success_flag = 1;
        end
        
        function inputs = getNumberOfStochasticInputs(obj)
            inputs = 1;
        end
        
        function outputs = getNumberOfStochasticOutputs(obj)
            outputs = obj.initialValue.getSize();
        end

        function series = simulate(obj, workerObj, corrNumElements)
	    series=ones(1,3); %hard coding size :(
            simsurface = cell(length(corrNumElements),1); % and again
	    
        % again this will pull out a hypercube of initial values
        initValue = obj.initialValue.values{1};
	initValue = squeeze(initValue)'; %gets rid of the singleton dimension(s) VERY DUBIOUS THAT WE ARE TRANSPOSING... NOTE TO SELF: ADJUST X AND Y IN CONTROL SHEET SO THAT X IS DOWN

	%want dimensions of init surf and sigma to match, so remove rows if sigma too big
	sigma = obj.sigma;
	d = size(sigma);
	e = size(initValue);
	if d(1)>e(1)
		sigma = sigma(1:e(1),:)	;
	end

	for i=1:length(corrNumElements)
	    simsurface(i) = {initValue .* exp(-0.5*12*sigma.^2 + corrNumElements(i)*sigma*sqrt(12))};
	end

	% flatten surfaces
	for i0=1:length(corrNumElements)
	i4=0;
		mat=cell2mat(simsurface(i0));
		for i1=1:size(mat,1)
			for i2=1:size(mat,2)
				i4=i4+1;
				series(i0,i4)=mat(i1,i2);
			end
		end
	end
	series = (series>=0.05).*series + (series<0.05)*0.05;   %floor values at 5%  
	end
        
        function s = validateCalibration( obj )
            s = 'Not implemented';
        end
          
    end
    
end

