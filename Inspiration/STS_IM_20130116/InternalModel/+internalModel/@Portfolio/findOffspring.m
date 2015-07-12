function offspring = findOffspring(obj, node)
%% findOffspring
% |offspring  = findOffspring(obj, node)|
% 
% Find all nodes in hierarchy below |node| (all offspring) in
% the portfolio object
% 
% Inputs:
% 
% * |node|          _char_ or _cell_
% 
% Outputs:
% 
% * |offspring|     _cell_
newChilds = obj.findChildNodes(node);
offspring = newChilds(:);

while ~isempty(newChilds)
    newChilds = obj.findChildNodes(newChilds);

    for iNewChilds = 1:length(newChilds(:))
        offspring{end + 1} = newChilds{iNewChilds}; %#ok<AGROW> Size not known a priori
    end
end

end
