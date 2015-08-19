function TestHugeXml()
    %TESTXMLMODELIMPORT test the general model xml import function    
    clear;
    clc;
     
    %fileName = fullfile('+prursg','+Test', '+UseCase', 'YE10 Base v8.xml');
    %fileName =  '/media/shared/prudential/ye10/BB - ud/YE10 BB v6.xml';
    fileName =  '/media/shared/prudential/ye10/base/YE10 Base Final v2.xml';
    
    testModelFile(fileName);
    %testImport();
end

function testModelFile(fileName)

    %tic;
    %dom = xmlread(fileName);
    %val = prursg.Xml.XmlTool.readString(dom.getFirstChild(), 'validation_rules', '')
    %toc;
    
    %return;
    tic;
    mf = prursg.Xml.ModelFile(fileName, true)  
    toc;
    
    
    return;
    
    %profile on;
    
    
    prursg.Xml.configureJava(true);
    root = xmlread(fileName);
    root = root.getFirstChild();
    risks = prursg.Xml.ModelFile.readRiskDrivers(root);
    
    %profile viewer;
    
    toc;
end
