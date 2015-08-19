%% DATA SEIES OBJECT  
%
% *The DataSeries object is the main container of time series data in the
% RSG. The risk factor values for a given date could be a HyperCube having
% one of the following number of dimensions
% 0d - stock index, FX rate
% 1d - yield curve
% 2d - volatility surface 
% 3d - swaption vola cube
%
% The ordering of the dimensions follows the ordering of the Axis
% vector.* The Axis object describes the name and possible values of a 
% dimension within a dataset described by a DataSeries object.An
% instansiated DataSeries object has as its property an array of
% instantiated Axis objects.

%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef DataSeries < dynamicprops & prursg.Engine.ICloneable

%% Properties
% *|[Name]|* - DataSeries name. SetAccess is private.
%
% *|[dates]|* - Cell array of datenums.
%
% *|[axes]|* - Ordered vector of Axis objects, one such object per 
% dimension in the HyperCube.
%
% *|[values]|* - cell array of HyperCubes. values{i} gives the HyperCube 
% for dates(i).
%
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties
        Status
        Purpose
        Name
        dates 
        effectiveDates
        axes 
        values
    end
    
    properties(Access = private)
        dynamicProperties
    end
        
%% Methods
% *1) |[getData]|* - Returns [data dates] given specific axis IDs on each 
% dimension. Eg. [1,1,3].
%
% *2) |[getDataByName]|* - As above by by Name.
%
% *3) |[getSize]|* - Returns the dimensionality of the data.
% 
% *4) |[AddReplaceDynamicProperty(obj, DynamcicProperty)]| - Adds a new
% DynamicProperty to the dynamicProperties collection
%
% *5) |[GetDynamicProperties]| - returns the collection of
% DynamicProperties held in the dynamicProperties property.
%
% *6) |[SetDynamicProperties(obj, properties)]| - Sets properties to the
% property, dynamicProperty, assigning the properties Name, Type and Value
% of each DynamicProperty.
%
% *7) |[HasDynamicProperty(obj, name)]| - Returns true if the dynamic 
% property exists, false otherwise.
% 
% *8) |[AddDynamicProperty(obj, name, value, type)]| - Adds the specified 
% dynamic property to the object. Throws an exception if it already exists 
% or if attempting to add a dynamic property with the % same name as a 
% class property.
%
% *9) |[RemoveDynamicProperties(obj, name)]| - Removes the specified 
% dynamic property. Returns true if the property was removed,
% false otherwise.
%
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    
    methods (Access = private)
        function RemoveAllDynamicProperties(obj)
            obj.dynamicProperties = [];
            allProperties = properties(obj);
            if ~isempty(allProperties)
                for i = 1:length(allProperties)
                    p = allProperties{i};
                    propertyInfo = obj.findprop(p);
                    if isempty(propertyInfo.DefiningClass) % dynamic property
                        delete(propertyInfo);
                    end
                end
            end
        end
    end
    
    methods
        function properties =  GetDynamicProperties(obj)            
            properties = obj.dynamicProperties;
        end
                
        function SetDynamicProperties(obj, properties)
            obj.RemoveAllDynamicProperties();
            obj.dynamicProperties = properties;
             if ~isempty(properties)
                for ii = 1:length(properties)
                    mp = obj.findprop(properties(ii).Name);
                    
                    if isempty(mp)
                        dynaProp = obj.addprop(properties(ii).Name);
                                               
                        dynaProp.SetObservable = true;
                        addlistener(obj, dynaProp, 'PostSet', @obj.handlePostPropEvents);
                    end
                    
                    %type = properties(ii).Type;
                    value = properties(ii).Value;
                    eval(['obj.' properties(ii).Name '= value;']);
                end
            end
        end
        
        function result = HasDynamicProperty(obj, name)           
           result = false;
           pInfo = obj.findprop(name);
           if (isempty(pInfo))
             return;
           end
           
           if isempty(pInfo.DefiningClass) 
             % dynamic property
             result = true;
           end
        end
        
        function AddDynamicProperty(obj, name, value, varargin)
           if (obj.HasDynamicProperty(name))
               % This is regarded as an error. Invoke HasDynamicProperty to 
               % test for existence and remove the property if necessary to 
               % avoid an exception being thrown
               ex = MException('DataSeries:AddDynamicProperty', ['Dynamic property "' name '" already exists!']);
               throw(ex);
           end
           
           %%%%%%%
           % Add to the object 
           %%%%%%%%
            
           % Add the dyn prop to the object. if 'name' is a class property 
           % matlab will generate an error when calling addprop
           dynaProp = obj.addprop(name);   
           eval(['obj.' name '= value;']);
                      
           % Set the listender
           dynaProp.SetObservable = true;
           addlistener(obj, dynaProp, 'PostSet', @obj.handlePostPropEvents); 
           
           %%%%%%%%
           % Add to internal representation
           %%%%%%%%
           
           % first assert that the property is not in the internal
	       % representation. If it is then we're in an inconsistent 
	       % state
	   	   for n = 1:length(obj.dynamicProperties)
               assert(~strcmp(obj.dynamicProperties(n).Name, name))
           end
           
	       % Add the dyn property to the DSO internal representation.
           % This is required to support type information and for
           % clone to work properly
           obj.dynamicProperties = [obj.dynamicProperties prursg.Engine.DynamicProperty(name, value, varargin{:})];
        end
        
        function result = RemoveDynamicProperty(obj, name)
            if (~obj.HasDynamicProperty(name))
                % Nothng to do - this is not an error
                % Just indicate that nothing was removed
                result = false;
                return;
            end
                    
            %%%%%%%%
            % Remove from internal representation
            %%%%%%%%
            
            % if empty we are in an inconsistent state as HasDynamicProperty 
            % tests the object
            assert(~isempty(obj.dynamicProperties)); 
            
            found = false;
            for n = 1:length(obj.dynamicProperties)
                if strcmp(obj.dynamicProperties(n).Name, name)
                    obj.dynamicProperties(n) = [];%#ok
                    found = true;
                    break;
                end
            end
            
            % if not found we are in an inconsistent state as HasDynamicProperty 
            % tests the object
            assert(true == found);
            
            %%%%%%%%
            % Remove from the object
            %%%%%%%%
            delete(obj.findprop(name));
            
            % Indicate that there was a removal
            result = true;
        end
        
        function newObj = Clone(obj)
            newObj = prursg.Engine.DataSeries();
            newObj.Name = obj.Name;
            newObj.Status = obj.Status;
            newObj.Purpose = obj.Purpose;
            if (~isempty(obj.GetDynamicProperties()))
                properties = obj.GetDynamicProperties().Clone();
                newObj.SetDynamicProperties(properties);
            end
            newObj.dates = obj.dates;
            newObj.effectiveDates = obj.effectiveDates;
            newObj.values = obj.values;
            
            if ~isempty(obj.axes)
                newObj.axes = prursg.Engine.Axis.empty();    
                for i = 1:length(obj.axes)
                    newObj.axes(end + 1) = obj.axes(i).Clone();
                end
            end
        end
    end
    
    methods (Static)
        function handlePostPropEvents(src, evnt)
            for ii = 1:length(evnt.AffectedObject.dynamicProperties)
                if (strcmp(evnt.AffectedObject.dynamicProperties(ii).Name, src.Name))
                    %dynamicPropVal = [];
                    dynamicPropVal =  evalc(['evnt.AffectedObject.' src.Name]);

                    if (~isempty(dynamicPropVal))
                        if (~ischar(dynamicPropVal) && ~strcmp(class(dynamicPropVal), 'double'))
                            err = MException('RSGBootstrap:UnsupportedDataType', ...
                                ['RSGBootstrap Error: The value of the dynamic property, of type ''' ...
                                class(dynamicPropVal) ''', is invalid as it is not a string or numeric!']);
                            throw(err);
                        end
                    end
                    
                    evalc(['evnt.AffectedObject.dynamicProperties(ii).Value = ' 'evnt.AffectedObject.' src.Name]);
                end
            end
        end
    end
    
    methods

        function [data dates] = getData(obj,varargin)
            % request data for specific index on each dimension, returning
            % an array of data and corresponding dates
            numDim = length(obj.axes);
            data = zeros(length(obj.dates),1);
            for i = 1:length(obj.dates)
                switch numDim
                    case 0
                        data(i) = obj.values{i};
                    case 1
                        data(i) = obj.values{i}(varargin{1});
                    case 2
                        data(i) = obj.values{i}(varargin{1},varargin{2});
                end
            end
            dates = obj.dates;
        end
        
        function [data dates] = getDataByName(obj,varargin)
            % request data for specific values on each dimension, returning
            % an array of data and corresponding dates
            numDim = length(obj.axes);
            for i = 1:numDim
                varargin{i} = obj.resolveIndex(obj.axes(i), varargin{i});
            end
            data = zeros(length(obj.dates),1);
            for i = 1:length(obj.dates)
                switch numDim
                    case 0
                        data(i) = obj.values{i};
                    case 1
                        data(i) = obj.values{i}(varargin{1});
                    case 2
                        data(i) = obj.values{i}(varargin{1},varargin{2});
                    case 3
                        data(i) = obj.values{i}(varargin{1},varargin{2},varargin{3});
                end
            end
            dates = obj.dates;
        end
        
        function index = resolveIndex(obj, axisObject, axisItem)
            % resolve an axis value into axis ID
            index = 0;
            cont = true;
            j = 0;
            while cont == true
                j = j + 1;
                if axisObject.values(j) == axisItem
                    cont = false;
                    index = j;
                end
            end
            if index == 0
                disp ('no such value exist along dimension axis');
            end
                
        end
        
        % dataseries has a cell array of hypercubes
        function algoRows = serialise(obj)
            % serialise the hyper cubes into Algo format vector
            algoRows = [];
            for i = 1:numel(obj.values)
                algoRows = [ algoRows; prursg.Engine.HyperCube.serialise(obj.values{i})]; %#ok<AGROW>
            end
        end
        
        function data = getFlatData(obj,timestep)
            % flatten hypercube into data for Pru aggregator convertor,
            % note ordering of axis is retained here
            dataCube = obj.values{timestep};
            switch length(obj.axes)
                case 0
                    data = dataCube;
                
                case 1
                    k = 0;
                    for i1 = 1:length(obj.axes(1).values)
                        k = k + 1;
                        data(k) = dataCube(i1);
                    end
                
                case 2
                    k = 0;
                    for i1 = 1:length(obj.axes(1).values)
                        for i2 = 1:length(obj.axes(2).values)
                            k = k + 1;
                            data(k) = dataCube(i1,i2);
                        end
                    end
                    
                case 3
                    k = 0;
                    for i1 = 1:length(obj.axes(1).values)
                        for i2 = 1:length(obj.axes(2).values)
                            for i3 = 1:length(obj.axes(3).values)
                                k = k + 1;
                                data(k) = dataCube(i1,i2,i3);
                            end
                        end
                    end
            end
        end
        
        function nSize = getSize(obj)
            % get number of entries in each hypercube, equal to product of
            % number of possible values in each axis
            nSize = 1;
            for i = 1:length(obj.axes)
                nSize = nSize * length(obj.axes(i).values);
            end
        end
        
        function names = getExpandedNames(obj)
            % get flat list containing all possible combinations of each
            % dimension
            nDim = length(obj.axes);
            names = cell(obj.getSize(),1);
            switch nDim
                case 0

                case 1
                    k = 0;
                    for i = 1:length(obj.axes(1).values)
                        k = k + 1;
                        names{k} = ['_' num2str(obj.axes(1).values(i))];
                    end
                case 2
                    k = 0;
                    for i1 = 1:length(obj.axes(1).values)
                        for i2 = 1:length(obj.axes(2).values)
                            k = k + 1;
                            names{k} = [...
                                '_' num2str(obj.axes(1).values(i1)) ...
                                '_' num2str(obj.axes(2).values(i2))];
                        end
                    end
                case 3
                    k = 0;
                    for i1 = 1:length(obj.axes(1).values)
                        for i2 = 1:length(obj.axes(2).values)
                            for i3 = 1:length(obj.axes(3).values)
                                k = k + 1;
                                names{k} = [...
                                    '_' num2str(obj.axes(1).values(i1)) ...
                                    '_' num2str(obj.axes(2).values(i2)) ...
                                    '_' num2str(obj.axes(3).values(i3))];
                            end
                        end
                    end
            end
        end
    end
    
    methods
        function tf = eq(obj, obj2)
            if CompareClassProperties(obj, obj2) ...
                && CompareDynamicProperties(obj, obj2) ... 
                && CompareAxes(obj.axes, obj2.axes) ...
                && CompareDates(obj.effectiveDates, obj2.effectiveDates) ...
                && CompareDates(obj.dates, obj2.dates) ...
                && CompareValues(obj.values, obj2.values)
             
                tf = true;
            else
                tf = false;
            end
        end
        
        function tf = ne(obj, obj2)
            tf = ~obj.eq(obj2);
        end
    end
end

function tf = CompareClassProperties(obj, obj2)
    tf = strcmpi(num2str(obj.Name), num2str(obj2.Name)) && ...
         strcmpi(num2str(obj.Status), num2str(obj2.Status)) && ...
         strcmpi(num2str(obj.Purpose), num2str(obj2.Purpose));
end

function tf = CompareDynamicProperties(obj, obj2)
    tf = true;
    p1 = obj.GetDynamicProperties();
    p2 = obj2.GetDynamicProperties();

    if isempty(p1) && ~isempty(p2)
        tf = false;
        return
    elseif ~isempty(p1) && isempty(p2)
        tf = false;
        return
    elseif ~isempty(p1) && ~isempty(p2) && length(p1) ~= length(p2)
        tf = false;
        return
    elseif ~isempty(p1) && ~isempty(p2) && length(p1) == length(p2)
        for i = 1:length(p1)
            index = find(cell2mat(arrayfun(@(x)strcmpi(x.Name, p1(i).Name), p2, 'UniformOutput', false)));
            if isempty(index)
                tf = false;
                return;
            end
            if p1(i) ~= p2(index)
                tf = false;
                return;
            end
        end
    end
end

function tf = CompareDates(dates1, dates2)
    tf = true;
    if isempty(dates1) && ~isempty(dates2)
        tf = false;
        return;
    elseif ~isempty(dates1) && isempty(dates2)
        tf = false;
        return;
     elseif ~isempty(dates1) && ~isempty(dates2) && length(dates1) ~= length(dates2)
        tf = false;
        return;        
    elseif ~isempty(dates1) && ~isempty(dates2) && length(dates1) == length(dates2)
        for i = 1:length(dates1)
            if datenum(dates1(i)) ~= datenum(dates2(i))
                tf = false;
                return;
            end
        end
    end
end

function tf = CompareValues(values1, values2)
    tf = true;
    if isempty(values1) && ~isempty(values2)
        tf = false;
        return;
    elseif ~isempty(values1) && isempty(values2)
        tf = false;
        return;
     elseif ~isempty(values1) && ~isempty(values2) && length(values1) ~= length(values2)
        tf = false;
        return;        
    elseif ~isempty(values1) && ~isempty(values2) && length(values1) == length(values2)
        for i = 1:length(values1)
            if values1{i} ~= values2{i}
                tf = false;
                return;
            end
        end
    end
end

function tf = CompareAxes(axes1, axes2)
    tf = true;
    if isempty(axes1) && ~isempty(axes2)
        tf = false;
        return;
    elseif ~isempty(axes1) && isempty(axes2)
        tf = false;
        return;
     elseif ~isempty(axes1) && ~isempty(axes2) && length(axes1) ~= length(axes2)
        tf = false;
        return;        
    elseif ~isempty(axes1) && ~isempty(axes2) && length(axes1) == length(axes2)
        for i = 1:length(axes1)
            if axes1(i) ~= axes2(i)
                tf = false;
                return;
            end
        end
    end
end
