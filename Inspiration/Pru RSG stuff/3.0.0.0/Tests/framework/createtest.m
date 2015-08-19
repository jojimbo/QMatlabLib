%% CREATETEST
%   This is used to create the standard test directory structure
%	and skeleton files
%%
function createtest(root, test_type, test_name, test_description)
    disp('Initiating test creation...');
    test_folder = create_test_folders(root, test_type, test_name);
    create_sample_test_file(root, test_folder, test_name, test_description);
    disp(['Test folder ' test_folder ' created']);
end

%     createtest(, 'tmp_test_type', 'tmp_test_name', 'Something descriptive');

function create_folder(path)
    fprintf('Creating folder %s\n', path);

    if (exist(path, 'dir'))
        error(['Folder ' path ' already exists!']);
    end

    [status, mess,~] = mkdir(path);

    if (~status)
        fprintf('Failed to create folder %s', path);
        error(mess);
    end
    fprintf(mess);
end

function test_folder = create_test_folders(root, test_type, test_name)
    source = fullfile(root, 'framework', 'templates', 'test_skeleton');
    test_root = fullfile(root, test_type);
    test_folder = fullfile(test_root, test_name);

    if (~exist(test_root, 'dir'))
        create_folder(test_root);
    end

    if (~exist(test_folder, 'dir'))
        create_folder(test_folder);
    else
        error(['Folder ' test_folder ' already exists!']);
    end

    copy_files(source, test_folder)
end

function copy_files(source, dest)
    contents = dir(source);
    for i = 1:length(contents)
        % ignore '.' and '..' and hidden files and folders on Linux
        if ~strncmpi(contents(i).name, '.', 1)
            target = fullfile(source, contents(i).name);
            if contents(i).isdir
                dest_dir =  fullfile(dest, contents(i).name);
                create_folder(dest_dir)
                copy_files(target, dest_dir);
            else
                % first check if basename matches
                [~, name, ext] = fileparts(contents(i).name);
                if (strcmpi(ext, '.pj'))
                    % don't copy MKS project files
                    continue;
                end

                if (strcmpi(name, 'Test_template'))
                    % don't copy this template file
                    continue;
                end
                % Copy everything else
                [status, mess, ~] = copyfile(target, dest);
                if (~status)
                    fprintf('Failed to copy file %s to %s', target, dest);
                    error(mess);
                end
            end
        end
    end
end


function create_sample_test_file(root, test_folder, test_name, test_description)
    macros = containers.Map;
    macros('<TEST_NAME>') = test_name;
    macros('<TEST_DESCRIPTION>') = test_description;

    source = fullfile(root, 'framework', 'templates', 'test_skeleton', 'Test_template.m');
    target =  fullfile(test_folder, ['Test_' test_name '.m']);
    testutil.TestUtil.file_strrep(macros, source, target);
end

