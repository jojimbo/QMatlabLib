classdef RiskMapperv2_3_0_0 < prursg.CorrelationMatrix.RiskMapping.RiskMapper
    methods
        % Construct a risk mapper. This class maps risk names to risks and
        % their associated entry in the correlation matrix
        function obj = RiskMapperv2_3_0_0(correlationSource, riskDrivers)
            obj = obj@prursg.CorrelationMatrix.RiskMapping.RiskMapper(riskDrivers);
            
            if isempty(correlationSource)
                throw(MException('RiskMapper:RiskMapper',...
                    'correlation source cannot be null'));
            end
            
            obj.correlationSource = correlationSource;
            
            import prursg.CorrelationMatrix.RiskMapping.*;
            obj.riskIndexResolver = RiskIndexResolver(obj.correlationSource.names);
            obj.correlatedRiskEntries = obj.getCorrelatedRiskEntries();
            obj.orderedRisks = obj.reOrder(obj.riskDrivers);
        end
        
        % Retrieve the correlated random numbers associated with the
        % named risk.  
        % RSG v3.0.0.0+: 
        %   Where there is a many to one risk->correlationEntry 
        %   mapping the entry for correlation group will be returned in a 
        %   1 * nsims matrix.
        % RSG v2.7.0 and below:
        %   Where there exists more than one stream per risk the returned
        %   in a n * nsims matrix; although as of this wirting there are no
        %   risk models requiring > 1 random stream.
        % in:
        %   riskName, The name of the risk
        % out:
        %   stochInputs, A n * nsims array of correlated random numbers;
        %   where nsims is the number of simulations
        function stochInputs = getStochInputs(obj, riskName)
            % The risk index resolver is the class that was used prior to
            % v3.0.0.0. It is now use to provide the range in the vent that
            % more than one stream per risk model is required. There are no
            % such cases however, so we should consider simplifying by
            % removing it entirely and merely looking up the risk in the
            % correlation row
            range = obj.riskIndexResolver.getStochasticInputRange(riskName);
            % Note, if the riskName is not known, range will be an empty
            % array. corrRandNum(:, []) will then return an N * 0 array
            stochInputs = obj.correlatedRandomNumbers(:, range);
        end
        
        % Retrieve a list of risk ordered according to the correlation matrix
        % Only risks which have a mapping into the correlation matrix are
        % returned and then only one risk will be returned for correlation row. 
        % i.e. where there is a many to one risk->correlationEntry only one 
        % risk will be returned per entry.
        % out:
        %   risks, An array of risk objects which have an entry in the
        %   correlation matrix. 
        function risks = getCorrelatedRisks(obj)
            % Note: RSG v2.7.0 and below have a one to one mapping.
            % RSG v3.0.0.0 introduced a many to one mapping
            risks = obj.correlatedRiskEntries;
        end
        
        % Retrieve a risk array with the risks which have a mapping into the 
        % correlation matrix first, followed by the risks with no entry.
        % out:
        %   risks, An array of risk objects.
        function risks = getOrderedRisks(obj)
            risks = obj.orderedRisks;
        end
    end
    
    methods(Access=private)
        
        % A risk object per entry in the correlation matrix based on the
        % risk object's corr_group name and the name of the entry
        % **The risks will be ordered accoring to the names in the corr
        % matrix**
        function risks = getCorrelatedRiskEntries(obj)
            corr_names = obj.correlationSource.names;
            numCorreEntries = numel(corr_names);
            risks = [];
            
            for i = 1:numCorreEntries
                name = corr_names(i);
                name = obj.riskIndexResolver.stripRiskName(name{1});
                if isKey(obj.risk_mapping, name)
                    r = obj.risk_mapping(name);
                    risks = [risks r];
                end
            end
        end
        
        function ordered = reOrder(obj, risks)
            % some of the risks are present in the correlation matrix.
            % some - being a pure function on top of other, are not - put
            % them at the back of the ordering.
            out = cell(1, numel(risks));
            
            backIndex = numel(obj.correlatedRiskEntries) + 1;
            
            for i = 1:numel(risks)
                risk = risks(i);
                riskName = risk.name;
                if isKey(obj.riskIndexResolver.resolver, riskName)
                    out(obj.riskIndexResolver.getIndex(riskName)) = { risk };
                else
                    out(backIndex) = { risk };
                    backIndex = backIndex + 1;
                end
            end
            ordered = []; % copy the cell array to an ordinary array. Lame. there must be a better way?
            for i = 1:numel(out)
                ordered = [ ordered out{i} ]; %#ok<AGROW>
            end
        end
    end
    
    methods(Access=protected)
        
        function validateCorrelatedRandomNumbers(obj, crn)
            if isempty(crn)
                throw(MException('RiskMapper:Validation:MalformedInput',...
                    'correlated random numbers cannot be empty'));
            end
        end    
    end
    
    properties(Access=private)
        % returns an index into the correlation matrix. Taken from the
        % original implementation
        riskIndexResolver
        
        % The source of the correlation matrix
        correlationSource
        
        % Maps correlation group names to risks one -> (_one_ of many)
        group_mapping
        
        % A list of correlation group names as provided by the correlation
        % source object
        correlationGroups
        
        % An **_ordered_** list of the risk objects with an entry in the 
        % correlation matrix 
        correlatedRiskEntries
        
        % An array of risks ordered according to the correlated risks
        % first, followed by the uncorrelated risks
        orderedRisks
    end
end