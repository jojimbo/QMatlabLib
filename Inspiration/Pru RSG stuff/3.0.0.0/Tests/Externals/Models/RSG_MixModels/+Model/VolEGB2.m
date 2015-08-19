classdef VolEGB2 < prursg.Engine.Model    

    properties
        % model parameters
        mu = [];
        sigma = [];
        alpha=[];
        beta=[];
        
    end
        
    methods
        function obj = VolEGB2()
            % Constructor
            obj = obj@prursg.Engine.Model('VolLogEGB2');
        end

        function success_flag = calibrate(obj, dataObj, calibParamNames, calibParamTargets)
        	%No code for calibration for now
            success_flag = 1;
        end
        
        function inputs = getNumberOfStochasticInputs(obj)
            inputs = 1;
        end
        
        function outputs = getNumberOfStochasticOutputs(obj)
            outputs = obj.initialValue.getSize();
        end

        function series = simulate(obj, workerObj, corrNumElements)
            series=ones(1,obj.initialValue.getSize()); 
            simsurface = cell(length(corrNumElements),1);
            
            % again this will pull out a hypercube of initial values
            initValue = obj.initialValue.values{1};
            initValue = squeeze(initValue)'; %gets rid of the singleton dimension(s) VERY DUBIOUS THAT WE ARE TRANSPOSING... NOTE TO SELF: ADJUST X AND Y IN CONTROL SHEET SO THAT X IS DOWN
            
            %want dimensions of init surf and sigma to match, so remove rows if sigma too big
            sigma = obj.sigma;
            mu = obj.mu;
            alpha = obj.alpha;
            beta = obj.beta;
            d = size(sigma);
            e = size(initValue);
            f = size(mu);
            g = size(alpha);
            h = size(beta);
            if d(1)>e(1)
                sigma = sigma(1:e(1),:)	;
            end
            if f(1)>e(1)
                mu = mu(1:e(1),:)	;
            end
            if g(1)>e(1)
                alpha(1) = alpha(1:e(1),:);
            end
            if h(1)>e(1)
                beta = beta(1:e(1),:);
            end
                        
            rnum = normcdf(corrNumElements);
            for i=1:length(corrNumElements)                
                simsurface(i) = {mu - sigma.*(log(1./betainv(rnum(i),alpha,beta)-1)) + initValue};
            end
            
            % flatten surfaces
            for i0=1:length(corrNumElements)
                i4=0;
                mat=cell2mat(simsurface(i0));
                mat = mat'; %Note the Matlab read first from up to down, then left to right!
                for i1=1:size(mat,1)
                    for i2=1:size(mat,2)
                        i4=i4+1;
                        series(i0,i4)=mat(i1,i2);
                    end
                end
            end
            
            series = (series>0).*series + (series<=0)*0.0001;   %remove all negative values

	end
        
        function s = validateCalibration( obj )
            s = 'Not implemented';
        end
          
    end
    
end

