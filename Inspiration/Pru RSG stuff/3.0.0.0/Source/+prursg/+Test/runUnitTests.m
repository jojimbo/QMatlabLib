function runUnitTests()
%RUNUNITTESTS Run all unit tests
    clear;
    clc;
    tic;
    runXmlRelatedTestCases();
   % runDbRelatedTestCases(); % you need a functional database for the purpose
    
    runBusinessLogicTestCases();
    toc();
end

function runBusinessLogicTestCases()
    prursg.Test.TestRiskIndexResolver();
    prursg.Test.TestHyperCubeFlattening();
    prursg.Test.TestPassByReference();
    prursg.Test.TestAxis();    
    prursg.Test.TestDefaultValueMap();
end

function runXmlRelatedTestCases()

    prursg.Xml.configureJava(true);

    prursg.Test.Xml.TestCalibrationSourceTargetXmlImport();
    prursg.Test.Xml.TestSerialisedHyperCubeImport();
    prursg.Test.Xml.TestScenarioImport();
    prursg.Test.Xml.TestXmlModelImport();
    prursg.Test.Xml.TestBaseScenarioSetImport();
    prursg.Test.Xml.TestWriteBackCalibrationInfo();
    prursg.Test.Xml.TestUserDefinedScenarioSetsImport();
    prursg.Test.Xml.TestBaseScenarioShockImport();
end

function runDbRelatedTestCases()
    prursg.Test.Db.TestDatetimePersistence();
    prursg.Test.Db.TestBlob();
    prursg.Test.Db.TestJavaBlob();
    prursg.Test.Db.TestRsgOutputDao();
    prursg.Test.Db.TestXmlPersistence();
end