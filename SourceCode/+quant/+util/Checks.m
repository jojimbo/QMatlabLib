% CheckDataTypes
% Collection of functions to check the Data Type (help enforce data types)

% Example use:
% OKs:
% Utils.Checks.isDoubleArrayWithSize(5,[1,1])
% Utils.Checks.isDoubleArrayWithSize([5,2],[1,2])
% Utils.Checks.isDoubleArrayWithSize([5,2; 1, 3],[2,2])
% Utils.Checks.isDoubleArrayWithSize([5; 3],[2,1])
%
% ERRORS:
% Utils.Checks.isDoubleArrayWithSize(5,[1])
% Utils.Checks.isDoubleArrayWithSize([5,2],[1,1])
% Utils.Checks.isDoubleArrayWithSize([5,2; 1, 3],[3,2])
% Utils.Checks.isDoubleArrayWithSize([5; 3],[2,2])
%



classdef Checks

    methods (Access = public, Static)
        %Checks input is a double
        function isDoubleArrayWithSize(input, size)
            validateattributes(input,{'double'}, {'size', size})
        end
    end

end
