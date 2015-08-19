classdef MockControlFile < prursg.Xml.ControlFile.IRSGControlFile & handle
    properties       
        % The fully qualified path to the control file
        % This value is not used by the tests but is included in order to
        % satisfy the interface
        controlFilePath = 'foo'
        
        % The control file DOM oject
        controlFileDOM
                
        % Determines the location of the correlation matrix. 
        % This value will be set by the test
        correlationMatrixSource 
    end
    
    methods
        function [filteredRisks, filteredData] = filterSuppressedRisks(obj, risks, data)
        end
    end
end
