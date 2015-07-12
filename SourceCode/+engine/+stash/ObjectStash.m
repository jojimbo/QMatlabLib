classdef ObjectStash
    %OBJECTSTASH store something safely in a secret place.
    %   Stash objects for later retrieval 
       
    methods (Static)
        function [uid] = stash(stashable)            
            % stash store an object in a safe place for later retrieval.
            % Object storage defaults to file system but can be configured
            % to use alternative mediums such as database. Currently ony
            % file system storage is supported.
            %   uid = stash(stashable)
            %
            %   The returned unique identifier can be used to retrieve the
            %   stashed object
            %
            %   See also search.
            path = engine.stash.ObjectStash.uniqueName(stashable);
            mkdir(path);
            fname = fullfile(path, 'stash.mat');
            save(fname, 'stashable', '-v7');
            uid = engine.stash.ObjectStash.obfuscate(path);
        end
        
        function [obj] = search(uid)
            % search search for a stached object.
            % Currently only search by uid is supported.
            % obj = search(uid)
            % 
            % The unique identifier must have been previously returned by
            % stash
            %
            % See also stash.
            path = engine.stash.ObjectStash.elucidate(uid);
            tmp = load(fullfile(path, 'stash.mat'));
            obj = tmp.stashable; 
        end
    end
    
    methods (Static, Access = private)
        function [name] = uniqueName(stashable)
            % uniqueName generates a unique name for the supplied object
            % based on object's package and the current date and time
            whence = class(stashable);
            ts = datestr(now, 30); % 30 (ISO 8601)  'yyyymmddTHHMMSS'        20000301T154517 
            
            confman = engine.util.config.ConfMan.instance();                    
            name = fullfile(confman.stash.location, whence, ts);
        end
        
        function [out] = obfuscate(in)
            % obfuscate the supplied string so that users do not depend on
            % the current uid implementation. It is currently a path but
            % may chage depending on the backing store
            out = unicode2native(in);
        end
        
        function [out] = elucidate(in)
            % Converts an obfuscated string back to its original state
            out = native2unicode(in);
        end
        
        %% Alternative save mechamism - curently unused but apparently faster than the builtin save 
        % see http://undocumentedmatlab.com/blog/serializing-deserializing-matlab-data
        function [out] = toStream(in)
            out = getByteStreamFromArray(in);
        end
        
        %% Alternative load mechamism - curently unused but apparently faster than the builtin load 
        % see http://undocumentedmatlab.com/blog/serializing-deserializing-matlab-data
        function [out] = fromStream(in)
            out = getArrayFromByteStream(in);
        end
    end
end

