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
            riskNameToIdMap = prursg.Cache.risk_factor.makeRiskNameToIdResolver(dao);
            listOfIds = zeros(1, numel(risks));
            for i = 1:numel(risks)
                listOfIds(i) = riskNameToIdMap(risks(i).name);
            end
        end
        
        function resolver = makeRiskNameToIdResolver(dao)
            resolver = dao.RiskNameToIdMap;
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
            %CR161: Logic previously in this method not required for
            %in-memory mode
            id = 0;
        end
        
        function delete(obj, connection)
            %CR161: Logic previously in this method not required for
            %in-memory mode
        end
        
        % search by natural key
        function obj = read(obj, connection)
            %CR161: Logic previously in this method not required for
            %in-memory mode
        end
                                   
        function id = getNaturalKey(obj)
            id = sprintf('name: %s id: %d', obj.risk_factor_name, obj.risk_factor_id);
        end
    
    end
end

