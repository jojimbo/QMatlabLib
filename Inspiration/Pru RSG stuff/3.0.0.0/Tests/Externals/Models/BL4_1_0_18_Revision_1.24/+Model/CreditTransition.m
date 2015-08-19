classdef CreditTransition < prursg.Engine.Model
    
    properties
        % model parameters
        AAA = [];
        AA = [];
        A = [];
        BBB = [];
        BB = [];
        B = [];
        sigma = [];
    end
    
    methods
        function obj = CreditTransition()
            % Constructor
            obj = obj@prursg.Engine.Model('CreditTransition');
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
            
            precedentsList = obj.getPrecedentObj();
            precedent  = precedentsList('fod');
            fod = workerObj.getSimResults(precedent);
            
            finalCreditRating = workerObj.currentRisk.name;
            
            if      ~isempty(strfind(finalCreditRating,'toaaa'))
                
                CumZValue1 = 10; %this represents the Z Value for probability 1
                CumZValue2 = norminv( obj.AA + obj.A + obj.BBB + obj.BB + obj.B,0,1);
                
            elseif ~isempty(strfind(finalCreditRating,'toaa'))
                
                CumZValue1 = norminv( obj.AA + obj.A + obj.BBB + obj.BB + obj.B,0,1);
                CumZValue2 = norminv( obj.A + obj.BBB + obj.BB + obj.B,0,1);
                
            elseif ~isempty(strfind(finalCreditRating,'toa'))
                
                CumZValue1 = norminv( obj.A + obj.BBB + obj.BB + obj.B,0,1);
                CumZValue2 = norminv( obj.BBB + obj.BB + obj.B,0,1);
                
            elseif ~isempty(strfind(finalCreditRating,'tobbb'))
                
                CumZValue1 = norminv( obj.BBB + obj.BB + obj.B,0,1);
                CumZValue2 = norminv( obj.BB + obj.B,0,1);
                
            elseif ~isempty(strfind(finalCreditRating,'tobb'))
                
                CumZValue1 = norminv( obj.BB + obj.B,0,1);
                CumZValue2 = norminv( obj.B,0,1);
                
            elseif ~isempty(strfind(finalCreditRating,'tob'))
                
                CumZValue1 = norminv( obj.B,0,1);
                CumZValue2 = -10;  %this represents the Z Value for probability 0
            end
            
            series = ...
                normcdf(CumZValue1 + norminv(normcdf(fod,0,1),0,obj.sigma),0,1)...
                -  normcdf(CumZValue2 + norminv(normcdf(fod,0,1),0,obj.sigma),0,1);
        
        end
        
        function s = validateCalibration( obj ) %#ok<MANU>
            s = 'Not implemented';
        end
    end
end 
    
