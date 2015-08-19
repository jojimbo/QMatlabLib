function TestUserDefinedScenarioSetsImport()
    %TESTXMLMODELIMPORT test the general model xml import function    
    clear;
    clc;
       
    %profile on; % str2double is extremely slow
    testImport('BB.xml');
    %profile viewer;
end


function testImport(fileName)
    dom = xmlread(fullfile('+prursg','+Test', '+UseCase', fileName));
    tag = prursg.Xml.XmlTool.getNode(dom.getFirstChild(), 'user_defined_sets');
    
    %tic;
    uds = prursg.Xml.ScenarioSetDao.readUserDefinedSets(tag);
    %toc;  % why is this so slow?
    assert(numel(uds) == 4); 
    for i = 1:numel(uds)
        assert(numel(uds(i).scenarios) == 1);
        assert(numel(uds(i).stochasticScenarios) == 1);        
    end
    %
    risk = prursg.Engine.Risk('TST_fx', []);
    deterministic = ones(1, 4) .* 1.54;
    stochastic = [ 1.694, 1.386, 1.848, 1.232 ];
    for i = 1:numel(uds)
        assert(deterministic(i) == uds(i).scenarios(1).getRiskScenarioValues(risk.name));
        outputs = uds(i).makeStochasticOutputs(risk);
        assert(stochastic(i) == outputs{1});
    end    
end





