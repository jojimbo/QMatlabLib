%% Generate documentation

% Fix the path. The Package directory must be only once in the search path
cd ../Package
mPath = fileparts(pwd);
addpath(fullfile(mPath, 'Package'));
rmpath('../../Package');
rmpath(fullfile(mPath, 'Tests', '..', 'Package'));

% Automatically generate Contents files
if exist(fullfile(pwd, 'Contents.m'), 'file')
    delete Contents.m
end
makecontentsfile(pwd)
cd ./+ing
if exist(fullfile(pwd, 'Contents.m'), 'file')
    delete Contents.m
end
makecontentsfile(pwd)

% Create documentation and fix hyperlinks for classes and functions
cd ../../CreateDocumentation
buildHTMLdoc

% build top-level navigation pages
publish('GettingStarted.m','outputDir','..\Documentation');
publish('Overview.m', 'outputDir', '..\Documentation');
publish('Index.m', 'outputDir', '..\Documentation');
copyfile('logo.jpg', '..\Documentation\logo.jpg');
copyfile('Overview.GIF', '..\Documentation\Overview.GIF');
% Open top-level navigation page of documentation
web ..\Documentation\Index.html