classdef VolNormal < prursg.Engine.Model    

    properties
        % model parameters
        sigma = [];
    end
        
    methods
        function obj = VolNormal()
            % Constructor
            obj = obj@prursg.Engine.Model('VolNormal');
        end

        function success_flag = calibrate(obj, dataObj, calibParamNames, calibParamTargets)
		% MODEL API NOTE
        % 5) this is an example of how to iterate through all data and create
        % a flattened structure to work with
        i4 = 0;
	for i1 = 1:length(dataObj{1}.axes(1).values)
            for i2 = 1:length(dataObj{1}.axes(2).values)
                for i3 = 1:length(dataObj{1}.axes(3).values)
                    i4 = i4 + 1;
                    y(:,i4) = dataObj{1}.getDataByName(dataObj{1}.axes(1).values(i1),dataObj{1}.axes(2).values(i2),dataObj{1}.axes(3).values(i3));
                end
            end
        end
		
		chng = zeros(size(y,1)-1,size(y,2));
        chng = (y(1:end-1,:) - y(2:end,:))/100;
        obj.sigma = std(chng);
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
	    series=ones(1,obj.initialValue.getSize()); %hard coding size :(
            simsurface = cell(length(corrNumElements),1); % and again
	    
        % again this will pull out a hypercube of initial values
        initValue = obj.initialValue.values{1};
	initValue = squeeze(initValue); %gets rid of the singleton dimension

	%want dimensions of init surf and sigma to match, so remove rows if sigma too big
	sigma = obj.sigma;
	d = size(sigma);
	e = size(initValue);
	if d(1)>e(1)
		sigma = sigma(1:e(1),:)	;
	end

	for i=1:length(corrNumElements)
	    simsurface(i) = {initValue + corrNumElements(i)*sigma*sqrt(12)};
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

	end
        
        function s = validateCalibration( obj )
            s = 'Not implemented';
        end
          
    end
    
end

