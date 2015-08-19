classdef JobUtil
    %JOBUTILS- Privoides utility functions required for job distribution
    %through the parallel toolbox.        
    properties
    end
    
    methods(Static)
        
        %Split Risk Id collection based on the number of batches.
        function [nRiskIdsLocal riskIdsLocal nBatches] = splitRiskIds(riskIds, nBatches)

            nRiskIds = numel(riskIds);
                                    
            if(nRiskIds >= nBatches)
                
                % begin by working out number of risk Ids in each batch
                for batchIndex = 1:nBatches
                    if batchIndex == nBatches
                        nRiskIdsLocal(batchIndex) = nRiskIds - (nBatches-1)*floor(nRiskIds/nBatches);
                    else
                        nRiskIdsLocal(batchIndex) = floor(nRiskIds/nBatches);
                    end
                end

                % then pick up the right number of rows of risk ids.
                riskIdsLocal = cell(nBatches,1);  
                rowStart = 1;
                rowEnd = 0;
                for i = 1:nBatches
                    rowEnd = rowEnd + nRiskIdsLocal(i);
                    riskIdsLocal{i} = riskIds(:, rowStart:rowEnd);
                    rowStart = rowEnd + 1;         
                end
            else
                for i = 1:nRiskIds                        
                    nRiskIdsLocal(i) = 1;
                    riskIdsLocal{i} = riskIds(:, i);                        
                end
                
                nBatches = nRiskIds;
            end
            
        end
        
        % retrieve sub risk details.
        function numSubRisks = getSubRisks(riskDrivers, expandedUniverse)
            startIndex = 0;
            endIndex = 0;
            numSubRisks = zeros(length(riskDrivers),3);        
            for i = 1:length(riskDrivers)
                startIndex = endIndex + 1;            
                numSubRisks(i, 1) = expandedUniverse(riskDrivers(i).name).getSize();
                endIndex = startIndex + numSubRisks(i, 1) - 1;
                numSubRisks(i, 2) = startIndex;
                numSubRisks(i, 3) = endIndex;
            end
        end
        
    end
    
end

