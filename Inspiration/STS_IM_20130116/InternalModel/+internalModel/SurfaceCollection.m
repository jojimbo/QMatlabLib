%% SurfaceCollection
% value class

classdef SurfaceCollection
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
    % * |this = SurfaceCollection(curveFile)|     _constructor_
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
        function obj = SurfaceCollection(calcObj, fileName)
            %% SurfaceCollection
            % |obj = SurfaceCollection(calcObj, fileName)|
            %
            % Inputs:
            % * calcObj     _Calculate_
            % * fileName    _char_
            
            % Collect Implied Vol data from 'Configuration' object
            IVSurfaces = calcObj.configuration.csvFileContents.(fileName);
            
            % Get location of the header row for each block.
            % TODO Is BAS definitely always the marker for an item header?  Could also
            % use the number of columns or the type of data in the columns.
            nItems = numel(IVSurfaces.identifiers);
            
            % Get moneyness, tenor and values, by converting to numeric arrays, and set them in
            % the output structure. Do this item by item, because they might have
            % different amounts of data in them.
            identifiers         = IVSurfaces.identifiers;
            itemLines           = IVSurfaces.itemLines;
            moneynesses         = cell(nItems, 1);
            terms               = cell(nItems, 1);
            values              = cell(nItems, 1);
            
            for iItem = 1:nItems
                moneynesses{iItem}  = cell2mat( IVSurfaces.moneynessDATA(itemLines(iItem, 1):itemLines(iItem, 2)) );
                terms{iItem}        = cell2mat( IVSurfaces.termDATA(itemLines(iItem, 1):itemLines(iItem, 2)) );
                values{iItem}       = cell2mat( IVSurfaces.valueDATA(itemLines(iItem, 1):itemLines(iItem, 2)) );
            end
            
            % Populate the collection
            obj.CurveMap = containers.Map;
            curves       = cell(numel(identifiers), 1);
            
            % Data consistency check
            for iCurve = 1:length(curves)
                m = moneynesses{iCurve};
                t = terms{iCurve};
                unique_m = unique(m);
                unique_t = unique(t);
                if numel(t)/numel(unique_t) ~= numel(unique_m)
                    error('STS_CM:SurfaceCollection', ...
                        ['Vol Surface for ' identifiers{iCurve} ' not complete, ' ...
                        'inspect file ' fileName]);
                elseif numel(m)/numel(unique_m) ~= numel(unique_t)
                    error('STS_CM:SurfaceCollection', ...
                        ['Vol Surface for ' identifiers{iCurve} ' not complete, ' ...
                        'inspect file ' fileName]);
                else
                    % Create all the IVSurfaces
                    % We transform the data into a 2D array
                    val = [];
                    v = values{iCurve};
                    for i=1:(numel(t)/numel(unique_t))
                        val = [val, v( (1+numel(unique_t)*(i-1)):(i*numel(unique_t)) )];
                    end
                    curves(iCurve) = {internalModel.Surface(...
                        identifiers{iCurve},...
                        unique_m,...
                        unique_t,...
                        val...
                        )};
                    obj.CurveMap(identifiers{iCurve}) = curves{iCurve};
                    continue
                end
            end
            
%             % Create all the IVSurfaces
%             for iCurve = 1:length(curves)
%                 curves(iCurve) = {internalModel.Surface(...
%                     identifiers{iCurve},...
%                     moneynesses{iCurve},...
%                     terms{iCurve},...
%                     values{iCurve}...
%                     )};
%                 obj.CurveMap(identifiers{iCurve}) = curves{iCurve};
%             end
%                         
        end % #SurfaceCollection
        
        
        function curve = findCurveByName(obj, name)
            %% findCurveByName
            % |curve = findCurveByName(obj, name)|
            %
            % Find a Curve from the SurfaceCollection by it's name
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
