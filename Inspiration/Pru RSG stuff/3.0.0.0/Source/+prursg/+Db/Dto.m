classdef Dto < handle
    %DTO Data Transfer Object
    
    properties (Access = 'protected')
        useFastInsert = true; % fastinsert is suitable for bulk inserts but slower in one row inserts
    end
    
    methods (Abstract)        
        obj = read(obj, connection)
        delete(obj, connection)
    end
    
    methods
        
        function tableName = getTableName(obj)             
            tableName = regexp(class(obj), '\.', 'split');
            tableName = tableName{end};
        end
        
        function sequenceName = getSequenceName(obj)
            sequenceName = [ obj.getTableName() '_sequence' ];
            sequenceName = sequenceName(1:min(31, end)); % max len of oracle object id            
        end
        
        % standard implementation basically maps between dto properties and
        % db table fields. Complicated Dto objects can override this method
        function result = insert(obj, dao)
            columns = obj.getTableColumnNames();
            data = obj.getTableRow();
            table = obj.getTableName();                        
            if obj.useFastInsert 
                dao.fastinsert(table, columns, data);
            else
                dao.slowinsert(connection, table, columns, data);   
            end
            result = true;
        end        

        % if object is already persisted return its PK or 0 (false)
        % oracle sequences start from 1.
        function id = exists(obj, dao) 
            id = 0;
        end

        
        function str = toString(obj)
            id = obj.getNaturalKey();
            if ~ischar(id)
                id = num2str(id);
            end
            str = [ class(obj) ' key ' id ];
        end
       
        function id = getNaturalKey(obj)
            p = getProperties(obj);
            id = obj.(p{1}.Name);
        end        
        
        function columns = getTableColumnNames(obj)
            p = getProperties(obj);
            columns = cell(1, numel(p));
            for i = 1:numel(p)
                columns(i) = { p{i}.Name };
            end
        end

        function row = getTableRow(obj)
            p = getProperties(obj);
            row = cell(1, numel(p));
            for i = 1:numel(p)
                row(i) = { obj.(p{i}.Name) };
            end            
        end        
        
    end
    
    methods (Static)
        % database toolbox gets out date fields out of Oracle as strings
        function t = toDate(dateStr)
            t = datenum(dateStr, 'yyyy-mm-dd HH:MM:SS');
        end 
        
        % Otherwise timestamps
        % read from database will not match the original timestamp written. 
        % and unit ests will not pass
        function out = floorToSecond(t)
            str = datestr(t, 'yyyy-mm-dd HH:MM:SS');
            out = datenum(str, 'yyyy-mm-dd HH:MM:SS');
        end
        
        function bytes = getBytes(blob)            
            bytes = blob.getBytes(1, blob.length());
            bytes = typecast(bytes', 'uint8');
        end
        
        function str = getString(blob)
            binary = blob.getBytes(1, blob.length());
            str = native2unicode(binary');            
        end
                
    end
    
    methods (Access = 'protected')
        
        function selectAndPopulateProperties(obj, connection, sqlSelect)
            q = exec(connection, sqlSelect);
            q = fetch(q);
            dbData = q.Data;
            %
            props = getProperties(obj);
            for i = 1:numel(props)
                obj.(props{i}.Name) = dbData{i};
            end            
            close(q);                                     
        end
        
    end
        
end

% return only the public properties of the Dto
function props = getProperties(obj)
    m = metaclass(obj);
    props = [];
    for i = 1:numel(m.Properties)
        p = m.Properties{i};
        if strcmp(p.SetAccess, 'public')
            props = [ props m.Properties(i) ]; %#ok<AGROW>
        end    
    end    
end

        
