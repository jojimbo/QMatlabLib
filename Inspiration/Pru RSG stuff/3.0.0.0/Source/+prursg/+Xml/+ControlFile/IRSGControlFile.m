classdef IRSGControlFile < handle
    properties (Abstract)
        % Added to support RSG v3.0.0.0 and the configurable correlation
        % matrix source
        
        % The fully qualified path to the control file
        controlFilePath
        
        % The control file DOM oject
        controlFileDOM
                
        % Determines the location of the correlation matrix. This is 
        % defined in the control file To be read from the control file
        correlationMatrixSource 
    end
    
    methods(Abstract)
        % Retrieve an array of data filtered according to the risk's 
        % suppressOutput flag.
        % in:
        %   risks, An array of risks ordered according to data
        %   data, The data to filter ordered according to risks
        % out:
        %   filteredRisks, An array of risks whose output is not to be
        %   filtered
        % out:
        %   filteredData, An Array of filtered data
        [filteredRisks, filteredData] = filterSuppressedRisks(obj, risks, data)
    end
end