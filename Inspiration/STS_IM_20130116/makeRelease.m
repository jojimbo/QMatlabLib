function makeRelease()
%MAKERELEASE Internal code to make a release
%
%  Copyright 2012 The MathWorks, Inc.
%  $Revision: 319 $  $Date: 2012-07-31 12:35:55 +0000 (Tue, 31 Jul 2012) $
addpath('Package');
ver = getVersion();
v = ver.version;

currDir = fileparts( mfilename('fullpath') );
parentDir = fileparts( currDir );
releaseDir = fullfile( parentDir, 'Releases' );
dirName = fullfile( releaseDir, ['Release_',v]);
fprintf('Making release  %s\n',dirName);

% make directory (blow away if already exists)
if exist( dirName, 'dir' )
    % delete it
    OK = rmdir( dirName, 's' );
    if ~OK
        error( ['Unable to delete directory ' dirName] );
    end
end
disp('');

% Ensure documentation is up to date
disp('Updating Documentation....');
cd CreateDocumentation;
CreateDocumentation;
cd ..;

% Remove cache files
disp('Clearing cache files....');
cd Tests;
deleteCaches('..');
cd ..;

% now make it
mkdir( dirName );
mkdir( [dirName,filesep,'Code'] );
mkdir( [dirName,filesep,'Code',filesep,'Package'] );
mkdir( [dirName,filesep,'Code',filesep,'Package',filesep,'+ing'] );
mkdir( [dirName,filesep,'Code',filesep,'Tests'] );
mkdir( [dirName,filesep,'Code',filesep,'Data'] );
mkdir( [dirName,filesep,'Code',filesep,'Data',filesep,'201108'] );
mkdir( fullfile(dirName, 'Code', 'InternalModel') );
% copy directories into the release directory
% directories relative to root
releaseDirs = {
    '\Code\Package' ...
    '\Code\Data\201108' ...
    '\Code\Data\201102' ...
    '\Code\Data\201112' ...
    '\Code\Tests' ...
    '\Code\deploy_miniECAPSCL.m' ...
    '\Code\deploy_extract_index_curve.m' ...
    '\Code\deploy_cat_cashflows.m' ...
    '\Code\CreateDocumentation' ...
    '\Code\Documentation' ...
    '\Code\InternalModel'
    };
for n = 1:numel( releaseDirs )
    fprintf(' Copying %s\n',releaseDirs{n});
    copyfile( fullfile(parentDir,releaseDirs{n}), fullfile( dirName, releaseDirs{n} ) );
end

%Remove asv files
fprintf(' Removing asv and xls files\n');
delete([dirName,filesep,'code',filesep,'package',filesep,...
    '*.asv']);
delete([dirName,filesep,'code',filesep,'package',filesep,'+wk',filesep...
    '*.asv']);

% get rid of CVS/SVN dirs!
fprintf('Removing SVN directories...')
iRemoveCVSDirs( dirName );
fprintf(' done.\n')
fprintf('Zipping all...')
zip([dirName '.zip'], dirName);
fprintf(' done.\n')

end

function iRemoveCVSDirs( theDir )

d = dir( theDir );
d(~[d.isdir]) = [];
if ismember( 'CVS', {d.name} )
    rmdir( fullfile( theDir, 'CVS' ), 's' );
    d(ismember( {d.name}, 'CVS' )) = [];
end
if ismember( '.svn', {d.name} )
    rmdir( fullfile( theDir, '.svn' ), 's' );
    d(ismember( {d.name}, '.svn' )) = [];
end

for n = 1:length( d )
    if ~isequal( d(n).name(1), '.' )
        iRemoveCVSDirs( fullfile( theDir, d(n).name ) )
    end
end



end % function
