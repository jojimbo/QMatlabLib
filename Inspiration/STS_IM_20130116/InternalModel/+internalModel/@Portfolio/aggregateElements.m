function [unInstr, unWeight] = aggregateElements(obj, node, calcNonMarketRisk)
%% aggregateElements
% |[unInstr, unWeight] = aggregateElements(obj, node, calcNonMarketRisk)|
% 
% Aggregate the elements which are in hierarchy deeper than
% 'node' in the portfolio object.
% 
% The calcNonMarketRisk flag determines whether market elements
% |false|) or non market elements (|true|) are aggregated
% (default |calcNonMarketRisk = false|)
% 
% Inputs:
% 
% * |node|              _char_
% * |calcNonMarketRisk| _logical_
% 
% Outputs:
% 
% * |unInstr|           _cell_
% * |unWeight|          _double_

% Check if node has a value
if isempty(node) || ~ischar(node)
    warning('ing:charRequested', 'Input #1 should be a char array');
    return
end

if nargin < 3
    % nonMarketRisk is assumed false
    calcNonMarketRisk = false;

elseif nargin == 3 && ~islogical(calcNonMarketRisk)
    error('ing:boolRequested', 'Input #2 should be a logical');
    
end

% Search for all offspring
childNodes = obj.findOffspring(node);
childNodes{end + 1} = node;

% ChildNodes now contains all offspring from input node.
% Find all positions which are in the offspring:
GIDs      = cellfun(@(x)(x.GID), obj.groups)';
positions = [];

for iChild = 1:numel(childNodes)
    idxChilds = strcmp(childNodes{iChild}, GIDs);
    hasPos    = isfield(obj.groups{idxChilds}, 'positions');

    if hasPos
        positions = [positions obj.groups{idxChilds}.positions]; %#ok<AGROW> Size not known a priori
    end
end

nonmarketString = 'Non-market';
idxNMPos        = false(length(positions), 1);

for iPos = 1:length(positions)
    % Find all the positions propeties which are non-market
    idxNMPos(iPos) = any(arrayfun(@(x)strcmpi(x.VALUE, nonmarketString), ...
                        positions(iPos).properties));
end

if ~calcNonMarketRisk
    % Calculate market risk
    idxPosUsed = ~idxNMPos;
else
    % Calculate non-market risk
    idxPosUsed = idxNMPos;
end

% Check whether any position should be used
if ~any(idxPosUsed)
    unInstr  = [];
    unWeight = [];
    return
end

% Prepare output
instruments = [positions(idxPosUsed).SEC_ID]';
weight      = cellfun(@(x)str2doubleq(x), [positions(idxPosUsed).POS_SZ])';

% Collect unique instruments
[unInstr, unInInput, unInOutput] = unique(instruments, 'stable');
unWeight = zeros(length(unInInput), 1);

if numel(unInInput) ~= numel(unInOutput)
    % Duplicates are found, weights need to be summed
    for iOutput = 1:numel(unInInput)
        unWeight(iOutput) = sum(weight(unInOutput == iOutput));
    end

else
    % No duplicates, so output
    unWeight = weight;
end

end
