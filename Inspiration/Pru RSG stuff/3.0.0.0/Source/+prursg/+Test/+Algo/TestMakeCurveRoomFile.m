function TestMakeBaseDeterministicScenarioFile()
    import prursg.Test.Algo.*;
    clc;
    clear;
    
    risks = AlgoTestsFixture.makeRisks();
    timesteps = AlgoTestsFixture.prepareBaseTZeroScenarioTimesteps();
    % a base t=0 scenario
    debug = 0;
    str = prursg.Algo.makeCurveRoomFile( ...
        AlgoTestsFixture.getBaseCurrency(), AlgoTestsFixture.getSessionDate() ...
       , risks, timesteps, debug ...
    );
    %disp(str);    
    %   
    fid = fopen(fullfile('outputs', AlgoTestsFixture.getCurveRoomFileName()), 'w');
    fwrite(fid, str);
    fclose(fid);    
end

