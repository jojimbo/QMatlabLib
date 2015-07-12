function instrData = processInstrData(obj, assetType)
% Collect Instrument Data
% User Story: P20-7
instrData = [];

% Switch case, processing is Asset Type specific
switch assetType
    
    case 'ZeroCouponBond'
        %% Zero Coupon Bond
        % +. Collect Header- and Data rows
        instrContents  = obj.csvFileContents.instFile;
        
        % +. Find ENUMERATOR column ID
        [~, basColID]  = find(strcmpi(instrContents, 'BAS'));
        idCol          = basColID(1) + 1;
        
        [headerRow, ~] = find(strcmpi(obj.headerSpecs,         'Zero Coupon BondSPEC'));
        [dataRows, ~]  = find(strcmpi(instrContents(:, idCol), 'Zero Coupon BondSPEC'));
        
        if isempty(dataRows) || isempty(headerRow)
            instrData = [];
            return
        end
        
        % +. Collect ZCB Header and Data
        ZCB_Header     = obj.headerSpecs(headerRow, :);
        ZCB_Data       = instrContents(dataRows,    :);
        
        % +. Collect relevant ZCB Instrument Data
        instrData.name          = obj.getContents(ZCB_Data, ZCB_Header, 'NAME');
        instrData.instrID       = obj.getContents(ZCB_Data, ZCB_Header, 'IDENTIFIER');
        instrData.currency      = obj.getContents(ZCB_Data, ZCB_Header, 'CurrencyUNIT');
        instrData.domesticCurve = obj.getContents(ZCB_Data, ZCB_Header, 'DiscountCurveXREF');
        instrData.tenor         = obj.getContents(ZCB_Data, ZCB_Header, 'MaturityDATE');
        instrData.creditSpread  = obj.getContents(ZCB_Data, ZCB_Header, 'INGCrdRtgNAME');
        instrData.notional      = obj.getContents(ZCB_Data, ZCB_Header, 'NotionalVAL');
        
        % +. Typecast 'tenor' and 'notional'
        instrData.tenor         = cell2mat(instrData.tenor);
        instrData.notional      = cell2mat(instrData.notional);
        
        instrData.instrCount    = size(ZCB_Data, 1);
        
        

    case 'FxForward'
        %% FX Forward
        % +. Collect Header- and Data rows
        instrContents  = obj.csvFileContents.instFile;
        
        % +. Find ENUMERATOR column ID
        [~, basColID]  = find(strcmpi(instrContents, 'BAS'));
        idCol          = basColID(1) + 1;
        
        [headerRow, ~] = find(strcmpi(obj.headerSpecs,         'DM FX ForwardSPEC'));
        [dataRows, ~]  = find(strcmpi(instrContents(:, idCol), 'DM FX ForwardSPEC'));
        
        if isempty(dataRows) || isempty(headerRow)
            instrData = [];
            return
        end
        
        % +. Collect 'FX Forward' Header and Data
        FXFw_Header    = obj.headerSpecs(headerRow, :);
        FXFw_Data      = instrContents(dataRows,    :);
        
        % +. Collect relevant 'FX Forward' Instrument Data
        instrData.instName              = obj.getContents(FXFw_Data, FXFw_Header, 'NAME');
        instrData.instrID               = obj.getContents(FXFw_Data, FXFw_Header, 'IDENTIFIER');
        instrData.currency              = obj.getContents(FXFw_Data, FXFw_Header, 'CurrencyUNIT');
        instrData.domesticCurrency      = obj.getContents(FXFw_Data, FXFw_Header, 'CurrencyUNIT');
        instrData.foreignCurrency       = obj.getContents(FXFw_Data, FXFw_Header, 'UnderlyingXREF');
        instrData.domesticDiscountCurve = obj.getContents(FXFw_Data, FXFw_Header, 'DiscountCurveXREF');
        instrData.foreignDiscountCurve  = obj.getContents(FXFw_Data, FXFw_Header, 'ForeignCurveXREF');
        instrData.maturityDate          = obj.getContents(FXFw_Data, FXFw_Header, 'Maturity DATE');
        % Not clear what SpotPriceVal is for these instruments--> MTM?
        instrData.SpotPriceVAL          = obj.getContents(FXFw_Data, FXFw_Header, 'SpotPriceVAL');
        instrData.strikePrice           = obj.getContents(FXFw_Data, FXFw_Header, 'StrikePriceVAL');
        
        % +. Typecast 'forwardSpotPrice' and 'strikePrice'
        instrData.SpotPriceVAL          = cell2mat(instrData.SpotPriceVAL);
        instrData.strikePrice           = cell2mat(instrData.strikePrice);
        % +. Typecast 'maturityDate'
        % American format for dates for now
        
        ConvertDate = @(x) datestr(datenum(x,'yyyy/mm/dd'),'mm/dd/yyyy');
        
%        instrData.maturityDate          = cellfun(ConvertDate,instrData.maturityDate, 'UniformOutput', false);
        
       instrData.maturityDate          =  cellfun(@(x) (datestr(x, 'mm/dd/yyyy')), instrData.maturityDate, 'UniformOutput', false);
        
        instrData.instrCount            = size(FXFw_Data, 1);
        
        % Check if the instrID is a string
        if any(~ischar(instrData.instrID))
            for i=1:instrData.instrCount
                if isnumeric(instrData.instrID{i})
                    instrData.instrID{i} = num2str(instrData.instrID{i});
                end
            end
        end
        
        
    case 'FXSwap'
        %% FX Swap
        % +. Collect Header- and Data rows
        instrContents  = obj.csvFileContents.instFile;
        
        % +. Find ENUMERATOR column ID
        [~, basColID]  = find(strcmpi(instrContents, 'BAS'));
        idCol          = basColID(1) + 1;
        
        [headerRow, ~] = find(strcmpi(obj.headerSpecs,         'DM FX SwapSPEC'));
        [dataRows, ~]  = find(strcmpi(instrContents(:, idCol), 'DM FX SwapSPEC'));
        
        if isempty(dataRows) || isempty(headerRow)
            instrData = [];
            return
        end
        
        % +. Collect 'FX Swap' Header and Data
        FXSw_Header    = obj.headerSpecs(headerRow, :);
        FXSw_Data      = instrContents(dataRows,    :);
        
        % +. Collect relevant 'FX Swap' Instrument Data
        instrData.instName              = obj.getContents(FXSw_Data, FXSw_Header, 'NAME');
        instrData.instrID               = obj.getContents(FXSw_Data, FXSw_Header, 'IDENTIFIER');
        instrData.currency              = obj.getContents(FXSw_Data, FXSw_Header, 'CurrencyUNIT');
        instrData.domesticCurrency      = obj.getContents(FXSw_Data, FXSw_Header, 'CurrencyUNIT');
        instrData.foreignCurrency       = obj.getContents(FXSw_Data, FXSw_Header, 'UnderlyingXREF');
        instrData.domesticDiscountCurve = obj.getContents(FXSw_Data, FXSw_Header, 'DiscountCurveXREF');
        instrData.foreignDiscountCurve  = obj.getContents(FXSw_Data, FXSw_Header, 'ForeignCurveXREF');
        instrData.effectiveDate         = obj.getContents(FXSw_Data, FXSw_Header, 'EffectiveDATE');
        instrData.maturityDate          = obj.getContents(FXSw_Data, FXSw_Header, 'Maturity DATE');
        instrData.contractSize          = obj.getContents(FXSw_Data, FXSw_Header, 'ContractSizeVAL');
        instrData.swapType              = obj.getContents(FXSw_Data, FXSw_Header, 'FxSwapTypeENUM');
        instrData.settlementType        = obj.getContents(FXSw_Data, FXSw_Header, 'SettlementTYPE');
        
        instrData.spotRate              = obj.getContents(FXSw_Data, FXSw_Header, 'SpotRateVAL'); % but we are going to override it when we value it, using the values in the Market Data file
        instrData.SpotPriceVAL          = obj.getContents(FXSw_Data, FXSw_Header, 'SpotPriceVAL'); % we don't really know yet what this is
        
        instrData.strikePrice           = obj.getContents(FXSw_Data, FXSw_Header, 'StrikePriceVAL');
        
        % +. Typecast 'tenor' and 'notional'
        instrData.contractSize          = cell2mat(instrData.contractSize);
        instrData.spotRate              = cell2mat(instrData.spotRate);
        instrData.strikePrice           = cell2mat(instrData.strikePrice);
        instrData.SpotPriceVAL          = cell2mat(instrData.SpotPriceVAL);
        % +. Typecast for dates
                ConvertDate = @(x) datestr(datenum(x,'yyyy/mm/dd'),'mm/dd/yyyy');
        
%        instrData.maturityDate          = cellfun(ConvertDate,instrData.maturityDate, 'UniformOutput', false);
        instrData.effectiveDate         = cellfun(ConvertDate, instrData.effectiveDate, 'UniformOutput', false);
        instrData.maturityDate          = cellfun(ConvertDate, instrData.maturityDate, 'UniformOutput', false);
        
        instrData.instrCount            = size(FXSw_Data, 1);
        
        % Check if the instrID is a string
        if any(~ischar(instrData.instrID))
            for i=1:instrData.instrCount
                if isnumeric(instrData.instrID{i})
                    instrData.instrID{i} = num2str(instrData.instrID{i});
                end
            end
        end
        
    case 'FXIRSwap'
        %% FXIR Swap
        % +. Collect Header- and Data rows
        instrContents  = obj.csvFileContents.instFile;
        
        % +. Find ENUMERATOR column ID
        [~, basColID]  = find(strcmpi(instrContents, 'BAS'));
        idCol          = basColID(1) + 1;
        
        % Read the generic fields for the Corss Currency Swap
        [headerRow, ~] = find(strcmpi(obj.headerSpecs,         'DM Cross Currency SwapSPEC'));
        [dataRows, ~]  = find(strcmpi(instrContents(:, idCol), 'DM Cross Currency SwapSPEC'));
        
        if isempty(dataRows) || isempty(headerRow)
            instrData = [];
            return
        end
        
        % +. Collect 'FXIR Swap' Header and Data
        Header    = obj.headerSpecs(headerRow, :);
        Data      = instrContents(dataRows,    :);
        
        % +. Collect relevant 'FXIR Swap' Instrument Data
        instrData.instName                      = obj.getContents(Data, Header, 'NAME');
        instrData.instrID                       = obj.getContents(Data, Header, 'IDENTIFIER');
        instrData.currency                      = obj.getContents(Data, Header, 'CurrencyUNIT');
        % ASSUMED WE RECEIVE THE DOMESTIC
        instrData.domesticCurrency              = obj.getContents(Data, Header, 'CurrencyUNIT');
        instrData.foreignCurrency               = obj.getContents(Data, Header, 'PayCurrencyUNIT');
        instrData.domesticDiscountCurve         = obj.getContents(Data, Header, 'DiscountCurveXREF');
        instrData.foreignDiscountCurve          = obj.getContents(Data, Header, 'PayDiscountCurveXREF');
        instrData.domesticDayCount              = obj.getContents(Data, Header, 'AccrualDCBasisDAYC');
        instrData.foreignDayCount               = obj.getContents(Data, Header, 'PayAccrualDCBasisDAYC');
        instrData.domesticRateType              = obj.getContents(Data, Header, 'RateTypeTYPE');
        instrData.foreignRateType               = obj.getContents(Data, Header, 'PayRateTypeTYPE');
        % DATES
        instrData.effectiveDate                 = obj.getContents(Data, Header, 'EffectiveDATE');
        instrData.maturityDate                  = obj.getContents(Data, Header, 'MaturityDATE');
        
        % If FIXED:
        instrData.domesticFixedCompPeriod       = obj.getContents(Data, Header, 'CouponRatePERD');
        instrData.foreignFixedCompPeriod        = obj.getContents(Data, Header, 'PayCouponRatePERD');
        % If FLOATING:
        instrData.domesticFloatCompPeriod       = obj.getContents(Data, Header, 'SpreadPERD');
        instrData.foreignFloatCompPeriod        = obj.getContents(Data, Header, 'PaySpreadPERD');
        % PAYMENT FREQUENCIES
        instrData.domesticFrequency             = obj.getContents(Data, Header, 'TermNB');
        instrData.domesticFrequencyUnits        = obj.getContents(Data, Header, 'TermUNIT');
        instrData.foreignFrequency              = obj.getContents(Data, Header, 'PayTermNB');
        instrData.foreignFrequencyUnits         = obj.getContents(Data, Header, 'PayTermUNIT');
        % Swap Market Value
        instrData.swapMarketValue               = obj.getContents(Data, Header, 'SpotPriceVAL'); % we don't really know yet what this is
        
        % +. Typecast for doubles
        instrData.swapMarketValue               = cell2mat(instrData.swapMarketValue);
        % +. Typecast for dates
                

        
        instrData.effectiveDate                 = cellfun(@(x) (datestr(x, 'mm/dd/yyyy')), instrData.effectiveDate, 'UniformOutput', false);
        instrData.maturityDate                  = cellfun(@(x) (datestr(x, 'mm/dd/yyyy')), instrData.maturityDate, 'UniformOutput', false);

        % Number of instruments
        instrData.instrCount                    = size(Data, 1);
        % Check if the instrID is a string
        if any(~ischar(instrData.instrID))
            for i=1:instrData.instrCount
                if isnumeric(instrData.instrID{i})
                    instrData.instrID{i} = num2str(instrData.instrID{i});
                end
            end
        end
        
        
        % Collect Coupon data
        [headerRow, ~] = find(strcmpi(obj.headerSpecs,         'DM Cross Currency SwapSPEC : Coupon List'));
        [dataRows, ~]  = find(strcmpi(instrContents(:, idCol), 'DM Cross Currency SwapSPEC : Coupon List'));
        if isempty(dataRows) || isempty(headerRow)
            % No coupons
            instrData.receiveCouponRate = NaN;
            instrData.receiveCouponDate = NaN;
        end
        Header    = obj.headerSpecs(headerRow, :);
        Data      = instrContents(dataRows,    :);
        if size(Data, 1) ~= instrData.instrCount
            % We are expecting just one Coupon List per FX IR Swap instrument
            error('STS_CM:processInstrData', ['FXIRSwaps: Unexpected instruments file, '...
                'not a single Receive Coupon List spec for each FXIR instrument'])
        end
        instrData.receiveCouponRate            = obj.getContents(Data, Header, 'CouponListVAL');
        instrData.receiveCouponDate            = obj.getContents(Data, Header, 'CouponListDATE');
        
        
        % Collect Spread data
        [headerRow, ~] = find(strcmpi(obj.headerSpecs,         'DM Cross Currency SwapSPEC : Spread List'));
        [dataRows, ~]  = find(strcmpi(instrContents(:, idCol), 'DM Cross Currency SwapSPEC : Spread List'));
        if isempty(dataRows) || isempty(headerRow)
            % No spreads for the receive leg
            instrData.receiveSpreadRate = NaN;
            instrData.receiveSpreadDate = NaN;
        end
        Header    = obj.headerSpecs(headerRow, :);
        Data      = instrContents(dataRows,    :);
        if size(Data, 1) ~= instrData.instrCount
            % We are expecting just one Coupon List per FX IR Swap instrument
            error('STS_CM:processInstrData', ['FXIRSwaps: Unexpected instruments file, '...
                'not a single Spread List spec for each FXIR instrument'])
        end
        instrData.receiveSpreadRate             = obj.getContents(Data, Header, 'SpreadListVAL');
        instrData.receiveSpreadDate             = obj.getContents(Data, Header, 'SpreadListDATE');
        
        
        % Collect Variable Notional data
        [headerRow, ~] = find(strcmpi(obj.headerSpecs,         'DM Cross Currency SwapSPEC : Variable Notional'));
        [dataRows, ~]  = find(strcmpi(instrContents(:, idCol), 'DM Cross Currency SwapSPEC : Variable Notional'));
        if isempty(dataRows) || isempty(headerRow)
            % No spreads for the pay leg
            instrData.receiveNotional = NaN;
            instrData.receiveNotionalDate = NaN;
        end
        Header    = obj.headerSpecs(headerRow, :);
        Data      = instrContents(dataRows,    :);
        if size(Data, 1) ~= instrData.instrCount
            % We are expecting just one Coupon List per FX IR Swap instrument
            error('STS_CM:processInstrData', ['FXIRSwaps: Unexpected instruments file, '...
                'not a single Receive Variable Notional spec for each FXIR instrument'])
        end
        instrData.receiveNotional                  = obj.getContents(Data, Header, 'VariabNotionalVAL');
        instrData.receiveNotionalDate              = obj.getContents(Data, Header, 'VariabNotionalDATE');
        
        
        % Collect Pay Coupon List
        [headerRow, ~] = find(strcmpi(obj.headerSpecs,         'DM Cross Currency SwapSPEC : Pay Coupon List'));
        [dataRows, ~]  = find(strcmpi(instrContents(:, idCol), 'DM Cross Currency SwapSPEC : Pay Coupon List'));
        if isempty(dataRows) || isempty(headerRow)
            % No coupons for the pay leg
            instrData.payCouponRate = NaN;
            instrData.payCouponDate = NaN;
        end
        Header    = obj.headerSpecs(headerRow, :);
        Data      = instrContents(dataRows,    :);
        if size(Data, 1) ~= instrData.instrCount
            % We are expecting just one Coupon List per FX IR Swap instrument
            error('STS_CM:processInstrData', ['FXIRSwaps: Unexpected instruments file, '...
                'not a single Pay Coupon List spec for each FXIR instrument'])
        end
        instrData.payCouponRate                  = obj.getContents(Data, Header, 'PayCouponListVAL');
        instrData.payCouponDate                  = obj.getContents(Data, Header, 'PayCouponListVAL');
        
        
        % Collect Pay Spread List
        [headerRow, ~] = find(strcmpi(obj.headerSpecs,         'DM Cross Currency SwapSPEC : Pay Spread List'));
        [dataRows, ~]  = find(strcmpi(instrContents(:, idCol), 'DM Cross Currency SwapSPEC : Pay Spread List'));
        if isempty(dataRows) || isempty(headerRow)
            % No spreads for the pay leg
            instrData.paySpreadRate = NaN;
            instrData.paySpreadDate = NaN;
        end
        Header    = obj.headerSpecs(headerRow, :);
        Data      = instrContents(dataRows,    :);
        if size(Data, 1) ~= instrData.instrCount
            % We are expecting just one Coupon List per FX IR Swap instrument
            error('STS_CM:processInstrData', ['FXIRSwaps: Unexpected instruments file, '...
                'not a single Pay Spread List spec for each FXIR instrument'])
        end
        instrData.paySpreadRate                  = obj.getContents(Data, Header, 'PaySpreadListVAL');
        instrData.paySpreadDate                  = obj.getContents(Data, Header, 'PaySpreadListDATE');
        
        
        % Collect Pay Variable Notional
        [headerRow, ~] = find(strcmpi(obj.headerSpecs,         'DM Cross Currency SwapSPEC : Pay Variable Notional'));
        [dataRows, ~]  = find(strcmpi(instrContents(:, idCol), 'DM Cross Currency SwapSPEC : Pay Variable Notional'));
        if isempty(dataRows) || isempty(headerRow)
            % No notional for the pay leg
            instrData.payNotional = NaN;
            instrData.payNotionalDate = NaN;
        end
        Header    = obj.headerSpecs(headerRow, :);
        Data      = instrContents(dataRows,    :);
        if size(Data, 1) ~= instrData.instrCount
            % We are expecting just one Coupon List per FX IR Swap instrument
            error('STS_CM:processInstrData', ['FXIRSwaps: Unexpected instruments file, '...
                'not a single Pay Variable Notional spec for each FXIR instrument'])
        end
        instrData.payNotional                    = obj.getContents(Data, Header, 'PayVariabNotionalVAL');
        instrData.payNotionalDate                = obj.getContents(Data, Header, 'PayVariabNotionalDATE');
        
        
        
    case 'FXOption'
        %% FX Option
        % +. Collect Header- and Data rows
        instrContents  = obj.csvFileContents.instFile;
        
        % +. Find ENUMERATOR column ID
        [~, basColID]  = find(strcmpi(instrContents, 'BAS'));
        idCol          = basColID(1) + 1;
        
        [headerRow, ~] = find(strcmpi(obj.headerSpecs,         'DM FX OptionSPEC'));
        [dataRows, ~]  = find(strcmpi(instrContents(:, idCol), 'DM FX OptionSPEC'));
        
        if isempty(dataRows) || isempty(headerRow)
            instrData = [];
            return
        end
        
        % +. Collect 'FX Option' Header and Data
        FXOpt_Header    = obj.headerSpecs(headerRow, :);
        FXOpt_Data      = instrContents(dataRows,    :);
        
        % +. Collect relevant 'FX Option' Instrument Data
        instrData.instName              = obj.getContents(FXOpt_Data, FXOpt_Header, 'NAME');
        instrData.instrID               = obj.getContents(FXOpt_Data, FXOpt_Header, 'IDENTIFIER');
        instrData.currency              = obj.getContents(FXOpt_Data, FXOpt_Header, 'CurrencyUNIT');
        instrData.domesticCurrency      = obj.getContents(FXOpt_Data, FXOpt_Header, 'CurrencyUNIT');
        instrData.foreignCurrency       = obj.getContents(FXOpt_Data, FXOpt_Header, 'UnderlyingXREF');
        instrData.domesticDiscountCurve = obj.getContents(FXOpt_Data, FXOpt_Header, 'DiscountCurveXREF');
        % The foreignDiscountCurve is not in the instruments file, we
        % derive it ourselves: NOT GOOD, BUT IT WORKS
        instrData.foreignDiscountCurve  = obj.getContents(FXOpt_Data, FXOpt_Header, 'UnderlyingXREF');
        f = @(x)strcat(x, '-SWAP');
        instrData.foreignDiscountCurve = cellfun(f, instrData.foreignDiscountCurve, 'UniformOutput', 0);
        
        instrData.maturityDate          = obj.getContents(FXOpt_Data, FXOpt_Header, 'MaturityDATE');
        instrData.contractSize          = obj.getContents(FXOpt_Data, FXOpt_Header, 'ContractSizeVAL');
        instrData.putCallFlag           = obj.getContents(FXOpt_Data, FXOpt_Header, 'OptionTypeENUM');
        
        %instrData.spotRate             we are going to take this from the Market Data file
        instrData.spotPriceVAL          = obj.getContents(FXOpt_Data, FXOpt_Header, 'SpotPriceVAL'); % we don't really know yet what this is
        
        instrData.strikePrice           = obj.getContents(FXOpt_Data, FXOpt_Header, 'StrikePriceVAL');
        
        % +. Typecast 'tenor' and 'notional'
        instrData.contractSize          = cell2mat(instrData.contractSize);
        %instrData.spotRate             = cell2mat(instrData.spotRate);
        instrData.strikePrice           = cell2mat(instrData.strikePrice);
        instrData.spotPriceVAL          = cell2mat(instrData.spotPriceVAL);
        
        
        % +. Typecast for dates
        instrData.maturityDate          = cellfun(@(x) (datestr(x, 'mm/dd/yyyy')), instrData.maturityDate, 'UniformOutput', false);
        
        instrData.instrCount            = size(FXOpt_Data, 1);
        
        % Check if the instrID is a string
        if any(~ischar(instrData.instrID))
            for i=1:instrData.instrCount
                if isnumeric(instrData.instrID{i})
                    instrData.instrID{i} = num2str(instrData.instrID{i});
                end
            end
        end
        
  
        
    case 'EquityIndex'
        %% EquityIndex
        % +. Collect Header- and Data rows
        instrContents  = obj.csvFileContents.instFile;
        
        % +. Find ENUMERATOR column ID
        [~, basColID]  = find(strcmpi(instrContents, 'BAS'));
        idCol          = basColID(1) + 1;
        
        [headerRow, ~] = find(strcmpi(obj.headerSpecs,         'DM EquitySPEC'));
        [dataRows, ~]  = find(strcmpi(instrContents(:, idCol), 'DM EquitySPEC'));
        
        if isempty(dataRows) || isempty(headerRow)
            instrData = [];
            return
        end
        
        % +. Collect 'EquityIndex' Header and Data
        EQ_Header    = obj.headerSpecs(headerRow, :);
        EQ_Data      = instrContents(dataRows,    :);
        
        % +. Collect relevant 'EquityIndex' Instrument Data
        instrData.instName              = obj.getContents(EQ_Data, EQ_Header, 'NAME');
        instrData.instrID               = obj.getContents(EQ_Data, EQ_Header, 'IDENTIFIER');
        instrData.currency              = obj.getContents(EQ_Data, EQ_Header, 'CurrencyUNIT');
        instrData.type                  = obj.getContents(EQ_Data, EQ_Header, 'ProductTypeENUM');
        instrData.spotPriceVAL          = obj.getContents(EQ_Data, EQ_Header, 'SpotPriceVAL');
        
        % +. Typecast 'spotPriceVAL'
        instrData.spotPriceVAL          = cell2mat(instrData.spotPriceVAL);
        
        % +. Typecast 'maturityDate'
        % American format for dates for now
        % instrData.maturityDate        =  cellfun(@(x) (datestr(x, 'mm/dd/yyyy')), instrData.maturityDate, 'UniformOutput', false);
        
        instrData.instrCount            = size(EQ_Data, 1);
        
        % Check if the instrID is a string
        if any(~ischar(instrData.instrID))
            for i=1:instrData.instrCount
                if isnumeric(instrData.instrID{i})
                    instrData.instrID{i} = num2str(instrData.instrID{i});
                end
            end
        end
        
        % Collect Equity Components for all the instruments
        [headerRow2, ~] = find(strcmpi(obj.headerSpecs,         'DM Equity'));
        [dataRows2, ~]  = find(strcmpi(instrContents(:, idCol), 'DM Equity'));
        instrData.underlyingFinancialEntities = [];
        if isempty(dataRows2) || isempty(headerRow2)
            % No Equity Underlying Components
            instrData.underlyingFinancialEntities = [];
        end
        Header    = obj.headerSpecs(headerRow2, :);
        Data      = instrContents(dataRows2,    :);
        if size(Data, 1) < instrData.instrCount
            % We are expecting at least one component per Equity instrument
            error('STS_CM:processInstrData', ['EquitySPEC: Unexpected instruments file, '...
                'could not find at least 1 underlying component for the Equity instruments'])
        end
        
        % We get the components data for all the instruments
        for iInst= 1: instrData.instrCount
            if iInst == instrData.instrCount
                % Just for the last instrument
                Components_Data = Data(dataRows2>dataRows(instrData.instrCount), :);
            else
                Components_Data = Data(dataRows2>dataRows(iInst) & dataRows2<dataRows(iInst+1), :);
            end
            if isempty(Components_Data)
                % No Equity Underlying Components
                error('STS:processInstrData', ['No underlying components for instrument '...
                    instrData.instName{iInst} ' in the instruments file']);
            end
            instrData.underlyingFinancialEntities{iInst}.Ref...
                = obj.getContents(Components_Data, Header, 'UndFinEntitisXREF');
            instrData.underlyingFinancialEntities{iInst}.Weight...
                = obj.getContents(Components_Data, Header, 'ComponentWghtVAL');
            % Type cast for Weight
            instrData.underlyingFinancialEntities{iInst}.Weight...
                = cell2mat(instrData.underlyingFinancialEntities{iInst}.Weight);
        end
        
        
        
        
        
        
        
        
        
        
        
        
    case 'nonMarketRisk'
        %% Non Market Risk
        % +. Collect Header- and Data rows
        instrContents  = obj.csvFileContents.instFile;
        
        % +. Find ENUMERATOR column ID
        [~, basColID]  = find(strcmpi(instrContents, 'BAS'));
        idCol          = basColID(1) + 1;
        
        [headerRow, ~] = find(strcmpi(obj.headerSpecs,         'Market IndexSPEC'));
        [dataRows, ~]  = find(strcmpi(instrContents(:, idCol), 'Market IndexSPEC'));
        
        if isempty(dataRows) || isempty(headerRow)
            instrData = [];
            return
        end
        
        % +. Collect 'Non Market Risk' Header and Data
        NMR_Header     = obj.headerSpecs(headerRow, :);
        NMR_Data       = instrContents(dataRows,    :);
        productType    = obj.getContents(NMR_Data, NMR_Header, 'ProductTypeENUM');
        
        nonMarketInd   = strcmpi(productType, 'Non Market');
        NMR_Data       = NMR_Data(nonMarketInd, :);
        
        % +. Collect relevant 'Non Market Risk' Instrument Data
        UserDefined1   = cell2mat(obj.getContents(NMR_Data, NMR_Header, 'UserDefined1NAME'));
        UserDefined2   = cell2mat(obj.getContents(NMR_Data, NMR_Header, 'UserDefined2NAME'));
        UserDefined3   = cell2mat(obj.getContents(NMR_Data, NMR_Header, 'UserDefined3NAME'));
        UserDefined4   = cell2mat(obj.getContents(NMR_Data, NMR_Header, 'UserDefined4NAME'));
        UserDefined5   = cell2mat(obj.getContents(NMR_Data, NMR_Header, 'UserDefined5NAME'));
        UserDefined6   = cell2mat(obj.getContents(NMR_Data, NMR_Header, 'UserDefined6NAME'));
        
        instrData.instrCount   = size(NMR_Data, 1);
        instrData.name         = obj.getContents(NMR_Data, NMR_Header, 'NAME');
        instrData.currency     = obj.getContents(NMR_Data, NMR_Header, 'CurrencyUNIT');
        instrData.ecParameters = [UserDefined1, UserDefined2, UserDefined3, ...
            UserDefined4, UserDefined5, UserDefined6];
        instrData.ecParameters(isnan(instrData.ecParameters)) = 0;
        
end

end % #processInstrData
