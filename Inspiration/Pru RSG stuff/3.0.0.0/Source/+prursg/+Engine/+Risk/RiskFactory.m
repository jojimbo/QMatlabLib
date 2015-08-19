% The risk factory provides a static create method to create an instance of 
% a risk object.
classdef RiskFactory               
    methods(Static)
        % Instantiate a risk mapping object
        % in:
        %   xmlRiskElement, A risk xml element
        % out:
        %   risk, A concrete instance of IRSGRisk
        function risk = create(xmlRiskElement, flagRNG_TYPE, rng_type)
            
            import prursg.Xml.ControlFile.*;
            import prursg.Version.*;
            import prursg.CorrelationMatrix.RiskMapping.*;
            
            instance = VersionInfo.instance();
            schemaVersion = instance.RSGSchemaVersion;
                    
            import prursg.Engine.Risk.*;
            model = RiskFactory.getRiskModel(xmlRiskElement);
            
            switch schemaVersion
                case instance.v2_3_0_0
                    risk = Riskv2_3_0_0(model);
                    % Now populate the risk's properties
                    RiskFactory.fromXml(risk, xmlRiskElement, flagRNG_TYPE, rng_type);
                case instance.v3_0_0_0
                    risk = Riskv3_0_0_0(model);
                    % Now populate the risk's properties
                    RiskFactory.setRiskProperties(xmlRiskElement, risk);
                    RiskFactory.fromXml(risk, xmlRiskElement, flagRNG_TYPE, rng_type);
                otherwise
                    fprintf(['Error parsing the control file when attempting'...
                        ' to read the schema version. '...
                        'Version %s found in PruRSG is not supported\n'], schemaVersion);
                    throw(MException('ControlFileFactory:create:MalformedInput',...
                        'Unsupported version'));
            end
        end
    end
    
    methods(Access=private, Static)  
       
        %%
        %% This code is _not_ nice but E187 does not give me enough time to fix the risk object construction.
        %% The code was taken from the original ModelFile class and massaged to get it work with XMl input with line breaks
        %%
        
        % Count the named element
        function count = getCountElementsByName(dom, elementName)
            elements = dom.getElementsByTagName(elementName);
            count = elements.getLength();
        end   
       
        function model = getRiskModel(xmlRiskElement)
            import prursg.Xml.*;
            import prursg.Engine.Risk.*;
            
            model = [];
            if RiskFactory.getCountElementsByName(xmlRiskElement, 'risk_calibration_set') == 0
                % The control file does not have a  risk_calibration_set element 
                % There are therfore no risk models. This is the case for a 
                % what-if for example i.e. where no simulation is to take place
                return;
            end

            modelName = XmlTool.readString(xmlRiskElement, 'model_name', '');
            
            if isempty(modelName)
                fprintf('Error instantiating a risk model for %s\n',...
                    char(xmlRiskElement.getTextContent()));
                throw(MException('ControlFileFactory:create:MalformedInput',...
                    'Cannot create risk model'));
            end
            
            if ~isdeployed
                addpath(prursg.Util.ConfigurationUtil.GetModelsPackage());
            end
            
            import Model.*;
            if ~isempty(modelName)
                % Ideally we'd have a risk model factory
                model = eval(['Model.' modelName '();']);
                model.fromXml(xmlRiskElement);
            end
            
            if isempty(model)
                fprintf('Error instantiating a risk model for %s', name);
                throw(MException('ControlFileFactory:create:MalformedInput',...
                    'Cannot create risk model'));
            end
        end
        
        function prop = setRiskProperties(xml, risk)
            prop = [];
            
            node_name = 'risk_properties';
            xmlNodes = xml.getElementsByTagName(node_name);
            if xmlNodes.getLength() ~= 1
               fprintf('Error: Expectings one "%s" element but found %d instances instead\n',...
                   node_name, xmlNodes.getLength());
               throw(MException('ControlFile:readRiskDrivers:MalformedInput',...
                   ['Could not find ' node_name]));
            end            
            
            % We know there's only one risk_properties element so item(0)
            % is safe
            properties = xmlNodes.item(0).getElementsByTagName('property');
            numProps = properties.getLength();
            
            % set to a null group by default - need to confirm if it can be
            % the case that a corr_group is ot specified
            risk.correlationGroup = 'Null';
            
            for i = 0 : (numProps - 1) 
                property = properties.item(i);
                attribute_name = 'name';
                attribute = property.getAttributes().getNamedItem(attribute_name);
                
                if isempty(attribute)
                   fprintf('Error: Could not find risk property attribute "name"\n');
                   throw(MException('ControlFile:readRiskDrivers:MalformedInput',...
                    'Could not find find risk property attribute "name"'));
                else
                    propName = char(attribute.getTextContent());                
                    propValue = char(property.getTextContent());
                end
            
                switch propName
                    case 'corr_group'
                        risk.correlationGroup = propValue;
                    case 'suppress_output'
                        risk.suppressOutput = logical(strcmpi('true', propValue));
                    otherwise
                        throw(MException('RiskFactory:create:MalformedInput',...
                            ['Property "' propName '" is not supported']));
                end
            end
        end
        
        function fromXml(risk, xml, flagRNG_TYPE, global_rng_type)
            import prursg.Engine.Risk.*;
            
            risk.name = prursg.Xml.XmlTool.readString(xml, 'name', risk.name);
            risk.currency = prursg.Xml.XmlTool.readString(xml, 'currency', risk.currency);
            risk.risk_family = prursg.Xml.XmlTool.readString(xml, 'risk_family', risk.risk_family);
            risk.pru_type = prursg.Xml.XmlTool.readString(xml, 'pru_type', risk.pru_type);
            risk.pru_group = prursg.Xml.XmlTool.readString(xml, 'pru_group', risk.pru_type);
            
            riskGroupNode = prursg.Xml.XmlTool.getNode(xml, 'risk_group');
            if ~isempty(riskGroupNode)
                % handle pre CR212 format.
                xmlTextNode = riskGroupNode.getFirstChild();
                riskGroup = [];
                if(~isempty(xmlTextNode))
                    riskGroup = char(xmlTextNode.getData());%convert the java.lang.String
                end
                risk.risk_groups = [prursg.Engine.RiskGroup('Risk Group', riskGroup)]; % create a default risk group.
            else
                % handle post CR212 format.
                riskgroups = prursg.Xml.XmlTool.getNode(xml, 'risk_groups');
                risk.risk_groups = RiskFactory.readRiskGroups(riskgroups);
            end
            
            risk.algo_type = prursg.Xml.XmlTool.readString(xml, 'algo_type', risk.algo_type);
            
            
            % NOW WE GET THE RANDOM NUMBER GENERATOR FOR THE RISK:
            %risk.random_seed = prursg.Xml.XmlTool.readDouble(xml, 'random_seed', risk.random_seed);
            if flagRNG_TYPE == true
                % Try to get <rng_type> and if it finds it, throw an
                % exception
                rng_type = prursg.Xml.XmlTool.readString(xml, 'rng_type','');
                if ~strcmp(rng_type,'')
                    error('RSGMain:RiskDaoError', '<rng_type> defined both in a <risk> element and in the top level within <run_parameters>')
                end
                rng_type = global_rng_type;
            else
                % Get <rng_type> without worries
                rng_type = prursg.Xml.XmlTool.readString(xml, 'rng_type','');
                if strcmp(rng_type,'')
                    error('RSGMain:RiskDaoError', '<rng_type> not defined for all the <risk> elements')
                end
            end
            
            % Now create the rng for the risk (default properties at this stage)
            try
                eval(['rng=prursg.RandomNumberGeneration.Generators.',rng_type,'();']);
            catch ME
                error('RSGMain:RiskDaoError', strcat('Non valid <rng_type> defined, no such class implemented: ', rng_type));
            end

            params = prursg.Xml.XmlTool.getNode(xml, 'rng_properties');
            %params = valReport.getElementsByTagName('Params').item(0);
            if ~isempty(params)
                numDynamicprops = params.getLength();
                for j=1:numDynamicprops
                    property = params.getElementsByTagName('property').item(j-1);
                    nameprop = prursg.Xml.XmlTool.getAttribute(property,'name');
                    typeprop = prursg.Xml.XmlTool.getAttribute(property,'type');
                    valueprop = char(property.getFirstChild().getData());
                    switch typeprop
                        case 'date'
                            valueprop = datenum(valueprop, 'dd/mm/yyyy');
                        case 'double'
                            valueprop = str2double(valueprop);
                        case 'number'
                            valueprop = str2double(valueprop);
                        otherwise
                    end
                    
                    if RiskFactory.exists_in_RNG(rng, nameprop)
                        eval(['rng.',nameprop,'=valueprop',';']);
                    end
                    
                end
            end
            
            risk.randomnumbergenerator = rng;           
        end        
        
        % Private functions declaration
        function exists = exists_in_RNG(rng, property)
            exists = false;
            meta = metaclass(rng);
            for i=1:length(meta.Properties)
                p = meta.Properties{i};
                if strcmp(p.Name, property)
                    exists = true;
                end
            end
        end        
        
        % function that reads the collection risk_groups for each risk driver
        function riskgroups = readRiskGroups(xmlnode_riskgroups)
            
            n_riskgroups = xmlnode_riskgroups.getChildNodes().getLength();
            xmlGroup = xmlnode_riskgroups.getFirstChild();
            riskgroups = [];
            for i=1:n_riskgroups
                if strcmp(xmlGroup.getTagName(), 'group')
                    riskgroup = prursg.Engine.RiskGroup('', '');
                    riskgroup.shredname = prursg.Xml.XmlTool.getAttribute(xmlGroup, 'shredname');
                    try
                        riskgroup.group = char(xmlGroup.getFirstChild().getNodeValue());
                    catch ME
                        error('The element <group> under <risk_groups> in the input XML file is not well defined. Most likely it is set up as an empty string, which is not supported');
                    end
                    if strcmp(riskgroup.group,'')
                        error('The element <group> under <risk_groups> in the input XML file cannot be an empty string, if should be set to "Null" if the risk does not belong to any particular group for that shred');
                    end
                    if strcmpi(riskgroup.group,'null') %we use strcmpi so the input XML file can have NULL, Null, null or any other combination
                        riskgroup.group = '';
                    end
                end
                riskgroups = [riskgroups riskgroup];
                xmlGroup = xmlGroup.getNextSibling();
            end
        end
    end
end