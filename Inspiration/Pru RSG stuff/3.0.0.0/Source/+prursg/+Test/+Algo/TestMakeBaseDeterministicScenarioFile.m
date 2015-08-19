function TestMakeBaseDeterministicScenarioFile()
    import prursg.Test.Algo.*;
    clc;
    clear;
    
    risks = AlgoTestsFixture.makeRisks();
    timesteps = AlgoTestsFixture.prepareBaseTZeroScenarioTimesteps();
    % a base t=0 scenario
    str = prursg.Algo.makeBaseDeterministicScenarioFile( ...
        AlgoTestsFixture.getBaseCurrency(), AlgoTestsFixture.getSessionDate() ...
       , risks, timesteps ...
    );
    disp(str);    
    %   
    fid = fopen(fullfile('outputs', AlgoTestsFixture.getDeterministicScenarioFileName()), 'w');
    fwrite(fid, str);
    ST = fclose(fid);    
end

