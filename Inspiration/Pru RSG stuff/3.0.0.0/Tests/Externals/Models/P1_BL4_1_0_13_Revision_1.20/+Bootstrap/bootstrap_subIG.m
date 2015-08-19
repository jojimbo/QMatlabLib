classdef bootstrap_subIG < handle
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
     % Enter Description
     properties
         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
         % Data Series
         InvestmentGrade = [];
         
         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
         % Parameters
         
         subIGratings = [];
         IndexValue = [];
         RecoveryRate = [];
         Duration = [];
         
     end
    
    methods
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Constructor
    
       function obj = bootstrap_subIG ()
           
       end
                  
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Other Methods
    
        function results = bs(obj, DataSeriesIn, ParametersIn)
            
            obj.InvestmentGrade = DataSeriesIn;
            
            obj.subIGratings = ParametersIn{1};
            obj.IndexValue = ParametersIn{2};
            obj.RecoveryRate = ParametersIn{3};
            obj.Duration = ParametersIn{4};            
            
            % interpolation
            D = str2num(obj.IndexValue)*(1/str2num(obj.RecoveryRate)^(1/str2num(obj.Duration))-1);
            num_subIG = size(strfind(obj.subIGratings,','),2)+1;
            LastIG_pos = find(obj.InvestmentGrade.values{1}>0,1,'last');
            delta = (D/obj.InvestmentGrade.values{1}(LastIG_pos))^(1/num_subIG);
            
            subIG(1) = obj.InvestmentGrade.values{1}(LastIG_pos)*delta;
            for i = 2:num_subIG
                subIG(i) = subIG(i-1)*delta;
            end
            
            results = obj.InvestmentGrade;
            results.values{1}(1:LastIG_pos) = obj.InvestmentGrade.values{1}(1:LastIG_pos);
            results.values{1}(LastIG_pos+1:num_subIG+4) = subIG(1:num_subIG);

            
        end
                  
        

    end
    
end

