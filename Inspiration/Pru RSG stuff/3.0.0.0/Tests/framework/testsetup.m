function testsetup(root, target)
%{
# This script traverses subdirectories hunting for files which match 'file_patterns'
#
# This script must be run in the iRSG/Tests directory. The source folder must be
# a peer of Tests i.e. iRSG/Source. Without this addpath directives will not be
# correct and the runtests.sh scripts will will contain invalid paths
#
# For each match it copies the file without the trailing suffix before applying
# substitution (see the key value pairs below)
# For example foo.sh.template is copied to foo.sh before expansion
# (it will backup existing files rather than overwrite)
#
# On Linux sym links to various top level files e.g. classpath.txt
# and runtests.m in each directory that a contains xunit.test.folder
# (see create_functional_test.(sh|m) are created. On Windows file copy is
# employed
#
# The runtests.sh script takes the same arguments as runtests.m except it
# strips off the first srgument if it matches (case insensitively) cl|ide.
# The shell script will invoke matlab (on the command line or ide) setting
# the requisite paths. Note by command line I do not mean invoking the complied
# version of the RSG.
#
# This scrip has been migrated from an earlier shell script I wrote for
# Linux
#
# J Mittelmann (Riskcare Aug 2012)
%}

%%
%% Should move into configuration file
%%

config = ConfigReader(fullfile(root, 'test.defaults.config')).Config;

macros = containers.Map;
RSG_TOP = fullfile(root, '..');

macros('IRSG_TOP') = RSG_TOP;
macros('RSG_CWD') = '';
macros('IRSG_TESTS') = fullfile(RSG_TOP, 'Tests');
macros('IRSG_TESTRESULTS') = fullfile(RSG_TOP, 'TestResults');
macros('IRSG_SOURCE') = fullfile(RSG_TOP, 'Source');
macros('IRSG_XUNIT') = fullfile(RSG_TOP, 'Tests', 'Externals', 'xunit');
macros('IRSG_TESTUTIL') = fullfile(RSG_TOP, 'Tests', 'framework');
macros('DEV_DBNAME') = '';
macros('DEV_DBUSERNAME') = '';
macros('DEV_DBPASSWORD') = '';
macros('MDS_DBNAME') = '';
macros('MDS_DBUSERNAME') = '';
macros('MDS_DBPASSWORD') = '';

% Determine the OS
if (isunix)
    envir = 'Linux';
else
    envir = 'Windows';
end

% Make this configurable - prompt user

if isempty(config.pillar1_checkpoint)
	checkpoint = 'P1_BL4_1_0_13_Revision_1.20'; 
else
    checkpoint = config.pillar1_checkpoint; 
end

macros('RSG_PILLARI_CHECKPOINT') = checkpoint;
macros('IRSG_EXTERNALS') = fullfile(RSG_TOP, 'Tests/Externals');
macros('IRSG_PILLARI_MODELS') = fullfile(RSG_TOP, 'Tests/Externals/Models', checkpoint);
macros('IRSG_PILLARI_CONTROLS') = fullfile(RSG_TOP, 'Tests/Externals/Inputs', checkpoint, '03 XML control files');
macros('IRSG_PILLARI_ARAREPORTS') = fullfile(RSG_TOP, 'Tests/Externals/Inputs', checkpoint, '02 Other inputs');
macros('IRSG_BASELINE_FOLDER') = fullfile(config.irsg_baseline_version, [checkpoint '_Output']);

% Create baseline folder
macros('IRSG_BASELINE_IDE_PERSISTENCE_NONGRID') = fullfile(macros('IRSG_TESTRESULTS'), macros('IRSG_BASELINE_FOLDER'), 'Regression', envir, 'IDE', 'Persistence', 'NonGrid');
macros('IRSG_BASELINE_IDE_PERSISTENCE_GRID') = fullfile(macros('IRSG_TESTRESULTS'), macros('IRSG_BASELINE_FOLDER'), 'Regression', envir, 'IDE', 'Persistence', 'Grid');
macros('IRSG_BASELINE_IDE_INMEM_NONGRID') = fullfile(macros('IRSG_TESTRESULTS'), macros('IRSG_BASELINE_FOLDER'), 'Regression', envir, 'IDE', 'InMem', 'NonGrid');
macros('IRSG_BASELINE_IDE_INMEM_GRID') = fullfile(macros('IRSG_TESTRESULTS'), macros('IRSG_BASELINE_FOLDER'), 'Regression', envir, 'IDE', 'InMem', 'Grid');

%{
    # Patterns to match template files. Files can have any extension but the
    # 'final' extension will be removed for the target. i.e. path/foo.bar.foobar
    # will be subject to the scripts listed below and output as path/foo.bar
    #
    # Quote the limit string to prevent parameter substitution ensuring the
    # content of the 'here' document remains unmodifiedOD
%}
    file_patterns = {'^.*\.config\.template$',...
        '^.*\.sh\.template$'...
        '^.*\.bat\.template$'...
        '^.*\.txt\.template$'...
        '^.*\.m\.template$'...
        '^.*\.properties\.template$'};

    runtime_template_root = fullfile('framework','templates', 'runtime');
    main(file_patterns, macros, target, runtime_template_root, config);
end

function main(patterns, macros, target, template_root, config)
    disp 'Searching for files which match the following patterns:'
    for i = 1:length(patterns)
        fprintf('%s\n', patterns{i});
    end

    disp ''

    fprintf('Found the following files in "%s"...\n', target);
    files =  find(patterns, target);
	if isempty(files)
		disp 'No files found'
		return
	end

    for i = 1:length(files)
        fprintf('%s\n', files{i});
    end

    % would be more efficient to cache files rather than searching
    % again later but it's probably fast enough
    disp 'Search complete.'
    disp ''

    message=['Existing files will be moved when new'...
        'files are derived from the templates. Continue?'];

    if proceed(message, 'N')
        disp '...';
        get_dbconnection_info(macros, config);
        process_matching_files(patterns, macros, target);
        process_matching_files(patterns, macros, template_root);
        create_framework_files(template_root, target);
        make_scripts_executable(target);
    else
        disp 'Processing complete. No files modified.'
    end
 end

 function result = proceed(message, default)
    if isempty(default)
        default = 'N';
    end

    reply = input([message ' (y/n) (default: ' default '): '], 's');
    if (isempty(reply))
        reply = default;
    end

    if (strcmpi(reply, 'y') || strcmpi(reply, 'yes'))
        result = true;
    else
        result = false;
    end
end

function value = getvalue(message, default)
    value = default;

    reply = input([message '(default: ' default '): '], 's');
    if (~isempty(reply))
        value = reply;
    end
end

function get_dbconnection_info(macros, config)
% Not enought time to make this more user friendly

    DEV_DBNAME = config.dev_dbname;
    DEV_DBUSERNAME = config.dev_dbusername;
    DEV_DBPASSWORD = config.dev_dbpassword;
    while true
        disp 'Confirm the following scenario database connection details are correct:';
        fprintf ('Name: %s\n', DEV_DBNAME);
        fprintf ('User: %s\n', DEV_DBUSERNAME);
        fprintf ('Password: %s\n', DEV_DBPASSWORD);

        if proceed('Okay? ', 'y')
            macros('DEV_DBNAME') = DEV_DBNAME;
            macros('DEV_DBUSERNAME') = DEV_DBUSERNAME;
            macros('DEV_DBPASSWORD') = DEV_DBPASSWORD;
            break;
        end

        if proceed('Configure the scenario database connection?: ', 'y')
            DEV_DBNAME = getvalue('Database name', config.dev_dbname);
            DEV_DBUSERNAME = getvalue('Database user', config.dev_dbusername);
            DEV_DBPASSWORD = getvalue('Database password', config.dev_dbpassword);
        else
            break;
        end
    end

    MDS_DBNAME = config.mds_dbname;
    MDS_DBUSERNAME = config.mds_dbusername;
    MDS_DBPASSWORD = config.mds_dbpassword;

    while true
        disp 'Confirm the following market data database connection details are correct:';
        fprintf ('Name: %s\n', MDS_DBNAME);
        fprintf ('User: %s\n', MDS_DBUSERNAME);
        fprintf ('Password: %s\n', MDS_DBPASSWORD);
        if proceed('Okay? ', 'y')
            macros('MDS_DBNAME') = MDS_DBNAME;
            macros('MDS_DBUSERNAME') = MDS_DBUSERNAME;
            macros('MDS_DBPASSWORD') = MDS_DBPASSWORD;
            break;
        end

        if proceed('Configure the Market Data Store (MDS) database connection?: ', 'y')
            MDS_DBNAME = getvalue('Database name', config.mds_dbname);
            MDS_DBUSERNAME = getvalue('Database user', config.mds_dbusername);
            MDS_DBPASSWORD = getvalue('Database password', config.mds_dbpassword);
        else
            break;
        end
    end
end

function files = find(patterns, root)
% Ensures consistent file search approach in the script
    if isempty(patterns)
        error('find(patterns, root) expects one or more regular expressions');
    end

    if isempty(root) || ~exist(root, 'dir')
        error(['find(patterns, root) requires a starting directory: "' root '"']);
    end


    % Folders containing the 'ignore' file will be ignored by this script
    ignore_pattern = '^xunit.test.ignore$';

    % consider building a file cache
    contents = dir(root);
    files = {};
    for i = 1:length(contents)
        if ~strncmpi(contents(i).name, '.', 1) % ignore '.' and '..' and hidden files and folders on Linux
            target = fullfile(root, contents(i).name);
            if contents(i).isdir
                files = [files find(patterns, target)];
            else
                for j = 1:length(patterns)
                    ignore = ~isempty(regexpi(contents(i).name, ignore_pattern));
                    if (ignore)
                        fprintf('Found ignore flag "%s" in "%s\n"', ignore_pattern, root) 
						files = {}; %discard any files that matched
                        return;
                    end

                    found = ~isempty(regexpi(contents(i).name, patterns{j}));
                    if found
                        files = [files target];
                        break;
                    end
                end
            end
        end
    end
end

function process_files(pattern, macros, root)
        
    % The first_iteration flag is used to warn just once that config params 
    % are being skipped due to being empty
    persistent first_iteration;
            
    files = find(pattern, root);
    for i = 1:length(files)
        file = files{i};
        fprintf('Processing file %s\n', file);

        % The target file is the original less the '.template' extension
        % note that name therefore includes a file extension
        [path, name, ~] = fileparts(file);
        target = fullfile(path, name);

        macros('RSG_CWD') = path;

        % Create backup if target exists
        if ~backup_file(path, name)
            error('File backup failed!');
        end

        fprintf('Generating file %s\n', target)

        fin = fopen(file, 'rt');
        if fin == -1
            error(['Unable to open ' file ' for reading'])
        end

        fout = fopen(target, 'w+t');
        if fout == -1
            error(['Unable to open ' target ' for writing'])
        end

        % Transform file
        key_list = keys(macros);
        while ~feof(fin)
            line = fgetl(fin);

            if line == -1
                % end-of-file marker
                % why foef doesn't detect eof is unclear
                break;
            end
                
            for i = 1:length(key_list)
                % All transforms are applied to all files
                % line by line...
                key = key_list{i};
                value = macros(key);

                if isempty(value)
                    if isempty(first_iteration)
                        % Warn about each missing config just once
                        fprintf('Skipping  "%s" as value is empty\n', key);
                    end
                    
                    continue;
                end
                line = strrep(line, ['{' key '}'], value);
            end
            fprintf(fout, '%s\n', line);
            first_iteration = false;
        end

        fclose(fin);
        fclose(fout);

        fprintf('Processing complete for %s\n\n', file);
    end
end

function create_framework_files(source, target)

% Create sym links to the runtests.m and runtests.sh scripts in
% every folder containing a xunit.test.folder file. This allows us
% to maintain a single instance of each. Note that if a
% 'xunit.test.ignore' file exists then the folder will be hidden.

    disp 'Creating framework files';

    pattern = {'xunit.test.folder'};

    if isunix
        runtests_sh = 'runtests.sh';
    else
        runtests_sh = 'runtests.bat';
    end

    runtests_m = 'runtests.m';
    classpath_txt = 'classpath.txt';

    files = find(pattern, target);
    for i = 1:length(files)
        [test_dir, ~, ~] = fileparts(files{i});

        if (false) %isunix)
            system(['ln -s ' fullfile(source, runtests_sh) ' ' fullfile(test_dir, runtests_sh)]);
            system(['ln -s ' fullfile(source, runtests_m) ' ' fullfile(test_dir, runtests_m)]);
            system(['ln -s ' fullfile(source, classpath_txt) ' ' fullfile(test_dir, classpath_txt)]);
        else
            [status, message] = copyfile(fullfile(source, runtests_sh), fullfile(test_dir, runtests_sh), 'f');
            if ~status
                fprintf('File copy failed: %s\n', message);
                error('Failed to create framework files');
            end

            [status, message] = copyfile(fullfile(source, runtests_m), fullfile(test_dir, runtests_m), 'f');
            if ~status
                fprintf('File copy failed: %s\n', message);
                error('Failed to create framework files');
            end

            [status, message] = copyfile(fullfile(source, classpath_txt), fullfile(test_dir, classpath_txt), 'f');
            if ~status
                fprintf('File copy failed: %s\n', message);
                error('Failed to create framework files');
            end
        end
    end
end

function make_scripts_executable(root)
% Make all shell scripts executable
    if (~isunix)
        return
    end

    disp 'Making scripts executable'
    pattern = {'^.*\.sh$'};

    files = find(pattern, root);
    for i = 1:length(files)
        file = files{i};
        system(['chmod a+x ' file]);
    end
end

function process_matching_files (file_patterns, macros, root)
    for i = 1:length(file_patterns)
        process_files(file_patterns(i), macros, root);
    end
end

function status = backup_file(path, name)
% Back directory to create and store files before
% overwriting

    source = fullfile(path, name);
    fprintf('Considering %s for backup\n', source);

    if ~exist(source, 'file')
        fprintf('No backup required for %s\n', source);
        status = true;
        return;
    end

    backup_dir = '.rsg_moved_test_files';

    if ~exist(fullfile(path, backup_dir), 'dir')
        [status, message] = mkdir(path, backup_dir);

        if ~status
            fprintf('Backup failed: %s\n', message);
            return;
        end
    end
    ts_name = [datestr(now, 30) '_' name];
    % 30 => (ISO 8601)  'yyyymmddTHHMMSS'        20120301T154517
    target = fullfile(path, backup_dir, ts_name);

    [status, message] = movefile(source, target);

    if ~status
        fprintf('Backup failed: %s\n', message);
        return;
    end

    if exist(target, 'file')
        fprintf('Backup %s created\n', target);
    else
        error('Something went wrong');
    end
end



