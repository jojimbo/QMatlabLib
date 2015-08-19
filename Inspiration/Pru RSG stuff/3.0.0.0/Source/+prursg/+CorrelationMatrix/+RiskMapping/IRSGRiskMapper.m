% The risk mapping interface. All risk mappings will support the
% methods defined in this interface. The interface derives from handle and
% therefore all derived classes have copy by reference semantics
classdef IRSGRiskMapper < handle
    methods(Abstract)
        % Initialise the mapper with the correlated random numbers. A call
        % to this method must be made before getStochInputs.
        % in:
        %   crn, An n * n array of correlated random numbers
        % out:
        %   An exception in the event that crn fails validation
        setCorrelatedRandomNumbers(obj, crn)
        
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
        stochInputs = getStochInputs(obj, riskName);
        
        % Find the risk object associated with the risk name from in the risk
        % universe read from the control file. This is not limited to the
        % correlation matrix entries.
        % in:
        %   The name of the risk
        % out:
        %   The risk object or [] if not found
        risk = getRisk(obj, riskName)
        
        % Retrieve risks which have a mapping into the correlation matrix.
        % One risk will be returned for each entry. Where there is a many 
        % to one risk->correlationEntry only one risk will be returned per 
        % entry.
        % out:
        %   risks, An array of risk objects which have an entry in the
        %   correlation matrix. 
        risks = getCorrelatedRisks(obj)
        
        % Retrieve a risk array with the risks which have a mapping into the 
        % correlation matrix first, followed by the risks with no entry.
        % out:
        %   risks, An array of risk objects.
        risks = getOrderedRisks(obj)
    end
end