%% DayCount

classdef DayCount  

    %% Properties 
    % 
    % *_Constant, Hidden_*
    % 
    % * Month1
    % * Month2
    % * Month3
    % * Month4
    % * Month6
    % * Month12

    properties (Constant, Hidden)

        Month1  = [30, 30, 31, 30, 31, 30, 30, 31, 30, 31, 30, 31]
        Month2  = [60, 61, 61, 61, 61, 61]
        Month3  = [91, 91, 91, 92];
        Month4  = [121, 122, 122]
        Month6  = [182, 183]
        Month12 = 365

    end


    %% Methods 
    %
    % *_Static_*
    %
    % |days = getDayCount(periodic)| 

    methods (Static)

        function days = getDayCount(periodic)
            %% getDayCount _static_
            % 
            % Inputs:
            % 
            % * periodic    _double_
            % 
            % Outputs:
            % 
            % * days        _double_
            if isempty(periodic)
                days    = DayCount.Month1;
                return
            end

            if ~isnumeric(periodic) || numel(periodic) > 1
                error('ing:DayCount', 'Only single numeric input is processed');
            end

            if any(eq(periodic, [1 2 3 4 6 12]))
                days = internalModel.DayCount.(['Month' num2str(periodic)]);
            else
                error('ing:DayCount', 'Period not implemented');
            end

        end

    end

end
