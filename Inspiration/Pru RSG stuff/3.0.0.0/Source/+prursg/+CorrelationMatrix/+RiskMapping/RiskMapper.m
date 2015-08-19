% This abstract base class implements the parts of the IRSGRiskMapper 
% interface common to derived implementations.
classdef RiskMapper < prursg.CorrelationMatrix.RiskMapping.IRSGRiskMapper & handle   
    methods   
        % Build a risk name to object mapping for use by derived classes
        function obj = RiskMapper(riskDrivers)
            obj.riskDrivers = riskDrivers;
            obj.risk_mapping = obj.buildRiskMapping(riskDrivers);
        end
        
        % Initialise the mapper with the correlated random numbers. A call
        % to this method must be made before getStochInputs.
        % in:
        %   crn, An n * n array of correlated random numbers
        % out:
        %   An exception in the event that crn fails validation
        function setCorrelatedRandomNumbers(obj, crn)
            obj.validateCorrelatedRandomNumbers(crn);
            obj.correlatedRandomNumbers = crn;
        end
        
        % Find the risk object associated with the risk name from in the risk
        % universe read from the control file. This is not limited to the
        % correlation matrix entries.
        % in:
        %   The name of the risk
        % out:
        %   The risk object or [] if not found
        function  risk = getRisk(obj, riskName)
            if isKey(obj.risk_mapping, riskName)
                risk = obj.risk_mapping(riskName);
            else
                risk = [];
            end
        end
    end
    
    properties(GetAccess=protected, SetAccess=private)
        % An n * n array of correlated random numbers.
        % This property must be initialised before getStochInputs is called
        correlatedRandomNumbers
  
        % An array of IRSGRisk objects read from the control file.
        riskDrivers
        
        % A map of risk names to risk object. The risk are from
        % the risk_driver_set.
        risk_mapping
    end    
        
    methods(Abstract, Access=protected)
        validateCorrelatedRandomNumbers(obj, crn);
    end
    
    methods(Access=private)
        % Build a mapping of risk names to risk object. The risk are from
        % the risk_driver_set.
        % in:
        %   riskUniverse, An array of IRSGRisk objects read from the
        %   control file.
        % out:
        %   riskMap, A map of risk names to risk object. 
        function riskMap = buildRiskMapping(obj, riskUniverse)
            
            function [key, value] = kvpair(risk)
                key = risk.name;
                value = risk;
            end
            
            [risk_names, risks] = arrayfun(@kvpair, riskUniverse, 'UniformOutput', false); 
            
            % Uncomment if the single step arrayfun causes issues
            %risk_names = arrayfun(@(x) x.name, riskUniverse, 'UniformOutput', false);                        
            %risks = arrayfun(@(x) x, riskUniverse, 'UniformOutput', false); 
            
            % <risk name, risk object>
            riskMap = containers.Map(risk_names, risks);
        end
    end
end