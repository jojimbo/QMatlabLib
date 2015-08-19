classdef AlgoBinary
    %ALGOBINARY support generation of algo binary stochastic file
    % First scenario in this file is a deterministic scenario taken from
    % expanded universe.
    % The other scenarios are stochastic and come from the chunks.
    
    methods (Static)
        
        function makeBinary(scenarioType, fileName, risks, algoCurves, scenarioSet, chunks, underlyingScenarioType)
            
            % Following the change to the Critical Scenario Engine, the
            % scenario type key could be a string with format 9:x, where 9 is the
            % Critical Scenario and x is the scenario type that the CS was run
            % against. If that's the case, grab the 9 and set the scenarioType.
            if (isa(scenarioType, 'char'))
                scenarioType = str2num(scenarioType(1:strfind(scenarioType, ':')-1));
            end
            
            if (int32(prursg.Engine.ScenarioType.WhatIfBase) == scenarioType)
                expandedUniverse = scenarioSet.getShockedBaseScenario().expandedUniverse;
            else
                expandedUniverse = scenarioSet.getBaseScenario().expandedUniverse;
            end
            
            subRisks = prursg.Util.JobUtil.getSubRisks(risks, expandedUniverse);
            
            startScenarioIndex = 0;
            deterministicChunk = prursg.Algo.AlgoBinary.toChunk(risks, expandedUniverse);
            [out2d startScenarioIndex]= prursg.Algo.AlgoBinary.toAlgoFormat(algoCurves, deterministicChunk, subRisks, startScenarioIndex, 0, scenarioType);
            writeToFile(fileName, 'w', out2d);
            rows=size(out2d,1);
            if ~isempty(scenarioSet.noRiskScenario)
                noRiskChunk = prursg.Algo.AlgoBinary.toChunk(risks, scenarioSet.noRiskScenario().expandedUniverse);
                startScenarioIndex = startScenarioIndex + 1;
                out2d= prursg.Algo.AlgoBinary.toAlgoFormat(algoCurves, noRiskChunk, subRisks, startScenarioIndex, 1, scenarioType);
                rows= rows + size(out2d, 1);
                writeToFile(fileName, 'a', out2d);
            end
            startScenarioIndex = startScenarioIndex + 1;
            
            % Check if the underlying data is Big Bang or Critical Scenario
            % in order to perform the shredding and include it in the Algo
            % binary file.
            if (int32(prursg.Engine.ScenarioType.BigBang) == underlyingScenarioType...
                || int32(prursg.Engine.ScenarioType.CriticalScenario) == underlyingScenarioType)
            
                shredGroups = containers.Map('keyType', 'char', 'valueType', 'char');
        
                for i = 1:numel(algoCurves)
                    algoCurve = algoCurves(i);        
                    for j=1:length(algoCurve.risk_groups)
                        %disp(algoCurve.risk_groups(j).shredname);
                        if (strcmp(algoCurve.risk_groups(j).shredname, 'XAllRisks'))
                            if ~shredGroups.isKey(algoCurve.risk_groups(j).group)
                                shredGroups(algoCurve.risk_groups(j).group) = 'XAllRisks';
                            end
                        end
                    end
                end
            
            
                out2d = prursg.Algo.AlgoBinary.toAlgoFormatBBAndCS(algoCurves, chunks, subRisks, startScenarioIndex, 1, scenarioType, noRiskChunk, shredGroups);
            else
                out2d = prursg.Algo.AlgoBinary.toAlgoFormat(algoCurves, chunks, subRisks, startScenarioIndex, 1, scenarioType);
            end
            writeToFile(fileName, 'a', out2d);
            
            rows = rows + size(out2d, 1);
            cols = size(out2d, 2);
            
            if prursg.Util.ConfigurationUtil.GetDebugMode()
                save(fullfile(fileparts(fileName), 'BinaryMetaData.mat'), 'rows', 'cols', prursg.Util.FileUtil.GetMatFileFormat());
                save(fullfile(fileparts(fileName), 'out2d.mat'), 'out2d', prursg.Util.FileUtil.GetMatFileFormat());
            end
            
        end
        
        % converts deterministic expanded universe to chunk format, which later can be
        % processed by toAlgoFormat
        function chunk = toChunk(risks, expandedUniverse)
            chunk = cell(1, numel(risks));
            for i = 1:numel(risks)
                chunk(i) = { expandedUniverse(risks(i).name).serialise() }; 
            end
        end
        
        % process one chunk of stochastic results
        function [out2d endScenarioIndex] = toAlgoFormatBBAndCS(algoCurves, chunk, numSubRisks, startScenarioIndex, isStochasticChunk, scenarioType, noRiskChunk, shredGroups)
            
            shredKeys = keys(shredGroups);
            
            if (isa(chunk, 'cell'))
                chunk = cell2mat(chunk);
            end
            
            if (isa(noRiskChunk, 'cell'))
                noRiskChunk = cell2mat(noRiskChunk);
            end
            
            chunkSize = size(chunk, 1);
            
            nRows = chunkSize*(1+numel(shredKeys));
            endScenarioIndex = startScenarioIndex + nRows -1;
            nColumns = 0;
            for i = 1:numel(algoCurves)
                nColumns = nColumns + algoCurves(i).getNumberOfColumnsByRisk(numSubRisks(:, 1));
            end
            
            nColumns = nColumns + 2; % for control information
            
            out2d = zeros(nRows, nColumns);  
            %scenario index
            out2d(:, 2) = startScenarioIndex:1:endScenarioIndex;
            %stochastic indicator
            if isStochasticChunk 
                out2d(:, 1) = 2;
            else
                if (scenarioType == int32(prursg.Engine.ScenarioType.WhatIfBase))    
                    out2d(:, 1) = 1; %shocked base
                else
                    out2d(:, 1) = 0; %base
                end
            end
            
            
            startColumn = 3;
            for i = 1:numel(algoCurves)
                
                endColumn = startColumn + algoCurves(i).getNumberOfColumnsByRisk(numSubRisks(:, 1)) - 1;
                
                subRisks = numSubRisks(algoCurves(i).indices, :);
                indexes = cellfun(@(x)colon(x(2), x(3)), mat2cell(subRisks, ones(1, size(subRisks, 1)), [3]), 'UniformOutput', 0);
                indexes = cell2mat(reshape(indexes, 1, []));
                                
                if(algoCurves(i).isTransformationRequired())                             
                    %handles credit curves.
                    creditRatingValuesSize = numel(indexes);                    
                    creditRatingValueIndexes = startColumn + (([1:creditRatingValuesSize] - 1) * algoCurves(i).creditRatingsSize + algoCurves(i).creditRatingIndex) - 1;
                    out2d(1:chunkSize, creditRatingValueIndexes) = chunk(:, indexes);
                else
                    out2d(1:chunkSize, startColumn:endColumn) = chunk(:, indexes);
                end                
                
                startColumn = endColumn + 1;
            end
            
            
            startRow = chunkSize + 1;
            for j = 1:numel(shredKeys)   
                endRow = chunkSize*(j+1);
                startColumn = 3;
                for i = 1:numel(algoCurves)
                    algoCurve = algoCurves(i); 
                    for k=1:length(algoCurve.risk_groups)
                        %disp(algoCurve.risk_groups(j).shredname);
                        if (strcmp(algoCurve.risk_groups(k).shredname, 'XAllRisks'))
                            shredGroup = algoCurve.risk_groups(k).group;
                            break;
                        end
                    end

                    endColumn = startColumn + algoCurve.getNumberOfColumnsByRisk(numSubRisks(:, 1)) - 1;

                    subRisks = numSubRisks(algoCurve.indices, :);
                    indexes = cellfun(@(x)colon(x(2), x(3)), mat2cell(subRisks, ones(1, size(subRisks, 1)), [3]), 'UniformOutput', 0);
                    indexes = cell2mat(reshape(indexes, 1, []));

                    if(algoCurve.isTransformationRequired())                             
                        %handles credit curves.
                        creditRatingValuesSize = numel(indexes);                    
                        creditRatingValueIndexes = startColumn + (([1:creditRatingValuesSize] - 1) * algoCurve.creditRatingsSize + algoCurve.creditRatingIndex) - 1;
                        if (strcmp(shredKeys{j}, shredGroup))
                            out2d(startRow:endRow, creditRatingValueIndexes) = chunk(:, indexes);
                        else
                            out2d(startRow:endRow, creditRatingValueIndexes) = repmat(noRiskChunk(:, indexes), chunkSize, 1);
                        end
                    else
                        if (strcmp(shredKeys{j}, shredGroup))
                            out2d(startRow:endRow, startColumn:endColumn) = chunk(:, indexes);
                        else
                            out2d(startRow:endRow, startColumn:endColumn) = repmat(noRiskChunk(:, indexes), chunkSize, 1);
                        end
                    end                

                    startColumn = endColumn + 1;
                end
                startRow = endRow + 1;
            end
        end
        
        % process one chunk of stochastic results
        function [out2d endScenarioIndex] = toAlgoFormat(algoCurves, chunk, numSubRisks, startScenarioIndex, isStochasticChunk, scenarioType)
            
            if (isa(chunk, 'cell'))
                chunk = cell2mat(chunk);
            end
            
            nRows = size(chunk, 1);
            endScenarioIndex = startScenarioIndex + nRows -1;
            nColumns = 0;
            for i = 1:numel(algoCurves)
                nColumns = nColumns + algoCurves(i).getNumberOfColumnsByRisk(numSubRisks(:, 1));
            end
            
            nColumns = nColumns + 2; % for control information
            
            out2d = zeros(nRows, nColumns);  
            %scenario index
            out2d(:, 2) = startScenarioIndex:1:endScenarioIndex;
            %stochastic indicator
            if isStochasticChunk 
                out2d(:, 1) = 2;
            else
                if (scenarioType == int32(prursg.Engine.ScenarioType.WhatIfBase))    
                    out2d(:, 1) = 1; %shocked base
                else
                    out2d(:, 1) = 0; %base
                end
            end
            
            startColumn = 3;
            for i = 1:numel(algoCurves)
                endColumn = startColumn + algoCurves(i).getNumberOfColumnsByRisk(numSubRisks(:, 1)) - 1;
                
                subRisks = numSubRisks(algoCurves(i).indices, :);
                indexes = cellfun(@(x)colon(x(2), x(3)), mat2cell(subRisks, ones(1, size(subRisks, 1)), [3]), 'UniformOutput', 0);
                indexes = cell2mat(reshape(indexes, 1, []));
                                
                if(algoCurves(i).isTransformationRequired())                             
                    %handles credit curves.
                    creditRatingValuesSize = numel(indexes);                    
                    creditRatingValueIndexes = startColumn + (([1:creditRatingValuesSize] - 1) * algoCurves(i).creditRatingsSize + algoCurves(i).creditRatingIndex) - 1;
                    out2d(:, creditRatingValueIndexes) = chunk(:, indexes);
                else
                    out2d(:, startColumn:endColumn) = chunk(:, indexes);
                end                
                
                startColumn = endColumn + 1;
            end
        end
    end
    
end


function writeToFile(fileName, openMode, out2d)
    fid = fopen(fileName, openMode);
    
    % in order to avoid out of memory exception, transpose 1000 rows at at
    % a time and write them to the disk.
    for i = 1:size(out2d, 1)
        fwrite(fid, out2d(i, :)', 'double');
    end
    
    fclose(fid);
end
