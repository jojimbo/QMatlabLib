function TestBaseScenarioSetImport()
    %TESTXMLMODELIMPORT test the general model xml import function    
    clear;
    clc;
       
    testImport();
end


function testImport()
    dom = xmlread(fullfile('+prursg','+Test', '+UseCase', 'T0 base run test.xml'));
    scenarioSetTag = prursg.Xml.XmlTool.getNode(dom.getFirstChild(), 'base_set');
    scenarioSetTag = prursg.Xml.XmlTool.getNode(scenarioSetTag, 'scenario_set');
    
    sset = prursg.Xml.ScenarioSetDao.read(scenarioSetTag);
    
    assert(numel(sset.scenarios) == 1); 
    assert(strcmp(sset.name, 'base t0_22Mar2011_14:31:35'));
    assert(sset.sess_date == prursg.Xml.XmlTool.stringToDate('31/12/2010'));
end



