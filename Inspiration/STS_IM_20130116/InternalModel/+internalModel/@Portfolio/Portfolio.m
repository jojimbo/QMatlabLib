%% Portfolio class definition
% handle class

classdef Portfolio < handle

    %% Properties
    % 
    % * |groups|        _cell_
    % * |groupLevel|    _double_
    % 
    % *_Private properties:_*
    % 
    % * |groupCharAr|   _cell_

    properties 
        groups      = {}
        groupLevel  = []
    end


    properties (Access = private)
        groupCharAr = {}
    end


    %% Methods
    % 
    % * |obj       = Portfolio(flNm)|               _constructor_
    % * |offspring = findOffspring(obj, node)|
    % * |[unInstr, unWeight] = aggregateElements(obj, node, calcNonMarketRisk)|
    % 
    % *_Private_*
    % 
    % * |ancestors    = findAncestors(obj, nodes)|
    % * |exportChilds = findChildNodes(obj, nodes)|
    % * |group        = readGroup(obj)|

    methods

        function obj = Portfolio(flNm)
            %% Portfolio _constructor_
            % |obj = Portfolio(flNm)|
            % 
            % Construct a portfolio object from a portfolio xml file
            % 
            % Inputs:
            % 
            % * |flNm|      _char_

            if ~eq(exist(flNm, 'file'), 2)
                % file not found
                error('ing:FileNotFound', 'File not found');
            end

            % Fetch File Identifier and start reading
            fid  = fopen(flNm);                
            line = fgets(fid);

            while ~isempty(line) && ischar(line)
                % Checking tag of line
                isGroup = regexp(line, '<Group\s');

                % Read whole group 
                if isGroup
                    obj.groupCharAr{1} = line;

                    % Check whether Groups end on same line
                    endOnSameLine = regexp(line, '.*/>', 'once');

                    if isempty(endOnSameLine)
                        line       = fgets(fid);
                        isGroupEnd = regexp(line, '</Group\s');

                        while isempty(isGroupEnd)
                            obj.groupCharAr{end + 1, 1} = line;
                            line       = fgets(fid);
                            isGroupEnd = regexp(line, '</Group[\s>]');
                        end

                        % Add line includeing </Group>
                        obj.groupCharAr{end + 1, 1} = line;
                    end

                    % Retrieve group information
                    obj.groups{end + 1} = obj.readGroup();

                    % Clear obj.groupCharAr
                    obj.groupCharAr = {};
                end

                % Read next line, for conditional while statement
                line = fgets(fid);
            end

            % Close file
            fclose(fid);

            % Find levels for each group
            GIDs      = cellfun(@(x)(x.GID), obj.groups);
            ancestors = obj.findAncestors(GIDs);

            for iGroup = 1:length(obj.groups)
                ancPerGroup            = ancestors(:, iGroup);                
                nrOfAncestors          = sum(~cellfun(@isempty, ancPerGroup)) + 1;
                obj.groupLevel(iGroup) = nrOfAncestors;
            end

            % -------------------- PHASED OUT TEMPORARILY -----------------
            % Collect legal entities
            %obj.getLegalEntities();
            % -------------------- PHASED OUT TEMPORARILY -----------------

        end

    end % #Methods Public



    methods (Access = private)

        function group = findGroupByGID(obj, GID)
            %% findGroupByGID
            % Inputs:
            % 
            % * |GID|   _char_
            % 
            % Outputs:
            % 
            % * |group| _struct_
            allGIDs  = cellfun(@(x)(x.GID{1}), obj.groups, 'UniformOutput', false);
            idxGroup = strcmp(GID, allGIDs);

            if any(idxGroup)
                group = obj.groups{idxGroup};
            else
                group = [];
            end
        end


        function ancestors = findAncestors(obj, nodes)
            %% findAncestors _private_
            % |ancestors = findAncestors(obj, nodes)|
            % 
            % Find all ancestor-nodes above |nodes| in the portfolio hierarchy.
            % 
            % Input:
            % 
            % * nodes        _char_ or _cell_
            % 
            % Output:
            % 
            % * ancestors    _cell_
            if isempty(nodes)
                return
            end

            if ~iscell(nodes)
                nodes = {nodes};
            end

            GIDs      = cellfun(@(x)(x.GID), obj.groups);
            allChilds = cell(length(obj.groups), 1);

            for iGroup = 1:numel(obj.groups)
                if isfield(obj.groups{iGroup}, 'groupRefs')
                    allChilds{iGroup} = obj.groups{iGroup}.groupRefs;
                end
            end

            ancestors = cell(1, numel(nodes));

            for iNode = 1:numel(nodes)
                idxAncestor = true(size(GIDs));
                nodeToFind  = nodes{iNode};
                iAncestor   = 0;

                while any(idxAncestor)

                    iAncestor   = iAncestor + 1;
                    anomStrcmp  = @(x)strcmp(nodeToFind, x);
                    cllAncestor = cellfun(anomStrcmp, allChilds, 'UniformOutput', false);
                    anomAny     = @any;
                    idxAncestor = cellfun(anomAny, cllAncestor);

                    if any(idxAncestor)
                        nodeToFind = GIDs{idxAncestor};
                        ancestors{iAncestor, iNode} = nodeToFind;
                    end
                end                
            end
        end


        function exportChilds = findChildNodes(obj, nodes)
            %% findChildNodes _private_
            % |exportChilds = findChildNodes(obj, nodes)|
            % 
            % Find the child nodes of a cell-array of nodes
            % 
            % Input:
            % 
            % * nodes           _char_ or _cell_
            % 
            % Output:
            % 
            % * exportChilds    _cell_
            if isempty(nodes)
                return
            end

            if ~iscell(nodes)
                nodes = {nodes};
            end

            GIDs      = cellfun(@(x)(x.GID), obj.groups);            
            allChilds = cell(numel(obj.groups), 1);

            for iGroup = 1:numel(obj.groups)
                if isfield(obj.groups{iGroup}, 'groupRefs')
                    allChilds{iGroup} = obj.groups{iGroup}.groupRefs;
                end
            end

            for iNode = 1:numel(nodes)
                childs{iNode, :} = allChilds{strcmp(GIDs, nodes{iNode})}; %#ok<AGROW> size is not known a priori
                exportChilds     = [childs{:}];
            end
        end


        function group = readGroup(obj)
            %% readGroup _private_
            % |group = readGroup(obj)|
            % 
            % obj contains property groupCharAr for internal use. It
            % contains a cell array including all text from a single group.
            % 
            % Outputs:
            % 
            % * |group| _struct_

            % Check whether obj.groupCharAr is empty, if so return without
            % taking any further action
            if isempty(obj.groupCharAr)
                return
            end

            % Extract data
            GID         = regexp(obj.groupCharAr, '<Group\s.*GID="([0-9a-zA-Z_-\s]+)"', 'tokens');
            NAME        = regexp(obj.groupCharAr, '\sNAME="([0-9a-zA-Z_-\s]+)"', 'tokens');
            TYPE        = regexp(obj.groupCharAr, '\sTYPE="([0-9a-zA-Z_-\s]+)"', 'tokens');
            NTYPE       = regexp(obj.groupCharAr, '\sNTYPE="([0-9a-zA-Z_-\s]+)"', 'tokens');

            groupRefs   = regexp(obj.groupCharAr, '<GroupRef\sGID="([0-9a-zA-Z_-\s]+)"', 'tokens');
            SEC_ID      = regexp(obj.groupCharAr, '<Position.+SEC_ID="([0-9a-zA-Z_-\s./=&;%]+)"', 'tokens');
            POS_SZ      = regexp(obj.groupCharAr, '<Position.+POS_SZ="([0-9a-zA-Z_-\s./=&;%]+)"', 'tokens');

            hasPos      = regexp(obj.groupCharAr, '<Position');
            idxHasPos   = ~cellfun(@isempty, hasPos);
            hasProp     = regexp(obj.groupCharAr, '<Property');
            idxHasProp  = ~cellfun(@isempty, hasProp);
            propName    = cell(length(idxHasProp), 1);
            propValue   = cell(length(idxHasProp), 1);

            if any(idxHasProp)  
                for iHasProp = 1:length(idxHasProp)
                    if strfind(obj.groupCharAr{iHasProp}, 'Property')
                        propName{iHasProp}  = regexp(obj.groupCharAr(iHasProp), '([A-Z_]+)=', 'tokens');
                        propValue{iHasProp} = regexp(obj.groupCharAr(iHasProp), '="([A-Za-z0-9-_\.\(\)\s%]+)"', 'tokens');
                    end
                end
            end

            % Use data to define group, properties come later
            tableNm       = {'GID', 'NAME', 'TYPE', 'NTYPE', 'groupRefs'};
            tableVal      = [GID NAME TYPE NTYPE groupRefs];
            idxTableProps = ~cellfun(@isempty, tableVal);
 
            for iTableProp = 1:size(idxTableProps, 2)

                if any(idxTableProps(:, iTableProp))
                    propVals                    = [tableVal{idxTableProps(:, iTableProp), iTableProp}];
                    group.(tableNm{iTableProp}) = [propVals{:}];
                end
            end

            if any(idxHasPos)
                group.positions(sum(idxHasPos)) = struct('SEC_ID', [], 'POS_SZ', [], 'properties', []);

                % To be copied
                sec_ids    = [SEC_ID{idxHasPos}];
                pos_szs    = [POS_SZ{idxHasPos}];
                propNames  = [propName{idxHasProp}];
                propValues = [propValue{idxHasProp}];

                % Find properties belonging to this position
                idxProps        = find(idxHasProp);
                idxPos          = find(idxHasPos);
                idxPos(end + 1) = length(idxHasPos);

                for iPos = 1:sum(idxHasPos)
                    group.positions(iPos).SEC_ID = sec_ids{iPos};
                    group.positions(iPos).POS_SZ = pos_szs{iPos};

                    % Only use items belonging to this position
                    idxPropsToPos   = idxProps > idxPos(iPos) & idxProps < idxPos(iPos + 1);

                    for iProperty = 1:length(idxPropsToPos)
                        % Loop over Properties belonging to Position
                        if idxPropsToPos(iProperty)
                            for jProperty = 1:length(propNames{iProperty})

                                propNm  = propNames{iProperty}{jProperty}{1};
                                propVal = propValues{iProperty}{jProperty};

                                % Create temp struct
                                property(iProperty).(propNm) = propVal; %#ok<AGROW> cannot be allocated
                            end
                        end
                    end

                    % Add property to positions
                    group.positions(iPos).properties = property;
                end          
            end            
        end

    end % #Methods Private

end
