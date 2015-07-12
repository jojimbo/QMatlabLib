classdef BaseFactory < handle  
    % BaseFactory - A factory class responsible for creating curve objects
    %
    % BaseFactory Properties:
    % path: The path to monitor for files
    % filter: The filter to apply to files in path
    %
    % BaseFactory Methods:
    % BaseFactory - The constructor
    %
    % list - List available files
    % exists - Verify specified file exists
    % get - Get the specified file
    
    properties (Access = public)
        path = '.' % The path to monitor for files
        filter = '*.m' % The filter to apply to files in path
    end
    
    methods (Access = public)
        function [factory] = BaseFactory(path, filter)   
            factory.path = path;
            factory.filter = filter;
            factory.files = containers.Map();
            
            % Load all files from the default load path
            factory.loadDefaultPath();
            
            % Change the constructor to accept these as arguments
            factory.watch(path, filter);
        end
               
        function [curveList] = list(factory)    
            % list  Return a list of all files found in the load path
            %   This method lists all available files. The list is
            %   updated dynamically and list items can be passed to the get
            %   and exists methods
            %
            %   See also get.
            curveList = factory.files.keys();
        end
       
        function [result] = exists(factory, name)
            % exists Check for existnce of a file
            %   This method verifies that the specified file exists in the 
            %   load path
            %
            %   See also get and list.
            result = factory.files.isKey(name);
        end
        
        function [curve] = get(factory, name, varargin)
            % get Instantiate the class represented by the specified name
            %   This method defers instantiation to a derived factory. A 
            %   BaseFactory:noSuchFile exception is thrown if name not founnd. 
            %
            %   See also get and list.
            
            if (factory.files.isKey(name))
                definition = factory.files(name);
                curve = factory.instantiate(definition(2:end), varargin{:});
                return;
            end
            
            ME = MException('BaseFactory:noSuchFile', ...
                'File "%s" not found', name);
            throw(ME);
        end
        
        % Destructor must be public
        % http://uk.mathworks.com/help/matlab/matlab_oop/handle-class-destructors.html
        function delete(factory)
            % delete The destructor
            %   This method releases resources. 
            %
            %   See also BaseFactory.
            if isempty(factory.fileObj) || ~isvalid(factory.fileObj)
                return;
            end
            factory.fileObj.EnableRaisingEvents = false;
            factory.fileObj.Dispose();
        end
    end
    
    properties (Access = private)
        files % A associative array (map) containing caches file names
            
        fileObj % The file system watcher
        created_watcher % The created file listener
        changed_watcher % The changed file listener
        deleted_watcher % The deleted file listener
        renamed_watcher % The renamed file listener
    end
    
    methods (Access=protected, Abstract)
        instantiate(obj, name, varargin)
    end
    
    methods (Access=private)
        function [] = loadDefaultPath(factory)
            factory.load(factory.path, factory.filter);
        end
        
        %% Find and load all files but defer instantiation until retrieved 
        %% via getCurve
        function [] = load(factory, path, filter)
            fileList = dir(fullfile(path, filter));
            
            if isempty(fileList)
                return
            end
            
            %{
                arrayfun tries to create and populate a scalar matrix of the 
                same size as the inputs. This will not work when the anon 
                function return a non-scalar output. UniformOutput = false 
                tells arrayfun to store the output in a cell matrix
            %}

            % arrayfun(@(x) deal(x.name(1:end-2), x.name), ...
            [keys, values] = ...
                arrayfun(@(x) deal(x.name(2:end), x.name), ...
                fileList, 'UniformOutput', false);

            factory.files = containers.Map(keys, values);
        end
        
        function watch(factory, path, filter)
            factory.fileObj = System.IO.FileSystemWatcher(path);
            factory.fileObj.Filter = filter;
            factory.fileObj.EnableRaisingEvents = true;
            
            % Note that a single change can trigger multiple events,            
            factory.created_watcher = addlistener(factory.fileObj, 'Created', @factory.createdCallback);
            factory.changed_watcher = addlistener(factory.fileObj, 'Changed', @factory.changedCallback);
            factory.deleted_watcher = addlistener(factory.fileObj, 'Deleted', @factory.deletedCallback);
            factory.renamed_watcher = addlistener(factory.fileObj, 'Renamed', @factory.renamedCallback);
        end
        
        function [] = createdCallback(factory, ~, event)
            %disp(fsw.Path)
            %disp(event.ChangeType)
            %disp(event.FullPath)
            %disp(event.Name);
            factory.add(char(event.Name));            
        end
        
        function [] = changedCallback(~, ~, ~)
            % Nothing to do. The source file has changed but currently we 
            % have no way of updating the object. We could keep a record of
            % the instance we create in getCurve and call update on it but
            % we need to confirm if this is required

            %disp(event.Name);
        end
        
        function [] = deletedCallback(factory, ~, event)
            %disp(event);
            factory.remove(char(event.Name));
        end
        
        function [] = renamedCallback(factory, ~, event)
           %disp(event);
           factory.update(char(event.OldName), char(event.Name));
        end
        
        function [] = remove(factory, name)
            % Remove an entry from the map
            factory.files.remove(name(2:end));
        end
        
        function [] = add(factory, name)
            % Add entry to the map
            factory.files(name(2:end)) = name;
        end

        function [] = update(factory, oldName, newName)
            factory.remove(oldName);
            factory.add(newName);
        end
    end
end

