%% DYNAMIC PROPERTY
%
% This class represents the values stored within the
% <DynamicProperty>
% <Property name="A"% type="B">C</Property>
% <DynamicProperty>
%
% <Property> tag

%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classdef DynamicProperty < handle & prursg.Engine.ICloneable
%% Properties
% *|[Name]|* - name attribute of property.
%
% *|[Type]|* - type can be either string or double.
%
% *|[Values]|* - value of property.
%
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties
        Name
        Type = 'string'
        Value
    end
    
    methods
        function obj = DynamicProperty(name, value, varargin)
            switch nargin
                case 0
                    ; % do nothing - default construction
                case 2
                    obj.Name = name;
                    obj.Value = value;
                case 3
                    obj.Name = name;
                    obj.Value = value;
                    
                    if strcmpi(varargin{1}, 'number')
                        obj.Type = 'number';
                    elseif strcmpi(varargin{1}, 'string')
                        obj.Type = 'string';
                    else
               			ex = MException('DynamicProperty:DynamicProperty',...
                            ['DynamicProperty does not support type "' char(varargin{1}) '". '...
							'Must be one of ''string'' or ''number''']);
               			throw(ex);
					end
                otherwise
               		ex = MException('DynamicProperty:DynamicProperty',...
                        ['Unexpected number "' nargin '" of arguments. ' ... 
						'Expecting DynamicProperty(name, value [, type])']);
               		throw(ex);
            end
        end
        
        function tf = eq(obj, obj2)
            tf = strcmpi(num2str(obj.Name), num2str(obj2.Name)) && ...
                 strcmpi(num2str(obj.Type), num2str(obj2.Type)) && ...
                 strcmpi(num2str(obj.Value), num2str(obj2.Value));
        end
        
        function tf = ne(obj, obj2)
            tf = ~obj.eq(obj2);
        end
        
        function newDynProp = Clone(obj)
            p = properties(obj);
            newDynProp = feval(class(obj));
            for ii = 1:length(obj)
                newDynPropObj = feval(class(obj));
                for i = 1:length(p)
                    newDynPropObj.(p{i}) = obj(ii).(p{i});
                end
                newDynProp(ii) = newDynPropObj;
            end
        end
    end
end
