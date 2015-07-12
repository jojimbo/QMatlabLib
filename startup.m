%% Startup configuration for Riskcare Quant Lib (RQL)

% Add the source directory to the path so packages are immediately
% available
source_root = fullfile(pwd, 'SourceCode');
addpath(source_root);

%% Add external library paths

%% JSON_LIB
json_lib_root = fullfile(source_root, 'libs', 'jsonlab-1.0');
json_lib_archive = strcat(json_lib_root, '.zip');

if (~exist(json_lib_archive, 'dir'))
    unzip(json_lib_archive, json_lib_root);
end

json_lib = fullfile(json_lib_root, 'jsonlab');
addpath(json_lib);
clear json_lib
clear json_lib_root
clear json_lib_archive

%% GET_FULL_PATH
gfp_lib_root = fullfile(source_root, 'libs', 'GetFullPath_17Jan2013');
gfp_lib_archive = strcat(gfp_lib_root, '.zip');

if (~exist(gfp_lib_archive, 'dir'))
    unzip(gfp_lib_archive, gfp_lib_root);
end

gfp_lib = gfp_lib_root;
addpath(gfp_lib);
clear gfp_lib
clear gfp_lib_root
clear gfp_lib_archive

%% Change to the source directory
cd(source_root);

%% Import the wrappers
import helper.*




%% Clear the source root once no longer required
clear source_root

cm = helper.confman;
cm.disp;
