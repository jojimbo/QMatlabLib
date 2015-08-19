classdef RsgDao
    
    properties(SetAccess = 'private', GetAccess = 'public');
        connection; % database toolbox connection object   
        connectionInfo;
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
            import prursg.Configuration.*;
            try
                cm = ConfigurationManager();
                dbSetting = cm.ConnectionStrings(cm.AppSettings('DefaultDB'));
                obj.connectionInfo = struct('url', dbSetting.Url, 'username', dbSetting.UserName, 'password', dbSetting.Password);
                obj.connection = database(dbSetting.DatabaseName,dbSetting.UserName, dbSetting.Password,...
                'oracle.jdbc.driver.OracleDriver', dbSetting.Url);
                set(obj.connection, 'AutoCommit', 'on');
                if numel(varargin) > 0
                    obj.sqlScriptFolder = fullfile('+prursg', '+Db', '+Blob');
                end
            catch ex
                disp(getReport(ex));
                rethrow(ex);
            end
        end
                
        function close(obj)
            close(obj.connection);            
        end
        
        function insert(obj, dto) 
            dto.insert(obj);
        end
        
        % bulk insert        
        function fastinsert(obj, table, columns, data)
            prursg.Db.rsg_fastinsert(obj.connection, table, columns, data); %support for binary double
        end
        
        % bulk insert
        function slowinsert(obj, table, columns, data)
            insert(obj.connection, table, columns, data); % no support for oracle's binary double
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
        
        function delete(obj, dto)
            dto.delete(obj.connection);
        end
        
        
        % optionaly return more than one identifier - useful for block
        % inserts
        function id = getNextId(obj, dto, varargin) 
            requiredNumberOfIdentifiers = 1;
            if numel(varargin) > 0
                requiredNumberOfIdentifiers = varargin{1};
            end            
            sql = sprintf('select %s.nextval from dual connect by level <= %d', ...
                           dto.getSequenceName(), requiredNumberOfIdentifiers);                                   
            id = obj.select(sql);
            id = cell2mat(id);
        end
        
        function resultset = select(obj, selectStatement)
            resultset = {};
            q = exec(obj.connection, selectStatement);
            q = fetch(q);
            if ~obj.isempty(q)
                resultset = q.Data;
            end
            close(q);            
        end
        
        function createTables(obj)
            executeStatements(obj.connection, loadStatements(obj.sqlScriptFolder, 'create_schema.sql'));
        end
        
        function dropTables(obj)
            executeStatements(obj.connection, loadStatements(obj.sqlScriptFolder, 'drop_schema.sql'));
        end
        
        function recreateMdsTables(obj)
            
            import prursg.Configuration.*;
            try
                cm = ConfigurationManager();
                dbSetting = cm.ConnectionStrings('MDS');                
                con = database(dbSetting.DatabaseName,dbSetting.UserName, dbSetting.Password,...
                'oracle.jdbc.driver.OracleDriver', dbSetting.Url);
                set(con, 'AutoCommit', 'on');                
                executeStatements(con, loadStatements(obj.sqlScriptFolder, 'MDS.sql'));
            catch ex
                disp(getReport(ex));
                rethrow(ex);
            end            
            
        end
        
        function beginTransaction(obj)
            set(obj.connection, 'AutoCommit', 'off');            
        end
        
        function commitTransaction(obj)
            commit(obj.connection);
        end
        
        function rollbackTransaction(obj)
            rollback(obj.connection);
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
