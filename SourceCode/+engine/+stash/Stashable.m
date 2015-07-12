classdef Stashable < handle
    %STASHABLE derived instances of this class can be stashed in the object
    %repository.
    %
    %
    
    %% Methods
    methods
        function [uid] = stash(stashable)
            uid = engine.stash.ObjectStash.save(stashable);
        end
    end
end

