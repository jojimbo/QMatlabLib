function getLegalEntities(obj)
%% getLegalEntities
% 
% Find all Legal Entities and add them to the corresponding
% Business Enitites and their offspring

% Only groups having the highest level can contain properties
maxLvl       = max(obj.groupLevel);
maxLvlGroups = [obj.groups{obj.groupLevel == maxLvl}];
allGIDs      = cellfun(@(x)(x.GID{1}), obj.groups, 'UniformOutput', false);

for iGroup = 1:numel(maxLvlGroups)
    % Identify Legal Entities
    fldNms   = fieldnames(maxLvlGroups(iGroup).positions(1).properties);
    idxName  = strcmpi('name', fldNms);
    idxValue = strcmpi('value', fldNms);
    propNms  = [maxLvlGroups(iGroup).positions(1).properties.(fldNms{idxName})];
    idxLEcll = regexp(propNms, 'Legal Entity');
    idxLE    = ~cellfun(@isempty, idxLEcll);

    if ~any(idxLE)
        warning('ing:Portfolio:NoLE', 'No legal entities found in portfolio');
        return
    end

    leVal = maxLvlGroups(iGroup).positions(1).properties(idxLE).(fldNms{idxValue});
    anc   = obj.findAncestors(maxLvlGroups(iGroup).GID);

    % All (3-level up) ancestors (groups) and their offspring should have
    % the same Legal Entity, for these groups a field legalEntity is created
    % 
    % Three levels up --> baseEntity
    baseEntity  = anc{3};
    offspring   = obj.findOffspring(baseEntity);
    offInclBase = [{baseEntity} offspring{:}];

    % Search tree
    for jOffspring = 1:numel(offInclBase)

        idxGroup = strcmp(offInclBase{jOffspring}, allGIDs);

        if any(idxGroup)
            % Group found
            if ~isfield(obj.groups{idxGroup}, 'legalEntity')
                % Add legalEntity field to structure
                obj.groups{idxGroup}.legalEntity = leVal{1};

            elseif ~strcmp(obj.groups{idxGroup}.legalEntity, leVal)
                % field legalEntity is found, however, its value is not equal to leVal
                error('ing:ErrorINPortfoio', 'Error in Portfolio, inconsistent legal entities');
            end

        else
            % Group not found
            continue
        end
    end
end

end
