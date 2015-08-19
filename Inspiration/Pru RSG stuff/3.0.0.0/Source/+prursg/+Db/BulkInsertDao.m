classdef BulkInsertDao < handle
    
    properties (Access = private)
        dao % reference to the workhorse RsgDao
        objectIds;  
        currentId;
        %        
        dbColumnNames; % map<tableName, columnNames>
        dbRows;        % map<tableName, accumulatedData>
    end
                
    methods
        function obj = BulkInsertDao(rsgDao, dto, nObjects)
            obj.dao = rsgDao;
            obj.objectIds = rsgDao.getNextId(dto, nObjects);
            obj.currentId = 1;
            %
            obj.dbColumnNames = prursg.Engine.DefaultValueMap();  
            obj.dbRows = prursg.Engine.DefaultValueMap();
            
        end
        
        function id = getNextId(obj, dto) 
            if obj.currentId > numel(obj.objectIds)
                id = obj.dao.getNextId(dto);
            else
                id = obj.objectIds(obj.currentId);
                obj.currentId = obj.currentId + 1;
            end
        end
        
        function insert(obj, dto) 
            dto.insert(obj);
        end
        
        % do not send data to database - rather accumulate for later
        function fastinsert(obj, table, columns, data)
            obj.slowinsert(table, columns, data);
        end
        
        % do not send data to database - rather accumulate for later bulkInsert      
        function slowinsert(obj, table, columns, data)
            obj.dbColumnNames(table) = columns;
            tableRows = obj.dbRows(table);
            tableRows = [ tableRows; data ];
            obj.dbRows(table) = tableRows;            
        end
            
        function bulkInsert(obj)
            tables = keys(obj.dbRows);
            for i = 1:numel(tables)                
                obj.dao.fastinsert( ...
                    tables{i}, obj.dbColumnNames(tables{i}), obj.dbRows(tables{i}) ...
                );
            end                                   
        end
        
    end
    
end
