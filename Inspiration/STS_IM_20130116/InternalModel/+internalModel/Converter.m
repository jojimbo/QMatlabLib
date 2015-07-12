%% Converter
% Static class
classdef Converter

    methods (Static)

        function rtTable = remapRTtable(rtTable)
            %% remapRTtable
            % |rtTable = remapRTtable(rtTable)|
            % 
            % Inputs:
            % 
            % * |rtTable|   _cell_
            hasSpace = regexp(rtTable, '\s');
            col_1    = any([hasSpace{:, 1}]);
            col_2    = any([hasSpace{:, 2}]);

            if col_1 && ~col_2
                % Correct order

            elseif ~col_1 && col_2
                % reverse order of column 1 and 2
                temp          = rtTable(:, 2);
                rtTable(:, 2) = rtTable(:, 1);
                rtTable(:, 1) = temp;

            elseif ~col_1 && col_2

                warning('ing:UnClearOrder', 'Converter: unclear whether order of columns of mapping table is correct');
            end
        end


        function beTable = remapBEtable(beTable)
            %% remapBEtable
            % |beTable = remapBEtable(beTable)|
            % 
            % Inputs:
            % 
            % * |beTable|   _cell_
            hasSpace = regexp(beTable, '\s');
            col_1    = any([hasSpace{:, 1}]);
            col_2    = any([hasSpace{:, 2}]);

            if col_1 && ~col_2
                % Correct order

            elseif ~col_1 && col_2
                % reverse order of column 1 and 2
                temp          = beTable(:, 2);
                beTable(:, 2) = beTable(:, 1);
                beTable(:, 1) = temp;

            elseif (~col_1 && ~col_2) || (col_1 && col_2)

                warning('ing:UnClearOrder', 'Converter: unclear whether order of columns of mapping table is correct');
            end
        end
    end

end
