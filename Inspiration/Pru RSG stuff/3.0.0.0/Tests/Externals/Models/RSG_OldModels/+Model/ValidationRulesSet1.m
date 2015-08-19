classdef ValidationRulesSet1 < prursg.Engine.ValidationRules

    properties
        ModelFile        
    end
    
    methods
        function obj = ValidationRulesSet1()
            obj = obj@prursg.Engine.ValidationRules();
        end
        
        function validate(obj, nBatches, modelFile, risks , scenarioSet, simResults, reportPath)                                                           
            obj.ModelFile = modelFile;
            resultFileNames{1} = obj.Process(1, risks, scenarioSet, simResults, reportPath);
            headerFileName = fullfile(reportPath, 'ValidationResults.csv');
            fid = fopen(headerFileName,'w+');   
            fclose(fid);            
            prursg.Util.FileUtil.CombineFiles(headerFileName, resultFileNames);
        end                               
    end
    
    methods(Access=private)
        
        function [itemNew, measureNew, valueNew] = validationSet(obj, riskName,expandedNames,simData)

            itemNew = cell(5, 1);
            itemNew(:, 1) = {[riskName expandedNames]};
            measureNew = {'mean'; '0.05'; '0.5'; '99.5'; '99.95'};
            valueNew = cell(5, 1);
            valueNew(1, 1) = {mean(simData)};
            valueNew(2, 1) = {prctile(simData,0.05,1)};
            valueNew(3, 1) = {prctile(simData,0.5,1)};
            valueNew(4, 1) = {prctile(simData,99.5,1)};
            valueNew(5, 1) = {prctile(simData,99.95,1)};    

        end

        function resultFileName = Process(obj, batchIndex, risks, scenarioSet, stoValues, reportPath)

            resultFileName = fullfile(reportPath, ['ValidationResults' num2str(batchIndex) '.csv']);

            import prursg.Xml.*;
            prursg.Xml.configureJava(true);

            setID = scenarioSet.name;
            detScenarios = scenarioSet.getDeterministicScenarios();
            baseScenario = scenarioSet.getBaseScenario();

            nSubRisks = 0;
            for i1 = 1:numel(risks)
               nSubRisks = nSubRisks + baseScenario.expandedUniverse(risks(i1).name).getSize();
            end


            rowSize = (length(detScenarios) * nSubRisks) + (nSubRisks * 5);
            valData = cell(rowSize, 4);
            valData(:, 1) = {'ruleSet1'};

            currentRow = 0;

            % deterministic validation
            for i1= 1:length(detScenarios)
                detDate = datestr(detScenarios(i1).date,24);
                for i2=1:numel(risks)
                    expandedNames = detScenarios(i1).expandedUniverse(risks(i2).name).getExpandedNames;
                    data = detScenarios(i1).expandedUniverse(risks(i2).name).getFlatData(1);
                    for i3 = 1:length(expandedNames)
                        currentRow = currentRow + 1;
                        valData(currentRow, 2) = {[risks(i2).name expandedNames{i3}]};
                        valData(currentRow, 3) = {detDate};
                        valData(currentRow, 4) = {data(i3)};                
                    end
                end
            end


            % stochastic validation
            for i1=1:numel(risks)
                expandedNames = baseScenario.expandedUniverse(risks(i1).name).getExpandedNames;
                simData = stoValues{i1};
                for i2 = 1:length(expandedNames) 
                    currentRow = currentRow + 1;
                    [itemNew, measureNew, valueNew] = obj.validationSet(risks(i1).name,expandedNames{i2},simData(:,i2));
                    valData(currentRow:currentRow + 4, 2) = itemNew;
                    valData(currentRow:currentRow + 4, 3) = measureNew;
                    valData(currentRow:currentRow + 4, 4) = valueNew;
                    currentRow = currentRow + 4;
                end
            end

            % write results to csv file                        
            fid = fopen(resultFileName,'w+');            
            for i=1:size(valData, 1)
                fprintf(fid,'%s,%s,%g,\r\n',valData{i, 2}, valData{i, 3}, valData{i, 4});                
            end
            fclose(fid);            

            % persist validation schedule in Oracle            
            db = prursg.Db.DataFacadeFactory.CreateFacade(obj.ModelFile.is_in_memory);            
            db.storeValidationSchedule(batchIndex, setID, valData);  
            delete(db);
        end   

    end
                    
end

