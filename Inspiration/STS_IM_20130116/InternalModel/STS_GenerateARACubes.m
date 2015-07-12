%% STS_GenerateARACubes
% STS_GenerateARACubes generates .csv files in ARA format with the instrument
% prices per scenario and matFile passed in.
%
% One file is produced per instrument with instrID as a name.
%%
function folderpath = STS_GenerateARACubes(targetpath, matFilesPaths)
% |folderpath = STS_GenerateARACubes(targetpath, matFilesPaths)|
%
% Input:
%
% * |targetpath|         _Char_
% * |matFilesPaths|      _cell_


% File extension
flNmExt = 'csv';

% Create directory if it doesn't exist
if ~exist(targetpath, 'dir')
    mkdir(targetpath);
end

% Number of .mat files
n_matfiles = numel(matFilesPaths);

% Get number and names of instruments
Cube = load([matFilesPaths{1} filesep 'Cube.mat']);
instrIDs = Cube.obj.instrumentIDs;
instrNames = Cube.obj.instrumentNms;
n_instruments = numel(instrIDs);

fileName = ['STS_IM_Output' '.' flNmExt];
instrlines = (4+size(Cube.obj.data, 2));
fileCell  = cell(n_instruments*instrlines, 1+ n_matfiles);
% Loop through all the instruments and create the files
for iInst=1:n_instruments
    % First line
    fileCell{1 +(iInst-1)*instrlines, 1} = 'Instrument ID';
    fileCell{1 +(iInst-1)*instrlines, 2} = instrIDs{iInst};
    [fileCell{1 +(iInst-1)*instrlines, 3:end}] = deal('');
    % Second line
    fileCell{2 +(iInst-1)*instrlines, 1} = 'Instrument name';
    fileCell{2 +(iInst-1)*instrlines, 2} = instrNames{iInst};
    [fileCell{2 +(iInst-1)*instrlines, 3:end}] = deal('');
    
    % Third to Last lines
    fileCell{3 +(iInst-1)*instrlines, 1} = 'Cube';
    n_scenarios = size(Cube.obj.data, 2);
    for iFile=1:n_matfiles
        Cube = load([matFilesPaths{iFile} filesep 'Cube.mat']);
        %[fileCell{4:end, 1+iFile}] = Cube.obj.data(iInst, :);
        % How to do the below for in 1 line? The above doesn't work so we use a for loop
        for j=1:n_scenarios
            [fileCell{3+j +(iInst-1)*instrlines, 1+iFile}] = Cube.obj.data(iInst, j);
            if iFile == 1
                fileCell{3+j +(iInst-1)*instrlines, 1} = Cube.obj.scenarioNames{j};
            end
        end
        fileCell{3 +(iInst-1)*instrlines, 1+iFile} = Cube.obj.setName{1};
    end
    % Last empty row
    [fileCell{4+n_scenarios +(iInst-1)*instrlines, :}] = deal('');
end

% Generate csv file
internalModel.Utilities.cell2csv(fullfile(targetpath, fileName), fileCell, ',');

folderpath = targetpath;
disp(['Generated ARA cubes in the directory: ' folderpath '.']);

end
