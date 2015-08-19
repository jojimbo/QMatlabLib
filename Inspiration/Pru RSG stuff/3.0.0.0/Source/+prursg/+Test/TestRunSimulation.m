function TestRunSimulation()
    clear;
    clc;

    import prursg.Xml.*;
    
    % instantiate a model file object from XML model file
    fprintf('Main - reading XML model file \n');

    %filePath = fullfile('SimpleTestv12.xml');
    filePath = fullfile('+prursg','+Test', '+UseCase', 'T0 base run test.xml');
    modelFile = ModelFile(filePath);
    
    % instantiate a RSG object
    fprintf('Main - Instantiating RSG object \n');
    rsg = prursg.Engine.RSG(modelFile.riskDrivers, modelFile.correlationMatrix);
    
    % calibrate
    % fprintf('Main - RSG calibrating \n');
    % rsg.calibrate();
    
    % write calibrated model file - THIS DOESN'T WORK YET
    modelFile.merge();
    str = modelFile.toString();
    fileName = 'SimpleTestv12_enriched.xml';
    fid = fopen(fileName, 'w');
    fwrite(fid, str);
    fclose(fid);
    
    % simulate, results under folder simResults
    fprintf('Main - RSG simulating \n');
    rsg.simulate(1,12, modelFile.num_simulations, 1, modelFile.riskIndexResolver);
    
    % validate, results under folder valReports
    % fprintf('Main - RSG validating \n');
    % rsg.validate();
    
    % prudential aggregator files
    fprintf('Main - making aggregator files \n');
    simulationOutputs = rsg.simEngine.simulationOutputs; 
        
    prursg.Aggregator.makePruFiles(modelFile.base_set.sess_date, modelFile.riskDrivers, simulationOutputs);
    
    % algo files
    %simulationOutputs = makeStubOutputs(modelFile.riskDrivers, 5);
    %fprintf('Main - making algo riskwatch files \n');
    
%     setId = storeInDb(modelFile, simulationOutputs); % oracle persistence of results
%     readOutputs = getFromDb(setId);
%     assert(isequal(simulationOutputs, readOutputs)); % make sure what was written/read equals the original
    
    % md5 check sum
    %checkMd5sum(simulationOutputs);
    %
    %generateAlgoFiles(modelFile, readOutputs);    
    %generateAlgoFiles(modelFile, simulationOutputs);
end 


%ALGO 
function generateAlgoFiles(modelFile, simulationOutputs)
    import prursg.Algo.*;
    import prursg.Xml.*;
    
    % curve room file
    roomFileContents = makeCurveRoomFile(modelFile.basecurrency, modelFile.session_date, modelFile.riskDrivers, modelFile.timesteps, 0);
    saveFile(fullfile('AlgoFiles', 'risk_drivers.csv'), roomFileContents);
    
    % deterministic scenario file
    baseDeterministicFileContents = prursg.Algo.makeBaseDeterministicScenarioFile( ...
        modelFile.basecurrency, modelFile.session_date ...
        , modelFile.riskDrivers, modelFile.timesteps ...
    );   
    saveFile(fullfile('AlgoFiles', 'LM_Asset_Macro_ScenSet.csv'), baseDeterministicFileContents);
    
    % manifest binary file
    xmlDoc = prursg.Algo.makeAlgoBinaryHeader(... 
        'SCEN_LM_GENERIC', modelFile.basecurrency, modelFile.session_date, ...
        '0', modelFile.num_simulations + 1, modelFile.riskDrivers ... 
    );
    manifest = XmlTool.toString(xmlDoc, true);
    manifest = sprintf('<?xml version="1.0" encoding="UTF-8" ?>\n%s', manifest);
    saveFile(fullfile('AlgoFiles', 'SCEN_LM_GENERIC.ce'), manifest);
    
    % binary algo file
    saveBinaryAlgoFile(fullfile('AlgoFiles', 'SCEN_LM_GENERIC.bin'), modelFile, simulationOutputs);
   % snifBinary(fullfile('AlgoFiles', 'SCEN_LM_GENERIC.bin'), modelFile.num_simulations + 1);

   
end

% fx nodes output need to be duplicated. reorder credit spreads outputs!
function saveBinaryAlgoFile(fileName, modelFile, stochasticOutputs)
    risks = modelFile.riskDrivers;
    timestep = modelFile.timesteps(end);
    outmatrix = [];
    for i = 1:numel(risks)        
        firstScenario = timestep.expandedUniverse(risks(i).name).serialise();                
        firstScenario = [firstScenario; stochasticOutputs{i} ]; %#ok<AGROW>
        if(strcmp(risks(i).risk_family, 'fx'))
            firstScenario = [ firstScenario firstScenario ]; %#ok<AGROW>
        end
        outmatrix = [ outmatrix firstScenario]; %#ok<AGROW>
    end
    % rearange into lines each line - one monte carlo scenario
    mout = [];
    for i = 1:size(outmatrix, 1)
        mout = [mout outmatrix(i, :)]; % there must be a more efficient way to do this
    end
        
    fid = fopen(fileName, 'w');
    fwrite(fid, mout, 'double');
    fclose(fid);
end

function saveFile(fileName, contents)
    fid = fopen(fileName, 'w');
    fwrite(fid, contents);
    fclose(fid);    
end

% dummy test data
function outputs = makeStubOutputs(riskDrivers, mcruns)
    outputs = [];
    for i = 1:numel(riskDrivers)
        samples = ones(mcruns, riskDrivers(i).model.getNumberOfStochasticOutputs()) .* i;
        outputs = [ outputs {samples} ]; %#ok<AGROW>
    end
end

%===== binary file sniffing

function snifBinary(fileName, rows)

    fid = fopen(fileName, 'r');
    mydata = fread(fid, 'double');
    fclose(fid);
    %length(mydata)/736   % should give exactly 11
   
    rowSize = length(mydata)/rows;
    m = zeros(rows, rowSize);
    for row = 1:rows
        mrow = mydata((row - 1) * rowSize + 1 : row * rowSize);
        m(row, :) = mrow;
    end
    m; %put a fat breakpoint here to observe
    clear import;
    clear;
end
