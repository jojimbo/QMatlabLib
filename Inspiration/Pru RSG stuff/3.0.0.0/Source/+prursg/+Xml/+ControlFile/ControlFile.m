% This class was previosuly called ObjectFile. It has been renamed and made
% a base class. The derived classes reflect differences in schema versions
classdef ControlFile < prursg.Xml.ControlFile.IRSGControlFile & handle
    properties (Abstract)
        % Determines the location of the correlation matrix. This is 
        % defined in the control file where the schema version is v3.0.0.0
        % The control file is the default for backward compatibility
        correlationMatrixSource
    end
    
    % ControlFile - properties: include all inputs in modelFile, data related
    % to risks should be in 1-D arrays/cells that has same dimenion as number
    % of risks
    properties
        modelFileDOM
        % general simulation params
        num_simulations   % number of monte carlo simulations
        scenario_set_type % ' some string description
        scenario_type_key % 1 = basic scenario
        rng_type   % random generator type
        run_date
        
        num_risks  % assert that it corresponds to the real number of risks
        basecurrency % base aggregation currency
        simtimestepinmonths = 12 % size of simulation timestep in months.
        riskDrivers
        is_in_memory = 0 % determines whether in in memory mode or not
        dependencyModel
        correlationMatrix
        riskIndexResolver  % to address the different orderings of the riskDrivers and correlationMatrix
        %
        base_set % base scenario set - generates one set of output files
        user_defined_sets % a list of eventual uds. each set generates separate output files
        %
        what_if_sets; % a list of eventual wiss each generating separate output files        
        what_if_sets_base_set_name; % optional name of a what_if_sets reference base scenario set
        %
        validation_rules 
        
        jobId
        scenarioSetId
        scenarioId
        
        flagRNG_TYPE % this property just stores if the rng_type property has been defined within <run_parameters>, and hence we are
        %expecting only one generator for all the risk drivers or not.
        
        % The following two properties satisfy the IRSGControlFeil 
        % interface. They have been added to support the introduction of 
        % schema versioning and configurable correlation matrix sources
    
        % The fully qualified path to the control file
        controlFilePath
        
        % The control file DOM oject
        controlFileDOM
    end
    
    methods
        
        % varargin defines if to use fast java based parsing
        function obj = ControlFile(dom, controlFilePath)
            obj.modelFileDOM = dom;
            obj.controlFileDOM = dom;
            obj.controlFilePath = controlFilePath;
        end
        
        % varargin defines if to use fast java based parsing
        function obj = processFile(obj)
            import prursg.Xml.*;

            root = obj.modelFileDOM.getFirstChild();
            runParams = XmlTool.getNode(root, 'run_parameters');

            obj.num_simulations = XmlTool.readDouble(runParams, 'num_simulations', 0);
            obj.scenario_set_type = XmlTool.readString(runParams, 'scenario_set_type', '');
            
            % Following the change to the Critical Scenario Engine, the
            % ModelFile needs to be able to handle string scenario type
            % keys. We will check for the key and assign accordingly.
            sstFromXml = XmlTool.readString(runParams, 'scenario_type_key', '');
            sst = strfind(sstFromXml, ':');
            
            % Convert the key if its not a CS else keep it as is.
            obj.scenario_type_key = obj.getScenKey(sstFromXml, sst);
            
            % Check if the scenario type key is a Critical Scenario one,
            % which means that it contains a colon. If it does, then grab
            % the 'base' scenario type key, else just convert to num.
            if (isempty(sst))
                baseKey = str2num(sstFromXml);
            else
                baseKey = str2num(sstFromXml(sst+1));
            end

            
            % If this is equal to '', it means we are going to have
            % different random number generators for each risk
            obj.rng_type = XmlTool.readString(runParams, 'rng_type', '');
            if strcmp(obj.rng_type,'')
                obj.flagRNG_TYPE = false;
            else
                obj.flagRNG_TYPE = true;
            end
            
            obj.run_date = XmlTool.readDate(runParams, 'run_date', '');
            
            
            obj.num_risks = XmlTool.readDouble(runParams, 'num_risks', 0);
            obj.basecurrency = XmlTool.readString(runParams, 'basecurrency', '');    
            obj.simtimestepinmonths = XmlTool.readDouble(runParams, 'simtimestepinmonths', obj.simtimestepinmonths);
            
            %CR161: In-Memory flag
            obj.is_in_memory = XmlTool.readDouble(runParams, 'is_in_memory', 0);
            
            switch baseKey
                % The previosu version of this object (ModelFile) did not
                % switch on the key but rather performed all the operations
                % below. This is inefficient and unnecessary. There is a
                % risk that there are dependencies on unknown side effects. 
                % This should become apparent in testing
                case {1,8}
                    % Simulation          
                    obj.riskDrivers = obj.readRiskDrivers(root, obj.flagRNG_TYPE, obj.rng_type);
                    
                    import prursg.Xml.*;
                    dependency_model_set_tag = XmlTool.getAndExpectOneElementItemByName(root,...
                                                            'dependency_model_set');    
                    obj.dependencyModel = readDependency(dependency_model_set_tag);

                    import prursg.CorrelationMatrix.*;
                    obj.correlationMatrix = CorrelationMatrixSourceFactory.create(obj);
                    result = obj.correlationMatrix.readCorrelationMatrix();

                    if ~result
                        % This could be because this XML control file has
                        % just been read back from the database but the
                        % corr matrix was external - not persisted in the db
                        fprintf('failed to read the correlation matrix\n');
                    else 
                        % No corr matrix => no correlated random numbers
                        % and therefore no simulation
                        obj.riskIndexResolver =...
                            RiskMapping.RiskMapperFactory.create(obj.correlationMatrix, obj.riskDrivers);
                        obj.riskDrivers = obj.riskIndexResolver.getOrderedRisks();
                        obj.base_set = obj.readBaseScenarioSet(root, obj.riskDrivers);
                    end
                case {2,3}
                    % What-if
                    obj.riskDrivers = obj.readRiskDrivers(root, obj.flagRNG_TYPE, obj.rng_type);
                    [obj.what_if_sets obj.what_if_sets_base_set_name] = ...
                        ScenarioSetDao.readWhatIfSets(XmlTool.getNode(root, 'what_if_sets'));
   
                case {4,7,5,6}
                    % UDS
                   obj.riskDrivers = obj.readRiskDrivers(root, obj.flagRNG_TYPE, obj.rng_type);
                   obj.user_defined_sets = ...
                       ScenarioSetDao.readUserDefinedSets(XmlTool.getNode(root, 'user_defined_sets'));                        
                otherwise
                    fprintf('Unknown scenario type %d\n', obj.scenario_type_key);
                    throw(MException('ControlFile:processFile:MalformedInput',...
                        'Unexpected scenario type key'));
            end           
            
            % Not clear which of the above scenarios requires the
            % validation rules
            obj.validation_rules = prursg.Xml.XmlTool.readString(root, 'validation_rules', 'ValidationRulesSet1');         
        end
        
        function scenKey = getScenKey(obj, sstFromXml, sst)
            
           if (isempty(sst))
                scenKey = str2num(sstFromXml);
           else
               	scenKey = sstFromXml;
           end
            
        end
        
        function str = toString(obj)
            str = prursg.Xml.XmlTool.toString(obj.modelFileDOM, true);
        end
        
        % merge back to xml dom any changes in risk drivers and dependency
        % structure
        function merge(obj)
            mergeRisks(obj.modelFileDOM.getFirstChild(), obj.riskDrivers);
            % for now there should be no changes to the
            % dependency_model_set so comment out lines below
			% correlationMatrixTag = prursg.Xml.XmlTool.getNode(obj.modelFileDOM.getFirstChild(), 'correlation_matrix');
            % mergeDependency(correlationMatrixTag, obj.riskDrivers, obj.correlationMatrix);
        end
                           
    end
    
    methods (Static) % methods useful in unit testing the db functionality
        
        function risks = readRiskDrivers(xml, flagRNG_TYPE, rng_type)
            import prursg.Xml.*;
            xmlRiskDriverSet = XmlTool.getAndExpectOneElementItemByName(xml, 'risk_driver_set');
            risks = parseRiskDrivers(xmlRiskDriverSet, flagRNG_TYPE, rng_type); 
        end
        
        function base_set = readBaseScenarioSet(xml, riskDrivers) 
            import prursg.Xml.*;
            baseSet = XmlTool.getAndExpectOneElementItemByName(xml, 'base_set');
            scenarioSet = XmlTool.getAndExpectOneElementItemByName(baseSet, 'scenario_set');
            
            base_set = prursg.Xml.ScenarioSetDao.read(scenarioSet);            
            if ~isempty(base_set)
                if ~isempty(base_set.scenarios)
                    % populate risks initial values with the last timestep values
                    expandedUniverse = base_set.scenarios(end).expandedUniverse;
                    for i = 1:length(riskDrivers)
                        risk = riskDrivers(i);
                        initvalue = expandedUniverse(risk.name);
                        risk.model.setInitialValue(initvalue);
                    end
                end
            end
        end
        
    end
end

%private function declarations

function risks = parseRiskDrivers(xml, flagRNG_TYPE, rng_type)            
    risks = [];
    node_name = 'risk';
    xmlNodes = xml.getElementsByTagName(node_name);
    if xmlNodes.getLength() == 0
        fprintf('Warning: No risks found\n');
        return;
    end
    
    import prursg.Engine.Risk.*;
    numRisks = xmlNodes.getLength();
    for i = 0:(numRisks - 1)
        risk = RiskFactory.create(xmlNodes.item(i), flagRNG_TYPE, rng_type);
        risks = [risks, risk]; %#ok<AGROW>
    end
end

%{
function risks = parseRiskDrivers(xmlRiskDriverSet, flagRNG_TYPE, rng_type)            
    risks = [];
    xmlRisk = xmlRiskDriverSet.getFirstChild();
    nRisks = xmlRiskDriverSet.getChildNodes().getLength();
    import prursg.Engine.Risk.*;
    for i = 0:nRisks - 1
        if strcmp(xmlRisk.getTagName(), 'risk')
            risk = RiskFactory.create(xmlRisk, flagRNG_TYPE, rng_type);
            risks = [risks, risk]; %#ok<AGROW>
        end
        xmlRisk = xmlRisk.getNextSibling();
    end
end
%}

%{
function risk = readRisk(riskTag, flagRNG_TYPE, rng_type)
    import prursg.Xml.*;

    risk = prursg.Engine.Risk([], []);
    RiskDao.fromXml(risk, riskTag, flagRNG_TYPE, rng_type);
    model = readModel(riskTag);
    risk.model = model;
end

function model = readModel(xmlRiskTag)
    import prursg.Xml.*;
    model = [];
    modelName = XmlTool.readString(xmlRiskTag, 'model_name', '');
    if ~isdeployed
        addpath(prursg.Util.ConfigurationUtil.GetModelsPackage());
    end
    import Model.*;
    if ~isempty(modelName)
        eval(['model = Model.' modelName '();']);
        model.fromXml(xmlRiskTag);
    end
end        
%}

function dependency = readDependency(xml)
    import prursg.Xml.*;
    type = readString(xml.getChildNodes().item(0), 'GaussianCopula'); 
    % using the default of GaussianCopula allows input files without the
    % relevent dependency_model_set set to work correctly.
          
    degrees_of_freedom = readDouble(xml.getChildNodes().item(1), 0);
        
    % Here we actually attempt to instantiate the dependency model
    % requested.
    import Model.*;
    dependency = eval(['Model.' type '();']);
end

function str = readString(node, defaultValue)
    if ~isempty(node) && ~isempty(node.getFirstChild())        
        str = char(node.getFirstChild().getData());
    else
        str = defaultValue;
    end
end

function dbl = readDouble(node, defaultValue)
    if ~isempty(node) && ~isempty(node.getFirstChild())        
        dbl = str2double(node.getFirstChild().getData());
    else
        dbl = defaultValue;
    end
end



% write back risks
function mergeRisks(xml, risks)
    import prursg.Xml.*;
    
    riskMap = makeRiskMap(risks);
    
    xmlRisks = XmlTool.getNode(xml, 'risk_driver_set');
    xmlRisks = xmlRisks.getElementsByTagName('risk');
    for i = 1:xmlRisks.getLength()
        xmlRiskTag = xmlRisks.item(i - 1);
        xmlNameTag = XmlTool.getNode(xmlRiskTag, 'name');
        xmlName = char(xmlNameTag.getFirstChild().getNodeValue());
        risk = riskMap(xmlName);
        risk.model.toXml(XmlTool.getNode(xmlRiskTag, 'model_params'));
    end    
end

function m = makeRiskMap(risks)
    m = containers.Map();
    for i = 1:length(risks)
        m(risks(i).name) = risks(i);
    end
end
%{

% a model file may or may not have a correlation matrix
function [corrs, resolver] = readCorrelationMatrix(xml)
    import prursg.Xml.*;
        
    corrs = []; resolver = [];
    if ~isempty(xml)
        rows = xml.getChildNodes();
        CORR_SIZE = rows.getLength();
        corrs = zeros(CORR_SIZE);
        riskNames = cell(1, CORR_SIZE);
        
        row = xml.getFirstChild();
        for i = 1:CORR_SIZE
            %disp(i);
            riskNames{i} = char(row.getAttribute('name'));
            %
            col = row.getFirstChild();
            for j = 1:CORR_SIZE
                if isempty(col.getFirstChild())
                    corrs(i,j) = 0;
                else
                    corrs(i, j) =str2double(col.getFirstChild().getData());
                end
                col = col.getNextSibling();
            end
            row = row.getNextSibling();
        end
        resolver = prursg.Engine.RiskIndexResolver(riskNames);
    end
end

% faster java based version
function [corrs, resolver] = javaReadCorrelationMatrix(xmlCorrs)
    corrs = []; resolver = [];
    if ~isempty(xmlCorrs)
        % javaaddpath([ pwd() '/+prursg/java/']);        
        corrs = xml.XmlParser.parseCorrelationMatrix(xmlCorrs);    
        %
        CORR_SIZE = xmlCorrs.getChildNodes().getLength();
        riskNames = cell(1, CORR_SIZE);
        row = xmlCorrs.getFirstChild();
        for i = 1:CORR_SIZE
            riskNames{i} = char(row.getAttribute('name'));
            row = row.getNextSibling();
        end
        resolver = prursg.Engine.RiskIndexResolver(riskNames);
    end
end

function mergeDependency(correlationMatrixTag, risks, corrs)
    
    while correlationMatrixTag.hasChildNodes()
        correlationMatrixTag.removeChild(correlationMatrixTag.getFirstChild());
    end
	%
	elements = makeCorrelationElementsNames(risks);
	assert(numel(elements) == size(corrs, 1));
    %
    dom = correlationMatrixTag.getOwnerDocument();
    for i = 1:length(elements)
        correlationMatrixTag.appendChild(makeCorrMatrixRow(dom, elements, i, corrs));
    end
end

function elements = makeCorrelationElementsNames(risks)
    elements = [];
	for i = 1:numel(risks)
		for j = 1:risks(i).model.getNumberOfStochasticInputs()
			elements = [ elements { [ risks(i).name '_factor' num2str(j) ] } ]; %#ok<AGROW>
		end
	end
end

function correlRow = makeCorrMatrixRow(dom, elements, i, corrs)
    correlRow = dom.createElement('correl_row');
    correlRow.setAttribute('name', elements{i});
    for j = 1:length(elements)
        correlElem = dom.createElement('correl_elem');
        correlElem.setAttribute('name', elements{j});
        textNode = dom.createTextNode(prursg.Xml.FormatModelValue(corrs(i, j)));
        correlElem.appendChild(textNode);
        correlRow.appendChild(correlElem);
    end
end
%}
