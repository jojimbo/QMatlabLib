classdef CreditTransitionMP < prursg.Engine.Model
    
    properties
        % model parameters
        p = [];
        h = [];
        sigma = [];
    end
    
    methods
        function obj = CreditTransitionMP()
            % Constructor
            obj = obj@prursg.Engine.Model('CreditTransitionMP');
        end
        
        % Perform calibration
        function success_flag = calibrate(obj, dataObj, calibParamNames, calibParamTargets)
            % no calibration in RSG
            success_flag = 1;
        end
        
        function inputs = getNumberOfStochasticInputs(obj)
            inputs = 1;
        end
        
        function outputs = getNumberOfStochasticOutputs(obj)
            outputs = obj.initialValue.getSize();
        end
        
        function series = simulate(obj, workerObj, corrNumElements)
            Ilist = {'aaa','aa','a','bbb','bb','b'};
            Jlist = {'aaa','aa','a','bbb','bb','b','ccc','d'};
            
            precedentsList = obj.getPrecedentObj();
            R = corrNumElements;
            
            myCreditRating = workerObj.currentRisk.name;
            for ii = 1:length(Jlist)
                fromRating = strcat('_',Jlist{ii});
                toRating = strcat('to',Jlist{ii});
                if      ~isempty(strfind(myCreditRating,toRating))
                    myToSpd = ii;
                end
                if      ~isempty(strfind(myCreditRating,fromRating))
                    myFromSpd = ii;
                end
            end
            
            for ii = 1:length(Ilist)
                for jj = 1:length(Jlist)
                    h(ii,jj) = workerObj.riskFactors(1,jj+(ii-1)*length(Jlist)).model.h;
                    sigma(ii,jj) = workerObj.riskFactors(1,jj+(ii-1)*length(Jlist)).model.sigma;
                end
            end
            
            for ii = 1:length(Ilist)
                for jj = 1:length(Jlist)
                    if ii == 1 && jj ==1
                        p(ii,jj) = min(exp(-(h(ii,length(Jlist)) + sigma(ii,length(Jlist)) * R)),1);
                    elseif ii == jj
                        p(ii,jj) = min(exp(-(h(ii,1)+sigma(ii,1) * R)),1);
                    elseif jj == ii+1
                        p(ii,jj) = max( ((p(ii,ii)-1)/log(p(ii,ii)) * (h(ii,jj) + sigma(ii,jj) * R) ),0);
                    end
                end
            end
            
            for jj = 3:length(Jlist)
                p(1,jj) = max( ((p(1,1)-1)/log(p(1,1)) * (h(1,jj) + sigma(1,jj) * R) ) -sum(p(1,2:jj-1)), 0);
            end
            
            for ii = 2:length(Ilist)
                for jj = ii+2:length(Jlist)
                    p(ii,jj) = max( ((p(ii,ii)-1)/log(p(ii,ii)) * (h(ii,jj) + sigma(ii,jj) * R) ) -sum(p(ii,ii+1:jj-1)), 0);
                end
            end
            for ii = 2:length(Ilist)
                for jj = ii-1:-1:1
                    p(ii,jj) = max( ((p(ii,ii)-1)/log(p(ii,ii)) * (h(ii,jj) + sigma(ii,jj) * R) ) -sum(p(ii,jj+1:end))+p(ii,ii), 0);
                end
            end
            
            
            series = p(myFromSpd,myToSpd);
            
        end
        
        function s = validateCalibration( obj ) %#ok<MANU>
            s = 'Not implemented';
        end
    end
end

