function obj = calcShockedProperties(obj)
%% calcShockedProperties
% |obj = calcShockedProperties(obj)|
propTable = obj.getShockedPropTable();

for iInst = 1:numel(obj.instCol.Instruments)

    iClass   = class(obj.instCol.Instruments{iInst});
    idxTable = strcmp(iClass, propTable{:, 1});

    if ~any(idxTable)
        % No additional shocks needed for any properties of
        % this instrument
        continue
    end

    postfix   = obj.instCol.Instruments{iInst}.(propTable{:, 4});
    idxShocks = strcmp([propTable{idxTable, 3} postfix], obj.scenCol.Headers);

    % Evaluate base value
    base   = eval(propTable{idxTable, 5});

    % Evaluate shocks
    shocks = obj.scenCol.ScenarioMatrix(:, idxShocks);
    values = base .* exp(shocks);

    % Propagate shocked properties
    obj.instCol.Instruments{iInst}.(propTable{idxTable, 2}) = values;

end

end
