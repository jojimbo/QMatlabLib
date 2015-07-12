%% CurveCollection 
% value class

classdef CurveCollection

    %% Properties 
    % *_Dependent, GetAccess = public, SetAccess = private_*
    % 
    % * |Curves|
    % * |CurveNames|
    % 
    % *_GetAccess = private, SetAccess = private_*
    % 
    % * |CurveMap|

    properties(Dependent, GetAccess = public, SetAccess = private)      
        Curves
        CurveNames
    end

    properties(GetAccess = private, SetAccess = private)
        CurveMap
    end


    %% Methods
    % 
    % * |this = CurveCollection(curveFile)|     _constructor_
    % * |curve = findCurveByName(this, name)|
    methods

        function curves = get.Curves(this)
            curves = this.CurveMap.values;
        end

        function curves = get.CurveNames(this)
            curves = this.CurveMap.keys;
        end

    end


    methods(Access = public)

        function obj = CurveCollection(calcObj, fileName)
            %% CurveCollection
            % |obj = CurveCollection(calcObj, curveFile)|
            % 
            % Inputs:
            % 
            % * calcObj     _Calculate_

            % Collect Interest Rate data from 'Configuration' object
            irCurve = calcObj.configuration.csvFileContents.(fileName);

            % Get location of the header row for each block.
            % TODO Is BAS definitely always the marker for an item header?  Could also
            % use the number of columns or the type of data in the columns.
            nItems = numel(irCurve.identifiers);

            % Get tenor and values, by converting to numeric arrays, and set them in
            % the output structure. Do this item by item, because they might have 
            % different amounts of data in them.
            identifiers = irCurve.identifiers;
            itemLines   = irCurve.itemLines;
            tenors      = cell(nItems, 1);
            values      = cell(nItems, 1);

            for iItem = 1:nItems
                tenors{iItem} = cell2mat( irCurve.tenorDATA(itemLines(iItem, 1):itemLines(iItem, 2)) );
                values{iItem} = cell2mat( irCurve.valueDATA(itemLines(iItem, 1):itemLines(iItem, 2)) );
            end

            % Populate the collection
            obj.CurveMap = containers.Map;
            curves       = cell(numel(identifiers), 1);

            for iCurve = 1:length(curves)
                curves(iCurve) = {internalModel.Curve(...
                                    identifiers{iCurve},...
                                    tenors{iCurve},...
                                    values{iCurve}...
                                    )};

                 obj.CurveMap(identifiers{iCurve}) = curves{iCurve}; 
            end

        end % #CurveCollection


        function curve = findCurveByName(obj, name)
            %% findCurveByName
            % |curve = findCurveByName(obj, name)|
            % 
            % Find a Curve from the CurveCollection by it's name
            % 
            % Inputs:
            % 
            % * |name|  _char_
            % 
            % Outputs:
            % 
            % * |curve| _Curve_
            if isprop(obj, 'CurveMap')
                curve = obj.CurveMap(name);
            else
                disp(['Cannot find: ' name '. Has no CurveMap.']);
                curve = [];
            end

        end % #findCurveByName

    end

end
