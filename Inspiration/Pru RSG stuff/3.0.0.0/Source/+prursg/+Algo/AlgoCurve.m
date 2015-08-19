classdef AlgoCurve < handle
    %ALGOCURVE Algo RiskWatch risk factors are called curves(everything is
    % a curve)
    %  This class mainains a mapping between RSG risk factors and Algo
    %  curves. 
    %  1. All fx risk factors are duplicated into 2 algo curves(one is a
    %  risk factor, the other is an exchange rate)
    %  1. RSG 1d credit spread factors, are aggregated into one algo 2d curve
    
    properties
        name        % different from risk.name in 'CREDIT_SPREAD' case
        risk_family % equals risk's risk family
        %risk_group  % equals risk's risk_group
        risk_groups % equals risk's risk_groups list
        currency    % equals risk currency
        type % one of 'INDEX' 'FX_RISK_FACTOR', 'FX_RATE', 'ZERO_CURVE', 'VOL', 'SVOL', 'CREDIT_SPREAD'
        indices % index/indices in global risks array and chunks array    
        dataSeries %dataSeries
        algoName % for perfomance improvement
        creditRatingAxisValues % cell array of 'AAA', 'AA' .... 'B'
        creditRatingIndex
        creditRatingsSize
    end
    
    methods
        function obj = AlgoCurve(name, riskFactor, type, index, dataSeries)            
            obj.name = name;
            obj.type = type;
            obj.algoName= [obj.makeSubsplit() '_sto'];
            obj.risk_family = riskFactor.risk_family;
            %obj.risk_group = riskFactor.risk_group;
            obj.risk_groups = riskFactor.risk_groups; % check that this is fine and that we do not need to create a Clone method
            obj.currency = riskFactor.currency;
            obj.indices = index;
            obj.dataSeries=dataSeries;
            obj.creditRatingAxisValues = []; % relevant only if type = CREDIT_SPREAD
            obj.creditRatingIndex = [];
            obj.creditRatingsSize = [];
        end
        
        
        % retrieves the column number
        function nColumns = getNumberOfColumns(obj, chunk)
            nColumns = 0;
            for i = 1:numel(obj.indices)                
                nColumns = nColumns + size(chunk{obj.indices(i)}, 2);
            end
        end
        
        function nColumns = getNumberOfColumnsByRisk(obj, nSubRisks)
            nColumns = 0;
            if(strcmp(obj.type, 'CREDIT_SPREAD'))
                nRating=numel(obj.creditRatingAxisValues);
                nColumns = nColumns + nSubRisks(obj.indices)*nRating;
            else
                nColumns = nColumns + nSubRisks(obj.indices);
            end
        end
        
        
        function result = isTransformationRequired(obj)
            result = 0;
            if (strcmpi(obj.type,'CREDIT_SPREAD'))
                result = 1;
            end
        end
        
        function out = getTransformedOutputs(obj, chunk, nSubRisks)                                    
            switch obj.type
                case 'CREDIT_SPREAD'     
                    nRows = size(chunk, 1);
                    nRating=numel(obj.creditRatingAxisValues);
                    out = zeros(nRows, size(chunk, 2)*nRating);
                    for i = 1:nRows
                        out(i, :) = transformCreditSpreadData(obj,chunk(i, :), nSubRisks(obj.indices(1)));
                    end
            end                
        end
        
        
        function value = getDeterministicValue(obj, expandedUniverse)
            
            value = expandedUniverse(obj.name).values{1}; % this is a single column vector
            
            % return a 2d matrix, first dimension is the term, second dim is
            % the credit rating
            if (strcmp(obj.type, 'CREDIT_SPREAD') )
                value = obj.initCreditSpread(value);
            end
        end
        
      
        
        function axis = getCreditSpreadTermAxis(obj,expandedUniverse)
            dataSeries = expandedUniverse(obj.name);
            axis = dataSeries.axes(1);
        end
        
        function str = getRatingsList(obj, delimiter)
            str = [];
            for i = 1:numel(obj.creditRatingAxisValues)
                str = [ str obj.creditRatingAxisValues{i} delimiter ];
            end                        
            str = str(1:end - 1);
        end
        
        function str = toString(obj)
            groups = obj.risk_groups(1).group;
            for i=2:length(obj.risk_groups)
                groups = [groups ', ' obj.risk_groups(i).group];
            end
            %str = sprintf('name: %s type: %s family: %s group: %s curr: %s indices: ', ...
            %              obj.name, obj.type, obj.risk_family, obj.risk_group, obj.currency);
            str = sprintf('name: %s type: %s family: %s groups: %s curr: %s indices: ', ...
                          obj.name, obj.type, obj.risk_family, groups, obj.currency);
            str = [ str num2str(obj.indices, '%d,') ];
            str = [str ' ' obj.getRatingsList(',') ];
        end
       

        % various algo naming conventions
        % in makeCurveRoom
        function out = makeSubsplit(obj)
            % GBP_equitycri becomes GBP_equitycri_default
            % GBP_equitycri_asx becomes GBP_equitycr_asx
            riskFactorName = obj.name;
            switch length(strfind(riskFactorName, '_'))
                case 1 %XXX_YYY
                    out = [riskFactorName '_default'];
                case 2 %XXX_YYY_ZZZ
                    if(strcmp(obj.type,'CREDIT_SPREAD')) %XXX_YYY_RRR
                        [ crvName rating ] = splitRiskName(obj.name);
                        riskFactorName=[crvName '_default_' rating];
                    end
                    out = riskFactorName;
                case 3 %XXX_YYY_ZZZ_RRRR credit spread                    
                    out = riskFactorName;
                otherwise
                    error(['wrong naming convention: ' riskFactorName]);
            end
        end

        % only here
        function out = makeDetCurve(obj)
            out = [ obj.makeSubsplit() '_det' ];
        end
        
        % makeAlgoBinaryHeader and makeBaseDeterministicScenarioFile
        function out = makeStoCurve(obj)
            out = [ obj.makeSubsplit() '_sto' ];
        end

        % makeCurveRoomFile
        function [split, det, sto ] = makeAllNames(obj)
            split = obj.makeSubsplit();
            det = obj.makeDetCurve();
            sto = obj.makeStoCurve();
        end        
        
        % create 2d credit spread matrix with the other rating initialiased to zero
         function crValue = initCreditSpread(obj,value)                          
            crValue=zeros(numel(value),obj.creditRatingsSize);
            crValue(:,obj.creditRatingIndex)=value;
         end
         
    end  
    
    methods (Static)
        function algoCurves = makeAlgoCurveList(risks, baseCurr, expandedUniverse)            
            algoCurves = [];
            i = 1;
            
            while i <= numel(risks) 
                risk = risks(i);
                dtSeries=expandedUniverse(risk.name);
                
                switch (risk.pru_type)
                    case { 'YC' }
                        algoCurves = [algoCurves curve(risk.name, risk, 'ZERO_CURVE', i, dtSeries) ];
                    case 'FX'
                        algoCurves = [algoCurves curve(risk.name, risk, 'FX_RISK_FACTOR', i, dtSeries) ]; %#ok<*AGROW>
                        algoCurves = [algoCurves curve(['FX_' baseCurr '/' risk.currency], risk, 'FX_RATE', i, dtSeries) ];                        
                    case 'Svol'
                        algoCurves = [ algoCurves curve(risk.name, risk, 'SVOL', i, dtSeries)];
                    case 'Vol'
                        algoCurves = [ algoCurves curve(risk.name, risk, 'VOL', i, dtSeries) ];
                    case 'Credit'
                        if strcmp(risk.risk_family, 'creditlqp')
                            algoCurves = [ algoCurves curve(risk.name, risk, 'ZERO_CURVE', i, dtSeries) ];
                        else
                            crv = curve(risk.name, risk, 'CREDIT_SPREAD', i , dtSeries);
                            crv.creditRatingAxisValues={'AAA'  'AA'  'A'  'BBB'  'BB'  'B'};
                            crv.creditRatingsSize = numel(crv.creditRatingAxisValues);
                            [ initRiskName rating ] = splitRiskName(risk.name);                                                        
                            crv.creditRatingIndex = find(ismember(crv.creditRatingAxisValues,rating)==1);
                            algoCurves=[algoCurves crv];
                        end
                    case 'Index'
                            algoCurves = [ algoCurves curve(risk.name, risk, 'INDEX', i , dtSeries) ];
                    otherwise
                        error('should not be here: %s', risk.name);
                end
                i = i + 1;
            end
        end
        
        
    end % methods
    

    
end

% private functions
function crv = curve(name, riskFactor, type, index, dataSeries)
    crv = prursg.Algo.AlgoCurve(name, riskFactor, type, index,dataSeries);
end


function [ name rating ] = splitRiskName(riskName)
    c = strfind(riskName, '_');
    name = riskName(1:c(end) - 1);
    rating = riskName(c(end) + 1: end);            
end

function row = transformCreditSpreadData(algoCurve, chunk, nSubRisk)
    crData = reshape(chunk', nSubRisk, []);  
    value2d   = algoCurve.initCreditSpread(crData);
    row = reshape(value2d', 1, []);
end