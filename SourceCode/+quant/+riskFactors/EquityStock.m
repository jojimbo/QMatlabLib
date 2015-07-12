%% Object Class EquityStock

classdef EquityStock < quant.riskFactors.Equity & handle
    
    %% Properties
    properties
        Name %Name of the Stock/ID
    end
    
    %% Abstract methods of Public access (and Static)
    methods (Access = public, Static) 
    end
    
    %% Static methods - e.g. Constructor
    methods (Static)
        function OBJ = EquityStock(Name)
           if nargin == 0 % Support calling with 0 arguments
               OBJ.Name = 'Unknown';
           elseif nargin == 1
               OBJ.Name = Name;
           else
               OBJ.Name = Name;
           end
       end
    end
    
   %% Non-Static methods
   methods
   end
    
end