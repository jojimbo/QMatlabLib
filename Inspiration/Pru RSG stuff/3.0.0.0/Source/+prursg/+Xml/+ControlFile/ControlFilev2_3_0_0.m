classdef ControlFilev2_3_0_0 < prursg.Xml.ControlFile.ControlFile
    methods
        function obj = ControlFilev2_3_0_0(dom, controlFile)
            obj = obj@prursg.Xml.ControlFile.ControlFile(dom, controlFile);
            obj.processFile();
        end
        
        
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
        function [filteredRisks, filteredData] = filterSuppressedRisks(obj, risks, data) %#ok<MANU>
            % There is no risk model output suppression in the v2.3.0 schema 
            % so return the input data
            filteredData = data;
            filteredRisks = risks;
        end
    end
    
    properties     
        % The following property satisfies the IRSGControlFile 
        % interface. They have been added to support the introduction of 
        % schema versioning and configurable correlation matrix sources
                
        % Determines the location of the correlation matrix. This is 
        % defined in the control file where the schema version is v3.0.0.0
        % The control file is the default for backward compatibility
        correlationMatrixSource = prursg.CorrelationMatrix.CorrelationMatrixSourceFactory.ControlFile;
    end
end