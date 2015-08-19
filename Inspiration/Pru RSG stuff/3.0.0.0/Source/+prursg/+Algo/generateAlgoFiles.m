function generateAlgoFiles(srisks, scenarioSet, basecurrency, sess_date, run_date, chunks, scenarioType, algoFilesPath)
    t = tic;
    
    % retrieve scenario value format.
    SCENARIO_VALUE_FORMAT = prursg.Util.ConfigurationUtil.GetScenarioValueNumberFormat();    
    
    % Following the change to the Critical Scenario Engine, the
    % scenario type key could be a string with format 9:x, where 9 is the
    % Critical Scenario and x is the scenario type that the CS was run
    % against. If that's the case, grab the 9 and set the scenarioType.
    if (isa(scenarioType, 'char'))
        scenarioType = str2num(scenarioType(1:strfind(scenarioType, ':')-1));
    end
            
    % retrieve deterministic scenarios including norisk scenario.
    detScenarios = scenarioSet.getDeterministicScenarios();
    
    %QC2492. the RSG need to treat the WhatIf Projection shocked base as the last
    %deterministic step.
    if (scenarioType == int32(prursg.Engine.ScenarioType.WhatIfProjection))
        shockedBaseScenario = scenarioSet.getShockedBaseScenario();
        if ~isempty(shockedBaseScenario)
            shockedBaseScenario.isShockedBase = 0;            
            detScenarios = [detScenarios shockedBaseScenario]; 
        end
    end
    
    %shredding
    %disp('shredding');
    risks = srisks;
    
    algoCurves = prursg.Algo.AlgoCurve.makeAlgoCurveList(risks, basecurrency, detScenarios(end).expandedUniverse);
         
 
        
    % curve room file    
    %disp('curve room');
    stoScenario = scenarioSet.noRiskScenario;
    if isempty(stoScenario)
        stoScenario = scenarioSet.getBaseScenario();
    end
    roomFileContents = prursg.Algo.makeCurveRoomFile(basecurrency, sess_date, run_date, algoCurves, detScenarios, stoScenario, false, SCENARIO_VALUE_FORMAT);
    saveFile(fullfile(algoFilesPath, 'risk_drivers.csv'), roomFileContents);
    
    
    % the 2 csv deterministic files
    %disp('deterministic')    
    baseDeterministicFileContents = prursg.Algo.makeBaseDeterministicScenarioFile( ...
        basecurrency, sess_date, algoCurves, detScenarios,'LM_Base_ScenSet', SCENARIO_VALUE_FORMAT ...
    );   
    saveFile(fullfile(algoFilesPath, 'LM_Base_ScenSet.csv'), baseDeterministicFileContents);
    
    baseDeterministicFileContents = prursg.Algo.makeBaseDeterministicScenarioFile( ...
        basecurrency, sess_date, algoCurves, detScenarios, 'Asset_Calib_ScenSet', SCENARIO_VALUE_FORMAT ...
    );       
    saveFile(fullfile(algoFilesPath, 'Asset_Calib_ScenSet.csv'), baseDeterministicFileContents);    
    
    baseScenario = scenarioSet.getBaseScenario();
    expandedUniverse = baseScenario.expandedUniverse;
    
    %QC2492. 
    if (scenarioType == int32(prursg.Engine.ScenarioType.WhatIfBase))    
        shockScenario = scenarioSet.getShockedBaseScenario();
        if ~isempty(shockScenario)
            baseScenario = shockScenario;
            expandedUniverse = shockScenario.expandedUniverse;
        end
    elseif(scenarioType == int32(prursg.Engine.ScenarioType.WhatIfProjection))
        baseScenario = detScenarios(end);
        expandedUniverse = detScenarios(end).expandedUniverse;
    end
    
    noRiskScenario = scenarioSet.noRiskScenario;
    containsNoRiskScenario = ~isempty(noRiskScenario);
    stoScenarios = scenarioSet.getStochasticScenarios();
    
    % Perform a check to see if the underlying data is Big Bang. We do that
    % by checking if the name of the first stochastic scenario contains the
    % string '++BB'. If it does we set the underlyingScenarioType to 4 (Big
    % Bang). The underlyingScenarioType is used when creating the Algo
    % binary header and the Algo binary file.
    underlyingScenarioType=scenarioType;
    if(strfind(stoScenarios(1).name ,'++BB' ))
        underlyingScenarioType=int32(prursg.Engine.ScenarioType.BigBang);
    end

    generateShreddingFiles(algoFilesPath, algoCurves, underlyingScenarioType);   
    
    [setName scenarioPrefix] = prursg.Algo.AlgoUtil.GetScenarioSetNameInfo(underlyingScenarioType);    
    manifestFileName = [setName '.ce'];
    binFileName = [setName '.bin'];
    
    %xml header
    %disp('xml header');        
    num_simulations = size(chunks, 1) + containsNoRiskScenario + 1;    
    triggerDays = prursg.Util.DateUtil.DaysActual(sess_date, prursg.Util.DateUtil.ReplaceLeapDate(baseScenario.date));
    xmlDoc = prursg.Algo.makeAlgoBinaryHeader(... 
        underlyingScenarioType, basecurrency, sess_date, ...
        triggerDays, num_simulations , algoCurves, ...
        expandedUniverse, containsNoRiskScenario, stoScenarios, setName, scenarioPrefix, SCENARIO_VALUE_FORMAT ... 
    );

    manifest = prursg.Xml.XmlTool.toString(xmlDoc, true);
    manifest = sprintf('<?xml version="1.0" encoding="UTF-8" ?>\n%s', manifest);
    saveFile(fullfile(algoFilesPath, manifestFileName), manifest);    
    
    % binary
    %disp('binary');    
    fileName = fullfile(algoFilesPath, binFileName);    
    prursg.Algo.AlgoBinary.makeBinary(scenarioType, fileName, risks, algoCurves, scenarioSet, chunks, underlyingScenarioType);    
end


function saveFile(fileName, contents)
    fid = fopen(fileName, 'w');
    fwrite(fid, contents);
    fclose(fid);    
end


function generateShreddingFiles(algoFilesPath, risks, scenarioType)
    %groupsMap = containers.Map();
    %for i = 1:numel(risks)
    %    algoCurve = risks(i);
    %    if ~isempty(algoCurve.risk_group) && ~strcmpi(strtrim(algoCurve.risk_group), '')
    %        if strcmp(algoCurve.type, 'FX_RATE')
    %            continue; % this is not a proper risk factor
    %        end
    %        if groupsMap.isKey(algoCurve.risk_group)
    %            v = groupsMap(algoCurve.risk_group);
    %        else
    %            v = [];
    %        end
    %        v = [v { algoCurve.makeStoCurve() } ]; %#ok<AGROW>
    %        groupsMap(algoCurve.risk_group) = v;
    %    end
    %end
    %
    %dom = xmlread(fullfile(prursg.Util.ConfigurationUtil.GetRootFolderPath(), '+prursg', '+Algo', 'XmlTemplates', 'risk_shredding.xml'));
    %root = dom.getFirstChild();
    %groups = groupsMap.keys();
    %for i = 1:numel(groups)
    %    root.appendChild(enumerateRisks(dom, groups{i}, groupsMap(groups{i})));
    %end    
    %out = prursg.Xml.XmlTool.toString(dom, true);
    
    
    shredsMap = containers.Map('keyType', 'char', 'valueType', 'any');
        
    for i = 1:numel(risks)
        algoCurve = risks(i);        
        for j=1:length(algoCurve.risk_groups)
            
            if ~shredsMap.isKey(algoCurve.risk_groups(j).shredname)
                shredsMap(algoCurve.risk_groups(j).shredname) = containers.Map();
            end
            
            groupsMap = shredsMap(algoCurve.risk_groups(j).shredname);
            
            if ~isempty(algoCurve.risk_groups(j).group) && ~strcmpi(strtrim(algoCurve.risk_groups(j).group), '')
                if groupsMap.isKey(algoCurve.risk_groups(j).group)
                    v = groupsMap(algoCurve.risk_groups(j).group);
                else
                    v = [];
                end
                if strcmp(algoCurve.type, 'FX_RATE')
                    v = [v { algoCurve.name } ]; %#ok<AGROW>    
                else
                    v = [v { algoCurve.makeStoCurve() } ]; %#ok<AGROW>
                end
                groupsMap(algoCurve.risk_groups(j).group) = v;
            end
        end
    end
    
    %
    shredKeys = keys(shredsMap);
    if numel(shredKeys) == 0
       disp('No shred names exist.');
    else
        if numel(shredKeys) == 1 && strcmpi(shredKeys(1), 'Risk Group')                                
            fileNameFormat = 'risk_factor_shredding.xml';
            
            fileName = sprintf(fileNameFormat, shredKeys{1});
            groupsMap = shredsMap(shredKeys{1});
            generateShreddingFile(algoFilesPath, fileName, groupsMap);
            
        else
            fileNameFormat = 'risk_factor_shredding_%s.xml';
            
            if ~(int32(prursg.Engine.ScenarioType.BigBang) == scenarioType...
            || int32(prursg.Engine.ScenarioType.CriticalScenario) == scenarioType)
                for i = 1:numel(shredKeys)
                    fileName = sprintf(fileNameFormat, shredKeys{i});
                    groupsMap = shredsMap(shredKeys{i});
                    generateShreddingFile(algoFilesPath, fileName, groupsMap);
                end
            end
        end
    end    
end

function generateShreddingFile(algoFilesPath, fileName, groupsMap)
    dom = xmlread(fullfile(prursg.Util.ConfigurationUtil.GetRootFolderPath(), '+prursg', '+Algo', 'XmlTemplates', 'risk_shredding.xml'));
    root = dom.getFirstChild();
    groups = groupsMap.keys();
    for i = 1:numel(groups)
        root.appendChild(enumerateRisks(dom, groups{i}, groupsMap(groups{i})));
    end    
    shreddingFileContents  = prursg.Xml.XmlTool.toString(dom, true);    
    saveFile(fullfile(algoFilesPath, fileName), shreddingFileContents);
end

function xmlGroup = enumerateRisks(dom, group, risks)
    xmlGroup = dom.createElement('RiskFactorGroup');    
    xmlGroup.setAttribute('filenamesuffix', group);
    
    % append control information.   
    xmlGroup.appendChild(createRiskFactorElement(dom, 'scenario_index'));        
    xmlGroup.appendChild(createRiskFactorElement(dom, 'stochastic_indicator'));
        
    % append each risk driver.
    for i = 1:numel(risks)
        xmlGroup.appendChild(createRiskFactorElement(dom, risks{i}));        
    end
end

function xmlRisk = createRiskFactorElement(dom, value)
    xmlRisk = dom.createElement('RiskFactor');
    xmlRisk.setAttribute('attr', 'Name');
    xmlRisk.setAttribute('value', value);    
end

%===== binary file sniffing

function snifBinary(fileName, rows)

    fid = fopen(fileName, 'r');
    mydata = fread(fid, 'double');
    fclose(fid);
    %length(mydata)/736   % should give exactly 11
   
    rowSize = length(mydata)/rows;
    m = zeros(rows, rowSize);
    for row = 1:rows
        mrow = mydata((row - 1) * rowSize + 1 : row * rowSize);
        m(row, :) = mrow;
    end
    m; %put a fat breakpoint here to observe
    clear import;
    clear;
end
