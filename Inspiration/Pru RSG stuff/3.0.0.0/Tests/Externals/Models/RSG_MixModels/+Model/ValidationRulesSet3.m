classdef ValidationRulesSet3 < prursg.Engine.ValidationRules

    properties
        ModelFile
    end
    
    methods
        function obj = ValidationRulesSet3()
            obj = obj@prursg.Engine.ValidationRules();
        end
        
        function validate(obj, nBatches, modelFile, risks , scenarioSet, simResults, reportPath)                                                         
            obj.ModelFile = modelFile;
            resultFileNames{1} = Process(obj, 1, risks, scenarioSet, simResults, reportPath);
            headerFileName = fullfile(reportPath, 'ValidationResults.csv');
            fid = fopen(headerFileName,'w+');
            fclose(fid);            
            prursg.Util.FileUtil.CombineFiles(headerFileName, resultFileNames);
        end
                
    end
                    
end

function [measureNew, valueNew] = validationSet(simData)
    
    measureNew = {'median' 'mean' 'std_dev' '0.05' '0.5' '99.5' '99.95'};
    valueNew = cell(1, 7);
    valueNew(1, 1) = {median(simData)};
    valueNew(1, 2) = {mean(simData)};
    valueNew(1, 3) = {std(simData)};
    valueNew(1, 4) = {prctile(simData,0.05,1)};
    valueNew(1, 5) = {prctile(simData,0.5,1)};
    valueNew(1, 6) = {prctile(simData,99.5,1)};
    valueNew(1, 7) = {prctile(simData,99.95,1)};    

end

function resultFileName = Process(obj, batchIndex, risks, scenarioSet, stoValues, reportPath)

    resultFileName = fullfile(reportPath, ['ValidationResults' num2str(batchIndex) '.csv']);    
    
    import prursg.Xml.*;
    prursg.Xml.configureJava(true);
    
    setID = scenarioSet.name;
    detScenarios = scenarioSet.getDeterministicScenarios();
    shockScen = scenarioSet.getShockedBaseScenario();
    noRiskScen = scenarioSet.noRiskScenario;
    baseScenario = scenarioSet.getBaseScenario();
    
    nSubRisks = 0;
    nRisks = numel(risks);
    for i1 = 1:nRisks
       nSubRisks = nSubRisks + baseScenario.expandedUniverse(risks(i1).name).getSize();       
    end
    
        
    rowSize = nSubRisks;
    colSize = length(detScenarios) + 7;  % Mean, Median, Std dev, 4 percentiles
    valData = cell(rowSize, colSize + 1);
    valData(:, 1) = {'ruleSet3'};    
            
    currentCol = 0;
    
    % deterministic validation 
    for i1= 1:length(detScenarios)
        detDate = datestr(detScenarios(i1).date,24);
        detName = detScenarios(i1).name;
        currentCol = currentCol + 1;
        currentRow = 0;
        for i2=1:nRisks
            expandedNames = detScenarios(i1).expandedUniverse(risks(i2).name).getExpandedNames;
            data = detScenarios(i1).expandedUniverse(risks(i2).name).getFlatData(1);
            for i3 = 1:length(expandedNames)
                currentRow = currentRow + 1;
                if currentCol == 1 
                    valData(currentRow + 2, 2) = {[risks(i2).name expandedNames{i3}]};
                end
                if currentRow == 1 
                    valData(1, currentCol + 2) = {detDate};
                    valData(2, currentCol + 2) = {detName};
                end
                valData(currentRow + 2, currentCol + 2) = {data(i3)};                
            end
        end
    end
    
    %shocked scenario (if any)
    if ~isempty(shockScen)
        detDate = datestr(shockScen.date,24);
        detName = shockScen.name;
        currentCol = currentCol + 1;
        currentRow = 0;
        for i2=1:nRisks
            expandedNames = shockScen.expandedUniverse(risks(i2).name).getExpandedNames;
            data = shockScen.expandedUniverse(risks(i2).name).getFlatData(1);
            for i3 = 1:length(expandedNames)
                currentRow = currentRow + 1;
                if currentRow == 1
                    valData(1, currentCol + 2) = {detDate};
                    valData(2, currentCol + 2) = {detName};
                end
                valData(currentRow + 2, currentCol + 2) = {data(i3)};
            end
        end
    end
    
    %no risk scr scenario validation
    if ~isempty(noRiskScen)
        detDate = datestr(noRiskScen.date,24);
        detName = noRiskScen.name;
        currentCol = currentCol + 1;
        currentRow = 0;
        for i2=1:nRisks
            expandedNames = noRiskScen.expandedUniverse(risks(i2).name).getExpandedNames;
            data = noRiskScen.expandedUniverse(risks(i2).name).getFlatData(1);
            for i3 = 1:length(expandedNames)
                currentRow = currentRow + 1;
                if currentRow == 1
                    valData(1, currentCol + 2) = {detDate};
                    valData(2, currentCol + 2) = {detName};
                end
                valData(currentRow + 2, currentCol + 2) = {data(i3)};
            end
        end
    end
    
    % stochastic validation
    currentRow = 0;
    for i1=1:nRisks
        expandedNames = baseScenario.expandedUniverse(risks(i1).name).getExpandedNames;
        simData = stoValues{i1};
        for i2 = 1:length(expandedNames) 
            currentRow = currentRow + 1;            
            [measureNew, valueNew] = validationSet(simData(:,i2));            
            if currentRow == 1 
                valData(currentRow, currentCol + 3:currentCol + 9) = measureNew;  %row 1 contains the names of the stats
            end            
            valData(currentRow + 2, currentCol + 3:currentCol + 9) = valueNew;            
        end
    end
        
    % write results to csv file                        
    fid = fopen(resultFileName,'w+');            
    numRows = size(valData, 1);
    numCols = size(valData, 2);
    for i=1:numRows
        for j = 2:numCols            
            if (i<=2 && j~=numCols) || j==2
                fprintf(fid,'%s,',valData{i,j});
            elseif i<=2 && j==numCols
                fprintf(fid,'%s,\r\n',valData{i,j});
            elseif j < numCols
                fprintf(fid,'%g,',valData{i,j});
            elseif i>2 && j == numCols
                fprintf(fid,'%g,\r\n',valData{i,j});
            end            
        end
    end
    fclose(fid);     
        
    %Re-format valData so that it can be saved into Oracle database (4
    %columns). Note the order for statistics is different to Ruleset1 in
    %that it is by type of stats here (so mean for all risks then median
    %for all risks) whilst in RuleSet1 it is by risk (so mean & other stats 
    %for risk1 and then those for risk 2, and so on).
    %Also include all the correlations
    numDetScen = length(detScenarios)+1; %include no risk scr scenario
    rowSize1 = (numDetScen * nSubRisks) + (nSubRisks * 7);
    rowSize = rowSize1 + (nRisks^2-nRisks)/2+nRisks; %Add correlations
    valData2 = cell(rowSize, 4);  
    valData2(:, 1) = {'ruleSet3'};
    %put valData into valData2
    for i=3:numRows
        for j = 2:numCols     
            if j==2  %Risk names
                for k = 1:(numDetScen+7)
                    valData2{(k-1)*nSubRisks+i-2,2}=valData(i,2);
                end
            elseif j <= numDetScen+2    %Deterministic values
                valData2{(j-3)*nSubRisks+i-2,3} = [valData{1,j} valData{2,j}];
                valData2{(j-3)*nSubRisks+i-2,4} = valData{i,j};
            elseif j > numDetScen+2     %Statistics
                valData2{(j-3)*nSubRisks+i-2,3} = valData{1,j};                
                valData2{(j-3)*nSubRisks+i-2,4} = valData{i,j};                
            end
        end
    end
       
    % persist validation schedule in Oracle
    db = prursg.Db.DataFacadeFactory.CreateFacade(obj.ModelFile.is_in_memory);            
    db.storeValidationSchedule(batchIndex, setID, valData2);  
    delete(db);            
        
end   