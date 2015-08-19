function generateStocasticFile(srisks, scenarioSet, basecurrency, sess_date, chunks, scenarioType, algoFilesPath)
%GENERATESTOCATICFILE converts risk into Aglo risk called AlgoCurve
%   srisk = list of RiskDrivers
%   scenarios = list of timesteps(deterministic scenarios)
%   noRiskScenario = no risk scenario
%   basecurrency = basecurrency
%   sess_date = the earlist timestep (session date)
%   chunks = cell array of risk driver stocastic values

    % retrieve scenario value format.
    SCENARIO_VALUE_FORMAT = prursg.Util.ConfigurationUtil.GetScenarioValueNumberFormat();
    
    risks=srisks;
   
    detScenarios = scenarioSet.getDeterministicScenarios();
    baseScenario = scenarioSet.getBaseScenario();
    shockScenario = scenarioSet.getShockedBaseScenario();
    noRiskScenario = scenarioSet.noRiskScenario;
    stoScenarios = scenarioSet.getStochasticScenarios();
    
    if ~isempty(shockScenario)
        baseScenario = shockScenario;
    end
    scenType=scenarioType;
    if(strfind(stoScenarios(1).name ,'++BB' ))
        scenType=4;
    end

    algoCurves = prursg.Algo.AlgoCurve.makeAlgoCurveList(risks, basecurrency, baseScenario.expandedUniverse);
       
    [setName scenarioPrefix] = prursg.Algo.AlgoUtil.GetScenarioSetNameInfo(scenType);
    
    csvFileName = [setName '.csv'];
    fid = fopen(fullfile(algoFilesPath, csvFileName), 'w');
    chunks={chunks};
    offsetDate = prursg.Util.DateUtil.DaysActual(sess_date, prursg.Util.DateUtil.ReplaceLeapDate(baseScenario.date));
    prursg.Algo.makeAlgoStocasticFile(fid, ...
       basecurrency, noOfSims(chunks), offsetDate, algoCurves, noRiskScenario , chunks, scenarioType, stoScenarios, setName, scenarioPrefix, SCENARIO_VALUE_FORMAT ...
    );       
    fclose(fid);
    
end


function n = noOfSims(chunks)
    n = 0;
    for i = 1:size(chunks, 2)
        chunk = chunks{i};
        n = n + size(chunk{1}, 1);
    end
end

