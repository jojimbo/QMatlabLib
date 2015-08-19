% A singleton class - effectively global static - which provides version
% info both to users but also to object factories to aid object
% construction dependent on the schema version
classdef VersionInfo < handle 
    
    properties
        % The version of the RSG - a build time setting. This is expected
        % to be set (and the resulting file committed to MKS) prior to 
        % creating a release checkpoint.
        % It is initialised at class instantiation time by loading a
        % persisted version string.
        RSGVersion = ''; % This initialisation is important so it's a char
    
        % The version of the control file schema being processed - a
        % runtime setting. The version information is set at the start of 
        % a process (e.g. RSGSimulate) but is not unset at the end; it is 
        % valid for the duration of the process that set the version
        RSGSchemaVersion = ''; % This initialisation is important so it's a char
    end % Read/Write properties
    
    properties(SetAccess=private, GetAccess=public)
        %%
        %% These properties should be treated as const. A get method has 
        %% been provided but the set implementation throws an exception
        %% 
        
        % Constants are poorly supported in Matlab. There's a real risk
        % that references to const values are misinterpreted and 
        % local structs are created which mask the const values. Acessor 
        % methods have been added to avoid this. It seems that it's not 
        % possible to have private const members.
        
        % The default SCHEMA version for initialisation purposes
        v0_0_0_0 = '0.0.0.0';
       
        % The version of the SCHEMA in use between RSGv2.3.0.0 and
        % RSGv3.0.0.0
        v2_3_0_0 = '2.3.0.0';
        
        % The version of the SCHEMA introduced in RSGv3.0.0.0
        v3_0_0_0 = '3.0.0.0';
    end % Read Only properties - Constants are not well supported   
         
    methods % NO ATTRIBUTES (See set.Property)   
        % Persist the RSG version to the filesystem. Intended to be invoked
        % as part of the release process - a build time setting
        % in:
        %   version, A version string of the form major.minor,defect.patch
        %   which matches this regex ^[0-9]\.[0-9]\.[0-9\.[0-9]$
        % out:
        %   An exception on error
        function set.RSGVersion(obj, version)
            obj.parseVersion(version);
                                  
            if ~isempty(obj.RSGVersion)
                % This method is called during initialisation. We don't
                % want to set the RSG version string unless it's an
                % explicit external action
                save(obj.RSGVersionFilePath, 'version');
            end
            
            % might be an idea to get the current version and ensure
            % the new version is logically higher - this might cause a
            % problem where we release a e.g. patch from an earlier branch 
            % though
            obj.RSGVersion = version;
        end        
        
        % Cache the version of the current control file
        % in:
        %   version, A version string of the form major.minor,defect.patch
        %   which matches this regex ^[0-9]\.[0-9]\.[0-9\.[0-9]$
        % out:
        %   An exception on error
        function set.RSGSchemaVersion(obj, version)
            obj.parseSchemaVersion(version);
            obj.RSGSchemaVersion = version;
        end    
        
        function ver = get.v0_0_0_0(obj)
            % Should be const but Matlab const support is poor
            ver = obj.v0_0_0_0;
        end
               
        function ver = get.v2_3_0_0(obj)
            % Should be const but Matlab const support is poor
            ver = obj.v2_3_0_0;
        end
                
        function ver = get.v3_0_0_0(obj)
            % Should be const but Matlab const support is poor
            ver = obj.v3_0_0_0;
        end
    end % Public methods
    
    methods(Static)
        % Singleton accessor method
        % out: 
        %   singleton, The single instance of this class
        function singleton = instance()
            persistent local;
            if isempty(local)
                local = prursg.Version.VersionInfo();
            end
            
            singleton = local;
        end
    end % Static methods
    
    methods(Access=private)
        % Prevent external construction
        function obj = VersionInfo()  
            if exist(obj.RSGVersionFilePath, 'file')
                % Load the RSGVersion string from file. The version will have
                % been set during the release process
                load(obj.RSGVersionFilePath, 'version');
                obj.RSGVersion = version;
            end
            
            if isempty(obj.RSGVersion)
                % In case the version file could not be found
                obj.RSGVersion = obj.v0_0_0_0;
            end
            
            % It's okay to initialise without a check as it cannot have
            % been set yet
            obj.RSGSchemaVersion = obj.v0_0_0_0;
        end
        
        function parseSchemaVersion(obj, version)
            obj.parseVersion(version);
            
            switch version
                % The schema version is one of a known set
                case {obj.v0_0_0_0,...
                      obj.v2_3_0_0,... 
                      obj.v3_0_0_0}
                    return;
                otherwise
                    fprintf(['Version is not one of the define values.'...
                    ' "%s" is not a valid schema version\n'], version);
                    throw(MException('VersionInfo:parseVersion:MalformedInput',...
                    ['Version is not one of the define values.'...
                    '"' version '" is not a valid schema version']));
            end
        end
    
        % Helper function to parse a version string.
        % in:
        %   version, A version string - see set.RSGVersion
        % out:
        %   major, minor, defect, patch, The four components of the version
        %   or an exception in the event of an error
        function [major, minor, defect, patch] = parseVersion(obj, version)
            if isempty(version)
                obj.errorMalformedVersion(version);
            end
            
            if isempty(regexpi(version, '^[0-9]\.[0-9]\.[0-9]\.[0-9]$'));
                obj.errorMalformedVersion(version);
            end
            
            major = version(1);
            minor = version(3);
            defect = version(5);
            patch = version(7);
        end
        
        % Throw a malformed input exception
        function errorMalformedVersion(obj, version)
            fprintf(['Expected version of the form major.minor.defect.patch'...
                ' but got "%s" instead\n'], version);
            throw(MException('VersionInfo:parseVersion:MalformedInput',...
                ['Expected version of the form major.minor.defect.patch'...
                'but got "' version '" instead']));            
        end
    end % Private methods
    
    properties (Constant)
        % The full path to the file in which to persist version information
        RSGVersionFilePath =...
            fullfile(prursg.Util.ConfigurationUtil.GetRootFolderPath(),...
            ... % Not using  RSGVersionFile here in case there's an 
            ... % initialization ordering issue
                '+prursg', '+Version', 'RSGVersion.mat');
    end
end
