classdef bootstrap_RawSwapIVtoSwapIV
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    % Description
    % 24/11/2011 Graeme Lawson
    % This class extrapolates and interpolates raw market yield curve data
    % to produce a Zero Coupon Bond (ZCB) yield curve
    
    % Parameters 1 to 6 are used in bootstrap_SwaptionPrice
    % Parameters 7 to end are used in bootstrap_LinearInterpolation
    
    properties
        method       
    end
    
    methods
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Constructor
    
       function obj =  bootstrap_RawSwapIVtoSwapIV ()
         
       end                  
        
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Other Methods
    
      function results = bs(obj,DataSeriesIn, ParametersIn)                    
           % import prursg.Bootstrap.*;
           obj.method = ParametersIn{7};
          
          switch lower(obj.method) % Change strings to lower case 
              case 'ivconstantextrap'                
                 % Description :: Method takes an implied vol surface and constant extrapolates the surface either in normal
                 % our lognormal space
                
                  % Create a new Data Series Object 
                 newIVDataseries = prursg.Bootstrap.bootstrap_SwaptionPrice();
                 IVDataseries = newIVDataseries.bs(DataSeriesIn, ParametersIn(1:6));
                 % Fit Wilson Smith to our Raw Data
                 newextrapolatedIVDataseries =  prursg.Bootstrap.bootstrap_LinearInterpolation();                             
                 extrapolatedIVDataseries  =  newextrapolatedIVDataseries.bs(IVDataseries, ParametersIn(9:end));
                 extrapolatedIVDataseries.addprop('volatilityType');
                 extrapolatedIVDataseries.volatilityType = ParametersIn{5};
                 
                 NewParameters = ParametersIn;
                 
                 NewParameters {1} = ParametersIn{10};    % Output Swap Tenors
                 NewParameters {2}= ParametersIn{11}; % Output Swap Maturities               
                 NewParameters {5} = ParametersIn{8}  ; % Output: Price, LogNormal Vol, or Normal Vol                
                  
                 DataSeriesIn(2) = extrapolatedIVDataseries  ;  
                 results = newIVDataseries.bs(DataSeriesIn, NewParameters (1:6));
                 
                 
              otherwise
                  disp('Unknown method.')
          end
       
      end
    
    end
    
end

