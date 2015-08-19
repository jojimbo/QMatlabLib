function TestBaseScenarioShockImport()
    %TESTXMLMODELIMPORT test the general model xml import function    
    clear;
    clc;
       
    testShockImport();
end


function testShockImport()
    dom = xmlread(fullfile('+prursg','+Test', '+Xml', 'shock.xml'));
    shockTag = dom.getFirstChild();
    s = prursg.Xml.BaseScenarioShockDao.read(shockTag);
    
    assert(s.date == datenum('2010/12/31', 'yyyy/mm/dd'));    
    assert(strcmp(s.name, '__shockedBase'));
    %
    shifts = s.shiftCoefficients('TST_fx');
    stretches = s.stretchCoefficients('TST_fx');
    multshock = s.multishock('TST_fx');
    
    assert(shifts.values{1} == 1.694);
    assert(stretches.values{1} == 1.5);
    assert(multshock);
    %
    shifts = s.shiftCoefficients('TST_equitycri_a');
    stretches = s.stretchCoefficients('TST_equitycri_a');
    multshock = s.multishock('TST_equitycri_a');
    
    assert(shifts.values{1} == 5500);
    assert(stretches.values{1} == 1.5);
    assert(multshock);

    shifts = s.shiftCoefficients('TST_ryc');
    stretches = s.stretchCoefficients('TST_ryc');
    multshock = s.multishock('TST_ryc');
    
    assert(shifts.values{1}(1) == 0.0055);
    assert(shifts.values{1}(end) == 2.41999994741689E-02);
    
    assert(stretches.values{1}(1) == 1.5);
    assert(stretches.values{1}(end) == 1.5);
    assert(~multshock);    
    
end



