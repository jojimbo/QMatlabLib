% The correlation matrix source factory creates an instance of a 
% correlation source as dictated by the version of the the control file and 
% if present (dependent on the control file version) the type of source 
% specified in the control file
classdef CorrelationMatrixSourceFactory
    properties (Constant = true)
        ControlFile = 'ControlFile'
        XLS = 'XLS'
        None = 'None'
    end
    
	methods(Static)
        % Instantiate a correlation source 
        % in: 
        %   controlFile, A concrete instance of IControlFile 
        % out:
        %   source, A concrete instance of IRSGCorrelationMatrixSource
		function source = create(controlFile)
            import prursg.CorrelationMatrix.*;
            import prursg.Version.*;
    
            instance = VersionInfo.instance();
            schemaVersion = instance.RSGSchemaVersion;
    
            switch schemaVersion
                case {instance.v0_0_0_0,...
                        instance.v2_3_0_0}
                    source = CorrelationMatrixControlFileSource(controlFile);
                case instance.v3_0_0_0
                    switch controlFile.correlationMatrixSource
                        case CorrelationMatrixSourceFactory.ControlFile
                            source = CorrelationMatrixControlFileSource(controlFile);
                        case CorrelationMatrixSourceFactory.XLS
                            source = CorrelationMatrixXlsSource(controlFile);
                        case CorrelationMatrixSourceFactory.None
                            source = [];
                        otherwise
                            fprintf('Error: Unexpected source tyep "%s"', controlFile.CorrelationSource);
                            throw(MException('CorrelationMatrixSourceFactory:getCorrelationSource:MalformedInput',...
                            'Unexpected correlation source'));
                    end
                otherwise
                    fprintf('Error: Unexpected schema version "%s"', schemaVersion);
                    throw(MException('CorrelationMatrixSourceFactory:getCorrelationSource:MalformedInput',...
                        'Unexpected schema version'));
            end
        end
    
        function source = getControlFileCorrelationSource(dom)
            import prursg.CorrelationMatrix.*;
            import prursg.Version.*;
            
            corr_elem = CorrelationMatrixSourceFactory.getCorrelationElement(dom);
            
            num_attributes = corr_elem.getAttributes().getLength();
            
            if num_attributes == 1
                % Safe to get item 0 as we know there's one attribute
                source = char(corr_elem.getAttributes().item(0).getTextContent());
            elseif num_attributes == 0
                instance = VersionInfo.instance();
                schemaVersion = instance.RSGSchemaVersion;
                if schemaVersion ~= instance.v3_0_0_0                                  
                    source = prursg.CorrelationMatrix.CorrelationMatrixSourceFactory.ControlFile;
                else
                    CorrelationMatrixSourceFactory.logAndThrowMalforedInput(...
                    'Version 3.0.0.0 must have a correlation_matrix source attribute\n',...
                    [], 'Missing correlation_matrix source attribute');
                end
            else
                CorrelationMatrixSourceFactory.logAndThrowMalforedInput(...
                    'Found %d attributes in correlation_matrix\n',...
                    num_attributes,...
                    'Too many attributes');
            end
        end
    end
    
    methods(Access=private, Static)           
        % Retrieve the correlation matirx
        function corr_elem = getCorrelationElement(dom)                        
            elements = dom.getElementsByTagName('correlation_matrix');
            if elements.getLength() ~= 1  
                import prursg.CorrelationMatrix.*;
                CorrelationMatrixSourceFactory.logAndThrowMalforedInput(...
                        'Found %d correlation_matrix elements',...
                        elements.getLength(),...
                        'Expected only one correlation_matrix element in the control file');                    
            end
            corr_elem = elements.item(0);
        end 
        
        function logAndThrowMalforedInput(log, val, mess)
            fprintf(['Error parsing the control file. ' log], val);
            throw(MException('ControlFileFactory:create:MalformedInput',...
                mess));
        end
    end
end
