classdef bootstrap_RawtoZCB_RiskCare < prursg.Bootstrap.BaseBootstrapAlgorithm
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    % Description
    % 03/10/2011 Graeme Lawson
	% Modified 25/11/2011 Jorge Pastor
    % This class extrapolates and interpolates raw market yield curve data
    % to produce a Zero Coupon Bond (ZCB) yield curve
    
    properties
        method
		% Parameters used to control interpolation/extrapolation method
        outputfreq
        ltfwd %longTermFwdRate
        llp % lastLiquidPoint
        decayrate
        startterm %outputStartTerm
        endterm %outputEndTerm
%		% Raw Data related Parameters & Arrays
%        ratetype
%        compounding
%        compoundingfrequency
%        daycount
%        units
		% local object validation parameters
        minValidRate = -0.05;
        MaxValidRate = 5;
				
    end
    
    methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Constructor
    function obj = bootstrap_RawtoZCB_RiskCare ()
		obj = obj@prursg.Bootstrap.BaseBootstrapAlgorithm();
    end                  
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Other Methods
    
    function results = Bootstrap(obj,DataSeriesIn)
		
		% import prursg.Bootstrap.*;
        switch lower(obj.method) % Change strings to lower case 
            case 'wilson smith'
				ParametersIn{1} = obj.outputfreq;
				ParametersIn = [ParametersIn obj.ltfwd obj.llp obj.decayrate obj.startterm obj.endterm obj.method];
                % Create a new Wilson Smith Bootstap Object 
                %newWilsoSmith = prursg.Bootstrap.BsWilsonSmith_RiskCare(DataSeriesIn, ParametersIn);
                newWilsoSmith = Bootstrap.BsWilsonSmith_RiskCare(DataSeriesIn, ParametersIn);
                % Fit Wilson Smith to our Raw Data
                newWilsoSmith.FitWilsonSmithParameters
                results= newWilsoSmith.WilsonsSmithZCBPrices;
            case 'cubic spline'
			
            otherwise
                disp('Unknown method.')
        end
	end
	
	
	function Calibrate(obj, inDataSeries)
		
    end
	
	
    
    end
    
end