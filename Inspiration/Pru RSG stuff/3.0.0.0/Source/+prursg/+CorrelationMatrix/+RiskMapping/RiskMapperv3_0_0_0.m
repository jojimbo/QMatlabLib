classdef RiskMapperv3_0_0_0 < prursg.CorrelationMatrix.RiskMapping.RiskMapper        
    methods   
        % Construct a risk mapper. This class maps risk names to risks and
        % correlation groups to their associated entry in the correlation
        % matrix
        function obj = RiskMapperv3_0_0_0(correlationSource, riskDrivers)
            obj = obj@prursg.CorrelationMatrix.RiskMapping.RiskMapper(riskDrivers);
                        
            if isempty(correlationSource)
                throw(MException('RiskMapper:RiskMapper',...
                    'correlation source cannot be empty'));
            end
            
            obj.correlationSource = correlationSource;            
            obj.correlationGroups = obj.correlationSource.names;
            
            obj.buildCorrelationGroupMapping(riskDrivers);
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
            risk = obj.getRisk(riskName);
            groupName = risk.correlationGroup;
            % There will only ever be a one to one mapping between a group
            % name and one row (or column) in the correlated random
            % numbers. If mutiple stochastic inputs are required by a risk
            % model then this will be managed upstream by having additional
            % correlation groups
            matches  = ismember(obj.correlationGroups, groupName);
            stochInputs = obj.correlatedRandomNumbers(:, matches);            
        end
        
        % Retrieve a list of risk ordered according to the correlation matrix
        % Only risks which have a mapping into the correlation matrix are
        % returned and then only oe risk will be returned for correlation row. 
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
        
        % Retrieve an array of logicals ordered according to the risks
        % returned by getOrderedRisks. Filter elements indicate whether the
        % corresponding risk's output should be filtered
        % out:
        %   filter, An array of logical
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
                if isKey(obj.group_mapping, name) % use obj.group_mapping
                    r = obj.group_mapping(name{1});
                    risks = [risks r];
                end
            end            
        end
        
        function ordered = reOrder(obj, risks)
            % it's not clear if we need ordering, if we do then what's the
            % order? can;t order by correlation entry as it's no longer one
            % to one risk -> corr entry
            ordered = risks;
            %{
            ordered = [];
            numRisks = numel(risks);
            
            for i = 1:numRisks
                risk = risks(i);
                groupName = risk.correlationGroup;
                matches  = ismember(obj.correlationGroups, groupName);
            end
            %}
        end
        
        % Build a mapping of correlation groups to their constituent risks
        % Note this is unordered - see correlatedRiskEntries for the
        % crucial ordered list
        function buildCorrelationGroupMapping(obj, riskUniverse)
                     
            function [key, value] = kvpair(risk)
                key = risk.correlationGroup;
                value = risk;
            end
            
            [group_names, risks] = arrayfun(@kvpair, riskUniverse, 'UniformOutput', false);                        
            
            % <corr_group name, risk object> one -> one
            % The map will ensure unique keys and therefore we'll have a
            % one to one mapping even though the mapping is actually one to
            % many
            obj.group_mapping = containers.Map(group_names, risks);
        end  
        
    end
    methods(Access=protected)
        % Perform simple validation on the correlation matrix
        function validateCorrelatedRandomNumbers(obj, crn)
            if isempty(crn)
                 throw(MException('RiskMapper:Validation',...
                    'correlated random numbers cannot be empty'));
            end
            
            % show that the size of the correlated random number matches
            % the size of the correlation matrix
            [~, n] = size(crn); 
            if n ~= size(obj.correlationGroups)
                throw(MException('RiskMapper:Validate',...
                    ['Correlated random numbers matrix dimensions must '...
                    'match the number of correlation groups']));
            end
        end
    end
    
    properties(Access=private)
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