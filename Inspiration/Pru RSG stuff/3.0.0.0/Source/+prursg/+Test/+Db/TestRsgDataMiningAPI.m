function TestRsgDataMiningAPI()
    clc;
    clear;
    tic;
    
    %profile on;
            
    db = prursg.Db.DbFacade();
    db.dao.dropTables();

    %{
    %db.dao.createTables();

    det = db.getRiskFactorDeterministicValues('TST_nycvol', 'base tgr0_22Mar2011_14:33:52')
    
    stoch = db.getRiskFactorStochasticValues('TST_nycvol', 'base tgr0_22Mar2011_14:33:52')
    %stoch.values{1}
    %}
    
    db.commitTransaction();
    db.dao.close();
    toc;
   % profile viewer;
end

function dump(e)
    e;
    for i = 1:numel(e)
        e.stack(i)
    end
end









