function TestMakeAlgoBinaryHeader()
    import prursg.Xml.*;
    import prursg.Test.Algo.*;
    
    clc;
    clear;
    
    risks = AlgoTestsFixture.makeRisks();
    
    % a base t=0 scenario
    xmlDoc = prursg.Algo.makeAlgoBinaryHeader(... 
        AlgoTestsFixture.getManifestScenarioName(), ...
        AlgoTestsFixture.getBaseCurrency(), ...
        AlgoTestsFixture.getSessionDate(), ...
        '0', 11, risks ...
    );
    str = XmlTool.toString(xmlDoc, true);
    str = sprintf('<?xml version="1.0" encoding="UTF-8" ?>\n%s', str);
    disp(str);
    fid = fopen(fullfile('outputs', [ AlgoTestsFixture.getManifestScenarioName() '.xml']), 'w');
    fwrite(fid, str);
    ST = fclose(fid);    
end
