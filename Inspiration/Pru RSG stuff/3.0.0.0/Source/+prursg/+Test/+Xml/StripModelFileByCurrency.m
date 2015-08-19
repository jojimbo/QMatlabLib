function StripModelFileByCurrency()
    %TESTXMLMODELIMPORT leave just the information for one currency in the model xml file    
    clear;
    clc;
    tic;
    currency = 'GBP';
    testStrip(currency);
    toc;
end


function testStrip(currency)
    filePath =  '/media/shared/prudential/ye10/base/YE10 Base Final v3.xml'

    dom = xmlread(filePath);
    root = dom.getFirstChild();
    dependency_model_set_tag = root.getChildNodes().item(1);    
    corrs = dependency_model_set_tag.getChildNodes().item(2);
    stripCorrs(corrs, currency);
    corrs.getChildNodes().getLength()
    xmlRiskDriverSet = root.getChildNodes().item(2);
    xmlRiskDriverSet = stripRiskFactors(xmlRiskDriverSet, currency);
    xmlRiskDriverSet.getChildNodes().getLength()
    %
    
    baseSetTag = root.getChildNodes().item(3);
    stripScenarioSet(baseSetTag.getFirstChild(), currency);    

      
    str = prursg.Xml.XmlTool.toString(dom, true);
    fileName = '/tmp/duda.xml';
    fid = fopen(fileName, 'w');
    fwrite(fid, str);
    fclose(fid);
    
    modelFile = prursg.Xml.ModelFile(fileName, true)
    
end

function stripScenarioSet(scenarioSet, currency)
    scenario = scenarioSet.getFirstChild();
    while ~isempty(scenario)
        if strcmp(scenario.getTagName(), 'scenario')
            stripScenario(scenario, currency);
        end
        scenario = scenario.getNextSibling();
    end
end

function stripScenario(scenario, currency)
    risk = scenario.getFirstChild();
    while ~isempty(risk)
        riskName = char(risk.getAttribute('name'));
        if isequal(riskName(1:numel(currency)), currency)
            risk = risk.getNextSibling();            
        else
            toBeDeleted = risk;
            risk = risk.getNextSibling();
            scenario.removeChild(toBeDeleted);
        end        
    end
end


function risks = stripRiskFactors(risks, currency)
    risk = risks.getFirstChild();
    while ~isempty(risk)
        curr = prursg.Xml.XmlTool.readString(risk, 'currency', '');
        if ~isequal(curr, currency)
            toBeDeleted = risk;
            risk = risk.getNextSibling();
            risks.removeChild(toBeDeleted);
        else  
            risk = risk.getNextSibling();
        end
    end
end


function corrs = stripCorrs(corrs, currency)
    nRows = corrs.getChildNodes().getLength();
    goodNodes = zeros(1, nRows); % only rows have a name attribute
    row = corrs.getFirstChild();
    i = 1;
    while ~isempty(row)
        riskName = char(row.getAttribute('name'));
        goodNodes(i) = isequal(riskName(1:numel(currency)), currency);
        row = row.getNextSibling();
        i = i + 1;
    end
    %
    corrs = removeBadNodes(corrs, goodNodes, 1);
end

function corrs = removeBadNodes(corrs, goodNodes, depth)
    if depth > 2
        return;
    end
    i = 1;
    row = corrs.getFirstChild();
    while ~isempty(row)
        if goodNodes(i)
            removeBadNodes(row, goodNodes, depth + 1);
            row = row.getNextSibling();
        else
            toBeRemoved = row;
            row = row.getNextSibling();
            corrs.removeChild(toBeRemoved);
        end
        i = i + 1;
    end    
end


function sniff(setTag)
    if strcmp(setTag.getTagName(), 'scenario_set')
        scenarios = setTag.getChildNodes();
        while setTag.getChildNodes().getChildNodes().getLength() > 5
            %fprintf('opalanka %d\n', setTag.getChildNodes().getChildNodes().getLength());
            setTag.removeChild(setTag.getFirstChild());            
        end        
    end
end


