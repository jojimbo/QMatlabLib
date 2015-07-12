%% STS_ECScenario
% STS_ECScenario generates a .csv file with the P&L (with respect to the
% Base Scenario) for a specific scenario (passed as an argument) and
% for all the instruments in the .mat files passed as arguments
%
% It creates the file in the folder specified by the targetpath argument
%
% One file is produced per instrument with MATLAB_AM_Output&(SCENNAME)&.csv as a name.
%%
function folderpath = STS_ECScenario(targetpath, scenarioname, varargin)
% |folderpath = STS_ECScenario(targetpath, scenarioname, varargin)|
%
% Input:
%
% * |targetpath|         _Char_
% * |scenarioname|       _Char_
% * |varargin|           _var_


% File extension
flNmExt = 'csv';

% Create directory if it doesn't exist
if ~exist(targetpath, 'dir')
    mkdir(targetpath);
end

% Number of config files
n_configfiles = numel(varargin);
if n_configfiles == 0
    error('STS_Run:Notenoughinputarguments', 'no config files were specified, nothing to run');
end 
results = cell(1, n_configfiles);
outputCubePaths = cell(1, n_configfiles);
% Run STS for all the config files
for iFile = 1:n_configfiles
    results{iFile} = STS_CM(varargin{iFile});
    outputCubePaths{iFile} = results{iFile}.cube.path;
end

% Number of Cube.mat files generated
n_matfiles = numel(outputCubePaths);
if n_matfiles == 0
    error('STS_Run:Notenoughinputarguments', 'no cubes were calculated, no data to read');
end

% Get number and names of instruments
Cube = load([outputCubePaths{1} filesep 'Cube.mat']);
instrIDs = Cube.obj.instrumentIDs;
instrNames = Cube.obj.instrumentNms;
n_instruments = numel(instrIDs);

fileName = ['MATLAB_AM_Output_' scenarioname '.' flNmExt];
fileCell  = cell(3+n_instruments, 2+ n_matfiles);

% First line
fileCell{1, 1} = 'ScenarioName';
fileCell{1, 2} = scenarioname;
[fileCell{1, 3:end}] = deal('');
% Second line header
fileCell{2, 1} = 'ScenarioSetName';
fileCell{2, 2} = deal('');
% Third line header
fileCell{3, 1} = 'TotalEC';
fileCell{3, 2} = deal('');

% First column for line 4 and below --> InstrumentIDs
for iInst= 1:n_instruments
    fileCell{3+iInst, 1} = instrIDs{:, iInst};
end
% Second column for line 4 and below --> InstrumentNamess
for iInst= 1:n_instruments
    fileCell{3+iInst, 2} = instrNames{:, iInst};
end

PnLs = zeros(n_instruments, n_matfiles);
totPnL = zeros(1, n_matfiles);
% Retrieve the Cube values for the specified scenario for all the Cubes
compare = @(x)strcmpi(x, scenarioname);
for iCube=1:n_matfiles
    Cube = load([outputCubePaths{iCube} filesep 'Cube.mat']);
    idxScen = cellfun(compare, Cube.obj.scenarioNames);
    if ~any(idxScen)
        disp(['No scenario data found in Cube ' outputCubePaths{iCube} filesep 'Cube.mat']);
        disp(['Asigning PnL = 0 for all instruments in that ScenarioSet: ' Cube.obj.setName{1}]);
        PnLs(:, iCube) = zeros(n_instruments, 1);
        %error('STS_ECScenario:NoScenarioData', ['No scenario data found in Cube ' varargin{iCube}]);
    else
        scenPrices = Cube.obj.data(:,idxScen);
        basePrices = Cube.obj.data(:,1); % Always assume the first scenario is the Base one
        PnLs(:, iCube) = scenPrices - basePrices;
    end
    % Total PnL for the ScenarioSet on l
    totPnL(1, iCube) = sum(PnLs(:, iCube));
    fileCell{3, 2+iCube} = totPnL(1, iCube);
    % Second line
    fileCell{2, 2+iCube} = Cube.obj.setName{1};
    % Lines 4 and below for the column corresponding to this ScenarioSet
    fileCell(4:end, 2+iCube) = num2cell(PnLs(:, iCube));
end

% Generate csv file
internalModel.Utilities.cell2csv(fullfile(targetpath, fileName), fileCell, ',');

folderpath = targetpath;
disp(['Generated ECScenario Report for scenario ' scenarioname ' in the directory: ' folderpath]);

end
