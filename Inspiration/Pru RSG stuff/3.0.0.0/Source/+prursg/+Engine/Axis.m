classdef Axis < handle & prursg.Engine.ICloneable
    %AXIS represents a named dimension in a HyperCube
    % examples: Moneyness, Expiration, Underlying Term etc
    % 
    % example from the XML file:
    % first dimension is "moneyness", second "term", third "tenor"
    %<risk name="TST_nycvol">
    %   <v moneyness="100" term="5" tenor="10">0.218</v> 
    %   <v moneyness="100" term="5" tenor="20">0.194</v> 
    %   <v moneyness="100" term="5" tenor="30">0.193</v> 
    %   ...
    %</risk>

    properties
        Scale
        Index
        title % String: "Moneyness", "Expiration", "Underlying Term" as taken from XML model file
        values % cell array . Example: { 0.7, 1, 1.3 } for moneyness
    end
    
    properties (Access = private)
        valuesMap; % facilitates the deserialisation from xml
    end
    
    methods (Static)
        % sometimes matlab's isequal does not work on axis objects. why?
        %
        % implementation assumes empty axis == empty axis
        function yesNo = areEqual(one, other)
            yesNo = isempty(one) && isempty(other) ...
                || (isequal(class(one), class(other)) ...
                 && areArrayEqual(one, other)); 
        end
        
    end
        
    methods        
        function obj = Axis(varargin)
            obj.Scale = prursg.Engine.AxisScale.Year;
            obj.valuesMap = containers.Map('KeyType', 'char', 'ValueType', 'any');                         
            if(numel(varargin) > 0)
                obj.title = varargin{1};
                assert(ischar(obj.title), 'axis title must be char type');
            end
            if(numel(varargin) > 1)
                obj.values = varargin{2};
                assert(isfloat(obj.values), 'axis values must be double type');
            end            
        end
        
        function wasAdded = addValue(obj, value)
            % a set like behaviour, a value is appended at the end of axis
            % values, only if it has not been appended so far. Xml
            % deserialisation.
            alreadyAdded = isKey(obj.valuesMap, num2str(value));
            if ~alreadyAdded
                obj.values{end + 1} = value;
                obj.valuesMap(num2str(value)) = value;
            end
            wasAdded = ~alreadyAdded;
        end
                
        function tf = eq(obj, obj2)            
            tf = strcmpi(num2str(obj.title), num2str(obj2.title)); 
            if ~tf
                return;
            end
            
            tf = CompareValues(obj.values, obj2.values);            
        end
        
        function tf = ne(obj, obj2)
            tf = ~obj.eq(obj2);
        end
    
        function disp(obj)
            for i = 1 :  length(obj)
                disp(['Axis title: ' obj(i).title]);
                disp(['Axis values: ']);
                if ~isempty(obj(i).values)                   
                    disp([ cellfun(@(x)(num2str(x)), obj(i).values, 'UniformOutput', false)]);
                end
            end
        end
                        
    end    
        
    methods
        function newObj = Clone(obj)
            newObj = prursg.Engine.Axis();
            newObj.Index = obj.Index;
            newObj.title = obj.title;
            for i = 1:length(obj.values)
                newObj.addValue(obj.values{i});
            end                
        end
        
        function newObj = Convert(obj)
            newObj = prursg.Engine.Axis();
            newObj.Index = obj.Index;
            newObj.title = obj.title;
            
            newValues = {};
            areAllNumericValues = true;
            for i = 1:length(obj.values)
                oldValue = obj.values{i};
                newValue = oldValue;
                
                if strcmpi(class(oldValue), 'char')
                    if regexpi(oldValue, '[0-9]+[dwmy]')                    
                        period = lower(oldValue(end));
                        oldValue(end) = [];
                        numericValue = str2num(oldValue);
                        switch (period)
                            case 'd'
                                newValue = numericValue / 360;
                            case 'w'
                                newValue = numericValue / 52;
                            case 'm'
                                newValue = numericValue / 12;
                            case 'y'
                                newValue = numericValue;
                        end
                    elseif isempty(oldValue) || ~isempty(str2num(oldValue))
                        newValue = str2num(oldValue);
                    else
                        areAllNumericValues = areAllNumericValues & false;
                        newValue = oldValue;                    
                    end
                else
                    newValue = oldValue;
                end
                
                newValues{end + 1} = newValue;                                
                
            end 
            
            for i = 1:length(newValues)
                if areAllNumericValues
                    newObj.addValue(newValues{i});
                else
                    newObj.addValue(num2str(newValues{i}));
                end
            end
                                       
        end
    end
        
        
end

% private methods
function yesNo = areArrayEqual(one, other)
    yesNo = isequal(size(one), size(other));
    if yesNo
        for i = 1:numel(one)
            yesNo = yesNo ... 
                    && isequal(one(i).title, other(i).title) ...
                    && isequal(one(i).values, other(i).values);                
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
            if ~strcmpi(num2str(values1{i}), num2str(values2{i}))
                tf = false;
                return;
            end
        end
    end
end
