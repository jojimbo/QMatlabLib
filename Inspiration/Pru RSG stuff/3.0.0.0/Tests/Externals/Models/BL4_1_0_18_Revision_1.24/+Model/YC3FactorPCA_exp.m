%% YC 3 FACTOR PCA EXP
% *PruRSG Engine Model  - Three Factor Principal Component Analysis Yield Curve Model*
% 
% 
% *The YC3FactorPCA_exp class
% returns a vector of Yield curves based on 3 factor Principal Component Analysis*
%
% 

%% 
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classdef YC3FactorPCA_exp < prursg.Engine.Model       
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Properties
% These are global parameters which are available to all methods in
% this class. They are all single values.
% 
% *|[PC1]|* - 1st Principal Component factor    
%
% *|[PC2]|* - 2nd Principal Component factor 
%
% *|[PC3]|* - 3rd Principal Component factor 
%
% *|[FwdCalib]|* - Forward Calibration Curve
%
% *|[alpha]|* - rate at which yield curve is smoothed to the long term
% forward rate
%
% *|[lfr]|* - long term forward rate - the interest rate which is expected as 
% $t \to \infty$
%
% *|[IsMultiple]|* - determines whether the Principal Components are an
% exponential product or additive sum 
%
% *|[ZE]|* - Last point in the yield curve. Also the point at which the forward rate reaches the long term forawrd rate, _lfr_.
%
% *|[LLP]|* - Last Liquid Point beyond which the Forward Rate is
% extrapolated.
%


%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties
        % model parameters
        PC1 = [];
        PC2 = [];
        PC3 = [];
        FwdCalib = []; 
        alpha = [];
        lfr = [];
        LLP = [];
        ZE = [];
        IsMultiple = [];
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
% *|4) [simulate()]|* - returns the vector of yield curves 
%
% *|5) [validateCalibration()]|* - not implemeted - returns 1 (success)
%
%MATLAB CODE    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
       
    methods
        function obj = YC3FactorPCA_exp()
        % Constructor
            obj = obj@prursg.Engine.Model('YC3FactorPCA_exp');
        end


        function success_flag = calibrate(obj, dataObj, calibParamNames, calibParamTargets)
            success_flag = 1;
        end
        
        function inputs = getNumberOfStochasticInputs(obj)
            inputs = 0;
        end
        
        function outputs = getNumberOfStochasticOutputs(obj)
            outputs = obj.initialValue.getSize();
        end
        
        function w = BuildW(obj, times, alpha, longf)
            N = size(times, 2);
            w(1:N, 1:N) = 0;
            for iL = 1:N
                for jL = 1:iL
                    time1 = times(iL);
                    time2 = times(jL);
                    w(iL, jL) = exp(-longf * (time1 + time2)) * (alpha * min(time1, time2) ...
                        - exp(-alpha * max(time1,time2)) * sinh(alpha * min(time1,time2)));
                    w(jL, iL) = w(iL, jL);
                end
            end            
        end
        
        function ZCB_Price = ZCB_Calc(obj, lfr, alpha, spotCurve, curveLen, outputLen)            
            %lfr long forward rate
            %alpha the reversion param
            %spotCurve a single simulated spot curve up to LLP
            %curveLen the last liquid point (
            %output len is the length of the extrapolated yield curve
            
            yields(1:curveLen) = 0;
            prices(1:size(spotCurve,1), 1:curveLen) = 0;
            
            for i = 1:curveLen
                yields(i) = 0;
                prices(:, i) = (1 + spotCurve(:, i)) .^ (-i);
            end
                        
            n_d = outputLen;
            n_y = curveLen;
            
            dates(1:n_d) = 0;
            CFs(1:n_y, 1:n_d) = 0;
            
            %Build cash flow matrix            
            for iL = 1:n_d
                dates(iL) = iL;
            end
            
            for iy = 1:n_y
                for ID = 1:n_d
                    if ID <= iy
                        CFs(iy, ID) = yields(iy);
                        if ID == iy 
                            CFs(iy, ID) = yields(iy) + 1;
                        end   
                    else
                        CFs(iy, ID) = 0;
                    end
                end
            end
            
%             %Wilson matrix            
%             w = obj.BuildW(dates, alpha, lfr);
%             
%             %Kernel functions                        
%             k = w * CFs';
%             
%             %Calculate Xi            
%             b = (CFs * k)^(-1);            
%             expft = exp(-lfr * dates');            
%             tempC0 = CFs * expft;
%             C0 = prices - ones(size(spotCurve,1),1)*tempC0';
%             Zeta = b*C0';
%             
%             %Calcluate and output the ZCB price            
%             K_t = k * Zeta;            
%             iTerm = [1:outputLen];
%             ZCB_Price = ones(size(K_t,2),1)*exp(-lfr * iTerm) + K_t';
            
            % alpha code change %
            alpha_v = ones(size(spotCurve,1),1) * alpha;
            ZCB_Price(1:size(spotCurve, 1), 1:size(dates, 2)) = 0;
            for ip = 1:size(spotCurve,1)
                ZCB_Price(ip, :) = obj.ZCB_iter(dates, alpha_v(ip), lfr, CFs, prices(ip, :), outputLen);

                while any(ZCB_Price(ip, :) < 0)  % we have negative ZCB Prices
                    alpha_v(ip, :) = alpha_v(ip) + 0.05; % increase alpha by 0.05 - check with calibration team if changed
                    ZCB_Price(ip, :) = obj.ZCB_iter(dates, alpha_v(ip), lfr, CFs, prices(ip, :), outputLen);
                end
            end
            
        end 
        
        function ZCB_Price = ZCB_iter(obj, dates, alpha, lfr, CFs, price, outputLen)
            
            %Wilson matrix            
            w = obj.BuildW(dates, alpha, lfr);
            
            %Kernel functions                        
            k = w * CFs';
            
            %Calculate Xi            
            b = (CFs * k)^(-1);            
            expft = exp(-lfr * dates');            
            tempC0 = CFs * expft;
            C0 = prices - ones(size(spotCurve,1),1)*tempC0';
            Zeta = b*C0';
            
            %Calcluate and output the ZCB price            
            K_t = k * Zeta;            
            iTerm = [1:outputLen];
            ZCB_Price = ones(size(K_t,2),1)*exp(-lfr * iTerm) + K_t';
        end
         
%%
% _________________________________________________________________________________________
%
%% simulate
%
% '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
%
% *Description*
%
% The simulate method calculates a yield curve using a 3 factor Principal
% Component Analysis as follows:
%
% 1. A spot calibration  
% $SZ_i$, for year $i$, is calculated from the forward calibration $FZ_i$, using 
%
% $SZ_i = (1+FZ_i)(1+(FZ_{i-1})^{i-3})^{\frac {1}{i-2}}-1$
%
% where $i$ is the index in the yield curve, with points defined at 3 months, 6
% months and then yearly.
%
% The 3 month and 6 month points on the yield curve are generally set to
% the same value as the 1 year point. This document ignores their treatment
% and assumes that the $i^{th}$ point on the yield curve is the year $i$ value.
%
% A Forward Curve is than calculated using the Prinicpal Components as far
% as the Last Liquid Point (LLP). The output is determined by the value of the 
% isMultiple flag, which is set to TRUE in the control sheet for a nominal yield 
% curve and FALSE for a real yield curve. The curve is calculated as follows:
%
% $F_i = \left\{ \begin{array}{l l} 
% FZ_i \exp(\sum_{k=1}^3YCf_kPC_{ki}) \quad \textrm{if isMultiple is TRUE}\\
% FZ_i + \sum_{k=1}^3YCf_kPC_{ki} \quad \textrm{if isMultiple is FALSE }\\
% \end{array} \right.$
%
% Where $PC_k$ is the $k^{th}$ Principal Component and $YCf_k$ is the stochastically generated weight for component $k$ generated by the precedent model.
%
% The Forward Curve, $F_i$, is then converted to a Spot Curve, $S_i$
%
% $S_i = (1+F_i)(1+(F_{i-1})^{i-1})^{\frac {1}{i}}-1$
%
% The curve is then extrapolated from LLP to ZE (the longest duration and also the number of points in the yield curve) 
% using Wilson-Smith extrapolation to calculated Zero Coupon Bond prices.
%
% (A full description of Wilson-Smith extrapolation can be found here:
%
% https://eiopa.europa.eu/fileadmin/tx_dam/files/consultations/QIS/QIS5/ceiops-paper-extrapolation-risk-free-rates_en-20100802.pdf)
% 
% This is performed as follows:
%
% An array of Cashflows, _CFs_, is created of size LLP x ZE with 1's on the leading diagonal and
% zeros elsewhere.
%
% A Wilson Matrix of size ZE x ZE is then created with each element set to
% 
% $W(i,j) = e^{-lfr(i+j)} [ \alpha \mbox{min}(i,j)-e^{-\alpha \mbox{max}(i,j)} \sinh(\alpha \mbox{max}(i,j))]$
%
% A Kernel, _K_ is then calculated as $K = W \times CFs$, effectively
% taking the first LLP columns of the _W_ matrix
%
% A second matrix, _B_, is created by taking the first LLP rows of K to yield a LLP x LLP matrix, and the finding the matrix inverse.
%
% _B_ is than multiplied by the difference between the Spot Curve _S_ and the Long Term Forward Rate Discount Factor:
%
% $H_i = B_i \times [S_i- e^{-lfr.i}]$
%                    
% The Extrapolated Zero Coupon Bond Price is then calculated as
%
% $Z_i = e^{-lfr.i} + K \times H$           
%             
% The Yield is then infered from the ZCB Price as
%
% $Y_i = (\frac {1}{Z_i})^{1/i}$
%
% Finally the yield curve is calculated by subtracting the Spot Calibration and then adding back initial values 
%
% $YC_i = Y_i - SC_i + init_i$
%
%
% The output is then floored to 0.0001 (1 basis point) if _isMultiple_ is
% TRUE to prevent nominal yields falling below 1 basis point. This floored
% value is then returned as the variable _series_.
%
%
%%
% *Inputs*
%
% *_Initial Values_*, _init_
%
% _FwdCalib_, the forward rate calibration values, passed in as
% _obj.fwdCalib_
%
% *_Precedents_*
%
% The Principal Component Coefficients: _YC1_, _YC2_, _YC3_
% 
% *_Distribution Parameters_*
%
% _PC1_ - 1st Principal Component factor    
%
% _PC2_ - 2nd Principal Component factor 
%
% _PC3_ - 3rd Principal Component factor 
%
% _FwdCalib_ - Forward Calibration Curve
%
% _alpha_ - rate at which yield curve is smoothed to the long term
% forward rate
%
% _lfr_ - long term forward rate - the interest rate which is expected as 
% $t \to \infty$
%
% _IsMultiple_ - determines whether the Principal Components are an
% exponential product or additive sum 
%
% _ZE_ - Last point in the yield curve. Also the point at which the forward rate reaches the long term forawrd rate, _lfr_.
%
% _LLP_ - Last Liquid Point beyond which the Forward Rate is
% extrapolated.
%
% *_Variates_*
%% NONE%
% *_Outputs_*
%
% An array of Yield Curves, _series_
       function series = simulate(obj, workerObj, corrNumElements)
            %get the three parameters
            precedentList = obj.getPrecedentObj();
            YC_f1 = workerObj.getSimResults(precedentList('YC_1'));
            YC_f2 = workerObj.getSimResults(precedentList('YC_2'));
            YC_f3 = workerObj.getSimResults(precedentList('YC_3'));
            
            % MODEL API NOTE
            % 7) initial values are contained again in the familiar
            % DataSeries object, this object has property "values" which is
            % a cell array of hypercubes, with as many hypercubes as there
            % are dates. Since this is an initialValue, there will always
            % only be one hypercube hence we can pull out the entire
            % initial value curve by obj.initialValue.values{1} and used
            % directly
            Y0 = obj.initialValue.values{1};   %Initial curve is spot         

            %Find number of terms on the curve
            numTenors = obj.LLP;
            SpotCalib = Y0;
            SpotCalib(1)=obj.FwdCalib(1);
            if length(Y0)-obj.ZE==2
                SpotCalib(2)=obj.FwdCalib(2);
                SpotCalib(3)=obj.FwdCalib(3);
                numTenors = obj.LLP + 2;
                HasShortEnd = 1;                             
            end
            
            startYr = numTenors - obj.LLP + 1;
                        
            for i = (startYr+1):length(Y0)
                SpotCalib(i) = ( (1+SpotCalib(i-1))^(i-startYr) * (1+obj.FwdCalib(i)) )^(1/(i-startYr+1)) - 1;
            end
            
            spotCurve(1:size(corrNumElements,1),1:obj.LLP) = 0; %spot curve that is input to WS extrapolation

            for i = 1:numTenors   %Only simulate to LLP (say 50Y)                
                %simulation on calibration forward
                if obj.IsMultiple
                    series(:,i) = obj.FwdCalib(i)* exp( YC_f1*obj.PC1(i) + YC_f2*obj.PC2(i) + YC_f3*obj.PC3(i));
                else
                    series(:,i) = obj.FwdCalib(i)+ (YC_f1*obj.PC1(i) + YC_f2*obj.PC2(i) + YC_f3*obj.PC3(i));
                end
            
                %convert fwd to spot
                if (HasShortEnd && i > 3) || (~HasShortEnd && i > 1)  %fwd=spot for 3mo, 6mo and 1Y rates                
                    if HasShortEnd
                        series(:,i) = ( (1+series(:,i)) .* (1+series(:,i-1)).^(i-3) ).^(1/(i-2)) - 1;                        
                    else
                        series(:,i) = ( (1+series(:,i)) .* (1+series(:,i-1)).^(i-1) ).^(1/(i)) - 1;                        
                    end 
                end
                
                %Get input spot curve for WS extrapolation ready
                if HasShortEnd && i > 2    %then we know i>3 must have been satisfied
                    spotCurve(:,i-2)=series(:,i);
                elseif ~HasShortEnd
                    spotCurve(:,i)=series(:,i);
                end

            end
            
                             
            
            %W-S extrapolation
            ZCBPrice = obj.ZCB_Calc(obj.lfr, obj.alpha, spotCurve, obj.LLP, obj.ZE); %extrapolated ZCB prices (1*N array)            
            Terms = ones(size(series,1),1)*[1:obj.ZE];
            series(:,startYr:(startYr+obj.ZE-1)) = (1./ZCBPrice).^(1./Terms) - 1;
                       
            %Apply shocks to the new initial spot curve (in case different 
            %to the initial curve used in calibration)
            series = series - ones(size(series,1),1)*SpotCalib' + ones(size(series,1),1)*Y0';
            
            if obj.IsMultiple  %Floor to rates (but not for RYC)                        
                series = series .* (series>0);
                series = (series<=0)*0.0001 + series;
            end   
            
        end
                function s = validateCalibration( obj )
            %Not implemented%;
        end
       
        
    end
    
end

