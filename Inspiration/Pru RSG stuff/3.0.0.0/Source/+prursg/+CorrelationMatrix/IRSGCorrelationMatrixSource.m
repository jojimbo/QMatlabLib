% The correlation matrix source interface. All sources will support the
% methods defined in this interface regardless of the data source e.g.
% filesystem, database, network (ftp, http etc.) or algorithm.
% The IRSGCorrelationMatrixSource interface derives from handle and
% therefore all derived classes have copy by reference sematics
classdef IRSGCorrelationMatrixSource < handle
    properties(Abstract)
        % Ordered names corresponding to Values
        % Used to look up one or more entries in the correlation matrix
        % Values. Names will not be unique where a risk model requires more
        % than one randome stream. Length(Names) == size(Values)
        % Will contain the Names of the correlated values follwing a 
        % successful invocation of readCorrelationMatrix
        names
        
        % An [n,n] matrix of ordered values corresponding to Names.
        % Will contain the correlated values follwing a successful
        % invocation of readCorrelationMatrix
        values
    end
	methods(Abstract)
        % The abstract method reads a correlation matrix from a source 
        % determined by a concrete implementation. 
        % out: result, true if the correlation matrix was sucessfully read,
        % false otherwise.
		result = readCorrelationMatrix(obj)
    end
end
