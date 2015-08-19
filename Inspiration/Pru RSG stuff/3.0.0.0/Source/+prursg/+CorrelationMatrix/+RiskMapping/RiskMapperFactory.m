% The risk mapping factory provides a static create method to create an
% instance of a risk mapping according to the version of the the control
% file.
classdef RiskMapperFactory
    methods(Static)
        % Instantiate a risk mapping object
        % in:
        %   schemaVersion, The version of he control file schema
        % out:
        %   riskMapper, A concrete instance of IRSGRiskMapping
        function riskMapper = create(correlationSource, riskDrivers)
            
            import prursg.Xml.ControlFile.*;
            import prursg.Version.*;
            import prursg.CorrelationMatrix.RiskMapping.*;
            
            instance = VersionInfo.instance();
            schemaVersion = instance.RSGSchemaVersion;
            
            switch schemaVersion
                case instance.v2_3_0_0
                    riskMapper = RiskMapperv2_3_0_0(correlationSource, riskDrivers);
                case instance.v3_0_0_0
                    riskMapper = RiskMapperv3_0_0_0(correlationSource, riskDrivers);
                otherwise                    
                    fprintf(['Error parsing the control file when attempting'...
                        ' to read the schema version. '...
                        'Version %s found in PruRSG is not supported\n'], value);
                    throw(MException('ControlFileFactory:create:MalformedInput',...
                        'Unsupported version'));
            end
        end
    end
end