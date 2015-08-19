% The control file factory provides a static create method to create an 
% instance of a control file according to the version of the the control file.
classdef ControlFileFactory
    methods(Static)
        % Instantiate a control file object
        % in:
        %   controlFilePath, A fully qualified path to a control file
        % out:
        %   contorlFile, A concrete instance of IRSGControlFile
        function controlFile = create(controlFilePath)
            if ~exist(controlFilePath, 'file')
                fprintf('The control file %s does not exist', controlFilePath);
                throw(MException('ControlFileFactory:create:FileNotFound',...
                    'The control file does not exist'));
            end
            
            %%
            %% WARNING configureJava calls clear all and therefore wipes out 
            %% the entire environment. Clearly this legacy code is very bad. 
            %% An alternative approach should be sought
            %%
            useJavaXmlParsing = true;
            prursg.Xml.configureJava(useJavaXmlParsing);
            
            dom = xmlread(controlFilePath);
            import prursg.Xml.ControlFile.*;
            controlFile = ControlFileFactory.createFromDOM(dom, controlFilePath);
        end
        
        % Read the RSG application configuration file and return true if
        % the ValidateSchema flag is set to true
        % out:
        %   value, True if the schema should be validated, False (the
        %   default if no flag present) is not validate should be performed
        function value = shouldValidateSchema()
            value = prursg.Util.ConfigurationUtil.ValidateControlFileSchema();
        end
    end
    
    methods(Static, Access=private)
        
        function controlFile = createFromDOM(dom, controlFilePath)
            import prursg.Xml.ControlFile.*;
            import prursg.Version.*;
            schemaVersion = ControlFileFactory.getSchemaVersion(dom);
            
            % Set the schema version on the system wide singleton
            instance = VersionInfo.instance();
            instance.RSGSchemaVersion = schemaVersion;

            switch schemaVersion
                case instance.v2_3_0_0
                    ControlFileFactory.validateSchema(controlFilePath, 'RSGSchema_2.3.0.0.xsd');
                    controlFile = ControlFilev2_3_0_0(dom, controlFilePath);
                case instance.v3_0_0_0
                    ControlFileFactory.validateSchema(controlFilePath, 'RSGSchema_3.0.0.0.xsd');
                    controlFile = ControlFilev3_0_0_0(dom, controlFilePath);
                otherwise
                    ControlFileFactory.logAndThrowMalforedInput(...
                        'Version %s found in PruRSG is not supported\n',...
                        schemaVersion,...
                        'Unsupported version');
            end            
        end
        
        function schemaVersion = getSchemaVersion(dom)
            import prursg.Xml.ControlFile.*;
            import prursg.Version.*;
            
            root_elem = ControlFileFactory.getElementbyName(dom, 'PruRSG');
            attributes = root_elem.getAttributes();
            num_attributes = attributes.getLength();
           
            name = 'xsi:noNamespaceSchemaLocation';
            attribute = root_elem.getAttributes().getNamedItem(name);

            if isempty(attribute) && num_attributes > 0
                ControlFileFactory.logAndThrowMalforedInput(...
                    'Found %d attributes in PruRSG but not the schema version\n',...
                    num_attributes,...
                    'Schema version not found');
            end
                
            if isempty(attribute)
                % default to v2.3.0.0 if no schema defined
                instance = VersionInfo.instance();
                schemaVersion = instance.v2_3_0_0;
            else
                raw = char(attribute.getTextContent());                
                schemaVersion = ControlFileFactory.getVersion(raw);
            end
        end
        
        % Extract the version from the schema location string
        % in:
        %   value, The value of the PruRSG schema location attribute
        % out:
        %   version, A version string as defined by prursg.Version.VersionInfo 
        %   or an exception on parse error  
        function version = getVersion(value)
            import prursg.Xml.ControlFile.*;
            import prursg.Version.*;
            
            instance = VersionInfo.instance();  
            
            if length(value) ~= 21
                ControlFileFactory.logAndThrowMalforedInput(...
                        'Version %s found in PruRSG is malformed\n',...
                        value,...
                        'Malformed version string');
            end
                                    
            % extract the version number from RSGSchema3.0.0.0.xsd
            ver = value(11:17);
            
            switch ver
                case instance.v3_0_0_0
                    version = instance.v3_0_0_0;
                case instance.v2_3_0_0
                    version = instance.v2_3_0_0;
                otherwise
                    ControlFileFactory.logAndThrowMalforedInput(...
                        'Version %s found in PruRSG is not supported\n',...
                        ver,...
                        'Unsupported version');
            end
        end
        
        function element = getElementbyName(dom, name)                        
            elements = dom.getElementsByTagName(name);
            if elements.getLength() ~= 1
               import prursg.Xml.ControlFile.*;
               ControlFileFactory.logAndThrowMalforedInput(...
                        'Found more than one %s element\n',...
                        name,...
                        'Malformed XML control file');
            end
            element = elements.item(0);
        end   
        
        function logAndThrowMalforedInput(log, val, mess)
            fprintf(['Error parsing the control file when attempting'...
                    ' to read the schema version.\n' log], val);
            throw(MException('ControlFileFactory:create:MalformedInput',...
                mess));
        end       
        

        % Validate the control file schema if the shouldValidateSchema
        % method returns true
        function validateSchema(controlFile, schemaFile)
            import prursg.Xml.ControlFile.*;
            if ControlFileFactory.shouldValidateSchema()
                root = prursg.Util.ConfigurationUtil.GetRootFolderPath();
                schemaLocation = fullfile(root, 'Schemas', schemaFile);
                ControlFileFactory.schemaValidation(controlFile, schemaLocation)
            else
                fprintf('Schema validation is disabled.\n');
            end
        end
        
        function schemaValidation(xmlFile, schemaLocation)            
            import java.io.*;
            import javax.xml.transform.Source;
            import javax.xml.transform.stream.StreamSource;
            import javax.xml.validation.*;
            
            fprintf('Validating control file (%s)\n against schema (%s)\n',...
                xmlFile, schemaLocation);
            
            try
                factory = SchemaFactory.newInstance('http://www.w3.org/2001/XMLSchema'); 
                schema = factory.newSchema(File(schemaLocation));
                validator = schema.newValidator();
                source = StreamSource(xmlFile);
                validator.validate(source);
            catch e
                import prursg.Xml.ControlFile.*;
                ControlFileFactory.logAndThrowMalforedInput(...
                        'Schema validation failed using (%s)\n',...
                        schemaLocation,...
                        ['Malformed XML control file:\n' e.message]);
            end
        end
    end
end
