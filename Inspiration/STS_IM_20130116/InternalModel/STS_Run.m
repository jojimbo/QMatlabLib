%% STS_Run
% STS_Run generates .csv files in ARA format with the instrument
% prices per scenario and matFile passed in.
%
% One file is produced per instrument with instrID as a name.
%%
function folderpath = STS_Run(targetpath, varargin)
% |folderpath = STS_Run(targetpath, varargin)|
%
% Input:
%
% * |targetpath|         _Char_
% * |vargin|             _Char_


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
%     outputCubePaths{iFile} = fullfile(outputCubePaths{iFile}, filesep, 'Cube.mat');
end

% GenerateARACube
folderpath = STS_GenerateARACubes(targetpath, outputCubePaths);

end
