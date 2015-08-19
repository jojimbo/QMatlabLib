classdef YC3FactorPCA_exp < prursg.Engine.Model    

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
        
    methods
        function obj = YC3FactorPCA_exp()
            % Constructor
            obj = obj@prursg.Engine.Model('YC3FactorPCA_exp');
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
            C0 = price - tempC0';
            Zeta = b*C0';
            
            %Calcluate and output the ZCB price            
            K_t = k * Zeta;            
            iTerm = [1:outputLen];
            ZCB_Price = ones(size(K_t,2),1)*exp(-lfr * iTerm) + K_t';
        end
        
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
            
            if obj.IsMultiple  %Floor to rates (but not for RYC)                        
                series = series .* (series>0);
                series = (series<=0)*0.0001 + series;
            end                    
            
            %W-S extrapolation
            ZCBPrice = obj.ZCB_Calc(obj.lfr, obj.alpha, spotCurve, obj.LLP, obj.ZE); %extrapolated ZCB prices (1*N array)            
            Terms = ones(size(series,1),1)*[1:obj.ZE];
            series(:,startYr:(startYr+obj.ZE-1)) = (1./ZCBPrice).^(1./Terms) - 1;
                       
            %Apply shocks to the new initial spot curve (in case different 
            %to the initial curve used in calibration)
            series = series - ones(size(series,1),1)*SpotCalib' + ones(size(series,1),1)*Y0';
            
        end
        
        function s = validateCalibration( obj )
            %Not implemented%;
        end
       
        
    end
    
end

