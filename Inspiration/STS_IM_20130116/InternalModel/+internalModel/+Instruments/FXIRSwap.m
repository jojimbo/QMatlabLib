%% FXIRSwap
% subclass of internalModel.Instrument
%

%%
classdef FXIRSwap < internalModel.Instrument
    
    %% Overview
    % A cross currency swap is given by a domestic (receive) leg and a
    % foreign (pay) leg. The first leg has notional $\ge0$, and the second
    % leg $\le 0$, so that the price is computed as the _sum_ of the present
    % values of the two legs.
    % A leg is given by a set of payment times $t_1<\ldots<t_N$ and
    % corresponding coupon payments $P_1,\ldots, P_N$. The last payment time is the
    % same for both legs and it equals the time to maturity, computed as the
    % number of days between evaluation and maturity date.
    %
    % Each leg can be fixed, which means each coupon pays a fixed interest rate for the relative coupon period
    % or floating, in which case the realized interest rate for the
    % corresponding period is paid.
    %
    
    %% Properties
    %
    % * |DomesticCurrency| _char_
    % * |ForeignCurrency| _char_
    % * |DomesticCurve| _char_
    % * |ForeignCurve| _char_
    % * |DomesticDayCount| _char_
    % * |ForeignDayCount| _char_
    % * |DomesticRateType| _char_
    % * |ForeignRateType| _char_
    %
    %  Payment Frequencies
    %
    % * |DomesticFrequency| _double_
    % * |DomesticFrequencyUnits| _char_
    % * |ForeignFrequency| _double_
    % * |ForeignFrequencyUnits| _char_
    %
    %  For Fixed legs:
    %
    % * |DomesticCouponRate| _double_
    % * |ForeignCouponRate| _double_
    %
    %  For Floating legs:
    %
    % * |DomesticSpread| _double_
    % * |ForeignSpread| _double_
    %
    % * |EffectiveDate| _char_
    % * |MaturityDate| _char_
    %
    %  Notionals
    %
    % * |DomesticNotional| _double_ (it has to be always non-negative)
    % * |ForeignNotional| _double_ (it has to be always non-positive)
    %
    %    Derived from Input
    %
    % * |TimeToMaturity| _double_
    % * |NumberOfDomesticCoupons| _double_
    % * |NumberOfForeignCoupons| _double_
    %
    % Arrays to store the payment times of each one of the legs
    %
    % * |DomesticPaymentTimes| _double_
    % * |ForeignPaymentTimes| _double_
    %
    % Arrays for the leg payments
    %
    % * |DomesticCoupons| _array_
    % * |ForeignCoupons|  _array_
    
    
    properties
        
        
        DomesticCurrency
        ForeignCurrency
        DomesticCurve
        ForeignCurve
        DomesticDayCount
        ForeignDayCount
        DomesticRateType
        ForeignRateType
        % Payment Frequencies
        DomesticFrequency
        DomesticFrequencyUnits
        ForeignFrequency
        ForeignFrequencyUnits
        % For Fixed legs:
        DomesticCouponRate
        ForeignCouponRate
        % For Floating legs:
        DomesticSpread
        ForeignSpread
        % Dates
        EffectiveDate
        MaturityDate
        %Notionals
        DomesticNotional
        ForeignNotional
        
        % Derived from input properties
        TimeToMaturity
        NumberOfDomesticCoupons
        NumberOfForeignCoupons
        
        % Arrays to store the payment times of each one of the legs
        DomesticPaymentTimes
        ForeignPaymentTimes
        
        % Arrays for the leg payments
        DomesticCoupons        % _array_
        ForeignCoupons         % _array_
        
        % Shocked market data (shouldn't be here, but design constraints force it)
        domesticInterestRate
        foreignInterestRate
        domesticForwardRate
        foreignForwardRate
        spotPrice
        
        %Lag
        Lag
        domesticLag
        foreignLag
    
    end % #Properties
    
    %% Methods
    %
    % * |obj = FXIRSwap(obj) = FXIRSwap(instName, instrID, ...)|
    % * |val = value(this)|
    % * |obj = couponsConstruction(obj)|
    
    methods
        function obj = FXIRSwap(name, instrID, currency,    ...
                domesticCurrency, foreignCurrency,          ...
                domesticCurve, foreignCurve,                ...
                domesticDayCount, foreignDayCount,          ...
                domesticRateType, foreignRateType,          ...
                domesticFrequency, domesticFrequencyUnits,  ...
                foreignFrequency, foreignFrequencyUnits,    ...
                domesticCouponRate, foreignCouponRate,      ...
                domesticSpread, foreignSpread,              ...
                domesticNotional, foreignNotional,          ...
                ...
                effectiveDate, maturityDate,                ...
                valuationDate                               ...
                )
            %% FXIRSwap _constructor_
            % |obj = FXIRSwap()|
            
            % Inputs:
            
            obj.Name                    = name;
            obj.ID                      = instrID;
            obj.Currency                = currency;
            obj.MarketRisk              = true;
            obj.ValuationDate           = valuationDate;
            
            obj.DomesticCurrency        = domesticCurrency;
            obj.ForeignCurrency         = foreignCurrency;
            obj.DomesticCurve           = domesticCurve;
            obj.ForeignCurve            = foreignCurve;
            obj.DomesticDayCount        = domesticDayCount;
            obj.ForeignDayCount         = foreignDayCount;
            obj.DomesticRateType        = upper(domesticRateType);
            obj.ForeignRateType         = upper(foreignRateType);
            
            % Clean-up on the Domestic and Foreign Curves - Support
            % EUR-SWAP as well as EUR-SWAP-SIM
            if strcmpi(obj.DomesticCurve(end-3:end), '-SIM')
                obj.DomesticCurve = obj.DomesticCurve(1:end-4);
            end
            if strcmpi(obj.ForeignCurve(end-3:end), '-SIM')
                obj.ForeignCurve = obj.ForeignCurve(1:end-4);
            end
            
            % In the below, ANNUAL compounding is assumed
            obj.DomesticFrequency       = domesticFrequency;
            obj.DomesticFrequencyUnits  = domesticFrequencyUnits;
            obj.ForeignFrequency        = foreignFrequency;
            obj.ForeignFrequencyUnits   = foreignFrequencyUnits;
            switch upper(domesticFrequencyUnits)
                case 'MONTHS'
                    F =@(x)30*x+floor(x/3)-floor(x/9)+2*floor(x/12);
                    G=@(x)mod(x-1,12)+1;
                    F_domesticDays = @(x)floor(x/12-0.01)*365 + F(G(x));
                case 'DAYS'
                    F_domesticDays= @(x)x;
                case 'YEARS'
                    F_domesticDays= @(x)365*x;
            end
            switch upper(foreignFrequencyUnits)
                case 'MONTHS'
                    F =@(x)30*x+floor(x/3)-floor(x/9)+2*floor(x/12);
                    G=@(x)mod(x-1,12)+1;
                    F_foreignDays= @(x)floor(x/12-0.01)*365 + F(G(x));
                case 'DAYS'
                    F_foreignDays= @(x)x;
                case 'YEARS'
                    F_foreignDays= @(x)365*x;
            end
            % Only for Fixed legs
            obj.DomesticCouponRate      = domesticCouponRate;
            obj.ForeignCouponRate       = foreignCouponRate;
            % Only for Floating legs
            obj.DomesticSpread          = domesticSpread;
            obj.ForeignSpread           = foreignSpread;
            % Notionals
            obj.DomesticNotional        = domesticNotional;
            obj.ForeignNotional         = foreignNotional;
            
            if (domesticNotional<0)
                disp('DomesticNotional must not be negative');
                return
            end
            
            if (foreignNotional>0)
                disp('ForeignNotional must not be positive');
                return
            end
            
            
            % Dates
            obj.EffectiveDate           = effectiveDate;
            obj.MaturityDate            = maturityDate;
            
            % Derived
            obj.TimeToMaturity          = (datenum(maturityDate,'mm/dd/yyyy')-datenum(obj.ValuationDate,'mm/dd/yyyy')); %expressed in days
            
            % Finding the maximum period
            
            if F_domesticDays(obj.DomesticFrequency)>F_foreignDays(obj.ForeignFrequency)
                FTemp = F_domesticDays;
                FreqTemp = obj.DomesticFrequency;
            else
                FTemp = F_foreignDays;
                FreqTemp = obj.ForeignFrequency;
            end
            
            % K will be the number of Coupons with higher period
            
            K = 0;
            
            while FTemp(K*FreqTemp) < obj.TimeToMaturity
                K = K+1;
            end
            
            % A positive Lag occurs if the evaluation date is between two
            % coupon dates
            
            obj.Lag = FTemp(K*FreqTemp) - obj.TimeToMaturity;
            
            % Creation of Payment Times
            
            k = 0;
            T = obj.TimeToMaturity + obj.Lag;
            
            while(F_domesticDays(k*obj.DomesticFrequency)< T)
                k = k + 1;
            end
            
            obj.NumberOfDomesticCoupons = k;
            
            k = 0;
            
            while (F_foreignDays(k*obj.ForeignFrequency)<T)
                k = k + 1;
            end
            
            obj.NumberOfForeignCoupons = k;
            
            
            obj.DomesticPaymentTimes    = ...
                F_domesticDays(obj.DomesticFrequency.*cumsum(ones(1,obj.NumberOfDomesticCoupons)));
            obj.ForeignPaymentTimes     = ...
                F_foreignDays(obj.ForeignFrequency.*cumsum(ones(1,obj.NumberOfForeignCoupons)));
            
            
            % Shift back the payment times
            
            obj.DomesticPaymentTimes    = obj.DomesticPaymentTimes - obj.Lag;
            obj.ForeignPaymentTimes     = obj.ForeignPaymentTimes - obj.Lag;
            
            % Remove first payment time if negative (all the other are
            % always >=0).
            
            obj.domesticLag = obj.Lag;
            obj.foreignLag = obj.Lag;
            
             %% Functionality to include leap years
            %  
            % Please uncomment code at this point to adjust the pament
            % times with the impact of leap years.
            % 
            %  evaluationDateNum = datenum(obj.ValuationDate,'mm/dd/yyyy');
            %  obj.DomesticPaymentTimes = adjustTimesForLeapYear(evaluationDateNum, obj.DomesticPaymentTimes);
            %  obj.ForeignPaymentTimes = adjustTimesForLeapYear(evaluationDateNum, obj.ForeignPaymentTimes);
            %
            
            firstPositiveTime = find (obj.DomesticPaymentTimes >0);
            
            if firstPositiveTime>1
                obj.domesticLag = -obj.DomesticPaymentTimes(firstPositiveTime-1);
            end
            
            obj.DomesticPaymentTimes = obj.DomesticPaymentTimes(firstPositiveTime:numel(obj.DomesticPaymentTimes));
            
            firstPositiveTime = find (obj.ForeignPaymentTimes >0);
            
            if firstPositiveTime>1
                obj.foreignLag = -obj.ForeignPaymentTimes(firstPositiveTime-1);
            end
            
            obj.ForeignPaymentTimes = obj.ForeignPaymentTimes(firstPositiveTime:numel(obj.ForeignPaymentTimes));
            
            obj.NumberOfDomesticCoupons = numel(obj.DomesticPaymentTimes);
            obj.NumberOfForeignCoupons = numel(obj.ForeignPaymentTimes);
            
        end
        
        
        function val = value(obj)
            %% value
            % |val = value(obj)|
            %
            % Outputs:
            %
            % * |val|
            %
            % The value of a cross-currency swap is given by
            %
            % $DomesticLeg + ForeignLeg\cdot SpotRate$
            
            % Constructing Coupons
            obj = obj.couponsConstruction();
            
            % Pricing
            domesticLeg = zeros(size(obj.spotPrice));
            foreignLeg  = zeros(size(obj.spotPrice));
            
            for idomesticLeg=1:obj.NumberOfDomesticCoupons
                domesticLeg = domesticLeg + obj.DomesticCoupons(idomesticLeg).value;
            end
            
            for iforeignLeg=1:obj.NumberOfForeignCoupons
                foreignLeg = foreignLeg + obj.ForeignCoupons(iforeignLeg).value;
            end
            
            val = domesticLeg + foreignLeg.*obj.spotPrice;
            
        end
        
        function obj = couponsConstruction(obj)
            %% Coupons construction
            %
            % The methods computes the number of Domestic and Foreign
            % coupons and computes their time to maturity; these are retrieved from
            % the arrays $DomesticPaymentTimes$ and $ForeignPaymentTimes.$
            %
            numberOfDomesticCoupons = obj.NumberOfDomesticCoupons;
            numberOfForeignCoupons = obj.NumberOfForeignCoupons;
            
            dLag = obj.domesticLag(1);
            fLag= obj.foreignLag(1);
            
            % Forward rates
            obj.domesticForwardRate = obj.domesticInterestRate;
            obj.foreignForwardRate  = obj.foreignInterestRate;
            
            % When the valuation date falls between 2 coupon dates, the
            % forward rate is not calculated from the IR curve, but it is
            % assumed to be the Coupon Rate
            if obj.Lag ~=0;
                obj.domesticForwardRate(:,1) = obj.DomesticCouponRate;
                obj.foreignForwardRate(:,1) = obj.ForeignCouponRate;
            end
            
            for idF = 2: size(obj.domesticForwardRate,2) % we start at 2 because the first forward rate is the interest rate
                r2 = obj.domesticInterestRate(:,idF);
                r1 = obj.domesticInterestRate(:,idF-1);
                
                t2 = obj.DomesticPaymentTimes(idF)/365; % Fraction of a year
                t1 = obj.DomesticPaymentTimes(idF-1)/365; % Fraction of a year
                
                obj.domesticForwardRate(:,idF) = (r2.*t2-r1.*t1)/(t2-t1);
                %obj.domesticForwardRate(:,idF) = -1 + (((1+ r2).^t2)./((1+ r1).^t1)).^(1/(t2-t1));
            end
            for ifF = 2: size(obj.foreignForwardRate,2)
                r2 = obj.foreignInterestRate(:,ifF);
                r1 = obj.foreignInterestRate(:,ifF-1);
                
                t2 = obj.ForeignPaymentTimes(ifF)/365; % Fraction of a year
                t1 = obj.ForeignPaymentTimes(ifF-1)/365; % Fraction of a year
                
                obj.foreignForwardRate(:,ifF) = (r2.*t2-r1.*t1)/(t2-t1);
                %obj.foreignForwardRate(:,idF) = -1 + (((1+ r2).^t2)./((1+ r1).^t1)).^(1/(t2-t1));
            end
            
            % Domestic Coupons
            obj.DomesticCoupons = internalModel.Instruments.Coupon.empty(obj.NumberOfDomesticCoupons, 0);
            if strcmpi(obj.DomesticRateType,'Fixed')
                for iDomesticCoupons = 1:obj.NumberOfDomesticCoupons
                    temp = (obj.DomesticPaymentTimes(1) + dLag)/365 ;
                    if iDomesticCoupons>1
                        temp = (obj.DomesticPaymentTimes(iDomesticCoupons)-obj.DomesticPaymentTimes(iDomesticCoupons-1))/365; % Fraction of a year
                    end
                    payment = obj.DomesticNotional*(obj.DomesticCouponRate*temp+ ...
                        floor(iDomesticCoupons/numberOfDomesticCoupons));
                    timeToMaturity = obj.DomesticPaymentTimes(iDomesticCoupons);
                    
                    if (timeToMaturity<0)
                        interestRate = 0.0;
                    else
                        interestRate = obj.domesticInterestRate(:,iDomesticCoupons);
                    end
                    
                    obj.DomesticCoupons(iDomesticCoupons)=internalModel.Instruments.Coupon(payment,...
                        obj.DomesticCurrency, interestRate, obj.ValuationDate, timeToMaturity ...
                        );
                end
                
            else
                if ~strcmpi(obj.DomesticRateType,'Floating')
                    return
                end
                for iDomesticCoupons = 1:obj.NumberOfDomesticCoupons
                    temp = (obj.DomesticPaymentTimes(1) + dLag)/365 ;
                    
                    if iDomesticCoupons>1
                        temp = (obj.DomesticPaymentTimes(iDomesticCoupons)-obj.DomesticPaymentTimes(iDomesticCoupons-1))/365; % Fraction of a year
                    end
                    payment = obj.DomesticNotional*((obj.domesticForwardRate(:,iDomesticCoupons)+...
                        obj.DomesticSpread)*temp+ ...
                        floor(iDomesticCoupons/numberOfDomesticCoupons));
                    timeToMaturity = obj.DomesticPaymentTimes(iDomesticCoupons);
                    if (timeToMaturity<0)
                        interestRate = 0.0;
                    else
                        interestRate= obj.domesticInterestRate(:,iDomesticCoupons); %this one is for discounting
                    end
                    obj.DomesticCoupons(iDomesticCoupons)=internalModel.Instruments.Coupon(payment,...
                        obj.DomesticCurrency, interestRate, obj.ValuationDate, timeToMaturity ...
                        );
                end
            end
            
            %ForeignCoupons
            obj.ForeignCoupons = internalModel.Instruments.Coupon.empty(obj.NumberOfForeignCoupons, 0);
            if strcmpi(obj.ForeignRateType,'Fixed')
                for iForeignCoupons=1:numberOfForeignCoupons
                    temp = (obj.ForeignPaymentTimes(1) + fLag)/365 ;
                    if iForeignCoupons>1
                        temp = (obj.ForeignPaymentTimes(iForeignCoupons)-obj.ForeignPaymentTimes(iForeignCoupons-1))/365; % Fraction of a year
                    end
                    payment = obj.ForeignNotional*(obj.ForeignCouponRate*temp+...
                        floor(iForeignCoupons/numberOfForeignCoupons));
                    timeToMaturity = obj.ForeignPaymentTimes(iForeignCoupons);
                    if (timeToMaturity<0)
                        interestRate = 0.0;
                    else
                        interestRate = obj.foreignInterestRate(:,iForeignCoupons);
                    end
                    obj.ForeignCoupons(iForeignCoupons)=internalModel.Instruments.Coupon(payment,...
                        obj.ForeignCurrency, interestRate, obj.ValuationDate, timeToMaturity ...
                        );
                end
                
            else
                if ~strcmpi(obj.ForeignRateType,'Floating')
                    return
                end
                for iForeignCoupons=1:numberOfForeignCoupons
                    temp = (obj.ForeignPaymentTimes(1) + fLag)/365 ;
                    if iForeignCoupons>1
                        temp = (obj.ForeignPaymentTimes(iForeignCoupons)-obj.ForeignPaymentTimes(iForeignCoupons-1))/365; % Fraction of a year
                    end
                    payment = obj.ForeignNotional*((obj.foreignForwardRate(:,iForeignCoupons)+...
                        obj.ForeignSpread)*temp+ floor(iForeignCoupons/numberOfForeignCoupons));
                    timeToMaturity = obj.ForeignPaymentTimes(iForeignCoupons);
                    if (timeToMaturity<0)
                        interestRate = 0.0;
                    else
                        interestRate = obj.foreignInterestRate(:,iForeignCoupons);
                    end
                    obj.ForeignCoupons(iForeignCoupons)=internalModel.Instruments.Coupon(payment,...
                        obj.ForeignCurrency, interestRate, obj.ValuationDate, timeToMaturity ...
                        );
                end
            end
        end
        
        
    end %# Methods
    
end
