function TestBaseScenarioSetSimulation()
    clc;
    clear;
    tic;
    %filePath = fullfile('+prursg','+Test', '+UseCase', 'Slimline 4Apr v4.xml');
    filePath = fullfile('+prursg','+Test', '+UseCase', 'usd_ye10_base_v3.xml');
    %filePath = fullfile('+prursg','+Test', '+UseCase', 'T0 base run test.xml');
    %filePath = fullfile('+prursg','+Test', '+UseCase', 'base tgr0.xml');
    
    %files = { 'Slimline 4Apr v4.xml', 'base tgr0.xml', 'T0 base run test.xml' };
    files = { 'base tgr0.xml' };
    
    for i = 1:numel(files)
        %filePath = fullfile('+prursg','+Test', '+UseCase', files{i});                
        modelFile = prursg.Xml.ModelFile(filePath, false);     
        uc = prursg.UseCase.BaseScenarioSetSimulation();
        testing = true;
        uc.run(modelFile, testing, true);    
    end
    toc;
end

