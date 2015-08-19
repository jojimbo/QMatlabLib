function xmlDom = makeAlgoBinaryHeader(scenarioType, baseCurrency, simulationStartDate,...
        trigerDays, scenarioSize, algoCurves, expandedUniverse, containsNoRiskScenario, stoScenarios, setName, scenarioPrefix, numberFormat )
%MAKEALGOBINARYHEADER Create the XML header file of Algo binary scenario
%file.
% The XML file consists of main/header part and risk factors descriptions
% lists
%
% @param setName corresponds to xml tag SETNAME
% @param baseCurrency should be the reference currency and corresponds to xml tag
% BASECURRENCY
% @param simulationStartDate? Most probably this is the Algo session date?
% @param trigerDays - should be a relative offset to a future date where the
%  monte carlo samples are in fact generated for. This is the Calculation
%  date.
% @param expandedUniverse is used to retrieve the axes information of each
% risk

% @param scenarioSize shold be 1 + number_of_monte_carlo_runs
% @param algoCurves the list of algo risk drivers(algo curves). 
% Each curve will populate a
% separate <RISKFACTOR> tag(using an xml template corresponding to its
% riskfamily property.
%
% Things to remember/consider:
%  1. The fx riskfactors are represented as 2 separate risk factors in the
%  algo binary and manifest files!!!
%  2. The dimensions of the credit spread curves are reversed.
%  3. The constant GBP_FX factor perhaps must be supported as a
%  SCENARIO_TYPE="constant factor"? or not?
        
    
    import prursg.Xml.*;
    
    % Following the change to the Critical Scenario Engine, the
    % scenario type key could be a string with format 9:x, where 9 is the
    % Critical Scenario and x is the scenario type that the CS was run
    % against. If that's the case, grab the 9 and set the scenarioType.
    if (isa(scenarioType, 'char'))
        scenarioType = str2num(scenarioType(1:strfind(scenarioType, ':')-1));
    end
    
    xmlDom = xmlread(fullfile(prursg.Util.ConfigurationUtil.GetRootFolderPath(), '+prursg', '+Algo', 'XmlTemplates', 'header.xml'));
    xml = xmlDom.getFirstChild();
    
    %header
    setText(xml, 'SETNAME', setName);
    setText(xml, 'BASECURRENCY', baseCurrency);
    setText(xml, 'SIMULATIONSTARTDATE', datestr(simulationStartDate, 'yyyy/mm/dd'));
    setText(xml, 'TRIGGERS', trigerDays);
    %addControlInfo
    algoCurves= addControlInfomation(algoCurves);
    
    %risks body
    tagRiskFactors = XmlTool.getNode(xml, 'RISKFACTORS');
    tagRiskFactors.setAttribute('ENTRIES', num2str(length(algoCurves)));    
    while tagRiskFactors.hasChildNodes() 
        tagRiskFactors.removeChild(tagRiskFactors.getFirstChild());
    end
    for i = 1:length(algoCurves)
        tags = processAlgoCurve(algoCurves(i), expandedUniverse, numberFormat); 
        for j = 1:length(tags) % fx risks generate more than one xml tag
           tagRiskFactors.appendChild(xmlDom.importNode(tags(j), true));             
        end
    end
    
    % footer
    if (int32(prursg.Engine.ScenarioType.BigBang) == scenarioType...
            || int32(prursg.Engine.ScenarioType.CriticalScenario) == scenarioType)
        
        shredGroups = containers.Map('keyType', 'char', 'valueType', 'char');
        
        for i = 1:numel(algoCurves)
            algoCurve = algoCurves(i);        
            for j=1:length(algoCurve.risk_groups)
                %disp(algoCurve.risk_groups(j).shredname);
                if (strcmp(algoCurve.risk_groups(j).shredname, 'XAllRisks'))
                    if ~shredGroups.isKey(algoCurve.risk_groups(j).group)
                        shredGroups(algoCurve.risk_groups(j).group) = 'XAllRisks';
                    end
                end
            end
        end
        
        setText(xml, 'SCENARIOSIZE', scenarioSize + (shredGroups.length * (scenarioSize - containsNoRiskScenario - 1))); 
        setText(xml, 'SCENARIONAMES', makeExtendedScenarioNames(setName, scenarioType, scenarioSize, containsNoRiskScenario, stoScenarios, scenarioPrefix, shredGroups));
        setText(xml, 'SCENARIOWEIGHTS', makeScenarioWeights(scenarioSize + (shredGroups.length * (scenarioSize - containsNoRiskScenario - 1)), containsNoRiskScenario));
    else
        setText(xml, 'SCENARIOSIZE', scenarioSize);    
        setText(xml, 'SCENARIONAMES', makeScenarioNames(setName, scenarioType, scenarioSize, containsNoRiskScenario, stoScenarios, scenarioPrefix));
        setText(xml, 'SCENARIOWEIGHTS', makeScenarioWeights(scenarioSize, containsNoRiskScenario));
    end
    setText(xml, 'SHIFTTYPES', makeShiftTypes(length(algoCurves)));
    setText(xml, 'BINARYFILES', [setName, '.bin']);    
end

function algoCurves = addControlInfomation(algoCurves)
    tmp=algoCurves(1);
    if ~exist('./tmp', 'dir')
        mkdir('./tmp');
    end
    save('./tmp/crv.mat', 'tmp', prursg.Util.FileUtil.GetMatFileFormat());
    crv1=load('./tmp/crv');
    crv2=load('./tmp/crv');
    stocasticIndicatorCurve=crv1.tmp;
    scenarioIndex=crv2.tmp;
    stocasticIndicatorCurve.name='stochastic_indicator';
    stocasticIndicatorCurve.type='CONTROL_INFO';
    scenarioIndex.name='scenario_index';
    scenarioIndex.type='CONTROL_INFO';
    algoCurves=[stocasticIndicatorCurve scenarioIndex algoCurves];
    delete('./tmp/crv.mat');
end

function xxx = makeExtendedScenarioNames(setName, scenarioType, scenarioSize, containsNoRiskScenario, stoScenarios, scenarioPrefix, shredGroups)
    %memory must be reserved in advanced(large buffer, otherwise takes too much time
    xxx = repmat('x', 1, length(setName) + 10); 
    xxx = repmat(xxx, 1, scenarioSize + (shredGroups.length * (scenarioSize - containsNoRiskScenario - 1))); % over excesive but will be trimmed later
    scenarioName = [scenarioPrefix 'base,'];
    pos = 1;
    xxx(pos : pos + length(scenarioName) - 1) = scenarioName;
    pos = pos + length(scenarioName);
    
    startIndex = 1;
    if containsNoRiskScenario
        scenarioName = [scenarioPrefix 'noriskscr,'];
        xxx(pos : pos + length(scenarioName) - 1) = scenarioName;
        pos = pos + length(scenarioName);
        startIndex = 2;
    end
        
    for i = 1:scenarioSize - startIndex
        scenarioName = [prursg.Algo.AlgoUtil.ConvertScenarioName(scenarioType, stoScenarios, i, scenarioPrefix) ','];        
        xxx(pos : pos + length(scenarioName) - 1) = scenarioName;
        pos = pos + length(scenarioName);        
    end
    
    shredKeys = keys(shredGroups);
    for j = 1:numel(shredKeys)           
        for i = 1:scenarioSize - startIndex
            scenarioName = [prursg.Algo.AlgoUtil.ConvertScenarioName(scenarioType, stoScenarios, i, scenarioPrefix)]; 
            scName = strcat(scenarioName,'_',shredKeys{j},',');
            xxx(pos : pos + length(scName) - 1) = scName;
            pos = pos + length(scName); 
        end
               
    end
    xxx = xxx(1:pos - 2); % trim the last comma;            
end

function xxx = makeScenarioNames(setName, scenarioType, scenarioSize, containsNoRiskScenario, stoScenarios, scenarioPrefix)
    %memory must be reserved in advanced(large buffer, otherwise takes too much time
    xxx = repmat('x', 1, length(setName) + 10); 
    xxx = repmat(xxx, 1, scenarioSize); % over excesive but will be trimmed later
    scenarioName = [scenarioPrefix 'base,'];
    pos = 1;
    xxx(pos : pos + length(scenarioName) - 1) = scenarioName;
    pos = pos + length(scenarioName);
    
    startIndex = 1;
    if containsNoRiskScenario
        scenarioName = [scenarioPrefix 'noriskscr,'];
        xxx(pos : pos + length(scenarioName) - 1) = scenarioName;
        pos = pos + length(scenarioName);
        startIndex = 2;
    end
        
    for i = 1:scenarioSize - startIndex
        scenarioName = [prursg.Algo.AlgoUtil.ConvertScenarioName(scenarioType, stoScenarios, i, scenarioPrefix) ','];        
        xxx(pos : pos + length(scenarioName) - 1) = scenarioName;
        pos = pos + length(scenarioName);        
    end
    xxx = xxx(1:pos - 2); % trim the last comma;            
end

function str = makeScenarioWeights(scenarioSize, containsNoRiskScenario)
    str = replicate('1', scenarioSize);
    str(1) = '0';
    
    if containsNoRiskScenario
        str(3) = '0';
    end
end

function str = makeShiftTypes(algoSize)
    str = replicate('absolute', algoSize);
end

function outstr = replicate(instr, times)
    outstr = repmat([instr, ','], 1, times);
    outstr = outstr(:, 1 : end - 1); % trim last comma away    
end


function tag = processAlgoCurve(algoCurve, expandedUniverse, numberFormat)
    %'INDEX' 'FX_RISK_FACTOR', 'FX_RATE', 'ZERO_CURVE', 'VOL', 'SVOL', 'CREDIT_SPREAD'
    switch (algoCurve.type)
        case { 'ZERO_CURVE' }
            tag = processZeroCurve(algoCurve, expandedUniverse(algoCurve.name), numberFormat);
        case 'FX_RISK_FACTOR'
            tag = processFxRiskFactor(algoCurve);
        case 'FX_RATE'
            tag = processFxRate(algoCurve);
        case 'SVOL'
            %error('Svol not ready');
            tag = processSvol(algoCurve, expandedUniverse(algoCurve.name), numberFormat);
        case 'VOL'
            tag = processVol(algoCurve, expandedUniverse(algoCurve.name), numberFormat);
        case 'CREDIT_SPREAD'
            tag = processCreditSpread2d(algoCurve, expandedUniverse, numberFormat);            
        case 'INDEX'
            tag = processIndex(algoCurve);
        case 'CONTROL_INFO'
            tag = processControlInfo(algoCurve);
            
        otherwise
            error('should not be here: %s', risk.name);
            
    end    
end

function setName(tag, name)
    tag.setAttribute('NAME', name);
    %shredding bits
    setProperty(tag, 'Name', name);    
end

function setProperty(tag, name, value)
    props = prursg.Xml.XmlTool.getNode(tag, 'PROPERTIES');
    props = props.getElementsByTagName('PROPERTY');
    for i = 1:props.getLength()
        p = props.item(i - 1);
        if strcmp(p.getAttribute('NAME'), name)
            p.setAttribute('VALUE', value);
            break;
        end
    end    
end

function tag = processIndex(algoCurve)
    xmlDom = xmlread(fullfile(prursg.Util.ConfigurationUtil.GetRootFolderPath(), '+prursg', '+Algo', 'XmlTemplates', 'index.xml'));
    tag = xmlDom.getFirstChild();
    setName(tag, algoCurve.makeStoCurve());
end

function tag = processVol(algoCurve, dataSeries, numberFormat)
    tag = makeVola2D(algoCurve.makeStoCurve(), dataSeries.axes, 'vol.xml', [ 1 365 ], numberFormat);  % first axis = moneyness, second term, which must be converted to days
end

function tag = processSvol(algoCurve, dataSeries, numberFormat)
    name = algoCurve.makeStoCurve();
    moneyness = dataSeries.axes(1);
    tag = [];
    for i = 1:numel(moneyness.values)
        curveName = [ name '_' num2str(moneyness.values(i), numberFormat) ];
        vola2d = makeVola2D(curveName, dataSeries.axes(2:3), 'svol.xml', [ 365 365 ], numberFormat); % convert years to days
        tag = [ tag vola2d ]; %#ok<AGROW>
    end    
end

function tag = processCreditSpread2d(algoCurve, expandedUniverse, numberFormat)    
    xmlDom = xmlread(fullfile(prursg.Util.ConfigurationUtil.GetRootFolderPath(), '+prursg', '+Algo', 'XmlTemplates', 'credit_spread.xml'));
    tag = xmlDom.getFirstChild();
    setName(tag, algoCurve.makeStoCurve());
    %
    setProperty(tag, 'CreditStateOrder', algoCurve.getRatingsList(';'));
    %
    axisList = prursg.Xml.XmlTool.getNode(tag, 'AXISLIST');
    axisTags = axisList.getElementsByTagName('AXIS');    
    % terms
    dseries = expandedUniverse(algoCurve.name);
    setAxisInfo(axisTags.item(0), floor(dseries.axes(1).values .* 365), numberFormat);
    % credit ratings
    setAxisValues(axisTags.item(1), ...
                  numel(algoCurve.creditRatingAxisValues), ...
                  algoCurve.getRatingsList(','));        
end

function tag = makeVola2D(curveName, axes, templateName, axisValuesMultiplier, numberFormat)
    xmlDom = xmlread(fullfile(prursg.Util.ConfigurationUtil.GetRootFolderPath(), '+prursg', '+Algo', 'XmlTemplates', templateName));
    tag = xmlDom.getFirstChild();
    setName(tag, curveName);
    %
    axisList = prursg.Xml.XmlTool.getNode(tag, 'AXISLIST');
    axisTags = axisList.getElementsByTagName('AXIS');
    
    assert(numel(axes) == axisTags.getLength());
    for i = 1:numel(axes)
        if axisValuesMultiplier(i) == 365 % handle term and tenor.
            setAxisInfo(axisTags.item(i - 1), floor(axes(i).values .* axisValuesMultiplier(i)), numberFormat);
        else
            setAxisInfo(axisTags.item(i - 1), axes(i).values .* axisValuesMultiplier(i), numberFormat);
        end
    end
end


function setAxisInfo(axisTag, values, numberFormat)
    terms = ''; 
    for i=1:numel(values)
        terms = [terms ',' num2str(values(i), numberFormat)]; %#ok<AGROW>
    end
    terms = terms(2:end); % get rid of starting comma
    %
    setAxisValues(axisTag, i, terms);
end

function setAxisValues(axisTag, nEntries, values)
    axisValues = prursg.Xml.XmlTool.getNode(axisTag,'AXISVALUES');
    axisValues.setAttribute('ENTRIES', num2str(nEntries));    
    setText(axisTag, 'AXISVALUES', values);

end

function tag = processZeroCurve(algoCurve, dataSeries, numberFormat)
    xmlDom = xmlread(fullfile(prursg.Util.ConfigurationUtil.GetRootFolderPath(), '+prursg', '+Algo', 'XmlTemplates', 'yieldcurve.xml'));
    tag = xmlDom.getFirstChild();
    setName(tag, algoCurve.makeStoCurve());
    % replace the term entries
    setAxisInfo(prursg.Xml.XmlTool.getNode(tag, 'AXIS') ...
              , floor(dataSeries.axes(1).values .* 365), numberFormat);    
end

function tag = processFxRiskFactor(risk)
    xmlDom = xmlread(fullfile(prursg.Util.ConfigurationUtil.GetRootFolderPath(), '+prursg', '+Algo', 'XmlTemplates', 'fx1.xml'));
    tag = xmlDom.getFirstChild();
    setName(tag, risk.makeStoCurve());
end

function tag = processControlInfo(risk)
    xmlDom = xmlread(fullfile(prursg.Util.ConfigurationUtil.GetRootFolderPath(), '+prursg', '+Algo', 'XmlTemplates', 'controlinformation.xml'));
    tag = xmlDom.getFirstChild();
    setName(tag, risk.name);
end


function tag = processFxRate(algoCurve)
    xmlDom = xmlread(fullfile(prursg.Util.ConfigurationUtil.GetRootFolderPath(), '+prursg', '+Algo', 'XmlTemplates', 'fx2.xml'));
    tag = xmlDom.getFirstChild();
    setName(tag, algoCurve.name);
end


function setText(xml, tagName, value)
    prursg.Xml.XmlTool.setNodeTextValue(xml, tagName, value);
end
