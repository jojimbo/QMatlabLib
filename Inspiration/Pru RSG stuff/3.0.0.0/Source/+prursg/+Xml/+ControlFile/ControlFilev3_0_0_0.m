% Class responsible for parsing a v3.0.0.0 schema and maintaning additional
% data such as the correlation source and groups
classdef ControlFilev3_0_0_0 < prursg.Xml.ControlFile.ControlFile
    methods
        function obj = ControlFilev3_0_0_0(dom, controlFile)
            obj = obj@prursg.Xml.ControlFile.ControlFile(dom, controlFile);
            obj.correlationMatrixSource = obj.getCorrelationSource();
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
        function [filteredRisks, filteredData] = filterSuppressedRisks(obj, risks, data)
            filter = arrayfun(@(x) ~x.suppressOutput, risks);

            % get all rows which match the filter
            filteredData = data(:,filter); 
            filteredRisks = risks(filter);
        end
    end
    
    properties     
        % The following property satisfies the IRSGControlFile 
        % interface. They have been added to support the introduction of 
        % schema versioning and configurable correlation matrix sources
        
        % Determines the location of the correlation matrix. This is 
        % defined in the control file where the schema version is v3.0.0.0
        % The control file is the default for backward compatibility
        correlationMatrixSource
    end
    
    methods(Access=private)
        function source = getCorrelationSource(obj)
            import prursg.CorrelationMatrix.*;
            source = CorrelationMatrixSourceFactory.getControlFileCorrelationSource(obj.controlFileDOM);      
        end
    end
end