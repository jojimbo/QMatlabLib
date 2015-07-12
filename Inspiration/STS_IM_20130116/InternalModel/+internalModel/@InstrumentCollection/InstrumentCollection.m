%% InstrumentCollection
% Implementation Type: Value Class (performance)
% Represents a collection of instruments, constructed with an instrument file
classdef InstrumentCollection
    %% Properties
    %
    % * |Instruments|
    %
    % *_private_*
    %
    % * |EquityIndex|
    properties(GetAccess = public)
        Instruments
    end
    
    properties (GetAccess = public, SetAccess = private)
        EquityIndex
    end
    
    %% Methods
    %
    % * |obj     = InstrumentCollection(calcObj)|                                   _constructor_
    % * |ECaggr  = calculateNonMarketECaggr(this, nmCorMat, ECmarket, ECop,             ...
    %                                       confidenceLvl, portfolio, portfolioNode,    ...
    %                                       forex, reportingCurrency, varargin)|
    % * |valCube = value(this , scenarioFile)|
    % * |ZCB     = extractZCBs(calcObj)|
    % * |FXFw    = extractFXForwards(calcObj)|
    % * |NMR     = extractEquityForwards(calcObj)|
    %
    methods
        function obj = InstrumentCollection(calcObj)
            %% InstrumentCollection _constructor_
            % |obj = InstrumentCollection(calcObj)|
            %
            % Inputs:
            % * |calcObj|       _Calculate_
            
            % Prepare Instrument Collection
            % 0. Initialize
            %#ok<*UNRCH>
            if nargin<1
                % return empty object
                return
            end
      
            % 1. Collect Instruments per Asset Class
            % Zero Coupon Bonds
            ZCB  = obj.extractZCBs(calcObj);
            
            % FX Forwards
            FXFw = obj.extractFXForwards(calcObj);  %#ok<*UNRCH>
            
            % FX Swaps
            FXSw = obj.extractFXSwaps(calcObj);
            
            % FX IR Swaps
            FXIRSw = obj.extractFXIRSwaps(calcObj);
            
            %FX Options
            FXOpt = obj.extractFXOptions(calcObj);
            
            % Equity Indices
            EQIndex = obj.extractEquityIndices(calcObj);
            
            % Non-Market Risk
            NMR  = obj.extractNonMarketRisk(calcObj);
            
         
            
            % 2. Prepare collection
            obj.Instruments = [num2cell(ZCB), num2cell(FXFw),       ...
                num2cell(FXSw),                      ...
                num2cell(FXIRSw), num2cell(FXOpt),                  ...
                num2cell(EQIndex),                                  ...
                num2cell(NMR)];
            
        end
        
        
        function valCube = value(obj, scenarioFile)
            %% value
            % |valCube = value(obj, scenarioFile)|
            %
            % Inputs:
            % * |scenarioFile|  _char_
            %
            % Outputs:
            % * |valCube|       _double_
            %
            instruments = obj.Instruments;
            
            for iIns = 1:numel(obj.Instruments)
                valCube(iIns, :) = instruments{iIns}.value(scenarioFile); %#ok<AGROW> size not known a priori
            end
            
        end % #Value
        
        
        function ECaggr = calculateNonMarketECaggr(this, nmCorMat, ECmarket,  ECop,          ...
                confidenceLvl,  portfolio, portfolioNode, ...
                forex,  reportingCurrency, varargin)
            %% calculateNonMarketECaggr
            % |EGaggr = calculateNonMarketECaggr(this)|
            %
            % Inputs:
            % * |this|          _InstrumentCollection_
            % * |nmCorMat|      _NonMarketCorrMatrix_
            % * |ECmarket|      _double_
            % * |ECop|          _double_
            % * |confidenceLvL| _double_
            % * |portfolio|     _char_
            % * |portfolioNode| _char_
            % * |varargin|      _cell_ riskType 1xn
            %
            % Output:
            % * |ECaggr|        _double_
            %
            if ~isempty(varargin)
                if iscell(varargin{1})
                    riskType = varargin{1};
                else
                    riskType = varargin(1);
                end
                
            else
                riskType = '';
            end
            
            % Find NonMarketRisk objects in this
            anomIsa = @(x)isa(x, 'internalModel.NonMarketRisk');
            idxNMR  = cellfun(anomIsa, this.Instruments);
            
            if ~any(idxNMR)
                % In this case, only propagate 'ECmarket'
                ECaggr = ECmarket;
                return
            end
            
            % Collect selected instruments
            NMRs            = this.Instruments(idxNMR);
            nmrIdInInstCol  = cellfun(@(x)(x.Name), NMRs, 'UniformOutput', false);
            
            % Compare to Portfolio, from node on
            groupsNmsNeeded = portfolio.findOffspring(portfolioNode);
            findGID         = @(x)(x.GID);
            allGroupNms     = cellfun(findGID, portfolio.groups);
            
            % Find intersection of groups needed for calculation and all groups(names)
            [~ ,~ ,idxGrNeeded] = intersect(groupsNmsNeeded, allGroupNms);
            groupsNeeded        = portfolio.groups(idxGrNeeded);
            
            % Check whether 'positions' field is available
            anomHasPos   = @(x)isfield(x, 'positions');
            idxHasPos    = cellfun(anomHasPos, groupsNeeded);
            groupsHasPos = groupsNeeded(idxHasPos);
            nmrIdsInPF   = [];
            
            for iGroupsPos = 1:numel(groupsHasPos)
                nmrIdsInPF = [nmrIdsInPF groupsHasPos{iGroupsPos}.positions.SEC_ID]; %#ok<AGROW> size not known a priori
            end
            
            % Find intersection of NMR needed for calculation and all
            % NMR in the instrumentCollection
            [~ ,~ , InPfAndIC] = intersect(nmrIdsInPF, nmrIdInInstCol);
            
            if ~isempty(riskType)
                NMRsRisk            = NMRs(InPfAndIC);
                nmrRtInInstCol      = cellfun(@(x)(x.RiskType), NMRsRisk, 'UniformOutput', false);
                
                [~, ~, idxRiskType] = intersect(riskType, nmrRtInInstCol);
                NMRsToCalc          = NMRsRisk(idxRiskType);
                
            else
                NMRsToCalc = NMRs(InPfAndIC);
            end
            
            % Calculate EC for NMR's
            ECvector = zeros(numel(NMRsToCalc) + 1, 1);
            
            for iNMR = 1:numel(NMRsToCalc)
                % Correct for Reporting Currency, if required
                instrCurr = NMRsToCalc{iNMR}.Currency;
                rate      = 1;
                
                if ~strcmpi(instrCurr, reportingCurrency)
                    % Rate Conversion call: [startCurrency, TargetCurrency]
                    rate = forex.getRate(instrCurr, reportingCurrency);
                end
                
                % Calculate Non-Market EC, FX corrected
                ECvector(iNMR) = rate * NMRsToCalc{iNMR}.calculateECVector(confidenceLvl);
            end
            
            % Add Market EC at the end of the Vector
            ECvector(end) = ECmarket;
            
            % Construct correlation matrix based on current NMR's instruments
            corrMat = zeros(numel(ECvector));
            
            for iNMR = 1:length(NMRsToCalc)
                % Loop over rows
                idxRow = nmCorMat.lookupBEandRT(NMRsToCalc{iNMR});
                
                for jNMR = 1:length(NMRsToCalc)
                    % Loop over columns
                    idxCol  = nmCorMat.lookupBEandRT(NMRsToCalc{jNMR});
                    
                    % Fill matrix entry
                    corrMat(iNMR, jNMR) = nmCorMat.correlationMatrix(idxRow, idxCol);
                end
                
                % Fill last column/row entry, reusage of idxRow for column,
                % as they are mirrored
                corrMat(iNMR, end) = nmCorMat.correlationMatrix(idxRow, end);
                corrMat(end, iNMR) = nmCorMat.correlationMatrix(end, idxRow);
            end
            
            % Final entry
            corrMat(end, end) = nmCorMat.correlationMatrix(end, end);
            ECaggr = sqrt(ECvector' * corrMat * ECvector) + ECop;
            
        end % #calculateNonMarketECaggr
        
    end % #Methods Public
    
    
    
    
    methods (Static, Access = private)
          function ZCB = extractZCBs(calcObj)
            %% extractZCBs _private static_
            % |ZCB = extractZCBs(calcObj)|
            %
            % Inputs:
            % * |calcObj|   _Calculation_
            %
            % Outputs:
            % * |ZCB|       _ZeroCouponBond_
            
            % Create Instance(s)
            dataZCB = calcObj.configuration.processInstrData('ZeroCouponBond');
            
            if isempty(dataZCB)
                ZCB = [];
                return
            end
            
            % Create Objects
            ZCB = internalModel.Instruments.ZeroCouponBond.empty(dataZCB.instrCount, 0);
            
            for iZCB = 1:dataZCB.instrCount
                % Loop over 'instrCount'
                ZCB(iZCB) = internalModel.Instruments.ZeroCouponBond(...
                    dataZCB.name{iZCB},          ...
                    dataZCB.instrID{iZCB},       ...
                    dataZCB.currency{iZCB},      ...
                    dataZCB.domesticCurve{iZCB}, ...
                    dataZCB.tenor(iZCB),         ...
                    dataZCB.creditSpread{iZCB},  ...
                    dataZCB.notional(iZCB),       ...
                    {datestr(calcObj.parameters.valuationDate, 'mm/dd/yyyy')} ...
                    );
            end
            
        end % #extractZCBs
        
        
        function FXFw = extractFXForwards(calcObj)
            %% extractFXForwards _private static_
            % |FXFw = extractFXForwards(calcObj)|
            %
            % Inputs:
            % * |calcObj|   _Calculation_
            %
            % Outputs:
            % * |FXFw|      _FXForward_
            
            % Create Instance(s)
            dataFXFw = calcObj.configuration.processInstrData('FxForward');
            
            if isempty(dataFXFw)
                FXFw = [];
                return
            end
            
            % Create Objects
            FXFw = internalModel.Instruments.FXForward.empty(dataFXFw.instrCount, 0);
            
            for iFXFw = 1:dataFXFw.instrCount
                % Loop over 'instrCount'
                FXFw(iFXFw) = internalModel.Instruments.FXForward(      ...
                    dataFXFw.instName{iFXFw},                           ...
                    dataFXFw.instrID{iFXFw},                            ...
                    dataFXFw.currency{iFXFw},                           ...
                    dataFXFw.domesticCurrency{iFXFw},                   ...
                    dataFXFw.foreignCurrency{iFXFw},                    ...
                    dataFXFw.domesticDiscountCurve{iFXFw},              ...
                    dataFXFw.foreignDiscountCurve{iFXFw},               ...
                    dataFXFw.maturityDate(iFXFw),                       ...
                    {datestr(calcObj.parameters.valuationDate, 'mm/dd/yyyy')},   ...
                    dataFXFw.SpotPriceVAL(iFXFw),                       ...
                    dataFXFw.strikePrice(iFXFw)                         ...
                    );
            end
            
        end % #extractFXForwards
        
        
        function FXSw = extractFXSwaps(calcObj)
            %% extractFXSwaps _private static_
            % |FXSw = extractFXSwaps(data)|
            %
            % Inputs:
            %
            % * |data|  _cell_
            %
            % Outputs:
            %
            % * |FXSw|   _FXSw_
            
            %Create Instance(s)
            dataFXSw = calcObj.configuration.processInstrData('FXSwap');
            
            
            if isempty(dataFXSw)
                FXSw = [];
                return
            end
            
            % Create Objects
            FXSw = internalModel.Instruments.FXSwap.empty(dataFXSw.instrCount, 0);
            
            for iFXSw = 1:dataFXSw.instrCount
                % Loop over 'instrCount'
                FXSw(iFXSw) = internalModel.Instruments.FXSwap(...
                    dataFXSw.instName{iFXSw},               ...
                    dataFXSw.instrID{iFXSw},                ...
                    dataFXSw.currency{iFXSw},               ...
                    dataFXSw.domesticCurrency{iFXSw},       ...
                    dataFXSw.foreignCurrency{iFXSw},        ...
                    dataFXSw.domesticDiscountCurve{iFXSw},  ...
                    dataFXSw.foreignDiscountCurve{iFXSw},   ...
                    dataFXSw.effectiveDate(iFXSw),          ...
                    dataFXSw.maturityDate(iFXSw),           ...
                    dataFXSw.contractSize(iFXSw),           ...
                    dataFXSw.swapType(iFXSw),               ...
                    dataFXSw.settlementType(iFXSw),         ...
                    dataFXSw.spotRate(iFXSw),               ...
                    dataFXSw.SpotPriceVAL(iFXSw),           ...
                    dataFXSw.strikePrice(iFXSw),            ...
                    {datestr(calcObj.parameters.valuationDate, 'mm/dd/yyyy')} ...
                    );
            end
        end % #extractFXSwaps
        
        
        function FXIRSw = extractFXIRSwaps(calcObj)
            %% extractFXIRSwaps _private static_
            % |FXIRSw = extractFXIRSwaps(data)|
            %
            % Inputs:
            %
            % * |data|  _cell_
            %
            % Outputs:
            %
            % * |FXIRSw|   _FXIRSw_
            
            %Create Instance(s)
            dataFXIRSw = calcObj.configuration.processInstrData('FXIRSwap');
            
            
            if isempty(dataFXIRSw)
                FXIRSw = [];
                return
            end
            
            % Create Objects
            FXIRSw = internalModel.Instruments.FXIRSwap.empty(dataFXIRSw.instrCount, 0);
            
            for iFXIRSw = 1:dataFXIRSw.instrCount
                % Loop over 'instrCount'
                FXIRSw(iFXIRSw) = internalModel.Instruments.FXIRSwap(   ...
                    dataFXIRSw.instName{iFXIRSw},                               ...
                    dataFXIRSw.instrID{iFXIRSw},                                ...
                    dataFXIRSw.currency{iFXIRSw},                               ...
                    dataFXIRSw.domesticCurrency{iFXIRSw},                       ...
                    dataFXIRSw.foreignCurrency{iFXIRSw},                        ...
                    dataFXIRSw.domesticDiscountCurve{iFXIRSw},                  ...
                    dataFXIRSw.foreignDiscountCurve{iFXIRSw},                   ...
                    dataFXIRSw.domesticDayCount{iFXIRSw},                       ...
                    dataFXIRSw.foreignDayCount{iFXIRSw},                        ...
                    dataFXIRSw.domesticRateType{iFXIRSw},                       ...
                    dataFXIRSw.foreignRateType{iFXIRSw},                        ...
                    dataFXIRSw.domesticFrequency{iFXIRSw},                      ...
                    dataFXIRSw.domesticFrequencyUnits{iFXIRSw},                 ...
                    dataFXIRSw.foreignFrequency{iFXIRSw},                       ...
                    dataFXIRSw.foreignFrequencyUnits{iFXIRSw},                  ...
                    dataFXIRSw.receiveCouponRate{iFXIRSw},                      ...
                    dataFXIRSw.payCouponRate{iFXIRSw},                          ...
                    dataFXIRSw.receiveSpreadRate{iFXIRSw},                      ...
                    dataFXIRSw.paySpreadRate{iFXIRSw},                          ...
                    dataFXIRSw.receiveNotional{iFXIRSw},                        ...
                    dataFXIRSw.payNotional{iFXIRSw},                            ...
                    ...
                    dataFXIRSw.effectiveDate(iFXIRSw),                          ...
                    dataFXIRSw.maturityDate(iFXIRSw),                           ...
                    {datestr(calcObj.parameters.valuationDate, 'mm/dd/yyyy')}   ...
                    );
            end
        end % #extractFXIRSwaps
        
         function FXOpt = extractFXOptions(calcObj)
        %% extractFXOpt _private static_
            % |FXOpt = extractFXOpt(data)|
            %
            % Inputs:
            %
            % * |data|  _cell_
            %
            % Outputs:
            %
            % * |FXOpt|   _FXOpt_
            
            %Create Instance(s)
            dataFXOpt = calcObj.configuration.processInstrData('FXOption');
            
            if isempty(dataFXOpt)
                FXOpt = [];
                return
            end
            
            % Create Objects
            FXOpt = internalModel.Instruments.FXOption.empty(dataFXOpt.instrCount, 0);
            
            for iFXOpt = 1:dataFXOpt.instrCount
                % Loop over 'instrCount'
                FXOpt(iFXOpt) = internalModel.Instruments.FXOption(           ...
                    dataFXOpt.instName{iFXOpt},                               ...
                    dataFXOpt.instrID{iFXOpt},                                ...
                    dataFXOpt.currency{iFXOpt},                               ...
                    dataFXOpt.domesticCurrency{iFXOpt},                       ...
                    dataFXOpt.foreignCurrency{iFXOpt},                        ...
                    dataFXOpt.domesticDiscountCurve{iFXOpt},                  ...
                    dataFXOpt.foreignDiscountCurve{iFXOpt},                  ...
                    dataFXOpt.maturityDate(iFXOpt),                           ...
                    dataFXOpt.spotPriceVAL(iFXOpt),                           ...
                    dataFXOpt.strikePrice(iFXOpt),                            ...
                    dataFXOpt.contractSize(iFXOpt),                           ...  
                    dataFXOpt.putCallFlag(iFXOpt),                            ...
                    {datestr(calcObj.parameters.valuationDate, 'mm/dd/yyyy')} ...
                    );
            end
        end % #extractFXOpt
        
        function EQIndex = extractEquityIndices(calcObj)
            %% extractEquityIndices _private_
            % |EQIndex = extractEquityIndices(calcObj)|
            %
            % Inputs:
            % * |calcObj|   _Calculation_
            %
            % Outputs:
            % * |EQIndex|  _EquityIndex_
            
            % Create Instance(s)
            dataEQ = calcObj.configuration.processInstrData('EquityIndex');
            
            if isempty(dataEQ)
                EQIndex = [];
                return
            end
            
            % Create Objects
            EQIndex = internalModel.Instruments.EQIndex.empty(dataEQ.instrCount, 0);
            
            % Loop over 'instrCount'
            for iEQ = 1:dataEQ.instrCount
                % Loop over 'Underlyings'
                underlyings = [];
                for iUnd = 1:numel(dataEQ.underlyingFinancialEntities{iEQ}.Ref)
                    underlyings = [underlyings ...
                        internalModel.EquityUnderlying(dataEQ.underlyingFinancialEntities{iEQ}.Ref{iUnd},...
                        dataEQ.underlyingFinancialEntities{iEQ}.Weight(iUnd) ) ];
                end          
                EQIndex(iEQ) = internalModel.Instruments.EQIndex(...
                    dataEQ.instName{iEQ},                       ...
                    dataEQ.instrID{iEQ},                        ...
                    dataEQ.currency{iEQ},                       ...
                    dataEQ.spotPriceVAL(iEQ),                   ...
                    dataEQ.type{iEQ},                           ...
                    underlyings,    ...
                    {datestr(calcObj.parameters.valuationDate, 'mm/dd/yyyy')} ...
                    );
            end
                                %dataEQ.underlyingFinancialEntities{iEQ},

        end % #extractEquityIndices
       
        
        function NMR = extractNonMarketRisk(calcObj)
            %% extractNonMarketRisk _private static_
            % |NMR = extractNonMarketRisk(calcObj)|
            %
            % Inputs:
            % * |calcObj|   _Calculation_
            %
            % Outputs:
            % * |NMR|       _NonMarketRisk_
            %
            % Create Instance(s)
            dataNMR = calcObj.configuration.processInstrData('nonMarketRisk');
            
            if isempty(dataNMR)
                NMR = [];
                return
            end
            
            
            % Create Objects
            NMR = internalModel.NonMarketRisk.empty(dataNMR.instrCount, 0);
            
            for iNMR = 1:dataNMR.instrCount
                % Loop over 'instrCount'
                NMR(iNMR) = internalModel.NonMarketRisk(       ...
                    dataNMR.name{iNMR},            ...
                    dataNMR.currency{iNMR},        ...
                    dataNMR.ecParameters(iNMR, :)  ...
                    );
            end
            
            
        end % #extractNonMarketRisk
        
    end % #Methods Static, Private
    
end
