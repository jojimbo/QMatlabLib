classdef HistoricalDataDaoFactory
    %HISTORICALDATADAOFACTORY 
    %   
    
    properties(Access=private)
        daoMap;
        defaultDaoName;
    end
    
    methods
        function obj = HistoricalDataDaoFactory()
            cm = prursg.Configuration.ConfigurationManager();
            obj.daoMap = cm.HistoricalDataDaoMap;
            obj.defaultDaoName = cm.DefaultDaoName;
        end
    
        function dao = Create(obj, varargin)
            dao = [];
            if isempty(obj.daoMap)
                ex = MException('HistoricalDataDaoFactory:Create', 'Internal map is empty.');
                throw(ex);
            end
            
            name = obj.defaultDaoName;
            
            if ~isempty(varargin) && ~isempty(varargin{1})
                name = varargin{1};
            end            
            
            if ~isKey(obj.daoMap, name)
                ex = MException('HistoricalDataDaoFactory:Create', ['The given name(' name ') is not found in the internal map.']);                
                throw(ex);
            end
            
            item = obj.daoMap(name);
            
            expression = ['dao = ' item.Class ';'];
            eval(expression);          
            
            propertyKeys = keys(item.Properties);
            if ~isempty(propertyKeys)
                for i = 1:length(propertyKeys)
                    expression = ['dao.' propertyKeys{i} ' = item.Properties(propertyKeys{i});'];
                    eval(expression);
                end            
            end
            
        end
    end
    
end

