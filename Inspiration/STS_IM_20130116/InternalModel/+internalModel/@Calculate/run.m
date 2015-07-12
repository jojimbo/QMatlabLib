function [result] = run(obj, confidenceLevel, reportingCurrency, varargin)
%% run
% |[result, errorMsg] = run(obj, confidenceLevel, reportingCurrency, varargin)|
% 
% Perform individual Internal Market Run
result   = [];

% Both product families (PF) and product family members should be
% calculated. However, the level inbetween i.e. 'Liabilities' and
% 'Non Market Data' should not. Therefore, ignore all nodes which
% have a groupLevel in Portfolio of max(groupLevel) - 1
findGID      = @(x)(x.GID);
gidNms       = cellfun(findGID, obj.portfolio.groups);
maxLevel     = max(obj.portfolio.groupLevel);
idxGidNeeded = obj.portfolio.groupLevel ~= (maxLevel - 1);
GIDsToCalc   = gidNms(idxGidNeeded);

% Market EC
% Call Method Implementation: automatic all GID's
EC_AllGroups = obj.cube.calculateMarketEC(obj.portfolio, obj.scenCol, confidenceLevel,   ...
                    obj.forexCol, reportingCurrency, GIDsToCalc);

% Non-Market EC
% ECop is left 0 for the moment
ECop         = 0;

% Calculate aggregated EC
topNodeNm    = gidNms(obj.portfolio.groupLevel ==  1);
idxECTopNode = strcmp(topNodeNm, EC_AllGroups.ids);
ECaggr       = obj.instCol.calculateNonMarketECaggr(              ...
                    obj.corrMat, EC_AllGroups.val(idxECTopNode),  ...
                    ECop, confidenceLevel, obj.portfolio,         ...
                    EC_AllGroups.ids(idxECTopNode), obj.forexCol, ...
                    reportingCurrency);

% Calculate Non-Market EC per group
NonMarketEC  = zeros(numel(EC_AllGroups.val), 1);

for iNMEC = 1:numel(EC_AllGroups.val)
    NonMarketEC(iNMEC) = obj.instCol.calculateNonMarketECaggr(       ...
                            obj.corrMat,   0, ECop, confidenceLevel, ...
                            obj.portfolio, EC_AllGroups.ids(iNMEC),  ...
                            obj.forexCol,  reportingCurrency);
end

% Prepare Results Property
result.confLevel    = confidenceLevel;
result.currency     = reportingCurrency;
result.IDs          = EC_AllGroups.ids;
result.GIDsToCalc   = GIDsToCalc;
result.MarketEC     = EC_AllGroups.val;
result.NonMarketEC  = NonMarketEC;
result.ECaggr       = ECaggr;
result.EC_AllGroups = EC_AllGroups;
result.ECop         = ECop;

end
