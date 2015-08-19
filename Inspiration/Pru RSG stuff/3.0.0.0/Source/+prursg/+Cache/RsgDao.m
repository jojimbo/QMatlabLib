classdef RsgDao
    
    properties
        RiskNameToIdMap
    end
    
    properties(SetAccess = 'private', GetAccess = 'public');
        data        
    end
    
    properties (Access = private)
        sqlScriptFolder = fullfile('+prursg', '+Db', '+Relational');
    end
    
    methods (Static)
        function yesNo = isempty(cursor)
            yesNo = strcmp(cursor.Data{1}, 'No Data');
        end
    end
        
    
    methods
        function obj = RsgDao(varargin)
            %obj.connection = database('c0224','RSG_JIMMY','RSG_JIMMY','oracle.jdbc.driver.OracleDriver' ...
            %                        ,'jdbc:oracle:thin:@c0224.riskcare.com:1521:');
            %get(obj.connection, 'AutoCommit')
            % Prudential's Oracle credentials
            try
                %CR161: Logic previously in this constructor not required for
                %in-memory mode
            catch ex
                disp(getReport(ex));
                rethrow(ex);
            end
        end
                
%         function close(obj)
%             close(obj.connection);            
%         end
%         
        function insert(obj, dto) 
            dto.insert(obj);
        end
        
        % bulk insert        
        function fastinsert(obj, table, columns, data)
            %CR161: Logic previously in this method not required for
            %in-memory mode
        end
        
        % bulk insert
        function slowinsert(obj, table, columns, data)
            %CR161: Logic previously in this method not required for
            %in-memory mode
        end        
        
        % return the PK if this object exists in db. 
        % Dto is expected to search by its NK
        function id = exists(obj, dto)
            id = dto.exists(obj.connection);
        end
        
        function dto = read(obj, dto)
            try 
                dto.read(obj.connection);            
            catch e 
                warning(e.message);
                fprintf('could not load object %s\n', dto.toString());
                dto = [];
            end
        end
        
        % optionaly return more than one identifier - useful for block
        % inserts
        function id = getNextId(obj, dto, varargin) 
            requiredNumberOfIdentifiers = 1;
            if numel(varargin) > 0
                requiredNumberOfIdentifiers = varargin{1};
            end            
            id = 1;
        end
                
    end % methods
    
end

function statements = loadStatements(sqlScriptFolder, scriptName)
    statements = fileread(fullfile(sqlScriptFolder, scriptName));
    statements = regexp(statements, ';', 'split');
end

function executeStatements(connection, statements)
    for i = 1:numel(statements)
        exec(connection, statements{i});
    end
end
