classdef SimulationResults < handle
    % Redundant object - delete for final release
    
    properties
        headings
        nSims
        nPeriods
        simTimeStepInMonths
    end
    
    methods
        function obj = SimulationResults()
        end
    end
    
    methods ( Static )
        function saveResults(folderName, data, batchIndex )
            fname = fullfile( folderName, sprintf( 'YYY_B%d', batchIndex ) );
            save(fname, 'data', prursg.Util.FileUtil.GetMatFileFormat());
        end
        function data = getSimData(batchIndex)
            data = []; % initialize
            for ii = 1:numel(batchIndex)
                fname = fullfile( 'simResults', sprintf( 'YYY_B%d', batchIndex(ii) ) );
                S = load( fname );
                data = [data; S.data];
            end
        end
    end
end

