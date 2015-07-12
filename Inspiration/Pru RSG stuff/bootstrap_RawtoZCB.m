classdef bootstrap_RawtoZCB
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    % Description
    % 03/10/2011 Graeme Lawson
    % This class extrapolates and interpolates raw market yield curve data
    % to produce a Zero Coupon Bond (ZCB) yield curve
    
    properties
        method       
    end
    
    methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Constructor
    
       function obj = bootstrap_RawtoZCB ()
         
       end                  
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Other Methods
    
      function results = bs(obj,DataSeriesIn, ParametersIn)                    
           % import prursg.Bootstrap.*;
           obj.method = ParametersIn{7};
          
          switch lower(obj.method) % Change strings to lower case 
              case 'wilson smith'
                 % Create a new Wilson Smith Bootstap Object 
                 newWilsoSmith = prursg.Bootstrap.BsWilsonSmith(DataSeriesIn, ParametersIn);
                 % Fit Wilson Smith to our Raw Data
                 newWilsoSmith.FitWilsonSmithParameters
                 results= newWilsoSmith.WilsonsSmithZCBPrices;
              case 'cubic spline'
              
              otherwise
                  disp('Unknown method.')
          end
       
      end
    
    end
    
end

