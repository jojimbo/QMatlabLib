function TestWhatIfScenarioSetSimulation()
    clc;
    clear;
    
%    filePath = fullfile('+prursg','+Test', '+UseCase', 'wi Tgr0.xml');
    %filePath = fullfile('+prursg','+Test', '+UseCase', 'wi t0.xml');
    
    filePath =  '/media/shared/prudential/ye10/BP - wi/YE10 BP v7.xml'
    %filePath =  '/tmp/duda.xml'
    tic;
    modelFile = prursg.Xml.ModelFile(filePath);
    toc;
    return;
    uc = prursg.UseCase.WhatIfScenarioSetSimulation();
    uc.run(modelFile, true);

end

