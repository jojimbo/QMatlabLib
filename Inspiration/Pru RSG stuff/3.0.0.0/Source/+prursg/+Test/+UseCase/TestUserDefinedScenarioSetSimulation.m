function TestUserDefinedScenarioSetSimulation()
    clc;
    clear;
    %filePath = fullfile('+prursg','+Test', '+UseCase', 'BB.xml');
    %filePath = fullfile('+prursg','+Test', '+UseCase', 'SF.xml');
    %filePath = fullfile('+prursg','+Test', '+UseCase', 'PnL.xml');
    %filePath = fullfile('+prursg','+Test', '+UseCase', 'LMC.xml');
    
    %xmls = { 'BB.xml', 'SF.xml', 'PnL.xml', 'LMC.xml' };
    xmls = { 'BB.xml' };       
    filePath = fullfile('+prursg','+Test', '+UseCase');

    %Big Bang tests
    %xmls = { 'YE10 BB v6.xml'};
    %filePath =  '/media/shared/prudential/ye10/BB - ud';
    
    %PnL tests
    %xmls = { 'YE10 OF PL1 v2.xml', 'YE10 OF PL2 v3.xml', 'YE10 OF PL3 v3.xml', 'YE10 OF PL4 v3.xml', 'YE10 OF PL5 v3.xml' };
    %xmls = [ xmls, { 'YE10 OF PL9 v3.xml', 'YE10 OF PL10 v3.xml'} ];
    %xmls = { 'YE10 OF PL10 v3.xml' };
    %filePath =  '/media/shared/prudential/ye10/PnL OF - ud';
    
    %
    %xmls = { 'YE10 SF v5.xml' };
    %filePath = '/media/shared/prudential/ye10/SF - ud';
    %profile on;
    for i = 1:numel(xmls)   
        tic;
        fileName = xmls{i};
        fprintf('Processing %s\n', fileName');
        fileName = fullfile(filePath, fileName);        
        modelFile = prursg.Xml.ModelFile(fileName, true);
        checkOrdering(modelFile.riskDrivers);        
        
        uc = prursg.UseCase.UserDefinedScenarioSetSimulation();
        testing = true;
        uc.run(modelFile, testing);    
        toc;
    end
   % profile viewer;
    

end

% good ordering matches
function checkOrdering(risks)
    riskNames = prursg.Test.UseCase.ExcelIssues.getExcelRiskNamesOrder();
    for i = 1:numel(riskNames)
      %  assert(isequal(riskNames{i}, risks(i).name));
    end
end
