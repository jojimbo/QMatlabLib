function TestScenarioImport()
    %TESTXMLMODELIMPORT test the general model xml import function    
    clear;
    clc;
       
    testTimestepImport();
end


function testTimestepImport()
    dom = xmlread(fullfile('+prursg','+Test', '+Xml', 'base-scenario-set.xml'));
    xmlScenario = dom.getFirstChild().getFirstChild();
    s = prursg.Xml.ScenarioDao.read(xmlScenario);
    
    assert(s.date == datenum('2010/12/31', 'yyyy/mm/dd'));    
    assert(strcmp(s.name, 'assets'));
    assert(s.number == 0);
    assert(s.scen_step == 0);
    %
    fxValues = s.expandedUniverse('TST_fx');
    assert(fxValues.values{1} == 1.54);
    %
    siValues = s.expandedUniverse('TST_equitycri_a');
    assert(siValues.values{1} == 5000);
    %
    nycValues = s.expandedUniverse('TST_nyc');
    values = nycValues.values{1};
    assert(abs(values(1) - 1.03253206390773E-02) < 1e-20);
    assert(abs(values(end) - 4.19991281134348E-02) < 1e-20);    
end



