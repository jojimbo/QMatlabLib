classdef DataFacadeFactory < handle
    %DBFACADEFACTORY Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods(Static)
        function facade = CreateFacade(inMemory)
            if(inMemory)
                facade = prursg.Cache.InMemoryFacade();
            else
                facade = prursg.Db.DbFacade();
            end
        end
        
        function riskFactor = CreateRiskFactor(inMemory)
            if(inMemory)
                riskFactor = prursg.Cache.risk_factor();
            else
                riskFactor = prursg.Db.risk_factor();
            end
        end
    end
    
end

