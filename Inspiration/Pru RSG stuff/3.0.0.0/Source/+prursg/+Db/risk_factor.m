classdef risk_factor < prursg.Db.Dto
    
    properties
        risk_factor_id 
        risk_factor_name
        risk_factor_currency
        risk_family
        pru_type
        algo_type
        pru_group
    end
    
    methods (Static)
        
        % return the list of risk_factor.risk_factor_id identifiers
        % for each risk factor in risks list. The ordering of listOfIds
        % follows the order of risks
        function listOfIds = getRiskFactorIds(dao, risks)
            nameToId = prursg.Db.risk_factor.makeRiskNameToIdResolver(dao);
            listOfIds = zeros(1, numel(risks));
            for i = 1:numel(risks)
                listOfIds(i) = nameToId(risks(i).name);
            end
        end
        
        function resolver = makeRiskNameToIdResolver(dao)
            resolver = containers.Map();
            sql = 'select risk_factor_name, risk_factor_id from risk_factor';
            data = dao.select(sql);
            for i = 1:size(data, 1)
                resolver(data{i, 1}) = data{i, 2};
            end            
        end
        function risk = getRiskFactorByName(dao, riskName)
            risk = prursg.Db.risk_factor();
            risk.risk_factor_name = riskName;
            risk = dao.read(risk);            
        end
        
    end
    
    methods
        
        function obj = risk_factor(varargin)
            if numel(varargin) == 1
                obj.populate(varargin{1});
            end
        end
           
        function obj = populate(obj, risk)
            % populate all fields but the db primary key
            obj.risk_factor_name = risk.name;
            obj.risk_factor_currency = risk.currency;
            obj.risk_family = risk.risk_family;
            obj.pru_type = risk.pru_type;
            obj.algo_type = risk.algo_type;
            obj.pru_group = risk.pru_group;                
        end
                
        function id = exists(obj, dao) 
            sql = sprintf('select risk_factor_id from %s where risk_factor_name = ''%s''', ...
                          obj.getTableName(), obj.risk_factor_name ...
            );
            data = dao.select(sql);
            id = 0;
            if numel(data) > 0 
                id = data{1};
            end
        end
        
        function delete(obj, connection)
            q = exec(connection, ...
                sprintf('delete from % where risk_factor_name=''%s''', obj.getTableName(), obj.risk_factor_name) ...
            );
            close(q);
        end
        
        % search by natural key
        function obj = read(obj, connection)
            sqlSelect = sprintf('select * FROM %s where risk_factor_name=''%s''', obj.getTableName(), obj.risk_factor_name);
            obj.selectAndPopulateProperties(connection, sqlSelect)
        end
                                   
        function id = getNaturalKey(obj)
            id = sprintf('name: %s id: %d', obj.risk_factor_name, obj.risk_factor_id);
        end
    
    end
end

