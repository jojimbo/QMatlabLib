%% SYNTHETIC TOTAL RETURN INDEX
% 
% *The class derives a synthetic equity Total Return Index (TRI) from an available
% Capital Return Index (CRI) by using MSCI TRI/CRI as proxies.*
%
%% 
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classdef bootstrap_syntheticTRI < prursg.Bootstrap.BaseBootstrapAlgorithm
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%% How to Use the Class
%
% This class inherits the properties and methods from the parent class |[BaseBootstrapAlgorithm]|.
%
% It contains two methods, one is |[Bootstrap]| and the other is |[Calibrate]|.
% New properties have been defined and the default method |[Bootstrap]| has been
% overwritten.
%
% The re-defined |[Bootstrap]| method produces a synthetic equity TRI from an
% available CRI by using the dividend yield calculated from the MSCI TRI and 
% the MSCI CRI in that currency as a proxy.
%
% Method |[Calibrate]| calibrates parameters which are then used in
% bootstrap methods. 
% We have not created a calibrate method.
%
%% Properties
%
% *|[synIndexBaseValue]|* : base start Total Return Index value, e.g. "10000" 
%
% _Data Type_: double
%
% *|[startDate]|* : start date from which the return change is measured
%
% _Data Type_: string
%
%%
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
    properties 
 
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
      % Parameters   
        synIndexBaseValue
        startDate
    end
%% List of Methods
% The class introduces one new method:
%
% *|1)[Bootstrap()]|* : The class produces a synthetic equity total return index
% from a capital return index
%
%%
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
  methods
    % Constructor    
       function obj = bootstrap_syntheticTRI ()
           obj = obj@prursg.Bootstrap.BaseBootstrapAlgorithm();   
       end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%       
%% Details of Methods
%
% *1) [Bootstrap()]|*
%
% """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
%
% *|_Description_|*
%
% The class produces a synthetic equity TRI from an available CRI by using 
% the dividend yield calculated from the MSCI TRI and the MSCI CRI as a proxy.
%
% *|_Inputs_|*
%
% *|[DataSeriesIn]|* - 3 equity indices, an equity CRI in a particular
% economy, the MSCI TRI and the MSCI CRI in that economy 
% 
% _Data Type_: all 1-dim array equity index
% 
% *|_Outputs_|*
% 
% Synthetic equity total return index in that economy
%
% _Data Type_: 1-dim array
% 
% *|_Calculations_|*
%
% STEP 1: Calculate return for the three input indices respectively
%
% STEP 2: Derive MSCI dividend yield by dividing MSCI TRI return by MSCI CRI return
%
% STEP 3: Calculate the synthetic TRI by using the MSCI dividend yield as a 
% proxy of its own dividend yield and multiplying the assumed index base
% value by it and by the capital return of its own.
%
%%
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Other Methods    
    function results = Bootstrap(obj, DataSeriesIn)

        results = DataSeriesIn(1).Clone;   

        startValue = zeros(1,3);
        endValue = zeros(1,3);
        Return = zeros(1,3);

        for i = 1:3
            startValue(i) = DataSeriesIn(i).values{...
                strmatch(obj.startDate,DataSeriesIn(i).dates)};
            endValue(i) = DataSeriesIn(i).values{end};      
            Return(i) = endValue(i)/startValue(i) - 1;
        end  

        % capital return calculated from available CRI
        inputCR = Return(1);
        % total return and capital return calculated from MSCI
        if strcmp('TRI',DataSeriesIn(2).index_type)
            proxyTR = Return(2);
            proxyCR = Return(3);
        else
            proxyTR = Return(3);
            proxyCR = Return(2);
        end
        % dividend return derived from MSCI TR and CR
        proxyDividend = (1 + proxyTR)/(1 + proxyCR) - 1;

        % calc of TRI using MSCI dividend as proxy
        TRI = obj.synIndexBaseValue * (1 + inputCR) * (1 + proxyDividend);           

        results.values = num2cell(TRI);
        results.dates = DataSeriesIn(1).dates(end);

        results.Name = '';
        results.source ='iMDP';
        results.ticker= 'na';
        results.index_type = 'TRI';
        results.description = 'derived syntheticTRI method';                 

    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
  end
   
end
    


