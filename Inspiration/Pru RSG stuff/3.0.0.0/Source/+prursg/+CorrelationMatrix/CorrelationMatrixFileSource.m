% The abstract CorrelationMatrixSource class redefines the abstract read
% method in the IRSGCorrelationMatrixSource interface. It provides functionality
% common to file based correlation matrix sources
% The CorrelationMatrixSource class is a handle class and therefore has
% copy by reference sematics
classdef CorrelationMatrixFileSource < prursg.CorrelationMatrix.IRSGCorrelationMatrixSource & handle
    properties
        % The name of the correlation matrix derived from the ControlFilePath
        CorrelationMatrixName
        
        % Path to the folder containing the control file associated 
        % with the correlation matrix
        ControlFileFolder
    end
    
    methods
        % The constructor expects the fully qualified path to the control
        % file
        % in: 
        %   controlFilePath, The path to control file associated with the
        %   correlation matrix
        function obj = CorrelationMatrixFileSource(controlFilePath)          
            [obj.ControlFileFolder, name, ~] = fileparts(controlFilePath);
            obj.CorrelationMatrixName = [name '_corr'];
        end

        % Find all correlation matrices that match one of the file
        % extension patterns.
        % in: 
        %   patterns, An array of patterns to match against the file suffix
        % out: 
        %   files, An array of matching files or an empty array in the 
        %   case of error
        function files = findFiles(obj, patterns)
            if isempty(patterns)
                fprintf(['CorrelationMatrixFileSource:NotFound: '...
                    'Expected one or more regular expressions.']);
                files = {};
                return;
            end
            
            root = obj.ControlFileFolder;
            
            if isempty(root) || ~exist(root, 'dir')
                fprintf(['CorrelationMatrixFileSource:NotFound: '...
                    'The control file folder "' root '" does not exist']);
                files = {};
                return;
            end
            
            contents = dir(root);
            files = {};
            for i = 1:length(contents)
                % ignore '.' and '..' and hidden files and folders on Linux
                if ~strncmpi(contents(i).name, '.', 1)
                    target = fullfile(root, contents(i).name);
                    if contents(i).isdir
                        % skip directories
                        continue;
                        % If directory recision is required uncomment the
                        % following line - almost certainly not required                       
                        % files = [files find(patterns, target)];
                    else
                        % first check if basename matches
                        [~, name, ext] = fileparts(contents(i).name);
                        if (~strcmpi(name, obj.CorrelationMatrixName))
                            % name match failed - no point looking at
                            % extensions - not necessarily an error
                            continue;
                        end
                        
                        for j = 1:length(patterns)
                            % So we have a name match but there may be
                            % corr matrices of different types. Perform a
                            % case insensitive extension match
                            pattern = patterns{j};
                            if (~strcmpi(ext, pattern))
                                % no match - not necessarily an error
                                continue;
                            end
                            
                            % Let the derived class worry if there's
                            % more than one result. This should be a rare
                            % event so suppress the preallocate warning
                            files = [files target]; %#ok<AGROW>
                            break;
                        end
                    end
                end
            end
        end
    end
end

