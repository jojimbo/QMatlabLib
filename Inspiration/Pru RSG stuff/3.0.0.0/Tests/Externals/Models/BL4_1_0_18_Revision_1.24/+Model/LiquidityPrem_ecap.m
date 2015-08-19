%% LIQUIDITY PREM ECAP
% *PruRSG Engine Model  - Economic Capital Liquidity Premium*
% 
% 
% *The LiquidityPrem_ecap class
% returns a vector of Liquidity premium spread values based on a
% weighted sum of the credit spreads of the bond ratings*
%
% 

%% 
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classdef LiquidityPrem_ecap < prursg.Engine.Model      
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Properties
% These are global parameters which are available to all methods in
% this class. They are all single values.
% 
% *|[mult]|* - scale factor    
%
% *|[deduct]|* - shift factor
%
% *|[LLP]|* - Last Liquid Point on the yield curve;
%
% *|[ZE]|* - Point at which the Liquidity Premium is interpolated to 0.
%
% *|[wAAA]|* - weight applied to AAA credit spread
%
% *|[wAA]|* - weight applied to AA credit spread
%
% *|[wA]|* - weight applied to A credit spread
%
% *|[wBBB]|* - weight applied to BBB credit spread
%
% *|[wBB]|* - weight applied to BB credit spread
%
% *|[wB]|* - weight applied to B credit spread

%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties
        % model parameters
        mult = [];        
        deduct = [];
        LLP = [];
        ZE = [];
        wAAA = [];
        wAA = [];
        wA = [];
        wBBB = [];
        wBB = [];
        wB = [];
    end
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

%% List of Methods
% This model class has the following methods:
%
% *|1) [calibrate()]|* - not implemeted - returns 1 (success)
%
% *|2) [getNumberOfStocasticInputs()]|* - returns the number of stochastic
% inputs (1 for this distribution)
%
% *|3) [getNumberOfStochasticOutputs()]|* - - returns the number of stochastic
% outputs (1 for this distribution)
%
% *|4) [simulate()]|* - returns the liquidity premium 
%
% *|5) [validateCalibration()]|* - not implemeted - returns 1 (success)
%

%MATLAB CODE    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
       
    methods
        function obj = LiquidityPrem_ecap()
            % Constructor
            obj = obj@prursg.Engine.Model('LiquidityPrem_ecap');
        end

        function success_flag = calibrate(obj, dataObj, calibParamNames, calibParamTargets)
	    % no calibration required
            success_flag = 1;
        end
        
        function inputs = getNumberOfStochasticInputs(obj)
            inputs = 0;
        end
        
        function outputs = getNumberOfStochasticOutputs(obj)
            outputs = obj.initialValue.getSize();
        end
    
%%
% _________________________________________________________________________________________
%
%%  simulate
%
% '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
%
% *Description*
%
% The simulate method calculates a Liquidity premium spread based on a
% weighted sum of the credit spreads of the bond ratings B -> AAA, times a scale factor, $m$ = _mult_ and less a shift value, _deduct_.
% The value is applied out to the Last Liquid Point (LLP) on the yield curve. It is then linearly smoothed to zero at a defined Zero End (ZE) point. 
% The forward rate is then converted to Spot Rate. It is calculated as
% follows:
% 
% The forward rate, $F$, is
% $F = \left\{ \begin{array}{l l} 
% lqp & \quad \textrm{if } i < LLP\\
% lqp(1- \frac{i-LLP-2}{ZE-LLP}) & \quad \textrm{if } LLP \leq i < ZE\\
% 0 & \quad \textrm{if } i \geq ZE \\ 
% \end{array} \right.$
%
% where the liquidity premium, $lqp$, is
%
% $lqp = m [\sum_{k=AAA}^{k=B} spd_kw_k-deduct]$
%
% The spot rate, $S_i$, for year $i$, is than calculated from the forward Rate, $F_i$, using 
%
% $S_i = (1+F_i)(1+(F_{i-1})^{i-3})^{\frac {1}{i-2}}-1$
%
% $i$ is the index in the yield curve, with points defined at 3 months, 6
% months and then yearly.
%
% *Inputs*
%
% *_Initial Values_*
%
% NONE
%
% *_Precedents_*
%
% -  _spdAAA - spdB_, the credit spreads of bonds rated AAA to B
%
% *_Distribution Parameters_*
%
% _mult_ - scale factor, passed in via _obj.scale_    
%
% _deduct_ - shift factor, passed in via _obj.deduct_ 
%
% _LLP_ - Last Liquid Point on the yield curve, passed in via _obj.LLP_ 
%
% _ZE_ - Point at which the Liquidity Premium is interpolated to 0, passed in via _obj.ZE_ 
%
% _wAAA_ - weight applied to AAA credit spread, passed in via _obj.wAAA_ 
%
% _wAA_ - weight applied to AA credit spread, passed in via _obj.wAA_ 
%
% _wA_ - weight applied to A credit spread, passed in via _obj.wA_ 
%
% _wBBB_ - weight applied to BBB credit spread, passed in via _obj.wBBB_ 
%
% _wBB_ - weight applied to BB credit spread, passed in via _obj.wBB_ 
%
% _wB_ - weight applied to B credit spread, passed in via _obj.wB_ 
%
% *_Variates_*
%
% NONE
%
% *Outputs*
%
% A vector of Liquidity Premium Spreads, _series_

%MATLAB CODE    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
        function series = simulate(obj, workerObj, corrNumElements)
            Y0 = obj.initialValue.values{1};
            curvelength = length(Y0);
            
            precedentList = obj.getPrecedentObj();
            spdAAA = workerObj.getSimResults(precedentList('spdAAA'));
            spdAA = workerObj.getSimResults(precedentList('spdAA'));
            spdA = workerObj.getSimResults(precedentList('spdA'));
            spdBBB = workerObj.getSimResults(precedentList('spdBBB'));
            spdBB = workerObj.getSimResults(precedentList('spdBB'));
            spdB = workerObj.getSimResults(precedentList('spdB'));                        
            lqp = obj.mult*(spdAAA(:,1)*obj.wAAA + spdAA(:,1)*obj.wAA + spdA(:,1)*obj.wA + spdBBB(:,1)*obj.wBBB + spdBB(:,1)*obj.wBB + spdB(:,1)*obj.wB - obj.deduct);
            
            %up to LLP, fwd LQP is just lpq
            for i=1:(obj.LLP+2)
                series(:,i)=lqp;
            end
            %between LLP and ZE we go linearly to zero
            for i=(obj.LLP+3):(obj.ZE+2)
                series(:,i)=lqp - (i-obj.LLP-2)*lqp/(obj.ZE-obj.LLP);
            end
            %after the ZE, it's zero
            for i = (obj.ZE+3):curvelength
                series(:,i) = zeros(size(corrNumElements,1),1);
            end
            
            %Convert fwd to spot lqp as final output
            for i = 4:curvelength    %remember the 3mo and 5mo rates
                series(:,i) = ( (1+series(:,i)) .* (1+series(:,i-1)).^(i-3) ).^(1/(i-2)) - 1;
            end
            
            
            series = (series>0).*series;   %remove all negative values

        end
        
        
        function s = validateCalibration( obj )
            s = 'Not implemented';
        end
       
        
    end
    
end

